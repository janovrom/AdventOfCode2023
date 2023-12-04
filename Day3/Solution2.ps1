$data = Get-Content .\Day3\input.txt

function MakeTuple([int] $x, [int] $y)
{
    return [System.ValueTuple[int,int]]::new($x, $y);
}

$numberDictionary = [System.Collections.Generic.Dictionary[System.ValueTuple[int,int], int]]::new()

$sum = 0
$lineNumber = 0
foreach ($line in $data) {
    $numMatch = [regex]::Matches($line, '\d+')
    foreach ($match in $numMatch)
    {
        $idx = $match.Index
        $number = [int]$match.Value

        for ($i = $idx; $i -lt $idx + $match.Length; $i += 1)
        {
            $key = MakeTuple -x $lineNumber -y $i
            $numberDictionary.Add($key, $number)
        }
    }

    $lineNumber += 1
}

$lineNumber = 0
$sum = 0
foreach ($line in $data) {
    $charArray = $line.ToCharArray()
    $column = 0
    foreach ($c in $charArray)
    {
        if ('*' -eq $c)
        {
            $adjacentNumbers = [System.Collections.Generic.HashSet[int]]::new()
            for ($i = $lineNumber - 1; $i -le $lineNumber + 1; $i += 1)
            {
                for ($j = $column - 1; $j -le $column + 1; $j += 1)
                {
                    $tuple = MakeTuple -x $i -y $j
                    if ($numberDictionary.ContainsKey($tuple))
                    {
                        [void]$adjacentNumbers.Add($numberDictionary[$tuple])
                    }
                }
            }

            if ($adjacentNumbers.Count -eq 2)
            {
                $mul = 1
                $adjacentNumbers.ForEach({ $mul = $_ * $mul })
                $sum += $mul
            }
        }

        $column += 1
    }
    
    $lineNumber += 1
}

Write-Host $sum
Set-Clipboard $sum