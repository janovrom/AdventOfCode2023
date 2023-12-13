$data = Get-Content .\Day11\input.txt

$galaxies = @()
$columnEmpty = @($true) * $data[0].Length
$rowEmpty = @($true) * $data.Count
for ($i = 0; $i -lt $data.Count; $i += 1)
{
    for ($j = 0; $j -lt $data[0].Length; $j += 1)
    {
        $c = $data[$i][$j]

        if ($c -eq '#')
        {
            $galaxies += (MakeIntTuple $i $j)
        }
    }
}

for ($i = 0; $i -lt $data.Count; $i += 1)
{
    for ($j = 0; $j -lt $data[0].Length; $j += 1)
    {
        $c = $data[$i][$j]

        if ($c -eq '#')
        {
            $rowEmpty[$i] = $false
            break
        }
    }
}

for ($j = 0; $j -lt $data[0].Length; $j += 1)
{
    for ($i = 0; $i -lt $data.Count; $i += 1)
    {
        $c = $data[$i][$j]

        if ($c -eq '#')
        {
            $columnEmpty[$j] = $false
            break
        }
    }
}

# To compute distance use Manhattan distance
# Use 2 for solution 1 and 1000000 for solution2
$expansion = 1000000
$sum = 0
for ($i = 0; $i -lt $galaxies.Length; $i += 1)
{
    for ($j = $i + 1; $j -lt $galaxies.Length; $j += 1)
    {
        $start = $galaxies[$i]
        $end = $galaxies[$j]

        $maxx = [Math]::Max($end.Item1, $start.Item1)
        $minx = [Math]::Min($end.Item1, $start.Item1)
        $maxy = [Math]::Max($end.Item2, $start.Item2)
        $miny = [Math]::Min($end.Item2, $start.Item2)
        $ix = [Math]::Sign($maxx - $minx)
        $iy = [Math]::Sign($maxy - $miny)

        $distance = 0
        if ($ix -ne 0)
        {
            for ($x = $minx + $ix; $x -le $maxx; $x += $ix)
            {
                if ($rowEmpty[$x])
                {
                    $distance += $expansion
                }
                else
                {
                    $distance += 1
                }
            }
        }

        if ($iy -ne 0)
        {
            for ($y = $miny + $iy; $y -le $maxy; $y += $iy)
            {
                if ($columnEmpty[$y])
                {
                    $distance += $expansion
                }
                else
                {
                    $distance += 1
                }
            }
        }

        # Write-Host "Galaxies" ($i+1) "and" ($j+1) "have distance" $distance
        $sum += $distance
    }
}

Write-Host $sum
Set-Clipboard $sum