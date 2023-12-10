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

$current = "AAA"
$direction = 0
$steps = 0
while ($current -ne "ZZZ")
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

Write-Host $steps
Set-Clipboard $steps