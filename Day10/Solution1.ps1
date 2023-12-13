. .\MakeTuples.ps1

$data = Get-Content .\Day10\input.txt

$graph = [System.Collections.Generic.Dictionary[System.ValueTuple[int,int], object]]::new()

$row = 0
$start = MakeIntTuple 0 0
foreach ($line in $data)
{
    $array = $line.ToCharArray()
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
$step = 1
$a = $graph[$start][0]
$b = $graph[$start][1]
[void]$visited.Add($start)

while ($a -ne $b)
{
    [void]$visited.Add($a)
    [void]$visited.Add($b)

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

Write-Host $step
Set-Clipboard $step