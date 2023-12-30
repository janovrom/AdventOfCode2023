$data = Get-Content .\Day25\input.txt

$sourcesToRemove = @("hcd", "bqp", "fhv") 
$dstsToRemove = @("cnr", "fqr", "zsp")

$string = "graph Day25Cut {`n"
foreach ($line in $data)
{
    $src, $dsts = $line.Split(": ")

    foreach ($dst in $dsts.Split(" "))
    {
        if ($sourcesToRemove.Contains($src) -and $dstsToRemove.Contains($dst))
        {
            continue
        }

        $string += "  $src -- $dst [label=`"$src to $dst`"];`n"
    }
}

$string += "}"

$string | Out-File -FilePath .\Day25\graphviz-cut.txt

ccomps ".\Day25\graphviz-cut.txt" "-sv"