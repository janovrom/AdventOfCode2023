$data = Get-Content .\Day19\input.txt

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
                Value = [int]$val
                Redirect = $redirect
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
                Value = [int]$val
                Redirect = $redirect
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

$states = @()
for ($i = $i + 1; $i -lt $data.Length; $i += 1)
{
    $line = $data[$i].Substring(1, $data[$i].Length-2)
    $state = @{}
    foreach ($var in $line.Split(","))
    {
        $name, $value = $var.Split("=")
        $state[$name] = [int]$value
    }

    $states += $state
}

function SumState($state)
{
    return $state["x"] + $state["m"] + $state["a"] + $state["s"]
}

$sum = 0
foreach ($state in $states)
{
    # Find first rule that applies
    $workflow = $workflows["in"]
    while ($workflow -ne $workflows["A"] -and $workflow -ne $workflows["R"])
    {
        foreach ($command in $workflow)
        {
            $redirect = $command.Evaluate($state)
            
            if ($null -ne $redirect)
            {
                $workflow = $workflows[$redirect]
                break
            }
        }
    }

    if ($workflow -eq $workflows["A"])
    {
        $sum += SumState $state
    }
}

Write-Host $sum
Set-Clipboard $sum