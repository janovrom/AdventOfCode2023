$data = Get-Content .\Day2\input.txt

$summedPower = 0
foreach ($line in $data)
{
    $line = $line.Replace("Game ", "")
    $split = $line.Split(": ")
    $gameNumber = [int]$split[0]
    $gameSets = $split[1].Split("; ")
    $counter = @{ red = 0; green = 0; blue = 0 }

    $gameSets | ForEach-Object { $_.Split(", ") } | ForEach-Object { 
        $s = $_.Split(" ");
        $value = [int] $s[0]
        $max = $counter[$s[1]]
        $counter[$s[1]] = [System.Math]::Max($value, $max);
    }
    
    $power = 1
    $counter.Values.forEach({$power = $_ * $power})

    $summedPower += $power

    Write-Host "Game" $gameNumber "has power:" $power
}

Write-Host $summedPower
Set-Clipboard $summedPower