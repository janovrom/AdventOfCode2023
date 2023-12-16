$data = Get-Content .\Day14\input.txt

$original = New-Object 'char[,]' $data.Length,$data[0].Length
$tilted = New-Object 'char[,]' $data.Length,$data[0].Length

for ($i = 0; $i -lt $data.Length; $i += 1)
{
    for ($j = 0; $j -lt $data[0].Length; $j += 1)
    {
        $original[$i,$j] = $data[$i][$j]
    }
}

function ComputeHash($original)
{
    $hash = ""
    for ($i = 0; $i -lt $data.Length; $i += 1)
    {
        for ($j = 0; $j -lt $data[0].Length; $j += 1)
        {
            $hash += $original[$i,$j]
        }
    }

    return $hash

    $mystream = [IO.MemoryStream]::new([byte[]][char[]]$hash)
    $sha = Get-FileHash -InputStream $mystream -Algorithm SHA1
    return $sha.Hash
}

$startTime = Get-Date

$map = [System.Collections.Generic.Dictionary[string,int]]::new()
$cycles = 1000000000
$cycle = 1
$stopHashing = $false
while ($cycle -le $cycles)
{
    $cycle
    # North. For each column, move up.
    for ($j = 0; $j -lt $data[0].Length; $j += 1)
    {
        $empty = 0
        for ($i = 0; $i -lt $data.Length; $i += 1)
        {
            $tilted[$i,$j] = '.'
        }
        for ($i = 0; $i -lt $data.Length; $i += 1)
        {
            $c = $original[$i,$j]
            if ($c -eq '#')
            {
                $empty = $i + 1
                $tilted[$i,$j] = '#'
            }
            elseif ($c -eq 'O')
            {
                $tilted[$empty,$j] = 'O'
                $empty += 1
            }
        }
    }

    $original = $tilted
    $tilted = New-Object 'char[,]' $data.Length,$data[0].Length

    # West. For each row, move left.
    for ($i = 0; $i -lt $data.Length; $i += 1)
    {
        $empty = 0
        for ($j = 0; $j -lt $data[0].Length; $j += 1)
        {
            $tilted[$i,$j] = '.'
        }
        for ($j = 0; $j -lt $data[0].Length; $j += 1)
        {
            $c = $original[$i,$j]
            if ($c -eq '#')
            {
                $empty = $j + 1
                $tilted[$i,$j] = '#'
            }
            elseif ($c -eq 'O')
            {
                $tilted[$i,$empty] = 'O'
                $empty += 1
            }
        }
    }

    $original = $tilted
    $tilted = New-Object 'char[,]' $data.Length,$data[0].Length

    # South. For each column, move down.
    for ($j = 0; $j -lt $data[0].Length; $j += 1)
    {
        for ($i = $data.Length - 1; $i -ge 0; $i -= 1)
        {
            $tilted[$i,$j] = '.'   
        }
        
        $empty = $data.Length - 1
        for ($i = $data.Length - 1; $i -ge 0; $i -= 1)
        {
            $c = $original[$i,$j]
            if ($c -eq '#')
            {
                $empty = $i - 1
                $tilted[$i, $j] = '#'
            }
            elseif ($c -eq 'O')
            {
                $tilted[$empty, $j] = 'O'
                $empty -= 1
            }
        }
    }
    
    $original = $tilted
    $tilted = New-Object 'char[,]' $data.Length,$data[0].Length

    # East. For each row, move right.
    for ($i = 0; $i -lt $data.Length; $i += 1)
    {
        for ($j = $data[0].Length - 1; $j -ge 0; $j -= 1)
        {
            $tilted[$i,$j] = '.'
        }

        $empty = $data[0].Length - 1
        for ($j = $data[0].Length - 1; $j -ge 0; $j -= 1)
        {
            $c = $original[$i,$j]
            if ($c -eq '#')
            {
                $empty = $j - 1
                $tilted[$i,$j] = '#'
            }
            elseif ($c -eq 'O')
            {
                $tilted[$i,$empty] = 'O'
                $empty -= 1
            }
        }
    }
    
    $original = $tilted
    $tilted = New-Object 'char[,]' $data.Length,$data[0].Length

    $cycle += 1

    if ($stopHashing)
    {
        continue
    }

    $hash = ComputeHash $original
    if ($map.ContainsKey($hash))
    {
        # We found a loop
        $storedCycle = $map[$hash]
        $offset = $cycle - $storedCycle
        $cycle = $cycles - ($cycles - $cycle) % $offset
        $stopHashing = $true
    }
    else
    {
        [void]$map.Add($hash, $cycle)
    }
}

$endTime = Get-Date
$executionTime = $endTime - $startTime

Write-Host "Script execution time: $executionTime"

$sum = 0
for ($i = 0; $i -lt $data.Length; $i += 1)
{
    for ($j = 0; $j -lt $data[0].Length; $j += 1)
    {
        if ($original[$i,$j] -eq 'O')
        {
            $sum += $data.Length - $i
        }
    }
}

Write-Host $sum
Set-Clipboard $sum