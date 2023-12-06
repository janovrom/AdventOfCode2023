$data = Get-Content .\Day4\input.txt

$sum = 0
foreach ($line in $data)
{
    $lineSplit = $line.Split(":")
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

    if (0 -ne $winningMatches)
    {
        $sum += [Math]::Pow(2, $winningMatches - 1)
    }
}

Write-Host $sum
Set-Clipboard $sum