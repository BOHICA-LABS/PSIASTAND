Function Get-Average($array)
{
    $RunningTotal = 0;
    foreach($i in $array){
        $RunningTotal += $i
    }
    return ([decimal]($RunningTotal) / [decimal]($array.Length));
}
