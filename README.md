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
**Description**
*Return a netmask string if given an integer between 0 and 32.*
**Usage:**
```CIDRtoMask(22);```
**Result:**
```string "255.255.252.0"```
**Input parameter type:**
```[int] $int Between 0 and 32.```
**Return parameter type:**
```[string] Netmask ip address```

### method maskToCIDR
**Description**
*Return a netmask string if given an integer between 0 and 32.*
**Usage:**
```maskToCIDR('255.255.252.0');```
**Result:**
```[int] 22```
**Input parameter type:**
```[string] $netmask IPv4 formatted ip address.```
**Return parameter type:**
```[int] between 0 and 32.```

### method countSetBits.
**Description**
*Return the number of bits that are set in an integer.
see [Hamming Weight](http://stackoverflow.com/questions/109023/best-algorithm-to-count-the-number-of-set-bits-in-a-32-bit-integer) algorithm*
**Usage:**
```countSetBits(ip2long('255.255.252.0'));```
**Result:**
```int(22)```
**Input parameter type:**
```[int] $int a number.```
**Return parameter type:**
```[int] number of bits set.```

### method validNetMask.
**Description**
*Determine if a string is a valid netmask.*
**Usage:**
```validNetMask('255.255.252.0');```
```validNetMask('127.0.0.1');```
**Result:**
```bool(true)```
```bool(false)```
**Input parameter type:**
```[string] $netmask IPv4 formatted ip address.```
**Return parameter type:**
```[bool] True if a valid netmask.```

### method alignedCIDR.
**Description**
*It takes an ip address and a netmask and returns a valid CIDR block.*
**Usage:**
```alignedCIDR('127.0.0.1','255.255.252.0');```
**Result:**
     string(12) "127.0.0.0/22"
**Input parameter type:**
```[string] $ipinput IPv4 formatted ip address.```
```[string] $netmask IPv4 formatted ip address.```
**Return parameter type:**
```[string] CIDR block.```

### method IPisWithinCIDR.
**Description**
*Check whether an IP is within a CIDR block.*
**Usage:**
```IPisWithinCIDR('127.0.0.33','127.0.0.1/24');```
```IPisWithinCIDR('127.0.0.33','127.0.0.1/27');```
**Result:**
```bool(true)```
```bool(false)```
**Input parameter type:**
```[string] $ipinput IPv4 formatted ip address.```
```[string] $cidr IPv4 formatted CIDR block. Block is aligned  during execution.```
**Return parameter type:**
```[string] CIDR block.```

### method maxBlock.
**Description**
*Determines the largest CIDR block that an IP address will fit into. Used to develop a list of CIDR blocks.*
**Usage:**
```maxBlock("127.0.0.1");```
```maxBlock("127.0.0.0");```
**Result:**
```int(32)```
```int(8)```
**Input parameter type:**
```[string] $ipinput IPv4 formatted ip address.```
**Return parameter type:**
```[int] CIDR number.```

### method rangeToCIDRList.
**Description**
*Returns an array of CIDR blocks that fit into a specified range of IP addresses.*
**Usage:**
```rangeToCIDRList("127.0.0.1","127.0.0.34");```
**Result:**
```"127.0.0.1/32"```
```"127.0.0.2/31"```
```"127.0.0.4/30"```
```"127.0.0.8/29"```
```"127.0.0.16/28"```
```"127.0.0.32/31"```
```"127.0.0.34/32"```
**Input parameter type:**
```[string] IPv4 ip address.```
```[string] $ipEnd a IPv4 ip address.```
**Return parameter type:**
``` @[string] Array CIDR blocks in a numbered array.```

### method cidrToRange.
**Description**
*Returns an array of only two IPv4 addresses that have the lowest IP address as the first entry. If you need to check to see if an IPv4 address is within range please use the IPisWithinCIDR method above.*
**Usage:**
```cidrToRange("127.0.0.128/25");```
**Result:**
```"127.0.0.128"```
```"127.0.0.255"```
**Input parameter type:**
```[string] $cidr CIDR block.```
**Return parameter type:**
```@[string] Array low end of range then high end of range.```

### method cidrDevider.
**Description**
*Returns an array of splited IPv4 networks.*
**Usage:**
```cidrDevider("127.0.0.0/23", 24);```
**Result:**
```"127.0.0.0/24"```
```"127.0.1.0/24"```
**Input parameter type:**
```[string] $cidr CIDR block```
```[int] $dstprefix result prefix```
**Return parameter type:**
```@[string] Array of splited networks.```

### method getIpInfo
**Description**
*Return info about IPv4 network/address.*
**Usage:**
```resolveASN("8.8.8.0/24");```
```resolveASN("8.8.8.8");```
**Result:**
```announced       : True```
```as_country_code : US```
```as_description  : GOOGLE - Google Inc.```
```as_number       : 15169```
```first_ip        : 8.8.8.0```
```ip              : 8.8.8.8```
```last_ip         : 8.8.8.255```
**Input parameter type:**
```[string] $cidr CIDR block or IPv4 Address```
**Return parameter type:**
```[object] object with fields - announced, as_country_code, as_description, as_number, first_ip,ip, last_ip.```

### method resolveASN.
**Description**
*Returns an ASN number from IPv4 network/address.*
**Usage:**
```resolveASN("8.8.8.0/24");```
**Result:**
```"15169"```
**Input parameter type:**
```[string] $cidr CIDR block or IPv4 Address.```
**Return parameter type:**
```[int] ASN Number.```

### method resolveCountry.
**Description**
*Returns an Country Code from IPv4 network/address.*
**Usage:**
```resolveASN("8.8.8.0/24");```
**Result:**
```"US"```
**Input parameter type:**
```[string] $cidr CIDR block or IPv4 Address.```
**Return parameter type:**
```[string] Country Code.```

### method CIDRsummarize.
**Description**
*Returns an Summarised IPv4 network.*
**Usage:**
```resolveASN(@("8.8.0.0/23","8.8.2.0/23","8.8.9.0/24","8.8.8.0/24"));```
**Result:**
```"8.8.0.0/22"```
```"8.8.8.0/23"```
**Input parameter type:**
```@[string] $cidr array of IPv4 CIDR block```
**Return parameter type:**
```@[string] array of Summarized CIDR blocks.```

