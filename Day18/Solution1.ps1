using namespace System
using namespace System.Collections.Generic

$data = Get-Content .\Day18\input.txt

$minx = 0
$miny = 0
$maxx = 0
$maxy = 0

$x = 0
$y = 0

$occupancySet = [HashSet[Tuple[int,int]]]::new()
[void]$occupancySet.Add([Tuple]::Create($x, $y))

function MapDirection($char)
{
    switch ($char)
    {
        "R" { return 1, 0 }
        "L" { return -1, 0 }
        "U" { return 0, -1 }
        "D" { return 0, 1 }
    }
}

foreach ($line in $data)
{
    $dir, $dist, $color = $line.Split(" ")
    $dx, $dy = MapDirection $dir

    for ($i = 0; $i -lt $dist; $i += 1)
    {
        $x += $dx
        $y += $dy
    
        [void]$occupancySet.Add([Tuple]::Create($x, $y))
    }
    
    $minx = [Math]::Min($minx, $x)
    $miny = [Math]::Min($miny, $y)
    $maxx = [Math]::Max($maxx, $x)
    $maxy = [Math]::Max($maxy, $y)
}

function IsValid($p)
{
    if ($p.Item1 -lt $minx - 1 -or $p.Item1 -gt $maxx + 1)
    {
        return $false
    }

    if ($p.Item2 -lt $miny - 1 -or $p.Item2 -gt $maxy + 1)
    {
        return $false
    }

    return $true
}

# Flood it with LAVA!
$lava = [HashSet[Tuple[int,int]]]::new()
$queue = [Queue[Tuple[int,int]]]::new()
[void]$queue.Enqueue([Tuple]::Create($minx - 1, $miny - 1))
while ($queue.Count -gt 0)
{
    $p = $queue.Dequeue()

    if ($lava.Contains($p))
    {
        continue
    }

    if ($occupancySet.Contains($p))
    {
        continue
    }

    if (-not (IsValid $p))
    {
        continue
    }

    [void]$lava.Add($p)

    $pl = [Tuple]::Create($p.Item1 - 1, $p.Item2)
    $pr = [Tuple]::Create($p.Item1 + 1, $p.Item2)
    $pu = [Tuple]::Create($p.Item1, $p.Item2 - 1)
    $pd = [Tuple]::Create($p.Item1, $p.Item2 + 1)

    [void]$queue.Enqueue($pl)
    [void]$queue.Enqueue($pr)
    [void]$queue.Enqueue($pu)
    [void]$queue.Enqueue($pd)
}

$area = ($maxx - $minx + 1 + 2) * ($maxy - $miny + 3)
$res = $area - $lava.Count
Write-Host $res
Set-Clipboard $res