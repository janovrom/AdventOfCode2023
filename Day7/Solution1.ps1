$data = Get-Content .\Day7\input.txt

$values = [System.Collections.Generic.Dictionary[char, int]]::new()
[void]$values.Add('A', 14)
[void]$values.Add('K', 13)
[void]$values.Add('Q', 12)
[void]$values.Add('J', 11)
[void]$values.Add('T', 10)
[void]$values.Add('9', 9)
[void]$values.Add('8', 8)
[void]$values.Add('7', 7)
[void]$values.Add('6', 6)
[void]$values.Add('5', 5)
[void]$values.Add('4', 4)
[void]$values.Add('3', 3)
[void]$values.Add('2', 2)

function Make-Hand
{
    param ([string] $hand, [int] $bid)

    $object = [PSCustomObject]@{
        Hand = $hand
        Type = 0
        Value = 0
        Bid = $bid
    }
    
    $object.PSObject.Methods.Add(
        [psscriptmethod]::new(
            'Initialize', {
                $chars = $this.Hand.ToCharArray()
                $chars.forEach({ $this.Value = $this.Value * 100 + $values[$_] })
                $counter = [System.Collections.Generic.Dictionary[char, int]]::new()
                $chars.forEach({
                    $counter[$_] += 1
                })
                $sorted = @($counter.Values | Sort-Object -Descending)
                
                if ($sorted.Count -eq 5) { $this.Type = 0 } # high card
                elseif ($sorted.Count -eq 4) { $this.Type = 1 } # one pair
                elseif ($sorted.Count -eq 3 -and $sorted[0] -eq 2) { $this.Type = 2 } # two pair
                elseif ($sorted.Count -eq 3 -and $sorted[0] -eq 3) { $this.Type = 3 } # three of a kind
                elseif ($sorted.Count -eq 2 -and $sorted[0] -eq 3) { $this.Type = 4 } # full house
                elseif ($sorted.Count -eq 2 -and $sorted[0] -eq 4) { $this.Type = 5 } # four of a kind
                elseif ($sorted.Count -eq 1) { $this.Type = 6 } # five of a kind
            }
        )
    )

    $object.PSObject.Methods.Add(
        [psscriptmethod]::new(
            'GetValue', {
                param ([int] $order)
                return $this.Bid * $order
            }
        )
    )

    $object.Initialize()

    return $object
}

$hands = @()

foreach ($line in $data)
{
    $split = $line.Split(" ")
    $hand = Make-Hand -hand $split[0] -bid ([int]$split[1])
    $hands += $hand
}

$hands = $hands | Sort-Object -Stable Type, Value | ForEach-Object -Begin {$index=1; $sum = 0} -Process {$sum += $_.GetValue($index); $index += 1;} -End {$sum}

Write-Host $sum
Set-Clipboard $sum