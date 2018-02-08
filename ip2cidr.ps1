function long2ip([int64]$ipAddress)
{
    return "$([BitConverter]::GetBytes($ipAddress)[3]).$([BitConverter]::GetBytes($ipAddress)[2]).$([BitConverter]::GetBytes($ipAddress)[1]).$([BitConverter]::GetBytes($ipAddress)[0])"
}

function ip2long([string]$ip){
    $ipaddress = [System.Net.IPAddress]::Parse($ip)
    return (([int64]$ipaddress.GetAddressBytes()[0]) -shl 24) + (([int64]$ipaddress.GetAddressBytes()[1]) -shl 16) + (([int64]$ipaddress.GetAddressBytes()[2]) -shl 8) + (([int64]$ipaddress.GetAddressBytes()[3]))
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
        $int
    )
    return long2ip(-1 -shl (32 - $int));
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
function countSetbits([int64]$int){
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
    $alignedIP = ip2long((ip2long($ipinput)) -band (ip2long($netmask)));
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

# method maxBlock.
# Determines the largest CIDR block that an IP address will fit into.
# Used to develop a list of CIDR blocks.
# Usage:
#     maxBlock("127.0.0.1");
#     maxBlock("127.0.0.0");
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
#     rangeToCIDRList("127.0.0.1","127.0.0.34");
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
    $start = ip2long($ipStart)
    $end = ip2long($ipEnd)
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
        $result += "$(long2ip($start))/$maxSize";
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
#     "127.0.0.128"
#     "127.0.0.255"
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
    $range += long2ip((ip2long($cidra[0])) -band (-1 -shl (32 - $cidra[1])));
    $range += long2ip((ip2long($cidra[0])) + [System.Math]::Pow(2, (32 - $cidra[1])) - 1);
    return $range;
}

# method cidrDevider.
# Returns an array of splited IPv4 networks.
# Usage:
#     cidrDevider("127.0.0.0/23", 24);
# Result:
#     "127.0.0.0/24"
#     "127.0.1.0/24"
# @param $cidr string CIDR block
# @param $dstprefix int result prefix
# @return Array of splited networks.
function cidrDevider ($cidr, [ValidateRange(0,32)][int]$dstprefix) {
	$range = cidrToRange($cidr);
	$result = @();
	if ($dstprefix -lt $($cidr.Split("/")[1])){throw "Invalid Destination Prefix"};
	$incr = [System.Math]::Pow(2, (32 - $dstprefix))
	$net = ip2long($range[0]);
	Do {
		$result += "$(long2ip($net))/$dstprefix";
		$net = $net + $incr;
	} While ($net -le $(ip2long($range[1])));
	return $result
}

# method getIpInfo
# Return info about IPv4 network/address.
# Usage:
#     resolveASN("8.8.8.0/24");
#     resolveASN("8.8.8.8");
# Result:
#     announced       : True
#     as_country_code : US
#     as_description  : GOOGLE - Google Inc.
#     as_number       : 15169
#     first_ip        : 8.8.8.0
#     ip              : 8.8.8.8
#     last_ip         : 8.8.8.255
# @param $cidr string CIDR block or IPv4 Address
# @return object with fields - announced,as_country_code,as_description,as_number,first_ip,ip,last_ip.
function getIpInfo($cidr){
	$apilink = "https://api.iptoasn.com/v1/as/ip/"
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	return ConvertFrom-Json($(Invoke-WebRequest $($apilink + $($cidr).Split("/")[0])).Content);
}

# method resolveASN.
# Returns an ASN number from IPv4 network/address.
# Usage:
#     resolveASN("8.8.8.0/24");
# Result:
#     "15169"
# @param $cidr string CIDR block or IPv4 Address
# @return ASN int.
function resolveASN($cidr){
	return $(getIpInfo($cidr)).as_number;
}

# method resolveCountry.
# Returns an Country Code from IPv4 network/address.
# Usage:
#     resolveASN("8.8.8.0/24");
# Result:
#     "US"
# @param $cidr string CIDR block or IPv4 Address
# @return US as string.
function resolveCountry($cidr){
	return $(getIpInfo($cidr)).as_country_code;
}

# method CIDRsummarize.
# Returns an Summarised IPv4 network.
# Usage:
#     resolveASN(@("8.8.0.0/23","8.8.2.0/23","8.8.9.0/24","8.8.8.0/24"));
# Result:
#     "8.8.0.0/22"
#     "8.8.8.0/23"
# @param $cidr array of string of IPv4 CIDR block
# @return array of string.
function CIDRsummarize($cidrs){
	[System.Collections.ArrayList]$cidrlist = $cidrs
	$mask = 32
	while ($mask -ge 1) {
		$addr = $($cidrlist | where {$_ -like "*/$mask"})
		[System.Collections.ArrayList]$addrl = @()
        $addr | ForEach-Object {$(ip2long($_.split("/")[0])) -shr $(32-$mask)} | Sort-Object | ForEach-Object {$addrl.Add($_) >$null}
		$pos = $addrl.count-1
		while ($pos -ge 1){
            if ($addrl[$pos] -eq $($addrl[$pos-1]+1)){
                $ip1 = long2ip($addrl[$pos-1] -shl $(32-$mask))
                $cidrlist.Remove("$ip1/$($mask)") >$null
                $ip2 = long2ip($addrl[$pos] -shl $(32-$mask))
                $cidrlist.Remove("$ip2/$($mask)") >$null
                $str = long2ip($addrl[$pos-1] -shl $(32-$mask))
                $cidrlist.Add("$str/$($mask-1)") >$null
                $pos = $pos-2
            } else {
                $pos--
            }
		}
		$mask--
	}
    return $cidrlist | Sort-Object
}
