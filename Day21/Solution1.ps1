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
    if (IsInGrid $row $col $data)
    {
        return -not $walls[$row][$col]
    }

    return $false
}

$maxSteps = 64
# x, y, steps
$positions = [Queue[Tuple[int,int,int]]]::new()
[void]$positions.Enqueue([Tuple[int,int,int]]::new($start.Item1, $start.Item2, 0))
$inGroup = [Dictionary[Tuple[int,int],int]]::new()
$globalGroup = $maxSteps % 2

while ($positions.Count -gt 0)
{
    $first = $positions.Dequeue()

    $x = $first.Item1
    $y = $first.Item2
    $steps = $first.Item3

    $t = [Tuple[int,int]]::new($x, $y)
    $group = $steps % 2

    if ($group -eq $globalGroup)
    {
        if ($inGroup.ContainsKey($t))
        {
            continue
        }
        else
        {
            [void]$inGroup.Add($t, $steps)
        }
    }

    if ($steps -eq $maxSteps)
    {
        continue
    }

    if (IsValid ($x+1) $y $data $walls)
    {
        [void]$positions.Enqueue([Tuple[int,int,int]]::new($x+1, $y, $steps + 1))
    }

    if (IsValid ($x-1) $y $data $walls)
    {
        [void]$positions.Enqueue([Tuple[int,int,int]]::new($x-1, $y, $steps + 1))
    }

    if (IsValid $x ($y+1) $data $walls)
    {
        [void]$positions.Enqueue([Tuple[int,int,int]]::new($x, $y+1, $steps + 1))
    }

    if (IsValid $x ($y-1) $data $walls)
    {
        [void]$positions.Enqueue([Tuple[int,int,int]]::new($x, $y-1, $steps + 1))
    }
}

# for ($i = 0; $i -lt $data.Length; $i += 1)
# {
#     $s = ""
#     for ($j = 0; $j -lt $data[0].Length; $j += 1)
#     {
#         $t = [Tuple[int,int]]::new($i, $j)
#         if ($inGroup.ContainsKey($t))
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