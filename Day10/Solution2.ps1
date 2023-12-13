. .\MakeTuples.ps1

$data = Get-Content .\Day10\input.txt
$emptyMap = @()
$visitedMap = @()

$graph = [System.Collections.Generic.Dictionary[System.ValueTuple[int,int], object]]::new()

$row = 0
$start = MakeIntTuple 0 0
foreach ($line in $data)
{
    $array = $line.ToCharArray()
    $emptyMap += ,(@(0) * $array.Length)
    $visitedMap += ,(@(0) * $array.Length)

    for ($col = 0; $col -lt $array.Length; $col+=1)
    {
        $c = $array[$col]
        $position = MakeIntTuple $row $col
        [void]$graph.Add($position, @())
        if ($c -eq 'S')
        {
            $start = $position
        }
        
        switch ($c)
        {
            'J' { $graph[$position] += (MakeIntTuple ($row - 1) $col); $graph[$position] += (MakeIntTuple ($row) ($col - 1)); }
            '|' { $graph[$position] += (MakeIntTuple ($row - 1) $col); $graph[$position] += (MakeIntTuple ($row + 1) ($col)); }
            '-' { $graph[$position] += (MakeIntTuple $row ($col - 1)); $graph[$position] += (MakeIntTuple ($row) ($col + 1)); }
            'L' { $graph[$position] += (MakeIntTuple ($row - 1) $col); $graph[$position] += (MakeIntTuple ($row) ($col + 1)); }
            '7' { $graph[$position] += (MakeIntTuple ($row + 1) $col); $graph[$position] += (MakeIntTuple ($row) ($col - 1)); }
            'F' { $graph[$position] += (MakeIntTuple ($row + 1) $col); $graph[$position] += (MakeIntTuple ($row) ($col + 1)); }
        }
    }

    $row += 1
}

for ($i = -1; $i -le 1; $i+=1)
{
    for ($j = -1; $j -le 1; $j+=1)
    {
        if ($i -eq 0 -and $j -eq 0)
        {
            continue
        }

        $pos = MakeIntTuple ($start.Item1 + $i) ($start.Item2 + $j)
        if ($graph[$pos].Contains($start))
        {
            $graph[$start] += $pos
        }
    }
}

$visited = [System.Collections.Generic.HashSet[System.ValueTuple[int,int]]]::new()

# This assignment is manual based on the map. For test inputs the value is F
$emptyMap[$start.Item1][$start.Item2] = "L"
$a = $graph[$start][0]
$b = $graph[$start][1]

[void]$visited.Add($start)

while ($a -ne $b)
{
    [void]$visited.Add($a)
    [void]$visited.Add($b)

    $emptyMap[$a.Item1][$a.Item2] = $data[$a.Item1][$a.Item2]
    $emptyMap[$b.Item1][$b.Item2] = $data[$b.Item1][$b.Item2]

    if ($visited.Contains($graph[$a][0]))
    {
        $a = $graph[$a][1]
    }
    else
    {
        $a = $graph[$a][0]
    }
    
    if ($visited.Contains($graph[$b][0]))
    {
        $b = $graph[$b][1]
    }
    else
    {
        $b = $graph[$b][0]
    }

    $step += 1
}

$emptyMap[$a.Item1][$a.Item2] = $data[$a.Item1][$a.Item2]

$floodFill = @()
for ($i=0; $i -lt $data.Count + 1; $i+=1)
{
    $floodFill += ,(@(0) * ($data[0].Length + 1))
}

$max = $floodFill[0].Length
$verticalWalls = [System.Collections.Generic.HashSet[System.ValueTuple[string,string]]]::new()
$t0 = (MakeStringTuple 'F' '|')
$t1 = (MakeStringTuple 'F' 'L')
$t2 = (MakeStringTuple 'F' 'J')
$t3 = (MakeStringTuple '|' '|')
$t4 = (MakeStringTuple '|' 'J')
$t5 = (MakeStringTuple '|' 'L')
$t6 = (MakeStringTuple '7' '|')
$t7 = (MakeStringTuple '7' 'L')
$t8 = (MakeStringTuple '7' 'J')
[void]$verticalWalls.Add($t0)
[void]$verticalWalls.Add($t1)
[void]$verticalWalls.Add($t2)
[void]$verticalWalls.Add($t3)
[void]$verticalWalls.Add($t4)
[void]$verticalWalls.Add($t5)
[void]$verticalWalls.Add($t6)
[void]$verticalWalls.Add($t7)
[void]$verticalWalls.Add($t8)

# Ignore first and last, those will be outside
for ($i=1; $i -lt $floodFill.Count - 1; $i+=1)
{
    $isOut = $true
    for ($j = 0; $j -lt ($max - 1); $j+=1)
    {
        $up = $emptyMap[$i - 1][$j]
        $down = $emptyMap[$i][$j]
        $wall = MakeStringTuple $up $down

        if ($isOut)
        {
            $floodFill[$i][$j] = "+"
        }

        if ($verticalWalls.Contains($wall))
        {
            $isOut = -not $isOut
        }
    }
}

for ($i=0; $i -lt $data.Count; $i+=1)
{
    $isOut = $true
    for ($j = 0; $j -lt $data[0].Length; $j+=1)
    {
        if ($floodFill[$i][$j] -eq 0 -and $floodFill[$i+1][$j] -eq 0 -and $floodFill[$i][$j+1] -eq 0 -and $floodFill[$i+1][$j+1] -eq 0)
        {
            $emptyMap[$i][$j] = "I"
        }
    }
}

$outString = ""
$emptyMap.forEach({ $outString += $_; $outString += "`r`n" })
$outString += "`r`n"
$floodFill.forEach({ $outString += $_; $outString += "`r`n" })
$outString | Out-File -FilePath .\Day10\MapWithLoop.txt

$emptyCount = $emptyMap.forEach({ $_.forEach({ if ($_ -eq "I") { 1 } }) }).Count

Write-Host $emptyCount
Set-Clipboard $emptyCount