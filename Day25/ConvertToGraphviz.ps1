$data = Get-Content .\Day25\input.txt

$string = "graph Day25 {`n"
foreach ($line in $data)
{
    $src, $dsts = $line.Split(": ")

    foreach ($dst in $dsts.Split(" "))
    {
        $string += "  $src -- $dst [label=`"$src to $dst`"];`n"
    }
}

$string += "}"

$string | Out-File -FilePath .\Day25\graphviz.txt

# Neato visualization from graphviz worked for me