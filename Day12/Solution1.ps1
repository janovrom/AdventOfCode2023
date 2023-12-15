$data = Get-Content .\Day12\input.txt

$sum = 0
$sink = 1000000000
foreach ($line in $data)
{
    $springs, $groups = $line.Split(" ")
    $groups = $groups.Split(",") | ForEach-Object { [int]$_ }
    $groups += $sink

    $queue = [System.Collections.Generic.Stack[System.Tuple[int,int,int,string,string]]]::new()
    $passed = [System.Collections.Generic.HashSet[System.Tuple[int,int,int,string,string]]]::new()
    [void]$queue.Push([System.Tuple]::Create(0, 0, 0, "*", ""))
    while ($queue.Count -gt 0)
    {
        $first = $queue.Pop()
        
        $hashCount = $first.Item1
        $groupIndex = $first.Item2
        $charIndex = $first.Item3
        $required = $first.Item4
        $group = $groups[$first.Item2]

        # Write-Host $first

        if ($charIndex -ge $springs.Length)
        {
            # Evaluate
            if ($group -eq $hashCount -and $groups[$groupIndex + 1] -eq $sink)
            {
                $t = [System.Tuple]::Create(0, $groupIndex, $charIndex, "", $first.Item5)
                [void]$passed.Add($t)   
            }

            if ($group -eq $sink)
            {
                # Pass
                $t = [System.Tuple]::Create(0, $groupIndex, $charIndex, "", $first.Item5)
                [void]$passed.Add($t)
            }
            
            # That's a fail
            continue
        }

        # Rewrite state only
        if ($group -eq $hashCount)
        {
            $groupIndex += 1
            $hashCount = 0
            
            $t = [System.Tuple]::Create(0, $groupIndex, $charIndex, ".", $first.Item5)
            [void]$queue.Push($t)

            continue
        }

        $char = $springs[$charIndex]

        if ($group -eq $sink)
        {
            $required = "."
        }

        if ($required -eq "*")
        {
            # Read any
            if ($char -eq ".")
            {
                [void]$queue.Push([System.Tuple]::Create($hashCount, $groupIndex, $charIndex + 1, "*", $first.Item5 + "."))
            }
            elseif ($char -eq "#")
            {
                [void]$queue.Push([System.Tuple]::Create($hashCount + 1, $groupIndex, $charIndex + 1, "#", $first.Item5 + "#"))
            }
            else
            {
                # Rewrite and duplicate stack
                # Add both possible states: dot or hash
                [void]$queue.Push([System.Tuple]::Create($hashCount, $groupIndex, $charIndex + 1, "*", $first.Item5 + "."))
                [void]$queue.Push([System.Tuple]::Create($hashCount + 1, $groupIndex, $charIndex + 1, "#", $first.Item5 + "#"))
            }
        }
        elseif ($required -eq "#" -and ($char -eq "#" -or $char -eq "?"))
        {
            [void]$queue.Push([System.Tuple]::Create($hashCount + 1, $groupIndex, $charIndex + 1, "#", $first.Item5 + "#"))
        }
        elseif ($required -eq "." -and ($char -eq "." -or $char -eq "?"))
        {
            [void]$queue.Push([System.Tuple]::Create($hashCount, $groupIndex, $charIndex + 1, "*", $first.Item5 + "."))
        }
    }
    
    # Write-Host $passed.Count
    # $passed | Sort-Object | ForEach-Object { Write-Host $_ }
    $sum += $passed.Count
}

Write-Host $sum
Set-Clipboard $sum