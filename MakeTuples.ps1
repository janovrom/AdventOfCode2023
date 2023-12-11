function MakeIntTuple([int]$x, [int]$y)
{
    return [System.ValueTuple[int,int]]::new($x, $y)
}

function MakeStringTuple([string]$x, [string]$y)
{
    return [System.ValueTuple[string,string]]::new($x, $y)
}

function MakeAnyTuple($x, $y)
{
    return [System.Tuple]::Create($x, $y)
}