using namespace System
using namespace System.Collections.Generic

$data = Get-Content .\Day22\input.txt

function ToXyz($string)
{
    $string.Split(",")
}

function GetAxis($x0, $y0, $z0, $x1, $y1, $z1)
{
    if ($x0 -ne $x1)
    {
        0
    }
    elseif ($y0 -ne $y1)
    {
        1
    }
    else
    {
        2
    }
}

function SumVectors3($x, $y)
{
    @($x[0] + $y[0], $x[1] + $y[1], $x[2] + $y[2])
}

function AddToVector3($x, $axis, $s)
{
    $clone = [int[]]$x.Clone()
    $clone[$axis] += $s
    $clone
}

$sandLines = @()
$queue = [PriorityQueue[hashtable,int]]::new()
foreach ($line in $data)
{
    $start, $end = $line.Split("~")
    [int]$x0, [int]$y0, [int]$z0 = ToXyz $start
    [int]$x1, [int]$y1, [int]$z1 = ToXyz $end
    $axis = GetAxis $x0 $y0 $z0 $x1 $y1 $z1
    $sandLine = @{
        Axis = $axis
        Start = @($x0, $y0, $z0)
        End = @($x1, $y1, $z1)
    }
    $sandLine["Length"] = $sandLine.End[$axis] - $sandLine.Start[$axis] + 1
    [void]$queue.Enqueue($sandLine, $sandLine.Start[2])
}

Write-Host "Data loaded into priority queue..."

while ($queue.Count -gt 0)
{
    $top = $queue.Dequeue()
    $sandLines += $top
}

Write-Host "Lines sorted..."

$occupancy = [Dictionary[Tuple[int,int,int],int]]::new()
$linesToPositions = @()
for ($i = 0; $i -lt $sandLines.Length; $i += 1)
{
    # Move down if possible
    $offsetDown = 0
    $sandLine = $sandLines[$i]
    
    
    # Try move it down
    :outer while (($sandLine.Start[2] + $offsetDown) -gt 0)
    {
        # Generate positions
        for ($j = 0; $j -lt $sandLine.Length; $j += 1)
        {
            $position = AddToVector3 $sandLine.Start $sandLine.Axis $j
            $position[2] += $offsetDown
            $t = [Tuple[int,int,int]]::new($position[0], $position[1], $position[2])
            
            # If there is something in this position, move it up
            if ($occupancy.ContainsKey($t))
            {
                break outer
            }
        }

        $offsetDown -= 1
    }
    
    # We stop on 0, or when we hit something. Move one up.
    $offsetDown += 1

    # Fill the occupancy
    $positions = @()
    for ($j = 0; $j -lt $sandLine.Length; $j += 1)
    {
        $position = AddToVector3 $sandLine.Start $sandLine.Axis $j
        $position[2] += $offsetDown
        $t = [Tuple[int,int,int]]::new($position[0], $position[1], $position[2])
        
        [void]$occupancy.Add($t, $i)
        $positions += ,$position
    }

    $linesToPositions += ,$positions
}

Write-Host "Occupancy set created..."

$supportsLines = @($null) * $sandLines.Length
$supportedBy = @($null) * $sandLines.Length
for ($i = 0; $i -lt $sandLines.Length; $i += 1)
{
    $supportsLines[$i] = [HashSet[int]]::new()
    $supportedBy[$i] = [HashSet[int]]::new()
}

for ($i = 0; $i -lt $sandLines.Length; $i += 1)
{
    $lineToPositions = $linesToPositions[$i]
    $sandLine = $sandLines[$i]

    foreach ($position in $lineToPositions)
    {
        $t = [Tuple[int,int,int]]::new($position[0], $position[1], $position[2] + 1)

        if ($occupancy.ContainsKey($t))
        {
            $lineIdx = $occupancy[$t]

            if ($lineIdx -eq $i)
            {
                # It's me! Your line!
                # Vertical line, ignore itself.
            }
            else
            {
                # if (-not $supportsLines[$i].Contains($lineIdx))
                # {
                #     $c0 = [char](65 + $i)
                #     $c1 = [char](65 + $lineIdx)
                    
                #     Write-Host "$c0 supportsLines $c1" 
                # }

                [void]$supportsLines[$i].Add($lineIdx)
                [void]$supportedBy[$lineIdx].Add($i)
            }
        }
    }
}

Write-Host "Support graph constructed..."
Write-Host "Evaluating..."

$sum = 0
for ($i = 0; $i -lt $sandLines.Length; $i += 1)
{
    $sandLine = $sandLines[$i]
    $canBeDissolved = $true
    foreach ($supported in $supportsLines[$i])
    {
        if ($supportedBy[$supported].Count -gt 1)
        {
            # If the line supports 'supported' and it is supported
            # by more then one, the line can be removed. But it
            # has to apply for each of them.
        }
        else
        {
            $canBeDissolved = $false
        }
    }
    
    if ($canBeDissolved)
    {
        # $c = [char](65 + $i)
        # Write-Host "$c can be dissolved"
        $sum += 1
    }
}

Write-Host $sum
Set-Clipboard $sum