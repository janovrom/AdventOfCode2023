using namespace System.Collections.Generic

$data = Get-Content .\Day20\input.txt

$types = @{}
$connections = @{}
$reverseConnections = @{}
foreach ($line in $data)
{
    $source, $targets = $line.Split(" -> ")
    $type = $source[0]
    if ($type -ne "b")
    {
        $source = $source.Substring(1)
    }
    $types[$source] = $type
    $connections[$source] = @($targets.Split(", "))
    foreach ($connection in $connections[$source])
    {
        if (-not $reverseConnections.ContainsKey($connection))
        {
            $reverseConnections[$connection] = @()
        }

        $reverseConnections[$connection] += $source
    }
}

$evaluators = @{}
foreach ($pair in $types.GetEnumerator())
{
    if ($pair.Value -eq "b")
    {
        $eval = [PSCustomObject]@{
            Name = $pair.Key
            Signal = $false
        }

        $eval.PSObject.Methods.Add(
            [psscriptmethod]::new('SendSignal', { 
                param ($isHigh, $source)

                $this.Signal = $isHigh

                $this.Signal
            })
        )

        $evaluators[$pair.Key] = $eval
    }
    elseif ($pair.Value -eq "%")
    {
        $eval = [PSCustomObject]@{
            Name = $pair.Key
            IsOn = $false
        }

        $eval.PSObject.Methods.Add(
            [psscriptmethod]::new('SendSignal', { 
                param ($isHigh, $source)

                if ($isHigh) {
                    return
                }

                $this.IsOn = -not $this.IsOn
                $this.IsOn
            })
        )

        $evaluators[$pair.Key] = $eval
    }
    elseif ($pair.Value -eq "&")
    {
        $eval = [PSCustomObject]@{
            Name = $pair.Key
            Signals = @{}
        }

        foreach ($connection in $reverseConnections[$pair.Key])
        {
            $eval.Signals[$connection] = $false
        }

        $eval.PSObject.Methods.Add(
            [psscriptmethod]::new('SendSignal', { 
                param ($isHigh, $source)

                $this.Signals[$source] = $isHigh
                $allHigh = $true
                foreach ($signal in $this.Signals.Values)
                {
                    $allHigh = $allHigh -and $signal
                }

                -not $allHigh
            })
        )

        $evaluators[$pair.Key] = $eval
    }
}
$highPulses = 0
$lowPulses = 0

$buttonPresses = 0
$stepsRx = 0
$highWatcher = @{
    "jg" = 0
    "rh" = 0
    "jm" = 0
    "hf" = 0
}
while ($stepsRx -eq 0)
{
    $queue = [Queue[Tuple[string,bool,string]]]::new()
    $queue.Enqueue([Tuple[string,bool,string]]::new("broadcaster",$false,"button"))
    $buttonPresses += 1
    Write-Host "Button pressed $buttonPresses"
    while ($queue.Count -gt 0)
    {
        $first = $queue.Dequeue()
    
        $name = $first.Item1
        $type = $types[$name]
        $eval = $evaluators[$name]
        $isHigh = $first.Item2
    
        # $signalString = $isHigh ? "high" : "low"
        # Write-Host $first.Item1 "received $signalString"
    
        if ($isHigh)
        {
            $highPulses += 1
        }
        else
        {
            $lowPulses += 1
        }
    
        if ($name -eq "rx" -and -not $isHigh)
        {
            $queue.Clear()
            $stepsRx = $buttonPresses
            break
        }

        # Output or other node, that don't have connections
        if ($null -eq $eval)
        {
            continue
        }
    
        $resultSignal = $eval.SendSignal($isHigh, $first.Item3)
    
        if ($null -eq $resultSignal)
        {
            continue
        }

        if ($highWatcher.ContainsKey($name))
        {
            if ($resultSignal -and $highWatcher[$name] -eq 0)
            {
                Write-Host "Watched value $name is high"
                $highWatcher[$name] = $buttonPresses
            }
        }

        $allWatchesFound = $true
        foreach ($value in $highWatcher.Values)
        {
            if ($value -eq 0)
            {
                $allWatchesFound = $false
                break
            }
        }

        if ($allWatchesFound)
        {
            $queue.Clear()
            Write-Host $highWatcher
            $mul = 1
            # The values happen to be primes. If not, decomposition would need to be made
            foreach ($value in $highWatcher.Values)
            {
                $mul *= $value
            }
            $stepsRx = $mul
            break
        }
    
        foreach ($connection in $connections[$name])
        {
            # Write-Host $name "-> $signalString ->" $connection
            [void]$queue.Enqueue([Tuple[string,bool,string]]::new($connection, $resultSignal, $name))
        }
    }
}

Write-Host $stepsRx
Set-Clipboard $stepsRx