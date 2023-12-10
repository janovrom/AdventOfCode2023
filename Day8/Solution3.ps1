$data = Get-Content .\Day8\input.txt

function MakeNode()
{
    param ([string] $left, [string] $right)

    return [PSCustomObject]@{
        Left = $left
        Right = $right
    }
}

function GetFactors($number)
{ 
    $factors = @()
    
    for ($i = 2; $i -lt $number; $i++)
    {
        if ($number % $i -eq 0)
        {
            $factors += $i
        }
    }
    
    if ($factors.Count -eq 0)
    {
        return @($number)
    }

    return $factors
}

$instructions = $data[0].ToCharArray()
$map = [System.Collections.Generic.Dictionary[string, object]]::new()

for ($i = 2; $i -lt $data.Count; $i+=1)
{
    $line = $data[$i].Replace(" ", "").Replace("(", "").Replace(")", "").Replace("=", " ").Replace(",", " ")
    $split = $line.Split(" ")
    [void]$map.Add($split[0], (MakeNode $split[1] $split[2]))
}

# Isn't this just a composite number?
# We need to find after how many steps you reach the Z for each of them.
# The result is just multiplication, since it's the smallest common multiple.

$current = @($map.Keys | Where-Object { $_.EndsWith("A") })
$steps = @()
foreach ($c in $current)
{
    $step = 0
    $direction = 0
    while (-not $c.EndsWith("Z"))
    {
        $instruction = $instructions[$direction]
        $direction = ($direction + 1) % $instructions.Count
    
        $c = switch ($instruction)
        {
            "R" { $map[$c].Right }
            "L" { $map[$c].Left }
        }
    
        $step += 1
    }

    $steps += $step
}

[bigint]$mul = 1
$steps.forEach({ GetFactors $_ }) | Sort-Object | Get-Unique | ForEach-Object { $mul *= $_ }

Write-Host $mul
Set-Clipboard $mul