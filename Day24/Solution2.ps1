# Big thanks to /r/user/FatalisticFeline-47/ and /r/user/Maeyven/

using namespace System
using namespace System.Numerics

$data = Get-Content ".\Day24\input.txt"

$lines = @()
foreach ($line in $data)
{
    $pos, $dir = $line.Split("@ ")
    [long]$x, [long]$y, [long]$z = $pos.Split(", ")
    [long]$dx, [long]$dy, [long]$dz = $dir.Split(", ")
    $speed = [Math]::Sqrt($dx * $dx + $dy * $dy + $dz * $dz)

    $lines += @{
        Origin = @($x, $y, $z)
        Velocity = @(($dx), ($dy), ($dz))
        Speed = $speed
    }
}

function TryIntersect($linex, $liney, $offset)
{
    $dx = $linex.Origin[0] - $liney.Origin[0]
    $dy = $linex.Origin[1] - $liney.Origin[1]

    $avx = $linex.Velocity[0] + $offset[0]
    $avy = $linex.Velocity[1] + $offset[1]
    $cvx = $liney.Velocity[0] + $offset[0]
    $cvy = $liney.Velocity[1] + $offset[1]
    $det = $avx * $cvy - $avy * $cvx
 
    if ($det -eq 0)
    {
        return @($false, @(-1, -1), -1)
    }
 
    $t = ($dy * $cvx - $dx * $cvy) / $det
 
    $Px = $linex.Origin[0] + $t * $avx
    $Py = $linex.Origin[1] + $t * $avy
 
    return @($true, @($Px, $Py), $t);
}

function NotEqual($x, $y)
{
    return $x[0] -ne $y[0] -or $x[1] -ne $y[1]
}

foreach ($i in -300..300)
{
    foreach ($j in -300..300)
    {
        # 1. We assume that the rock is not moving, so the task changes to finding common intersection point
        # for all lines, and that point is the position of the rock. 
        # 2. Since the rock can be moving, we modify the velocities of the hailstones, which transforms
        # the task to 1.
        # To get the result, getting 3 hits should be enough: That's three different lines hitting
        # the rock, and 3 points well-define a line unless the rock hits two or more hailstones
        # at the same time.
        $intersect1 = TryIntersect $lines[1] $lines[0] @($i, $j)
        $intersect2 = TryIntersect $lines[2] $lines[0] @($i, $j)
        $intersect3 = TryIntersect $lines[3] $lines[0] @($i, $j)

        # If they don't align, keep searching
        if (-not $intersect1[0] -or (NotEqual $intersect1[1] $intersect2[1]) -or (NotEqual $intersect1[1] $intersect3[1]))
        {
            continue
        }
            

        # Brute force the Z velocity as well.
        foreach ($k in -300..300)
        {
            # We know at what timestamp we would intersect the rock its initial position, so we can 
            # just check where the Z would end up at.
            $intersectZ1 = $lines[1].Origin[2] + $intersect1[2] * ($lines[1].Velocity[2] + $k);
            $intersectZ2 = $lines[2].Origin[2] + $intersect2[2] * ($lines[2].Velocity[2] + $k);
            $intersectZ3 = $lines[3].Origin[2] + $intersect3[2] * ($lines[3].Velocity[2] + $k);

            # If they don't align, keep searching
            if ($intersectZ1 -ne $intersectZ2 -or $intersectZ1 -ne $intersectZ3)
            {
                continue
            }

            # If hailstones happen to align, just assume we found the answer and exit.
            $result = $intersect1[1][0] + $intersect1[1][1] + $intersectZ1
            Set-Clipboard $result
            return $result
        }
    }
}

Write-Host "No solution found"