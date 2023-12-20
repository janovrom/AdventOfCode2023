$data = Get-Content .\Day16\input.txt

function AddBeam($beam, $output, $cache)
{
    if (-not (IsBeamValid $beam))
    {
        return
    }

    if (-not $cache.Contains($beam))
    {
        [void]$output.Add($beam)
    }
}

function IsPositionValid($row, $col)
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

function IsBeamValid($beam)
{
    return IsPositionValid $beam.Item1 $beam.Item2
}

function MapDirection($dx, $dy, $mirror)
{
    if ($mirror -eq "/")
    {
        $tmp = $dx
        $dx = -$dy
        $dy = -$tmp
    }
    elseif ($mirror -eq "\")
    {
        $tmp = $dx
        $dx = $dy
        $dy = $tmp
    }

    $dx, $dy
}

function RollOutTheBeam($inputBeam)
{

    $energized = @()
    foreach ($line in $data)
    {
        $energized += ,(@($false) * $line.Length)
    }
    $beams = @($inputBeam)
    $cache = [System.Collections.Generic.HashSet[System.Tuple[int,int,int,int]]]::new()
    
    while ($beams.Count -gt 0)
    {
        $newBeams = [System.Collections.Generic.HashSet[System.Tuple[int,int,int,int]]]::new()
        # Energize the fields
        for ($i = 0; $i -lt $beams.Length; $i += 1)
        {
            $beam = $beams[$i]
            $row = $beam.Item1
            $col = $beam.Item2
            $energized[$row][$col] = $true
        }
    
        # Cache the beams
        for ($i = 0; $i -lt $beams.Length; $i += 1)
        {
            $beam = $beams[$i]
            [void]$cache.Add($beam)
        }
    
        # Move the beams
        for ($i = 0; $i -lt $beams.Length; $i += 1)
        {
            $beam = $beams[$i]
            $row = $beam.Item1
            $col = $beam.Item2
            $dx = $beam.Item3
            $dy = $beam.Item4
    
            $row += $dy
            $col += $dx
    
            $isPositionValid = IsPositionValid $row $col
            if (-not $isPositionValid)
            {
                continue
            }
            
            $char = $data[$row][$col]
            if ($char -eq ".")
            {
                # Just pass it
                $newBeam = [System.Tuple[int,int,int,int]]::new($row, $col, $dx, $dy)
                AddBeam $newBeam $newBeams $cache
            }
            elseif ($char -eq "-")
            {
                if ($dy -eq 0)
                {
                    $newBeam = [System.Tuple[int,int,int,int]]::new($row, $col, $dx, $dy)
                    AddBeam $newBeam $newBeams $cache
                    # Pass through as is
                }
                else 
                {
                    # We are splitting. One left, one right
                    $left = [System.Tuple[int,int,int,int]]::new($row, $col, -1, 0)
                    $right = [System.Tuple[int,int,int,int]]::new($row, $col, 1, 0)
                    AddBeam $left $newBeams $cache
                    AddBeam $right $newBeams $cache
                }
            }
            elseif ($char -eq "|")
            {
                if ($dx -eq 0)
                {
                    # Pass through as is
                    $newBeam = [System.Tuple[int,int,int,int]]::new($row, $col, $dx, $dy)
                    AddBeam $newBeam $newBeams $cache
                }
                else
                {
                    # We are splitting. One up, one down
                    $up = [System.Tuple[int,int,int,int]]::new($row, $col, 0, -1)
                    $down = [System.Tuple[int,int,int,int]]::new($row, $col, 0, 1)
                    AddBeam $up $newBeams $cache
                    AddBeam $down $newBeams $cache
                }
            }
            else
            {
                $dx, $dy = MapDirection $dx $dy $char
                $newBeam = [System.Tuple[int,int,int,int]]::new($row, $col, $dx, $dy)
                AddBeam $newBeam $newBeams $cache
            }
        }
    
        $beams = @($newBeams)
    }
    
    $sum = 0
    for ($i = 0; $i -lt $energized.Length; $i += 1)
    {
        $row = $energized[$i]
        $row.forEach({ if($_) { $sum += 1 } })
    }

    return $sum
}

$max = 0
# Start the downs
for ($i = 0; $i -lt $data[0].Length; $i += 1)
{
    $beam = [System.Tuple[int,int,int,int]]::new(0,$i,0,1)
    $value = RollOutTheBeam $beam
    $max = [Math]::Max($max, $value)
}

# Start the ups
for ($i = 0; $i -lt $data[0].Length; $i += 1)
{
    $beam = [System.Tuple[int,int,int,int]]::new($data.Length-1,$i,0,-1)
    $value = RollOutTheBeam $beam
    $max = [Math]::Max($max, $value)
}

# Start the rights
for ($i = 0; $i -lt $data.Length; $i += 1)
{
    $beam = [System.Tuple[int,int,int,int]]::new($i,0,1,0)
    $value = RollOutTheBeam $beam
    $max = [Math]::Max($max, $value)
}

# Start the lefts
for ($i = 0; $i -lt $data.Length; $i += 1)
{
    $beam = [System.Tuple[int,int,int,int]]::new($i,$data[0].Length-1,-1,0)
    $value = RollOutTheBeam $beam
    $max = [Math]::Max($max, $value)
}

Write-Host $max
Set-Clipboard $max