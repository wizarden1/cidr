function ip2long($ip){
    $ip = [System.Net.IPAddress]::Parse($ip)
    return ([uint32]($ip.GetAddressBytes()[0]) -shl 24) + ([uint32]($ip.GetAddressBytes()[1]) -shl 16) + ([uint32]($ip.GetAddressBytes()[2]) -shl 8) + ([uint32]($ip.GetAddressBytes()[3]))
}

# method CIDRtoMask
# Return a netmask string if given an integer between 0 and 32. I am
# not sure how this works on 64 bit machines.
# Usage:
#     CIDRtoMask(22);
# Result:
#     string(13) "255.255.252.0"
# @param $int int Between 0 and 32.
# @access public
# @static
# @return String Netmask ip address
function CIDRtoMask {
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [Int]
        [ValidateRange(0,32)]
        $Mask
    )
    return [System.Net.IPAddress]::Parse(([uint32]::MaxValue -shl (32 - $Mask))).ToString();
}

# method countSetBits.
# Return the number of bits that are set in an integer.
# Usage:
#     countSetBits(ip2long('255.255.252.0'));
# Result:
#     int(22)
# @param $int int a number
# @access public
# @static
# @see http://stackoverflow.com/questions/109023/best-algorithm-to-count-the-number-of-set-bits-in-a-32-bit-integer
# @return int number of bits set.
function countSetbits([uint32]$int){
    $count = 0;

    while ($int -ne 0) {
        if (($int -band 1) -eq 1){$count++};
        $int = $int -shr 1;
    }
    return $count
}

# method validNetMask.
# Determine if a string is a valid netmask.
# Usage:
#     validNetMask('255.255.252.0');
#     validNetMask('127.0.0.1');
# Result:
#     bool(true)
#     bool(false)
# @param $netmask String a 1pv4 formatted ip address.
# @see http://www.actionsnip.com/snippets/tomo_atlacatl/calculate-if-a-netmask-is-valid--as2-
# @access public
# @static
# return bool True if a valid netmask.
function validNetMask($netmask){
    $netmask = ip2long($netmask);
    $neg = ((-bnot [uint32]$netmask) -band 0xFFFFFFFF);
    return (($neg + 1) -band $neg) -eq 0;
}

# method maskToCIDR.
# Return a CIDR block number when given a valid netmask.
# Usage:
#     maskToCIDR('255.255.252.0');
# Result:
#     int(22)
# @param $netmask String a 1pv4 formatted ip address.
# @access public
# @static
# @return int CIDR number.
function maskToCIDR($netmask){
    if(validNetMask($netmask)){
        return countSetBits(ip2long($netmask));
    } else {
        throw "Invalid Netmask";
    }
}

# method alignedCIDR.
# It takes an ip address and a netmask and returns a valid CIDR
# block.
# Usage:
#     alignedCIDR('127.0.0.1','255.255.252.0');
# Result:
#     string(12) "127.0.0.0/22"
# @param $ipinput String a IPv4 formatted ip address.
# @param $netmask String a 1pv4 formatted ip address.
# @access public
# @static
# @return String CIDR block.
function alignedCIDR($ipinput,$netmask){
    $alignedIP = [System.Net.IPAddress]::Parse((ip2long($ipinput)) -band (ip2long($netmask)));
    return "$alignedIP/$(maskToCIDR($netmask))";
}

# method IPisWithinCIDR.
# Check whether an IP is within a CIDR block.
# Usage:
#     IPisWithinCIDR('127.0.0.33','127.0.0.1/24');
#     IPisWithinCIDR('127.0.0.33','127.0.0.1/27');
# Result:
#     bool(true)
#     bool(false)
# @param $ipinput String a IPv4 formatted ip address.
# @param $cidr String a IPv4 formatted CIDR block. Block is aligned
# during execution.
# @access public
# @static
# @return String CIDR block.
function IPisWithinCIDR($ipinput,$cidr){
    $cidr = $cidr.Split("/");
    $cidr = alignedCIDR -ipinput $cidr[0] -netmask $(CIDRtoMask([int]$cidr[1]));
    $cidr = $cidr.Split("/");
    $ipinput = (ip2long($ipinput));
    $ip1 = (ip2long($cidr[0]));
    $ip2 = ($ip1 + [System.Math]::Pow(2, (32 - [int]$cidr[1])) - 1);
    return $(($ip1 -le $ipinput) -and ($ipinput -le $ip2));
}

* method maxBlock.
* Determines the largest CIDR block that an IP address will fit into.
* Used to develop a list of CIDR blocks.
* Usage:
*     maxBlock("127.0.0.1");
*     maxBlock("127.0.0.0");
# Result:
#     int(32)
#     int(8)
# @param $ipinput String a IPv4 formatted ip address.
# @access public
# @static
# @return int CIDR number.
function maxBlock($ipinput) {
    [int]$z = ip2long($ipinput);
    $y = -($z -band -$z);
    return maskToCIDR("$([System.BitConverter]::GetBytes($y)[3]).$([System.BitConverter]::GetBytes($y)[2]).$([System.BitConverter]::GetBytes($y)[1]).$([System.BitConverter]::GetBytes($y)[0])");
}

# function rangeToCIDRList.
# Returns an array of CIDR blocks that fit into a specified range of
# ip addresses.
# Usage:
#    rangeToCIDRList("127.0.0.1","127.0.0.34");
# Result:
#     "127.0.0.1/32"
#     "127.0.0.2/31"
#     "127.0.0.4/30"
#     "127.0.0.8/29"
#     "127.0.0.16/28"
#     "127.0.0.32/31"
#     "127.0.0.34/32"
# @param $ipStart String or Long a IPv4 ip address.
# @param $ipEnd String or Long a IPv4 ip address.
# @see http://null.pp.ru/src/php/Netmask.phps
# @return Array CIDR blocks in a numbered array.
function rangeToCIDRList($ipStart, $ipEnd)
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

# method cidrToRange.
# Returns an array of only two IPv4 addresses that have the lowest ip
# address as the first entry. If you need to check to see if an IPv4
# address is within range please use the IPisWithinCIDR method above.
# Usage:
#     cidrToRange("127.0.0.128/25");
# Result:
#     array(2) {
#   *       [0]=> string(11) "127.0.0.128"
#   *       [1]=> string(11) "127.0.0.255"
#   *     }
# @param $cidr string CIDR block
# @return Array low end of range then high end of range.
function cidrToRange {
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [String]
        $cidr
    )
    $range = @()
    $cidra = $cidr.Split("/")
    $range += [System.Net.IPAddress]::Parse(((ip2long($cidra[0])) -band (([uint32]::MaxValue -shl (32 - $cidra[1]))))).ToString();
    $range += [System.Net.IPAddress]::Parse(((ip2long($cidra[0])) + [System.Math]::Pow(2, (32 - $cidra[1])) - 1)).ToString();
    return $range;
}
