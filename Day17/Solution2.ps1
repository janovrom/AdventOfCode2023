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

function GetCost($state, $heatCost)
{
    if ($heatCost.ContainsKey($state))
    {
        return $heatCost[$state]
    }

    return 10000000
}

$heatLosses = @()
foreach ($line in $data)
{
    $heatLosses += ,[int[]]@($line.ToCharArray() | ForEach-Object { ([int]$_) - 48})
}

# x,y,dx,dy,count,heat loss
$visiting = [PriorityQueue[[Tuple[int,int,int,int,int]], int]]::new()
$heatCost = [Dictionary[[Tuple[int,int,int,int,int]], int]]::new()
$visited = [HashSet[[Tuple[int,int,int,int,int]]]]::new()

$goal = [Tuple]::Create($data.Count - 1, $data[0].Length - 1)
[void]$visiting.Enqueue([Tuple[int,int,int,int,int]]::new(0, 0, 0, 0, 0), 0)
[void]$heatCost.Add([Tuple[int,int,int,int,int]]::new(0, 0, 0, 0, 0), 0)

$iterations = 0
$cmin = 4
$cmax = 10

$startTime = Get-Date
$directions = @([Tuple[int,int]]::new(1, 0), [Tuple[int,int]]::new(-1, 0), [Tuple[int,int]]::new(0, 1), [Tuple[int,int]]::new(0, -1))
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
    $dx = $pos.Item3
    $dy = $pos.Item4
    $count = $pos.Item5

    
    if ($x -eq $goal.Item1 -and $y -eq $goal.Item2 -and $count -ge $cmin)
    {
        $cost = $heatCost[$pos]
        break
    }

    if ($visited.Contains($pos))
    {
        continue
    }
    
    [void]$visited.Add($pos)

    # Continue if possible
    if ($count -lt $cmax -and -not ($dx -eq 0 -and $dy -eq 0))
    {
        $newState = [Tuple[int,int,int,int,int]]::new($x + $dx, $y + $dy, $dx, $dy, $count + 1)
        if ((IsInGrid $newState.Item1 $newState.Item2))
        {
            if ((GetCost $newState $heatCost) -gt (GetCost $pos $heatCost) + $heatLosses[$newState.Item1][$newState.Item2])
            {
                $heatCost[$newState] = $heatCost[$pos] + $heatLosses[$newState.Item1][$newState.Item2]
                [void]$visiting.Enqueue($newState, $heatCost[$newState])
            }
        }
    }

    # Change direction
    if ($count -ge $cmin -or ($dx -eq 0 -and $dy -eq 0))
    {
        $cdir = [Tuple[int,int]]::new($dx, $dy)
        $rdir = [Tuple[int,int]]::new(-$dx, -$dy)
        foreach ($dir in $directions)
        {
            if ($dir -ne $cdir -and $dir -ne $rdir)
            {
                $newState = [Tuple[int,int,int,int,int]]::new($x + $dir.Item1, $y + $dir.Item2, $dir.Item1, $dir.Item2, 1)
                if ((IsInGrid $newState.Item1 $newState.Item2))
                {
                    if ((GetCost $newState $heatCost) -gt (GetCost $pos $heatCost) + $heatLosses[$newState.Item1][$newState.Item2])
                    {
                        $heatCost[$newState] = $heatCost[$pos] + $heatLosses[$newState.Item1][$newState.Item2]
                        [void]$visiting.Enqueue($newState, $heatCost[$newState])
                    }
                }
            }
        }
    }
}

$endTime = Get-Date
$executionTime = $endTime - $startTime

Write-Host "Script execution time: $executionTime"

Write-Host "Iterations" $iterations
Write-Host $cost
Set-Clipboard $cost