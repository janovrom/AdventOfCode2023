$data = Get-Content .\Day1\input.txt

[int] $sum = 0
foreach ($line in $data) 
{
    $values =@()
    Select-String '\d' -input $line -allmatches | ForEach-Object { $values += $_.matches.Value }
    $strVal = $values[0] + $values[-1]
    $sum += [int] $strVal
}

Write-Output $sum
Set-Clipboard $sum