function iprange2cidr($ipStart, $ipEnd)
{
    $start = [System.Net.IPAddress]::Parse($ipStart)
    $start = ([uint32]($start.GetAddressBytes()[0]) -shl 24) + ([uint32]($start.GetAddressBytes()[1]) -shl 16) + ([uint32]($start.GetAddressBytes()[2]) -shl 8) + ([uint32]($start.GetAddressBytes()[3]))
    $end = [System.Net.IPAddress]::Parse($ipEnd)
    $end = ([uint32]($end.GetAddressBytes()[0]) -shl 24) + ([uint32]($end.GetAddressBytes()[1]) -shl 16) + ([uint32]($end.GetAddressBytes()[2]) -shl 8) + ([uint32]($end.GetAddressBytes()[3]))
    $result = @();
 
    while ($end -ge $start)
    {
        [byte]$maxSize = 32;
        while ($maxSize -gt 0)
        {
            [int64]$mask = [System.Math]::Pow(2, 32) - [System.Math]::Pow(2, (32 - ($maxSize - 1)));
            [int64]$maskBase = $start -band $mask;
 
            if ($maskBase -ne $start){break}
            $maxSize--;
        }
        [byte]$maxDiff = [byte](32 - [System.Math]::Floor([System.Math]::Log($end - $start + 1) / [System.Math]::Log(2)));
        if ($maxSize -lt $maxDiff){$maxSize = $maxDiff}
        $result += [System.Net.IPAddress]::Parse($start).ToString() + "/" + $maxSize;
        $start += [int64][System.Math]::Pow(2, (32 - $maxSize));
    }
    return $result;
}

 

#iprange2cidr -ipstart 3232235520 -ipend "192.168.0.255"
iprange2cidr -ipstart "192.168.0.1" -ipend "192.168.255.255"
