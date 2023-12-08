# $data = Get-Content .\Day6\input2.txt

# $times = @()
# $dists = @()
# [regex]::Matches($data[0], '\d+').forEach({ $times += [long]$_.Value })
# [regex]::Matches($data[1], '\d+').forEach({ $dists += [long]$_.Value })

# $mul = 1
# for ($k = 0; $k -lt $times.Length; $k+=1)
# {
#     $count = 0
#     $time = $times[$k]
#     $dist = $dists[$k]
#     for ($i = 0; $i -le $time; $i+=1)
#     {
#         $timeMoving = $time - $i
        
#         $distanceTravelled = $i * $timeMoving
    
#         if ($distanceTravelled -gt $dist)
#         {
#             $count += 1
#         }
#     }

#     $count = [Math]::Max(1, $count)
#     $mul *= $count
# }

# Write-Host $mul
# Set-Clipboard $mul

# 0 = -x^2 + 42899189 * x - 308117012911467

$a = -1
$b = 42899189
$c = -308117012911467

$ad = -0.0001
$bd = 4289.9189
$cd = -30811701291.1467

$x1 = (-$bd - [System.Math]::Sqrt($bd * $bd - 4 * $ad * $cd)) / (2 * $ad)
$x2 = (-$bd + [System.Math]::Sqrt($bd * $bd - 4 * $ad * $cd)) / (2 * $ad)

$range = [Math]::Floor($x1) - [Math]::Ceiling($x2) + 1
Write-Host $range

# Math it out, since it's just speed and distance travelled (those are large numbers, beware of overflow)
# s = v * t, use substitute with variable x (time pressed), and constant c
# v = x, t = c - x, where t is always positive or 0
# That's a parabole in the shape of reverse U
# 308117012911467 <= x * (42899189 - x)
# That solves for x1≈9.12206063052865×10^6 = 9122060.63052865 and x2≈3.37771283694713×10^7 = 33777128.3694713
# We have discreet values => x1 = 9122061 and x2 = 33777128.
# The result is the difference between these numbers + 1 for x1: 2.465506773894265 × 10^7 => 24655067 + 1
# 24655068