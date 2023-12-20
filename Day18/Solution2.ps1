using namespace System
using namespace System.Collections.Generic

$data = Get-Content .\Day18\input.txt

$minx = 0
$miny = 0
$maxx = 0
$maxy = 0

$x = 0
$y = 0

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

function IsOpening($dx)
{
    return $dx -ge 0
}

function MapToChar($s)
{
    switch ($s)
    {
        "0" { return "R" }
        "1" { return "D" }
        "2" { return "L" }
        "3" { return "U" }
    }
}

$lines = @()
$next = [Dictionary[Tuple[long,long], [Tuple[long,long]]]]::new()
$prev = [Dictionary[Tuple[long,long], [Tuple[long,long]]]]::new()
foreach ($line in $data)
{
    $dir, $dist, $color = $line.Split(" ")
    $color = $color.Replace("#","").Replace("(","").Replace(")","")
    $dist = [Convert]::ToInt64($color.Substring(0, $color.Length - 1), 16)
    $dx, $dy = (MapDirection (MapToChar $color[-1]))
    # $dx, $dy = MapDirection $dir

    $sx = $x
    $sy = $y
    $x += $dx * $dist
    $y += $dy * $dist
    
    $minx = [Math]::Min($minx, $x)
    $miny = [Math]::Min($miny, $y)
    $maxx = [Math]::Max($maxx, $x)
    $maxy = [Math]::Max($maxy, $y)

    if ($dx -ne 0)
    {
        $lines += [Tuple[long,long,long]]::new($sx, $x, $y)
    }

    $e0 = [Tuple[long,long]]::new($sx, $sy)
    $e1 = [Tuple[long,long]]::new($x, $y)
    [void]$next.Add($e0, $e1)
    [void]$prev.Add($e1, $e0)
}

$lines = $lines | Sort-Object -Property Item3

$lineMapOpen = [Dictionary[long,List[Tuple[long,long,bool]]]]::new()
$lineMapEnd = [Dictionary[long,List[Tuple[long,long,bool]]]]::new()
foreach ($line in $lines)
{
    if (-not $lineMapOpen.ContainsKey($line.Item3))
    {
        [void]$lineMapOpen.Add($line.Item3, [List[Tuple[long,long,bool]]]::new())
        [void]$lineMapEnd.Add($line.Item3, [List[Tuple[long,long,bool]]]::new())
    }

    $start = [Math]::Min($line.Item1, $line.Item2)
    $end = [Math]::Max($line.Item1, $line.Item2)
    $t = [Tuple[long,long,bool]]::new($start, $end, ($start -eq $line.Item1))
    if ($t.Item3)
    {
        [void]$lineMapOpen[$line.Item3].Add($t)
    }
    else
    {
        [void]$lineMapEnd[$line.Item3].Add($t)
    }
}

Write-Host "Searching in region min=" $minx,$miny "and max=" $maxx,$maxy

$sum = 0l
$inside = @($false) * ($maxx - $minx + 1)
$lastIterationResult = 0
for ($y = $miny; $y -le $maxy; $y += 1)
{
    if ($y % 100000 -eq 0)
    {
        Write-Host $y
    }

    if ($lineMapOpen.ContainsKey($y))
    {
        $added = 0
        foreach ($range in $lineMapOpen[$y])
        {
            for ($x = $range.Item1; $x -le $range.Item2; $x += 1)
            {
                # inside is always true
                if (-not $inside[$x])
                {
                    $added += 1
                }

                $inside[$x] = $true
            }
        }

        $sum += $lastIterationResult + $added

        $removed = 0
        # $ranges = $lineMap[$y] | Sort-Object -Property 
        foreach ($range in $lineMapEnd[$y])
        {
            # Left to right
            for ($x = $range.Item1 + 1; $x -lt $range.Item2; $x += 1)
            {
                # inside is always true
                if ($inside[$x])
                {
                    $removed += 1
                }
                $inside[$x] = $false
            }

            $s = $prev[[Tuple[long,long]]::new($range.Item2, $y)]
            $e = $next[[Tuple[long,long]]::new($range.Item1, $y)]

            $sbool = $s.Item2 -gt $y
            $ebool = $e.Item2 -gt $y

            if ($inside[$range.Item2] -ne $sbool)
            {
                if ($sbool)
                {
                    $added += 1
                }
                else
                {
                    $removed += 1
                }
            }

            if ($inside[$range.Item1] -ne $ebool)
            {
                if ($ebool)
                {
                    $added += 1
                }
                else
                {
                    $removed += 1
                }
            }

            $inside[$range.Item2] = $sbool
            $inside[$range.Item1] = $ebool
        }

        $lastIterationResult += $added - $removed
    }
    else {
        $sum += $lastIterationResult
    }
}

Write-Host $sum
Set-Clipboard $sum