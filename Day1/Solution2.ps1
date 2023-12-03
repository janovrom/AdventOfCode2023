$data = Get-Content .\Day1\input.txt

$keywords = @("1", "2", "3", "4", "5", "6", "7", "8", "9",
    "one", "two", "three", "four", "five", "six", "seven", "eight", "nine")

[int] $sum = 0
foreach ($line in $data) 
{
    $min = 0
    $max = 0
    $minIndex = 10000
    $maxIndex = -1
    $keyIndex = 1
    foreach ($keyword in $keywords)
    {
        $firstIndex = $line.IndexOf($keyword)
        
        if ($firstIndex -ne -1)
        {
            if ($minIndex -gt $firstIndex)
            {
                $minIndex = $firstIndex
                $min = $keyIndex
            }

            $lastIndex = $line.LastIndexOf($keyword)
            if ($maxIndex -lt $lastIndex)
            {
                $maxIndex = $lastIndex
                $max = $keyIndex
            }
        }


        $keyIndex += 1
        if ($keyIndex -eq 10)
        {
            $keyIndex = 1
        }
    }

    $strVal = $min * 10 + $max
    $sum += [int] $strVal
}

Write-Output $sum
Set-Clipboard $sum