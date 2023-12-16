$data = Get-Content .\Day14\input.txt

$startTime = Get-Date

# Make it column major - x indexes column, y indexes row
$sum = 0
for ($j = 0; $j -lt $data[0].Length; $j += 1)
{
    $empty = 0
    for ($i = 0; $i -lt $data.Length; $i += 1)
    {
        $c = $data[$i][$j]
        if ($c -eq '#')
        {
            $empty = $i + 1
        }
        elseif ($c -eq 'O')
        {
            $sum += $data.Length - $empty
            $empty += 1
        }
    }
}

$endTime = Get-Date
$executionTime = $endTime - $startTime

Write-Host "Script execution time: $executionTime"

Write-Host $sum
Set-Clipboard $sum