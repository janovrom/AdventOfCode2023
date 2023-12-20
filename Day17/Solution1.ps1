using namespace System
using namespace System.Collections.Generic

$data = Get-Content .\Day17\input.txt

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

$global:R = 0
$global:D = 1
$global:L = 2
$global:U = 3

function MapDirection($d)
{
    switch ($d)
    {
        $global:R { 1, 0 }  # R
        $global:D { 0, 1 }  # D
        $global:L { -1, 0 } # L
        $global:U { 0, -1 } # U
    }
}

function MapLeft($d)
{
    switch ($d)
    {
        $global:R { $global:U }
        $global:D { $global:R }
        $global:L { $global:D }
        $global:U { $global:L }
    }
}

function MapRight($d)
{
    switch ($d)
    {
        $global:R { $global:D }
        $global:D { $global:L }
        $global:L { $global:U }
        $global:U { $global:R }
    }
}

function GetAdjacent($pos, $cmin, $cmax)
{
    $x = $pos.Item1
    $y = $pos.Item2
    $dx, $dy = MapDirection $pos.Item3
    $count = $pos.Item4

    # Change direction
    if ($count -ge $cmin)
    {
        $l = MapLeft $pos.Item3
        $xl, $yl = MapDirection $l

        $r = MapRight $pos.Item3
        $xr, $yr = MapDirection $r

        [Tuple]::Create($x + $xl, $y + $yl, $l, 1)
        [Tuple]::Create($x + $xr, $y + $yr, $r, 1)
    }

    # Continue if possible
    if ($count -lt $cmax)
    {
        [Tuple]::Create($x + $dx, $y + $dy, $pos.Item3, $count + 1)
    }
}

function GetCost($state, $heatCost)
{
    if ($heatCost.ContainsKey($state))
    {
        return $heatCost[$state]
    }

    return [Double]::PositiveInfinity
}

$heatLosses = @()
foreach ($line in $data)
{
    $heatLosses += ,[int[]]@($line.ToCharArray() | ForEach-Object { ([int]$_) - 48})
}
$minHeatFound = 0
for ($i = 1; $i -lt $heatLosses.Count; $i += 1)
{
    $minHeatFound += $heatLosses[$i][$i]
    $minHeatFound += $heatLosses[$i][$i - 1]
}

# x,y,dx,dy,count,heat loss
$visiting = [PriorityQueue[[Tuple[int,int,int,int]], int]]::new()
$heatCost = [Dictionary[[Tuple[int,int,int,int]], int]]::new()

$goal = [Tuple]::Create($data.Count - 1, $data.Count - 1)
[void]$visiting.Enqueue([Tuple[int,int,int,int]]::new(0, 0, 0, 1), 0)
[void]$heatCost.Add([Tuple[int,int,int,int]]::new(0, 0, 0, 1), 0)

$iterations = 0
$cmin = 1
$cmax = 3
$cost
$startTime = Get-Date
while ($visiting.Count -ne 0)
{
    $iterations +=1

    if ($iterations % 1000 -eq 0)
    {
        Write-Host ($iterations / 1000)"K"
    }

    $pos = $visiting.Dequeue()
    $x = $pos.Item1
    $y = $pos.Item2
    $count = $pos.Item4
    
    # Prune
    if ($heatCost[$pos] -gt $minHeatFound)
    {
        continue
    }

    if ([Tuple]::Create($x, $y) -eq $goal -and $count -ge $cmin)
    {
        $cost = $heatCost[$pos]
        break
    }

    $validConnections = (GetAdjacent $pos $cmin $cmax).Where({ IsInGrid $_.Item1 $_.Item2 }).Where({ 
        (GetCost $pos $heatCost) + $heatLosses[$_.Item1][$_.Item2] -lt (GetCost $_ $heatCost)
    })
    
    $validConnections.forEach({
        $heatCost[$_] = $heatCost[$pos] + $heatLosses[$_.Item1][$_.Item2]
        [void]$visiting.Enqueue($_, $heatCost[$_])
    })
}

$endTime = Get-Date
$executionTime = $endTime - $startTime

Write-Host "Script execution time: $executionTime"

Write-Host "Iterations" $iterations
Write-Host $cost
Set-Clipboard $cost