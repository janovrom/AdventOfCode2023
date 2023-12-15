$data = Get-Content .\Day12\input.txt

function Consume($first, $queue)
{
    $hashCount = $first.Item1
    $groupIndex = $first.Item2
    $charIndex = $first.Item3
    $required = $first.Item4
    $hashesToRewrite = $groups[$first.Item2]

    $char = $springs[$charIndex]
    
    if ($hashesToRewrite -eq $sink)
    {
        $required = "."
    }
    
    if ($required -eq "*")
    {
        # Read any
        if ($char -eq ".")
        {
            [void]$queue.Push([System.Tuple]::Create($hashCount, $groupIndex, $charIndex + 1, "*", $first.Item5, $first.Item6 + "."))
        }
        elseif ($char -eq "#")
        {
            [void]$queue.Push([System.Tuple]::Create($hashCount + 1, $groupIndex, $charIndex + 1, "#", $first.Item5, $first.Item6 + "#"))
        }
        else
        {
            # Rewrite and duplicate stack
            # Add both possible states: dot or hash
            [void]$queue.Push([System.Tuple]::Create($hashCount, $groupIndex, $charIndex + 1, "*", $first.Item5, $first.Item6 + "."))
            [void]$queue.Push([System.Tuple]::Create($hashCount + 1, $groupIndex, $charIndex + 1, "#", $first.Item5, $first.Item6 + "#"))
        }
    }
    elseif ($required -eq "#" -and ($char -eq "#" -or $char -eq "?"))
    {
        [void]$queue.Push([System.Tuple]::Create($hashCount + 1, $groupIndex, $charIndex + 1, "#", $first.Item5, $first.Item6 + "#"))
    }
    elseif ($required -eq "." -and ($char -eq "." -or $char -eq "?"))
    {
        [void]$queue.Push([System.Tuple]::Create($hashCount, $groupIndex, $charIndex + 1, "*", $first.Item5, $first.Item6 + "."))
    }
}

$sum = 0
$sink = 1000000000
foreach ($line in $data)
{
    Write-Host $data.IndexOf($line)
    $springs, $groups = $line.Split(" ")
    $springs = ($springs + "?") * 4 + $springs
    $groups = $groups.Split(",") | ForEach-Object { [long]$_ }
    $groups *= 1
    
    $minLenRequired = 0
    $groups.forEach({ $minLenRequired += $_ + 1 })

    $groups += $sink

    # hashCount, groupIndex, current char index, required char, read string, duplicates count
    $queue = [System.Collections.Generic.Stack[System.Tuple[long,long,long,string,long,string]]]::new()
    [void]$queue.Push([System.Tuple]::Create(0l, 0l, 0l, "*", 1l, ""))

    for ($i = 0; $i -lt 5; $i+=1)
    {
        # We only need to cache: sink, character index and number of times we reached this
        $cache = [System.Collections.Generic.Dictionary[long,long]]::new()
        while ($queue.Count -gt 0)
        {
            $first = $queue.Pop()
            
            $hashCount = $first.Item1
            $groupIndex = $first.Item2
            $charIndex = $first.Item3
            $hashesToRewrite = $groups[$first.Item2]

            if (($springs.Length - $charIndex) -lt ((4 - $i) * $minLenRequired - 1))
            {
                continue
            }
    
            # We have reached the sink, that's stopping criteria
            if ($hashesToRewrite -eq $sink)
            {
                # Write-Host $first.Item6
                if ($cache.ContainsKey($charIndex))
                {
                    $cache[$charIndex] += $first.Item5
                }
                else
                {
                    [void]$cache.Add($charIndex, $first.Item5)
                }
    
                continue
            }

            # Rewrite state only
            if ($hashesToRewrite -eq $hashCount)
            {
                $groupIndex += 1
                $hashCount = 0
                
                $t = [System.Tuple]::Create(0l, $groupIndex, $charIndex, ".", $first.Item5, $first.Item6)
                [void]$queue.Push($t)

                continue
            }
    
            if ($charIndex -ge $springs.Length)
            {
                continue
            }

            Consume $first $queue
        }

        # Merge cached keys since we really care only about position of the caret
        foreach ($key in $cache.Keys)
        {
            # We swapped to sink, next HAS TO BE "dot"
            [void]$queue.Push([System.Tuple]::Create(0l, 0l, $key, ".", $cache[$key], ""))
        }
    }

    $iterationSolutions = 0
    while ($queue.Count -gt 0)
    {
        # Evaluate count of possible solutions
        $first = $queue.Pop()
            
        $hashCount = $first.Item1
        $groupIndex = $first.Item2
        $charIndex = $first.Item3
        $required = $first.Item4
        $hashesToRewrite = $groups[$first.Item2]

        if ($charIndex -ge $springs.Length)
        {
            # Evaluate
            if ($hashCount -eq 0)
            {
                $iterationSolutions += $first.Item5
            }

            # That's a fail otherwise
            continue
        }

        Consume $first $queue
    }
    
    # Write-Host $iterationSolutions
    # Write-Host ($passed.Count * [Math]::Pow($toMul, 4))
    # $passed | Sort-Object | ForEach-Object { Write-Host $_ }
    $sum += $iterationSolutions
}

Write-Host $sum
Set-Clipboard $sum