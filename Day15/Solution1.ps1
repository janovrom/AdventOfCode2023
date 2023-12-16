$data = Get-Content .\Day15\input.txt

$commands = $data.Split(",")

$sum = 0
foreach ($command in $commands)
{
    $cmdValue = 0
    foreach ($char in $command.ToCharArray())
    {
        $cmdValue += [int]$char
        $cmdValue *= 17
        $cmdValue %= 256
    }

    $sum += $cmdValue
}

Write-Host $sum
Set-Clipboard $sum