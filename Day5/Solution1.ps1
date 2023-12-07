$data = Get-Content .\Day5\input.txt

function Translate
{ 
    param([long] $x, [long[]] $srcA, [long[]] $dstA, [long[]] $lenA)

    for ($i = 0; $i -lt $srcA.Length; $i+=1)
    {
        $src = $srcA[$i]
        $dst = $dstA[$i]
        $len = $lenA[$i]

        if ($x -ge $src -and $x -lt $src + $len)
        {
            return $x - $src + $dst;
        }
    }

    return $x;
}

function Create-LookUp([int]$start, $data)
{
    $object = [PSCustomObject]@{
        Src = @()
        Dst = @()
        Len = @()
    }
    
    $object.PSObject.Methods.Add(
        [psscriptmethod]::new(
            'LookUp', {
                param([long] $x)
    
                Translate $x $this.Src $this.Dst $this.Len
            }
        )
    )

    $i = $start + 1 # Skip the header
    while ("" -ne $data[$i] -and $i -lt $data.Length)
    {
        $split = $data[$i].Split(" ")
        $object.Dst += [long]$split[0]
        $object.Src += [long]$split[1]
        $object.Len += [long]$split[2]

        $i += 1
    }

    return $object, ($i + 1); # Current is empty line, skip it
}

$i = 0
$seeds = @()
[regex]::Matches($data[$i], '\d+').forEach({ $seeds += [long]$_.Value })
$i = 2

$seedToSoil, $i = Create-LookUp -start $i -data $data
$soilToFertilizer, $i = Create-LookUp -start $i -data $data
$fertilizerToWater, $i = Create-LookUp -start $i -data $data
$waterToLight, $i = Create-LookUp -start $i -data $data
$lightToTemperature, $i = Create-LookUp -start $i -data $data
$temperatureToHumidity, $i = Create-LookUp -start $i -data $data
$humidityToLocation, $i = Create-LookUp -start $i -data $data

$lookups = @($seedToSoil, $soilToFertilizer, $fertilizerToWater, $waterToLight, $lightToTemperature, $temperatureToHumidity, $humidityToLocation)

$min = [long]::MaxValue
$seeds.forEach({
    $seed = [long]$_
    foreach ($lookup in $lookups)
    {
        $seed = $lookup.LookUp($seed)
    }

    $min = [Math]::Min($min, $seed)
    Write-Host "Seed" $_ "maps to" $seed
})

Write-Host $min
Set-Clipboard $min