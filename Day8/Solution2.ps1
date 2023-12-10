$data = Get-Content .\Day8\input.txt

function MakeNode()
{
    param ([string] $left, [string] $right)

    return [PSCustomObject]@{
        Left = $left
        Right = $right
    }
}

$instructions = $data[0].ToCharArray()
$map = [System.Collections.Generic.Dictionary[string, object]]::new()

for ($i = 2; $i -lt $data.Count; $i+=1)
{
    $line = $data[$i].Replace(" ", "").Replace("(", "").Replace(")", "").Replace("=", " ").Replace(",", " ")
    $split = $line.Split(" ")
    [void]$map.Add($split[0], (MakeNode $split[1] $split[2]))
}

$current = @($map.Keys | Where-Object { $_.EndsWith("A") })
$direction = 0
$steps = 0
while ($current.Where({ -not $_.EndsWith("Z") }, 'First').Count -ne 0)
{
    $instruction = $instructions[$direction]
    $direction = ($direction + 1) % $instructions.Count

    $current = switch ($instruction)
    {
        "R" { $map[$current].Right }
        "L" { $map[$current].Left }
    }

    $steps += 1
}

# Isn't this just a composite number?
# We need to find after how many steps you reach the Z for each of them.
# The result is just multiplication, since it's the smallest common multiple.

Write-Host $steps
Set-Clipboard $steps