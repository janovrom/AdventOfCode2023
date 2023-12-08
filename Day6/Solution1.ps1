$data = Get-Content .\Day6\input.txt

$times = @()
$dists = @()
[regex]::Matches($data[0], '\d+').forEach({ $times += [int]$_.Value })
[regex]::Matches($data[1], '\d+').forEach({ $dists += [int]$_.Value })

$mul = 1
for ($k = 0; $k -lt $times.Length; $k+=1)
{
    $count = 0
    $time = $times[$k]
    $dist = $dists[$k]
    for ($i = 0; $i -le $time; $i+=1)
    {
        $timePressed = $i
        $speed = $timePressed
        $timeMoving = $time - $timePressed
        
        $distanceTravelled = $speed * $timeMoving
    
        if ($distanceTravelled -gt $dist)
        {
            $count += 1
        }
    }

    $count = [Math]::Max(1, $count)
    $mul *= $count
}

Write-Host $mul
Set-Clipboard $mul