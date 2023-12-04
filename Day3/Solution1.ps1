$data = Get-Content .\Day3\input.txt

function MakeTuple([int] $x, [int] $y)
{
    return [System.ValueTuple[int,int]]::new($x, $y);
}

$symbolSet = [System.Collections.Generic.HashSet[System.ValueTuple[int,int]]]::new()

[int]$lineNumber = 0
foreach ($line in $data) {
    $charArray = $line.ToCharArray()
    [int]$j = 0
    foreach ($c in $charArray)
    {
        if (-not ($c -match '[0-9.]'))
        {
            $tuple = MakeTuple -x $lineNumber -y $j
            [void]$symbolSet.Add($tuple)
        }

        $j += 1
    }
    
    $lineNumber += 1
}

$sum = 0
$lineNumber = 0
foreach ($line in $data) {
    $numMatch = [regex]::Matches($line, '\d+')
    foreach ($match in $numMatch)
    {
        [int]$idx = $match.Index
        
        $surroundingArea = @()
        $surroundingArea += MakeTuple -x $lineNumber -y ($idx - 1)
        $surroundingArea += MakeTuple -x $lineNumber -y ($idx + $match.Length)
        
        for ([int]$i = $idx - 1; $i -le $idx + $match.Length; $i += 1)
        {
            $surroundingArea += MakeTuple -x ($lineNumber - 1) -y $i
            $surroundingArea += MakeTuple -x ($lineNumber + 1) -y $i
        }

        foreach ($point in $surroundingArea)
        {
            if ($symbolSet.Contains($point))
            {
                Write-Host $match
                $sum += [int]$match.Value
                break
            }
        }
    }

    $lineNumber += 1
}

Write-Host $sum
Set-Clipboard $sum