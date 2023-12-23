using namespace System.Linq
using namespace System.Collectionts.Generic
using namespace System

$data = Get-Content .\Day19\input.txt

$min = 1
$max = 4000

$workflows = @{}
$workflows["A"] = [PSCustomObject]@{ Name = "Success" }
$workflows["R"] = [PSCustomObject]@{ Name = "Failure" }
for ($i = 0; $i -lt $data.Length; $i += 1)
{
    $line = $data[$i]
    if ($line -eq "")
    {
        break
    }
    
    $node, $commands = $line.Replace("}", "").Split("{")

    $workflow = @()
    foreach ($command in $commands.Split(","))
    {
        if ($command.Contains(">"))
        {
            $var, $val, $redirect = $command.Split(">").Split(":")
            $cmd = [PSCustomObject]@{
                Property = $var
                Value = [bigint]$val
                Redirect = $redirect
                String = $command
                Type = "lb"
            }
            $cmd.PSObject.Methods.Add(
                [psscriptmethod]::new(
                    'Evaluate', {
                        param ($state)

                        if ($state[$this.Property] -gt $this.Value)
                        {
                            return $this.Redirect
                        }
                    }
                )
            )
            $workflow += $cmd
        }
        elseif ($command.Contains("<"))
        {
            $var, $val, $redirect = $command.Split("<").Split(":")
            $cmd = [PSCustomObject]@{
                Property = $var
                Value = [bigint]$val
                Redirect = $redirect
                String = $command
                Type = "ub"
            }
            $cmd.PSObject.Methods.Add(
                [psscriptmethod]::new(
                    'Evaluate', {
                        param ($state)

                        if ($state[$this.Property] -lt $this.Value)
                        {
                            return $this.Redirect
                        }
                    }
                )
            )
            $workflow += $cmd
        }
        else 
        {
            $cmd = [PSCustomObject]@{
                Redirect = $command
                String = $command
                Type = "none"
            }
            $cmd.PSObject.Methods.Add(
                [psscriptmethod]::new(
                    'Evaluate', {
                        return $this.Redirect
                    }
                )
            )
            $workflow += $cmd
        }
    }

    $workflows[$node] = $workflow
}

$workflow = $workflows["in"]
$acceptingStates = @()
$stack = @()
# Name, Path of commands, Path of nodes, commands
$stack += [Tuple[string,string[],string[],int[]]]::new("in", @(), @(),@())
$categories = @("x", "m", "a", "s")
while ($stack.Length -gt 0)
{
    $top = $stack[-1]
    if ($stack.Length -eq 1)
    {
        $stack = @()
    }
    else 
    {
        $stack = $stack[0..($stack.Length-2)]
    }
    
    if ($top.Item1 -eq "R")
    {
        continue
    }

    if ($top.Item1 -eq "A")
    {
        $acceptingStates += $top
    }

    $index = 0
    foreach ($command in $workflows[$top.Item1])
    {
        $next = [Tuple[string,string[],string[],int[]]]::new($command.Redirect, $top.Item2 + $command.String, $top.Item3 + $top.Item1, $top.Item4 + $index)
        $stack += $next
        $index += 1
    }
}

$results = @()
foreach ($accepting in $acceptingStates)
{
    $ranges = @{
        "x" = @{
            Min = $min 
            Max = $max 
        }
        "m" = @{
            Min = $min 
            Max = $max 
        }
        "a" = @{
            Min = $min 
            Max = $max 
        }
        "s" = @{
            Min = $min 
            Max = $max 
        }
    }

    $index = 0
    foreach ($node in $accepting.Item3)
    {
        $workflow = $workflows[$node]

        $branchIndex = $accepting.Item4[$index]
        # Evaluate passed branches - reverse the bounds
        for ($i = 0; $i -lt $branchIndex; $i+=1)
        {
            $command = $workflow[$i]
            if ($command.Property)
            {
                $range = $ranges[$command.Property]
                if ($command.Type -eq "ub")
                {
                    $range.Min = $command.Value
                }
                elseif ($command.Type -eq "lb")
                {
                    $range.Max = $command.Value
                }

                if ($range.Min -gt $range.Max)
                {
                    $range.Min = 0
                    $range.Max = 0
                }
            }
        }

        # Evaluate branching - use the bounds
        $command = $workflow[$branchIndex]
        if ($command.Property)
        {
            [int]$rangeStart, [int]$rangeEnd = $command.Accepts()
            $range = $ranges[$command.Property]
            if ($command.Type -eq "ub")
            {
                $range.Max = $command.Value - 1
            }
            elseif ($command.Type -eq "lb")
            {
                $range.Min = $command.Value + 1
            }

            if ($range.Min -gt $range.Max)
            {
                $range.Min = 0
                $range.Max = 0
            }
        }

        $index += 1
    }

    $results += $ranges

    Write-Host $accepting.Item2
    Write-Host $accepting.Item3
    foreach ($range in $ranges.GetEnumerator())
    {
        $rmin = $range.Value.Min
        $rmax = $range.Value.Max
        $name = $range.Key

        Write-Host "$name : [$rmin,$rmax]"
    }
}

$sum = 0
foreach ($range in $results)
{
    $mul = 1
    foreach ($category in $categories)
    {
        $r = $range[$category]
        if ($r.Min -eq 0 -or $r.Max -eq 0)
        {
            $mul = 0
            continue
        }
        $mul *= $r.Max - $r.Min + 1
    }
    $sum += $mul
}

Write-Host $sum
Set-Clipboard $sum