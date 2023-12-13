$data = Get-Content .\Day9\input.txt

$sum = 0
foreach ($line in $data)
{
    $values = @($line.Split(" ") | ForEach-Object { [int]$_})
    $iterations = @()
    $iterations += ,$values

    while ($true)
    {
        $reducedValues = @()
        for ($i = 0; $i -lt $values.Count - 1; $i+=1)
        {
            $reducedValues += $values[$i + 1] - $values[$i]
        }

        $values = $reducedValues
        $iterations += ,$values

        if ($reducedValues.Where({ $_ -ne 0 }, 'First').Count -eq 0)
        {
            $a = 0
            for ($i = $iterations.Count - 2; $i -ge 0; $i-=1)
            {
                $a = $iterations[$i][0] - $a
            }

            $sum += $a
            break
        }
    }
}

Write-Host $sum
Set-Clipboard $sum