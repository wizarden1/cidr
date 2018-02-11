# CIDR Library for Powershell
This library was build based on CIDR.php by Jonavon Wilcox <jowilcox@vt.edu> Thanks to him.
Some functions was converted from PHP, some was written from scratch.

## Function List
- *CIDRtoMask* - convert subnet mask view. From "/24" to "255.255.255.0"
- *maskToCIDR* - convert subnet mask view. From "255.255.255.0" to "/24"
- *countSetBits* - check how many bit set
- *validNetMask* - test correct or not subnet mask in form "255.255.255.0"
- *alignedCIDR* - convert IP + subnet mask to CIDR format "127.0.0.0" "255.255.255.0" > "127.0.0.0/24"
- *IPisWithinCIDR* - check if IP in CIDR block
- *maxBlock* - return largest CIDR block for entered IP
- *rangeToCIDRList* - convert range to CIDR. "127.0.0.0" "127.0.0.255" > "127.0.0.0/24"
- *cidrToRange* - convert CIDR to range. "127.0.0.0/24" > "127.0.0.0" "127.0.0.255"
- *cidrDevider* - split CIDR to smallest CIDR blocks
- *getIpInfo* - return some information about IP, like: Announced, Country Code, ASN Description, ASN, Range
- *resolveASN* - Return ASN for IP
- *resolveCountry* - Return Country Code for IP
- *CIDRsummarize* - Aggregate routes. "127.0.0.0/24,127.0.1.0/24" > "127.0.0.0/23"

## Function usage in details
### method CIDRtoMask
**Description**<br/>
*Return a netmask string if given an integer between 0 and 32.*<br/>
**Usage:**<br/>
```CIDRtoMask(22);```<br/>
**Result:**<br/>
```"255.255.252.0"```<br/>
**Input parameter type:**<br/>
```[int] $int Between 0 and 32.```<br/>
**Return parameter type:**<br/>
```[string] Netmask ip address```<br/>

### method maskToCIDR
**Description**<br/>
*Return a netmask string if given an integer between 0 and 32.*<br/>
**Usage:**<br/>
```maskToCIDR('255.255.252.0');```<br/>
**Result:**<br/>
```[int] 22```<br/>
**Input parameter type:**<br/>
```[string] $netmask IPv4 formatted ip address.```<br/>
**Return parameter type:**<br/>
```[int] between 0 and 32.```<br/>

### method countSetBits.
**Description**<br/>
*Return the number of bits that are set in an integer.<br/>
see [Hamming Weight](http://stackoverflow.com/questions/109023/best-algorithm-to-count-the-number-of-set-bits-in-a-32-bit-integer) algorithm*<br/>
**Usage:**<br/>
```countSetBits(ip2long('255.255.252.0'));```<br/>
**Result:**<br/>
```22```<br/>
**Input parameter type:**<br/>
```[int] $int a number.```<br/>
**Return parameter type:**<br/>
```[int] number of bits set.```<br/>

### method validNetMask.
**Description**<br/>
*Determine if a string is a valid netmask.*<br/>
**Usage:**<br/>
```validNetMask('255.255.252.0');```<br/>
```validNetMask('127.0.0.1');```<br/>
**Result:**<br/>
```$true```<br/>
```$false```<br/>
**Input parameter type:**<br/>
```[string] $netmask IPv4 formatted ip address.```<br/>
**Return parameter type:**<br/>
```[bool] True if a valid netmask.```<br/>

### method alignedCIDR.
**Description**<br/>
*It takes an ip address and a netmask and returns a valid CIDR block.*<br/>
**Usage:**<br/>
```alignedCIDR('127.0.0.1','255.255.252.0');```<br/>
**Result:**<br/>
```[string] "127.0.0.0/22"```<br/>
**Input parameter type:**<br/>
```[string] $ipinput IPv4 formatted ip address.```<br/>
```[string] $netmask IPv4 formatted ip address.```<br/>
**Return parameter type:**
```[string] CIDR block.```

### method IPisWithinCIDR.
**Description**<br/>
*Check whether an IP is within a CIDR block.*<br/>
**Usage:**<br/>
```IPisWithinCIDR('127.0.0.33','127.0.0.1/24');```<br/>
```IPisWithinCIDR('127.0.0.33','127.0.0.1/27');```<br/>
**Result:**<br/>
```$true```<br/>
```$false```<br/>
**Input parameter type:**<br/>
```[string] $ipinput IPv4 formatted ip address.```<br/>
```[string] $cidr IPv4 formatted CIDR block. Block is aligned  during execution.```<br/>
**Return parameter type:**<br/>
```[bool] True if IP in CIDR block.```<br/>

### method maxBlock.
**Description**<br/>
*Determines the largest CIDR block that an IP address will fit into. Used to develop a list of CIDR blocks.*<br/>
**Usage:**<br/>
```maxBlock("127.0.0.1");```<br/>
```maxBlock("127.0.0.0");```<br/>
**Result:**<br/>
```32```<br/>
```8```<br/>
**Input parameter type:**<br/>
```[string] $ipinput IPv4 formatted ip address.```<br/>
**Return parameter type:**<br/>
```[int] CIDR number.```<br/>

### method rangeToCIDRList.
**Description**<br/>
*Returns an array of CIDR blocks that fit into a specified range of IP addresses.*<br/>
**Usage:**<br/>
```rangeToCIDRList("127.0.0.1","127.0.0.34");```<br/>
**Result:**<br/>
```"127.0.0.1/32"```<br/>
```"127.0.0.2/31"```<br/>
```"127.0.0.4/30"```<br/>
```"127.0.0.8/29"```<br/>
```"127.0.0.16/28"```<br/>
```"127.0.0.32/31"```<br/>
```"127.0.0.34/32"```<br/>
**Input parameter type:**<br/>
```[string] IPv4 ip address.```<br/>
```[string] $ipEnd a IPv4 ip address.```<br/>
**Return parameter type:**<br/>
``` @[string] Array CIDR blocks in a numbered array.```<br/>

### method cidrToRange.
**Description**<br/>
*Returns an array of only two IPv4 addresses that have the lowest IP address as the first entry. If you need to check to see if an IPv4 address is within range please use the IPisWithinCIDR method above.*<br/>
**Usage:**<br/>
```cidrToRange("127.0.0.128/25");```<br/>
**Result:**<br/>
```"127.0.0.128"```<br/>
```"127.0.0.255"```<br/>
**Input parameter type:**<br/>
```[string] $cidr CIDR block.```<br/>
**Return parameter type:**<br/>
```@[string] Array low end of range then high end of range.```<br/>

### method cidrDevider.
**Description**<br/>
*Returns an array of splited IPv4 networks.*<br/>
**Usage:**<br/>
```cidrDevider("127.0.0.0/23", 24);```<br/>
**Result:**<br/>
```"127.0.0.0/24"```<br/>
```"127.0.1.0/24"```<br/>
**Input parameter type:**<br/>
```[string] $cidr CIDR block```<br/>
```[int] $dstprefix result prefix```<br/>
**Return parameter type:**<br/>
```@[string] Array of splited networks.```<br/>

### method getIpInfo
**Description**<br/>
*Return info about IPv4 network/address.*<br/>
**Usage:**<br/>
```resolveASN("8.8.8.0/24");```<br/>
```resolveASN("8.8.8.8");```<br/>
**Result:**<br/>
```announced       : True```<br/>
```as_country_code : US```<br/>
```as_description  : GOOGLE - Google Inc.```<br/>
```as_number       : 15169```<br/>
```first_ip        : 8.8.8.0```<br/>
```ip              : 8.8.8.8```<br/>
```last_ip         : 8.8.8.255```<br/>
**Input parameter type:**<br/>
```[string] $cidr CIDR block or IPv4 Address```<br/>
**Return parameter type:**<br/>
```[object] object with fields - announced, as_country_code, as_description, as_number, first_ip,ip, last_ip.```<br/>

### method resolveASN.
**Description**<br/>
*Returns an ASN number from IPv4 network/address.*<br/>
**Usage:**<br/>
```resolveASN("8.8.8.0/24");```<br/>
**Result:**<br/>
```"15169"```<br/>
**Input parameter type:**<br/>
```[string] $cidr CIDR block or IPv4 Address.```<br/>
**Return parameter type:**<br/>
```[int] ASN Number.```<br/>

### method resolveCountry.
**Description**<br/>
*Returns an Country Code from IPv4 network/address.*<br/>
**Usage:**<br/>
```resolveASN("8.8.8.0/24");```<br/>
**Result:**<br/>
```"US"```<br/>
**Input parameter type:**<br/>
```[string] $cidr CIDR block or IPv4 Address.```<br/>
**Return parameter type:**<br/>
```[string] Country Code.```<br/>

### method CIDRsummarize.
**Description**<br/>
*Returns an Summarised IPv4 network.*<br/>
**Usage:**<br/>
```resolveASN(@("8.8.0.0/23","8.8.2.0/23","8.8.9.0/24","8.8.8.0/24"));```<br/>
**Result:**<br/>
```"8.8.0.0/22"```<br/>
```"8.8.8.0/23"```<br/>
**Input parameter type:**<br/>
```@[string] $cidr array of IPv4 CIDR block```<br/>
**Return parameter type:**<br/>
```@[string] array of Summarized CIDR blocks.```<br/>
