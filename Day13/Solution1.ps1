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
        $continue = $true
        while ($left -ge 0 -and $right -lt $mirror[0].Length -and $continue)
        {
            foreach ($line in $mirror)
            {
                if ($line[$left] -ne $line[$right])
                {
                    $continue = $false
                    break
                }
            }

            $left -= 1
            $right += 1
        }

        if ($continue)
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
        $continue = $true
        while ($above -ge 0 -and $below -lt $mirror.Length)
        {
            if ($mirror[$above] -ne $mirror[$below])
            {
                $continue = $false
                break
            }

            $above -= 1
            $below += 1
        }

        if ($continue)
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