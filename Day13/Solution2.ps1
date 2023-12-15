$data = Get-Content .\Day13\input.txt

$current = @()
$mirrors = @()
foreach ($line in $data)
{
    if ($line -eq "")
    {
        $mirrors += ,$current
        $current = @()
        continue
    }
    else
    {
        $current += ,$line
    }
}

$mirrors += ,$current
$sum = 0
foreach ($mirror in $mirrors)
{
    $isVertical = $false
    for ($i = 1; $i -lt $mirror[0].Length; $i += 1)
    {
        $left = $i - 1
        $right = $i
        $smudges = 0
        while ($left -ge 0 -and $right -lt $mirror[0].Length)
        {
            foreach ($line in $mirror)
            {
                if ($line[$left] -ne $line[$right])
                {
                    $smudges += 1
                }
            }

            $left -= 1
            $right += 1
        }

        if ($smudges -eq 1)
        {
            $isVertical = $true
            $summary = $i
            $sum += $summary
            Write-Host $summary
            break
        }
    }

    if ($isVertical)
    {
        continue
    }

    # Do it transpose
    for ($i = 1; $i -lt $mirror.Length; $i += 1)
    {
        $above = $i - 1
        $below = $i
        $smudges = 0
        while ($above -ge 0 -and $below -lt $mirror.Length)
        {
            for ($j = 0; $j -lt $mirror[0].Length; $j += 1)
            {
                if ($mirror[$above][$j] -ne $mirror[$below][$j])
                {
                    $smudges += 1
                }

            }

            $above -= 1
            $below += 1
        }

        if ($smudges -eq 1)
        {
            $summary = 100 * $i
            $sum += $summary
            Write-Host $summary
            break
        }
    }
}

Write-Host $sum
Set-Clipboard $sum