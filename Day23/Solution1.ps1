using namespace System
using namespace System.Collections.Generic
using namespace System.Linq

$data = Get-Content .\Day23\input.txt

$distances = @()
foreach ($line in $data)
{
    $distances += ,(@([int]::MaxValue) * $line.Length)
}

$nodes = [HashSet[Tuple[int,int]]]::new()
$start = [Tuple[int,int]]::new(0, 1)
$end = [Tuple[int,int]]::new($data.Length-1, $data[0].Length-2)
[void]$nodes.Add($start)
[void]$nodes.Add($end)
$directions = @(@(1,0), @(-1,0), @(0,1), @(0,-1))
for ($i = 1; $i -lt $data.Length - 1; $i += 1)
{
    $line = $data[$i]
    for ($j = 1; $j -lt $data[0].Length - 1; $j += 1)
    {
        $c = $line[$j]

        if ($c -eq ".")
        {
            $count = 0
            foreach ($direction in $directions)
            {
                $x = $i + $direction[0]
                $y = $j + $direction[1]

                if ($data[$x][$y] -ne "#")
                {
                    $count += 1
                }
            }

            if ($count -gt 2)
            {
                # 2 is just line, so at least 3
                [void]$nodes.Add([Tuple[int,int]]::new($i, $j))
            }
        }
    }
}

function IsInGrid($row, $col)
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

function ForceMovement($c)
{
    if ($c -eq ">")
    {
        0, 1
    }
    elseif ($c -eq "<")
    {
        0,-1
    }
    elseif ($c -eq "v")
    {
        1,0
    }
    elseif ($c -eq "^")
    {
        -1,0
    }
    else
    {
        0,0
    }
}

function IsValidPath($x, $y, $x1, $y1, $data, $distances)
{
    if (-not (IsInGrid $x1 $y1))
    {
        return $false
    }

    if ($data[$x1][$y1] -eq "#")
    {
        return $false
    }

    if ($distances[$x1][$y1] -ne [int]::MaxValue)
    {
        return $false
    }

    $dx, $dy = ForceMovement $data[$x1][$y1]
    if ($x1 + $dx -eq $x -and $y1 + $dy -eq $y)
    {
        return $false
    }

    return $true
}

$graph = [Dictionary[Tuple[int,int], hashtable]]::new()
# x,y,steps,nodex,nodey
$queue = [Queue[Tuple[int,int,int,int,int]]]::new()
[void]$queue.Enqueue([Tuple[int,int,int,int,int]]::new(0, 1, 0, 0, 0))

foreach ($node in $nodes)
{
    $graph.Add($node, @{
        Branches = @()
    })
}

$graph.Add([Tuple[int,int]]::new(0, 0), @{
    Branches = @()
})

while ($queue.Count -gt 0)
{
    $top = $queue.Dequeue()

    $x = $top.Item1
    $y = $top.Item2
    $steps = $top.Item3
    $nodex = $top.Item4
    $nodey = $top.Item5

    $t = [Tuple[int,int]]::new($x, $y)
    if ($nodes.Contains($t))
    {
        # We can get from 'node' to 't' (current)
        # This is a branch also => update to 'node'
        $startNode = [Tuple[int,int]]::new($nodex, $nodey)
        $graph[$startNode].Branches += @{
            Position = $t
            Length = $steps - 1
        }

        $nodex = $x
        $nodey = $y

        $steps = 1
    }

    if ($xt -eq $end)
    {
        # We reached the end
        continue
    }

    if ($data[$x][$y] -eq "#")
    {
        # Oopsie, we stepped into a wall
        continue
    }

    if ($distances[$x][$y] -ne [int]::MaxValue)
    {
        # Already visited this place
        continue
    }

    # Not yet discovered. Save the distances
    $distances[$x][$y] = $steps
    $dx, $dy = ForceMovement $data[$x][$y]
    if ($dx -ne 0 -or $dy -ne 0)
    {
        # Movement was forced, just move, and skip branching
        [void]$queue.Enqueue([Tuple[int,int,int,int,int]]::new($x + $dx, $y + $dy, $steps + 1, $nodex, $nodey))
    }
    else
    {
        foreach ($direction in $directions)
        {
            $x1 = $x + $direction[0]
            $y1 = $y + $direction[1]

            if (IsValidPath $x $y $x1 $y1 $data $distances)
            {
                [void]$queue.Enqueue([Tuple[int,int,int,int,int]]::new($x1, $y1, $steps + 1, $nodex, $nodey))
            }
        }
    }
}

# for ($i = 0; $i -lt $data.Length; $i += 1)
# {
#     $line = $data[$i]
#     for ($j = 0; $j -lt $data[0].Length; $j += 1)
#     {
#         $c = $line[$j]

#         if ($distances[$i][$j] -ne [int]::MaxValue)
#         {
#             Write-Host ("{0,-3}" -f $distances[$i][$j]) -NoNewline
#         }
#         else
#         {
#             Write-Host ("{0,-3}" -f $c) -NoNewline
#         }
#     }
#     Write-Host
# }

# Write-Host

$queue = [Queue[Tuple[Tuple[int,int],int,string]]]::new()
[void]$queue.Enqueue([Tuple]::Create($start, 0, ""))
$walks = @()
while ($queue.Count -ne 0)
{
    $top = $queue.Dequeue()
    $position = $top.Item1
    $distance = $top.Item2
    $node = $graph[$position]
    $path = $top.Item3
    $path += $position

    if ($position -eq $end)
    {
        # Write-Host $path
        $walks += $distance
        continue
    }

    foreach ($branch in $node.Branches)
    {
        # Write-Host "Branching from $position to" $branch.Position "after" $node.Length
        [void]$queue.Enqueue([Tuple]::Create($branch.Position, $distance + $branch.Length, $path))
    }
}

# Write-Host $walks
$max = [Enumerable]::Max([int[]]$walks)
Write-Host $max
Set-Clipboard $max