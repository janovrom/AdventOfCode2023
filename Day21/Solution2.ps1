using namespace System
using namespace System.Collections.Generic

$data = Get-Content .\Day21\input.txt

$walls = @()
$lineIdx = 0
foreach ($line in $data)
{
    $lineWalls = @($false) * $line.Length
    $idx = 0
    foreach ($c in $line.ToCharArray())
    {
        if ($c -eq '.')
        {
        }
        elseif ($c -eq '#')
        {
            $lineWalls[$idx] = $true
        }
        else
        {
            # That's 'S'
            $start = [Tuple]::Create($lineIdx, $idx)
        }
        $idx += 1
    }
    $walls += ,$lineWalls

    $lineIdx += 1
}

function IsInGrid($row, $col, $data)
{
    if ($row -lt 0 -or $row -ge $data.Length)
    {
        return $false
    }

    if ($col -lt 0 -or $col -ge $data[0].Length)
    {
        return $false
    }

    return $true
}

function IsValid($row, $col, $data, $walls)
{
    return -not $walls[$row][$col]
}

function Mod($x, $m)
{
    return ($x % $m + $m) % $m
}

function Hash($x, $m)
{
    if ($x -lt 0)
    {
        return [int](($x - $m) / $m)
    }

    return [int]($x / $m)
}

$maxSteps = 26501365
# x, y, steps, tx, ty
$positions = [Queue[Tuple[int,int,int]]]::new()
# [void]$positions.Enqueue([Tuple[int,int,int]]::new(0, 0, 0, 0, 0))
[void]$positions.Enqueue([Tuple[int,int,int]]::new($start.Item1, $start.Item2, 0))
$inGroup = [Dictionary[Tuple[int,int],int]]::new()
$notInGroup = [HashSet[Tuple[int,int]]]::new()
$globalGroup = $maxSteps % 2

while ($positions.Count -gt 0)
{
    $first = $positions.Dequeue()

    $x = $first.Item1
    $y = $first.Item2
    $steps = $first.Item3

    $p = [Tuple[int,int]]::new($x, $y)
    $group = $steps % 2

    if ($group -eq $globalGroup)
    {
        if ($inGroup.ContainsKey($p))
        {
            continue
        }
        else
        {
            [void]$inGroup.Add($p, $steps)
        }
    }
    else
    {
        if ($notInGroup.Contains($p))
        {
            continue
        }
        else 
        {
            [void]$notInGroup.Add($p)
        }
    }

    if ($steps -eq $maxSteps)
    {
        continue
    }

    $xm = Mod $x $data.Length
    $ym = Mod $y $data[0].Length

    $xp1 = Mod ($x + 1) $data.Length
    $xm1 = Mod ($x - 1) $data.Length

    $yp1 = Mod ($y + 1) $data[0].Length
    $ym1 = Mod ($y - 1) $data[0].Length

    if (IsValid $xp1 $ym $data $walls)
    {
        $tx = Hash ($x + 1) $data.Length
        $ty = Hash ($y + 0) $data[0].Length
        [void]$positions.Enqueue([Tuple[int,int,int]]::new($x + 1, $y, $steps + 1))
    }

    if (IsValid $xm1 $ym $data $walls)
    {
        $tx = Hash ($x - 1) $data.Length
        $ty = Hash ($y + 0) $data[0].Length
        [void]$positions.Enqueue([Tuple[int,int,int]]::new($x - 1, $y, $steps + 1))
    }

    if (IsValid $xm $yp1 $data $walls)
    {
        $tx = Hash ($x + 0) $data.Length
        $ty = Hash ($y + 1) $data[0].Length
        [void]$positions.Enqueue([Tuple[int,int,int]]::new($x, $y + 1, $steps + 1))
    }

    if (IsValid $xm $ym1 $data $walls)
    {
        $tx = Hash ($x + 0) $data.Length
        $ty = Hash ($y - 1) $data[0].Length
        [void]$positions.Enqueue([Tuple[int,int,int]]::new($x, $y - 1, $steps + 1))
    }
}

# for ($i = 0; $i -lt $data.Length; $i += 1)
# {
#     $s = ""
#     for ($j = 0; $j -lt $data[0].Length; $j += 1)
#     {
#         $t = [Tuple[int,int]]::new($i, $j)
#         if ($uniquePositions.Contains($t))
#         {
#             $s += "0"
#         }
#         else 
#         {
#             $s += $data[$i][$j]
#         }
#     }
#     Write-Host $s
# }

$count = $inGroup.Count

Write-Host $count
Set-Clipboard $count