$data = Get-Content .\Day2\input.txt

$summedGameids = 0
foreach ($line in $data)
{
    $line = $line.Replace("Game ", "")
    $split = $line.Split(": ")
    $gameNumber = [int]$split[0]
    $gameSets = $split[1].Split("; ")
    $loadedDices = @{ red = 12; green = 13; blue = 14 }

    $isGameViable = $gameSets | ForEach-Object { $_.Split(", ") } | ForEach-Object { 
        $s = $_.Split(" "); 
        if ($loadedDices[$s[1]] -lt [int] $s[0])
        {
            return $false
        }
    } | Select -First 1

    if ($null -eq $isGameViable)
    {
        $isGameViable = $true
    }

    if ($isGameViable)
    {
        $summedGameids += $gameNumber
    }
    
    Write-Host "Game" $gameNumber "is viable:" $isGameViable
}

Write-Host $summedGameids
Set-Clipboard $summedGameids