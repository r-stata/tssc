{smcl}
{* 26Sep2017}{...}
{hi:help chinagcode}
{hline}

{title:Title}

{phang}
{bf:chinagcode} {hline 2} Baidu Map API is widely used in China. This Stata module helps to extract longitude and latitude for a given Chinese address from Baidu Map API(http://api.map.baidu.com)


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:chinagcode}{cmd:,} baidukey(string) [{it:options}]

Extracts the longitude and latitude of Chinese address from Baidu Map API

{p 8 17 2}
{cmdab:chinaaddress}{cmd:,} baidukey(string) lat(varname) long(varname) [{it:options}]

chinaaddress is the inverse command for chinagcode. It converts a location (pair of longitude and latitude) into the corresponding address in Chinese with Baidu Map API

{marker description}{...}
{title:Description}

{pstd}
{cmd:chinagcode} uses Baidu Map API to extract longitude and latitude of Chinese address. However, 
a Baidu secret key from Baidu Map API is needed upon using this command. A typical Baidu secret key 
is an alphanumeric string. The option baidukey(string) is actually not optional. If you have a Baidu 
key, which is, say CH8eakl6UTlEb1OakeWYvofh, the baidukey option must be specified as 
baidukey(CH8eakl6UTlEb1OakeWYvofh). You can get a secret key from Baidu Map open 
platform(http://lbsyun.baidu.com). The process normally will take 3-5 days after you submit your 
application online. When using chinagcode to map a Chinese address to a longitude and latitude location, 
users can specify the address with two ways. First, combination address. With this mode, users can specify 
the Chinese address with a combination of information including province, city, district and if possible, 
an address. Secondly, full address, in which the user specify a full address which encompasses the 
information on province and city into a single line of address. Users can also specify both, however, 
if both addresses are used, chinagcode will pick the one which can yield a location. If both can yield 
locations, the default choice is to use the location yield from the combination address. But users can 
change this priority with ffirst option, which will return the location from the full address if the 
location of full address and combination address are different. {p_end}

{pstd}
{cmd:chinaaddress} uses Baidu Map API to extract Chinese address of the location defined by longitude 
and latitude. Again, users need to get a secret key from Baidu Map open platform, and input it with 
the baidukey() option. You will get province, city, district, street, full address and a sematic 
description of the location defined by longitude and latitude. {p_end}

{pstd}
Both {cmd:chinagcode} and {cmd:chinaaddress} require Stata version 14 or higher. {p_end}

{marker options}{...}
{title:Options for chinagcode}

{dlgtab:Credentials(required)}

{phang}
{opt baidukey(string)} is required before using this command. You can get a secret key from Baidumap open platform(http://lbsyun.baidu.com). The process normally will take 3-5 days after you submit your application online. {p_end}


{dlgtab:Address}

{phang}
{opt pro:vince(varname)} specifies the string variable that contains the name of province. {p_end}

{phang}
{opt cit:y(varname)} specifies the string variable that contains the name of city. {p_end}

{phang}
{opt dis:trict(varname)} specifies the string variable that contains the name of district. {p_end}

{phang}
{opt add:ress(varname)} specifies the string variable that contains the address. {p_end}

{phang}
{opt fulladd:ress(varname)} specifies the string variable that contains the full address. {p_end}


{dlgtab:Response switches}

{phang}
{opt lat:itude(newvar)} is required when you want to specify the name of the variable that contains latitude. Default choice is longitude. {p_end}

{phang}
{opt long:itude(newvar)} is required when you want to specify the name of the variable that contains longitude. Default choice is latitude. {p_end}

{phang}
{opt ffirst:} If the location yield from the combination address is different from the return location from the full address, {opt ffirst} specifies that the location from the full location is a first priority.
 {p_end}


{title:Options for chinaaddress}


{dlgtab:Credentials(required)}

{phang}
{opt baidukey(string)} is required before you use this command. You can get a secret key from Baidumap open platform(http://lbsyun.baidu.com). The process normally will take 3-5 days after you submit your application online. {p_end}


{dlgtab:Location(required)}

{phang}
{opt lat:itude(varname)} specifies the numeric variable that contains latitude. {p_end}

{phang}
{opt long:itude(varname)} specifies the numeric variable that contains longitude. {p_end}


{dlgtab:Response switches}

{phang}
{opt pro:vince(newvar)} is required when you want to specify the name of the variable that contains the name of province. {p_end}

{phang}
{opt cit:y(newvar)} is required when you want to specify the name of the variable that contains the name of city. {p_end}

{phang}
{opt dis:trict(newvar)} is required when you want to specify the name of the variable that contains the name of district. {p_end}

{phang}
{opt str:eet(newvar)} is required when you want to specify the name of the variable that contains the name of street. {p_end}

{phang}
{opt add:ress(newvar)} is required when you want to specify the name of the variable that contains the full address. {p_end}

{phang}
{opt des:cription(newvar)} is required when you want to specify the name of the variable that contains the sematic description of the location from Baidu Map. {p_end}



{marker example}{...}
{title:Example}

{pstd}
Input the address

{phang}
{stata `"clear"'}
{p_end}
{phang}
{stata `"set more off"'}
{p_end}
{phang}
{stata `"input str15 prov str15 city str15 dist str60 addr str100 fulladdress"'}
{p_end}
{phang}
{stata `""湖北省" "武汉市" "" "南湖大道中南财经政法大学" """'}
{p_end}
{phang}
{stata `""" "北京市" "海淀区" "北京大学" "湖北省武汉市南湖大道中南财经政法大学""'}
{p_end}
{phang}
{stata `""" "" "" "" "北京市海淀区北京大学""'}
{p_end}
{phang}
{stata `"end"'} 
{p_end}

{pstd}
extracts longitude and latitude of the combination of province, city, district and address

{phang}
{stata `"chinagcode, baidukey(your secret key) province(prov) city(city) district(dist) address(addr)"'}
{p_end}
{phang}
{stata `"list prov - addr longitude latitude"'}
{p_end}


{pstd}
extracts longitude and latitude of fulladdress

{phang}
{stata `"chinagcode, baidukey(your secret key) fulladdress(fulladdress) lat(lat1) long(long1)"'}
{p_end}
{phang}
{stata `"list fulladdress long1 lat1"'}
{p_end}


{pstd}
When you specify both province/city/district/address and fulladdress, 
you will first get longitude and latitude from the combination of province, 
city, district, address. Afterwards for those observations that can not 
extract longitude and latitude, you will get them from full address mode.

{phang}
{stata `"chinagcode, baidukey(your secret key) province(prov) city(city) district(dist) address(addr) fulladdress(fulladdress) lat(lat2) long(long2)"'}
{p_end}
{phang}
{stata `"list prov - fulladdress long2 lat2"'}
{p_end}


{phang}
{stata `"chinagcode, baidukey(your secret key) province(prov) city(city) district(dist) address(addr) fulladdress(fulladdress) lat(lat3) long(long3) ffirst"'} 
{p_end}
{phang}
{stata `"list prov - fulladdress long3 lat3"'} 
{p_end}


{pstd}
extract Chinese address of location defined by longitude and latitude

{phang}
{stata `"keep long3 lat3"'} 
{p_end}
{phang}
{stata `"chinaaddress, baidukey(your secret key) lat(lat3) long(long3)"'} 
{p_end}
{phang}
{stata `"list"'} 
{p_end}



{title:Author}

{pstd}Chuntao LI{p_end}
{pstd}China Stata Club(爬虫俱乐部){p_end}
{pstd}Wuhan, China{p_end}
{pstd}chtl@zuel.edu.cn{p_end}

{pstd}Yuan XUE{p_end}
{pstd}China Stata Club(爬虫俱乐部){p_end}
{pstd}Wuhan, China{p_end}
{pstd}xueyuan19920310@163.com{p_end}


