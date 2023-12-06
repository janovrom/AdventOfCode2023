$data = Get-Content .\Day4\input.txt

[long]$sum = 0
$counter = @(1) * $data.Count
$additionalCards = 0
foreach ($line in $data)
{
    $lineSplit = $line.Split(":")
    $cardNumber = [int]$lineSplit[0].Replace("Card ", "")
    $lineSplit = $lineSplit[1].Split("|")
    $winningNumbers = [System.Collections.Generic.HashSet[int]]::new()
    [regex]::Matches($lineSplit[0], '\d+') | ForEach-Object {
        [void]$winningNumbers.Add([int]$_.Value)
    }

    $myNumbers = [regex]::Matches($lineSplit[1], '\d+')
    $winningMatches = 0
    foreach ($number in $myNumbers)
    {
        if ($winningNumbers.Contains($number.Value))
        {
            $winningMatches += 1
        }
    }

    for ($i = $cardNumber + 1; $i -le $cardNumber + $winningMatches; $i += 1)
    {
        if ($i -ge $data.Count)
        {
            $additionalCards += $counter[$cardNumber]
        }
        else 
        {
            $counter[$i] += $counter[$cardNumber]
        }
    }
}

$counter.ForEach({ $sum += $_ })
$sum += $additionalCards

Write-Host $sum
Set-Clipboard $sum