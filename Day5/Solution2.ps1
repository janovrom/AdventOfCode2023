$data = Get-Content .\Day5\input.txt

function MakeTuple([long]$x, [long]$y)
{
    return [System.Tuple[long,long]]::new($x, $y)
}

function ProcessRange($startx, $endx, $starty, $endy, $dst)
{
    $outputRanges = @()
    $toProcess = @()
    
    if ($starty -le $endx -and $starty -ge $startx)
    {
        # Start is in the middle of our range
        $len = [Math]::Min($endx - $starty, $endy - $starty)

        if ($startx -ne $starty)
        {
            $toProcess += MakeTuple $startx ($starty - 1)
        }

        $outputRanges += MakeTuple $dst ($dst + $len + 1)

        if ($starty + $len -ne $endx)
        {
            $toProcess += MakeTuple ($starty + $len + 2) $endx
        }
    }
    elseif ($endy -ge $startx -and $endy -le $endx)
    {
        # end is in the middle
        $len = [Math]::Min($endy - $startx, $endy - $starty)

        if ($startx + $len -ne $endy)
        {
            $toProcess += MakeTuple $startx ($starty - 1)
        }

        $dstStart = $dst + $startx - $starty
        $outputRanges += MakeTuple $dstStart ($dstStart + $len)

        if ($endx -ne $endy)
        {
            $toProcess += MakeTuple ($endy + 1) $endx
        }
    }
    else 
    {
        # No intersection or fully contained
        if ($startx -gt $starty -and $endx -lt $endy)
        {
            $dstStart = $dst + $startx - $starty
            $outputRanges += MakeTuple ($dstStart) ($dstStart + $endx - $startx)
        }
        # else
        # {
        #     $toProcess += MakeTuple $startx $starty
        # }
    }

    return $outputRanges, $toProcess
}

function Update-Ranges
{ 
    param([System.Tuple[long,long][]] $ranges, [long[]] $srcA, [long[]] $dstA, [long[]] $lenA, $isLast)

    $processedRanges = [System.Collections.Generic.HashSet[System.Tuple[long,long]]]::new()

    foreach ($range in $ranges)
    {
        $queue = [System.Collections.Generic.Queue[System.Tuple[long,long]]]::new()
        [void]$queue.Enqueue($range)
        while ($queue.Count -ne 0)
        {
            $rangeToProcess = $queue.Dequeue()
            $rangeProcessed = $false
            for ($i = 0; $i -lt $srcA.Length; $i+=1)
            {
                $src = $srcA[$i]
                $dst = $dstA[$i]
                $len = $lenA[$i]
    
                $start = $src
                $end = $src + $len - 1
        
                $processed, $toProcess = (ProcessRange $rangeToProcess.Item1 $rangeToProcess.Item2 $start $end $dst)
                $processed.forEach({ [void]$processedRanges.Add($_) })
                $toProcess.forEach({ [void]$queue.Enqueue($_) })

                if ($processed.Length -ne 0)
                {
                    $rangeProcessed = $true
                }
            }
    
            # Nobody processed this. Add it as is.
            if (-not $rangeProcessed)
            {
                [void]$processedRanges.Add($rangeToProcess)
            }
        }
    }

    return @($processedRanges);
}

function Create-LookUp([int]$start, $data)
{
    $object = [PSCustomObject]@{
        Src = @()
        Dst = @()
        Len = @()
        IsLast = $false
    }
    
    $object.PSObject.Methods.Add(
        [psscriptmethod]::new(
            'LookUp', {
                param([System.Tuple[long,long][]] $x)
    
                Update-Ranges $x $this.Src $this.Dst $this.Len $this.IsLast
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

$upperBound = 462648396
$seedBound = 907727477

$i = 2

$seedToSoil, $i = Create-LookUp -start $i -data $data
$soilToFertilizer, $i = Create-LookUp -start $i -data $data
$fertilizerToWater, $i = Create-LookUp -start $i -data $data
$waterToLight, $i = Create-LookUp -start $i -data $data
$lightToTemperature, $i = Create-LookUp -start $i -data $data
$temperatureToHumidity, $i = Create-LookUp -start $i -data $data
$humidityToLocation, $i = Create-LookUp -start $i -data $data
$humidityToLocation.IsLast = $true

$lookups = @($seedToSoil, $soilToFertilizer, $fertilizerToWater, $waterToLight, $lightToTemperature, $temperatureToHumidity, $humidityToLocation)

$min = [long]::MaxValue
$split = $data[0].Replace("seeds: ", "").Split(" ")
for ($j = 0; $j -lt $split.Length; $j+=2)
{
    $start = [long]$split[$j]
    $length = [long]$split[$j + 1]

    Write-Host "Processing seed" $start ($start + $length)
    
    $ranges = @(MakeTuple $start ($start + $length - 1))
    foreach ($lookup in $lookups)
    {
        # ConvertTo-Json $lookup | Write-Host
        $ranges = $lookup.LookUp($ranges)
    }

    $ranges.forEach({ $min = [Math]::Min($min, $_.Item1) })
}

Write-Host $min
Set-Clipboard $min