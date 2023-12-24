using namespace System
using namespace System.Collections.Generic

$data = Get-Content .\Day21\testinput.txt

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

function Mod($x, $m)
{
    return ($x % $m + $m) % $m
}

function Hash($x, $m)
{
    if ($x -lt 0)
    {
        return [int][Math]::Floor($x / $m)
    }

    return [int][Math]::Floor($x / $m)
}

$maxSteps = 10
# x, y, steps, tx, ty
$lb = - 4 * $data.Length
$ub = 5 * $data[0].Length
$positions = [Queue[Tuple[int,int,int]]]::new()
# [void]$positions.Enqueue([Tuple[int,int,int]]::new(0, 0, 0, 0, 0))
[void]$positions.Enqueue([Tuple[int,int,int]]::new($start.Item1, $start.Item2, 0))
# Reading the inputs, it's always odd number with padding around => if we start at
# the padding with 0, the tile next to it starts odd. Given this knowledge,
# it should be sufficient to get only 3x3 tiles with distances, take the even
# distances (those are the final spot for even $maxSteps) and use tiling.
$inGroup = [Dictionary[Tuple[int,int],int]]::new()

while ($positions.Count -gt 0)
{
    $first = $positions.Dequeue()

    $x = $first.Item1
    $y = $first.Item2
    $steps = $first.Item3

    $p = [Tuple[int,int]]::new($x, $y)

    if ($inGroup.ContainsKey($p))
    {
        if ($inGroup[$p] -le $steps)
        {
            continue
        }

        $inGroup[$p] = [Math]::Min($inGroup[$p], $steps)
    }
    else
    {
        $inGroup.Add($p, $steps)
    }

    if ($x -lt $lb -or $x -gt $ub)
    {
        continue
    }

    if ($y -lt $lb -or $y -gt $ub)
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
        [void]$positions.Enqueue([Tuple[int,int,int]]::new($x + 1, $y, $steps + 1))
    }

    if (IsValid $xm1 $ym $data $walls)
    {
        [void]$positions.Enqueue([Tuple[int,int,int]]::new($x - 1, $y, $steps + 1))
    }

    if (IsValid $xm $yp1 $data $walls)
    {
        [void]$positions.Enqueue([Tuple[int,int,int]]::new($x, $y + 1, $steps + 1))
    }

    if (IsValid $xm $ym1 $data $walls)
    {
        [void]$positions.Enqueue([Tuple[int,int,int]]::new($x, $y - 1, $steps + 1))
    }
}

$oddPositions = [Dictionary[Tuple[int,int],[Dictionary[Tuple[int,int],int]]]]::new()
$evenPositions = [Dictionary[Tuple[int,int],[Dictionary[Tuple[int,int],int]]]]::new()
$maxima = [Dictionary[Tuple[int,int],int]]::new()
$minima = [Dictionary[Tuple[int,int],int]]::new()
foreach ($pos in $inGroup.GetEnumerator())
{
    $x = $pos.Key.Item1
    $y = $pos.Key.Item2
    $d = $pos.Value

    $tx = Hash $x $data.Length
    $ty = Hash $y $data[0].Length
    $t = [Tuple[int,int]]::new($tx, $ty)
    $x = Mod $x $data.Length
    $y = Mod $y $data[0].Length
    $p = [Tuple[int,int]]::new($x, $y)

    if (-not $oddPositions.ContainsKey($t))
    {
        [void]$oddPositions.Add($t, [Dictionary[Tuple[int,int],int]]::new())
        [void]$evenPositions.Add($t, [Dictionary[Tuple[int,int],int]]::new())
        [void]$minima.Add($t, 10000000)
        [void]$maxima.Add($t, -10000000)
    }

    $minima[$t] = [Math]::Min($minima[$t], $d)
    $maxima[$t] = [Math]::Max($maxima[$t], $d)
    if ($d % 2 -eq 0)
    {
        $evenPositions[$t].Add($p, $d)
    }
    else
    {
        $oddPositions[$t].Add($p, $d)
    }
}

"" > .\distances.txt

for ($i = $lb; $i -lt $ub; $i += 1)
{
    $s = ""
    for ($j = $lb; $j -lt $ub; $j += 1)
    {
        $t = [Tuple[int,int]]::new($i, $j)
        $im = Mod $i $data.Length
        $jm = Mod $j $data[0].Length
        $tm = [Tuple[int,int]]::new($im, $jm)
        $tx = Hash $i $data.Length
        $ty = Hash $j $data[0].Length
        $thash = [Tuple[int,int]]::new($tx, $ty)
        if ($inGroup.ContainsKey($t))
        {
            $s += "{0,-4}" -f ($inGroup[$t])
        }
        else 
        {
            $s += "{0,-4}" -f $data[$im][$jm]
        }
    }
    $s >> distances.txt
}

# If we do cycles from (-1,-1) we should cycle +2,+1,+2,+1,...
# +2 => add evens
# +1 => add odds
# We have the padding => always subtract the length
$offset = [int][Math]::Ceiling($maxSteps / $data.Length)
$ranges = @(@{
    StartX = -2
    StartY = -2
    EndX = -$offset
    EndY = -$offset
},@{
    StartX = 0
    StartY = -2
    EndX = 0
    EndY = -$offset
},@{
    StartX = 0
    StartY = 2
    EndX = 0
    EndY = $offset
},@{
    StartX = 2
    StartY = 0
    EndX = $offset
    EndY = 0
}, @{
    StartX = -2
    StartY = 0
    EndX = -$offset
    EndY = 0
}, @{
    StartX = -2
    StartY = 2
    EndX = -$offset
    EndY = $offset
}, @{
    StartX = 2
    StartY = 2
    EndX = $offset
    EndY = $offset
}, @{
    StartX = 2
    StartY = -2
    EndX = $offset
    EndY = -$offset
})

function Iterator($sx, $sy, $ex, $ey)
{
    $ix = [Math]::Sign($ex - $sx)
    $iy = [Math]::Sign($ey - $sy)

    if ($ix -eq 0 -and $iy -eq 0)
    {
    }
    elseif ($ix -eq 0)
    {
        for ($j = $sy; $j -ne $ey + $iy; $j += $iy)
        {
            0, $j
        }
    }
    elseif ($iy -eq 0)
    {
        for ($i = $sx; $i -ne $ex + $ix; $i += $ix)
        {
            $i, 0
        }
    }
    else 
    {
        for ($i = $sx; $i -ne $ex + $ix; $i += $ix)
        {
            for ($j = $sy; $j -ne $ey + $iy; $j += $iy)
            {
                $i, $j
            }
        }
    }
}

$count = 0
foreach ($range in $ranges)
{
    $iter = Iterator $range.StartX $range.StartY $range.EndX $range.EndY  

    if (-not $iter)
    {
        continue
    }

    $torigin = [Tuple[int,int]]::new($range.StartX, $range.StartY)

    for ($it = 0; $it -lt $iter.Length; $it += 2)
    {
        $i = $iter[$it]
        $j = $iter[$it + 1]

        # Plus ones as in - (-1) which is the top left corner of the grid
        $dx = [Math]::Abs($i - $range.StartX)
        $dy = [Math]::Abs($j - $range.StartY)

        $t = [Tuple[int,int]]::new($i, $j)
        $diff = ($maxima[$torigin] - $minima[$torigin]) * ($dx + $dy)
        $max = $maxima[$torigin] + $diff
        
        # Even number of steps to get there means we use even positions, odd otherwise
        if (($dx + $dy) % 2 -eq 1)
        {
            $searchSpace = $evenPositions[$torigin]
        }
        else
        {
            $searchSpace = $oddPositions[$torigin]
        }

        if ($max -gt $maxSteps)
        {
            $c = 0
            # We have to search manually
            foreach ($distance in $searchSpace.Values)
            {
                if ($distance + $diff -le $maxSteps) {
                    $c += 1
                }
            }
            $count += $c
        }
        else
        {
            $count += $searchSpace.Count
        }
    }
}

for ($i = -1; $i -le 1; $i += 1)
{
    for ($j = -1; $j -le 1; $j += 1)
    {
        $count += ($evenPositions[[Tuple[int,int]]::new($i,$j)].Values | Where-Object { $_ -le $maxSteps }).Count
    }
}

Write-Host $count
Set-Clipboard $count