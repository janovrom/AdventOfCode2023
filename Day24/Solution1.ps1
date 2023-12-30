using namespace System

$data = Get-Content ".\Day24\input.txt"

$lines2D = @()
foreach ($line in $data)
{
    $pos, $dir = $line.Split("@ ")
    [long]$x, [long]$y, [long]$z = $pos.Split(", ")
    [long]$dx, [long]$dy, [long]$dz = $dir.Split(", ")
    $speed = [Math]::Sqrt($dx * $dx + $dy * $dy + $dz * $dz)

    $lines2D += @{
        Origin = @($x, $y, $z)
        Velocity = @(($dx), ($dy), ($dz))
        Speed = $speed
    }
}

$minx = 200000000000000
$miny = 200000000000000
$maxx = 400000000000000
$maxy = 400000000000000
$collisions = 0
for ($i = 0; $i -lt $lines2D.Length; $i += 1)
{
    for ($j = $i + 1; $j -lt $lines2D.Length; $j += 1)
    {
        $linex = $lines2D[$i]
        $liney = $lines2D[$j]
        if ($linex -eq $liney)
        {
            continue
        }

        $dx = $linex.Origin[0] - $liney.Origin[0]
        $dy = $linex.Origin[1] - $liney.Origin[1]
        $det = $linex.Velocity[0] * $liney.Velocity[1] - $linex.Velocity[1] * $liney.Velocity[0]

        if ($det -ne 0)
        {
            $u = ($dy * $liney.Velocity[0] - $dx * $liney.Velocity[1]) / $det
            $v = ($dy * $linex.Velocity[0] - $dx * $linex.Velocity[1]) / $det
            
            if ($u -ge 0 -and $v -ge 0)
            {
                $px = $linex.Origin[0] + $u * $linex.Velocity[0]
                $py = $linex.Origin[1] + $u * $linex.Velocity[1]

                
                if ($px -ge $minx -and $px -le $maxx -and $py -ge $miny -and $py -le $maxy)
                {
                    $collisions += 1
                }
            }
        }
    }
}

Write-Host $collisions
Set-Clipboard $collisions