$data = Get-Content .\Day15\input.txt

$commands = $data.Split(",")

function GetCommandHash($command)
{
    $cmdValue = 0
    foreach ($char in $command.ToCharArray())
    {
        $cmdValue += [int]$char
        $cmdValue *= 17
        $cmdValue %= 256
    }

    return $cmdValue
}

$hashToBoxLenses = [System.Collections.Generic.Dictionary[int, System.Collections.Generic.Dictionary[string,int]]]::new()
$hashToBoxOrder = [System.Collections.Generic.Dictionary[int, System.Collections.Generic.List[string]]]::new()
foreach ($command in $commands)
{
    $cmdValue = 0
    if ($command.Contains("="))
    {
        # Add focal length
        $split = $command.Split("=")
        $hash = GetCommandHash $split[0]
        $focalLength = [int]$split[1]

        if (-not $hashToBoxLenses.ContainsKey($hash))
        {
            [void]$hashToBoxLenses.Add($hash, [System.Collections.Generic.Dictionary[string,int]]::new())
            [void]$hashToBoxOrder.Add($hash, [System.Collections.Generic.List[string]]::new())
        }

        if ($hashToBoxLenses[$hash].ContainsKey($split[0]))
        {
            # Update: replace the value
            $hashToBoxLenses[$hash][$split[0]] = $focalLength
        }
        else
        {
            # Add as last.
            [void]$hashToBoxLenses[$hash].Add($split[0], $focalLength)
            [void]$hashToBoxOrder[$hash].Add($split[0])
        }
    }
    else
    {
        # Remove
        $cmd = $command.Substring(0, $command.Length-1)
        $hash = GetCommandHash $cmd

        if (-not $hashToBoxLenses.ContainsKey($hash))
        {
            [void]$hashToBoxLenses.Add($hash, [System.Collections.Generic.Dictionary[string,int]]::new())
            [void]$hashToBoxOrder.Add($hash, [System.Collections.Generic.List[string]]::new())
        }

        [void]$hashToBoxLenses[$hash].Remove($cmd)
        [void]$hashToBoxOrder[$hash].Remove($cmd)
    }
}

$sum = 0

foreach ($key in $hashToBoxLenses.Keys)
{
    $val = 0
    $slot = 1
    foreach ($cmd in $hashToBoxOrder[$key])
    {
        $val += ($key + 1) * $slot * $hashToBoxLenses[$key][$cmd]
        $slot += 1
    }
    $sum += $val
}

Write-Host $sum
Set-Clipboard $sum