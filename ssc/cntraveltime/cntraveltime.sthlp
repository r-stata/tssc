{smcl}
{* 20Dec2018}{...}
{hi:help cntraveltime}
{hline}

{title:Title}

{phang}
{bf:cntraveltime} {hline 2} 
This Stata module helps to extract the time needed for traveling between two locations from Baidu Map API(http://api.map.baidu.com).

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:cntraveltime}{cmd:,} baidukey(string) {startlat(varname) startlng(varname) endlat(varname) endlng(varname)} [{it:options}]

Extracts the time spent in traveling and other relevant informations with BaiduMap API, conditional on a given travel mode.


{marker description}{...}
{title:Description}

{pstd}
Baidu Map API is widely used in China.
{cmd:cntraveltime} use Baidu Map API to extract the time traveling from one location to another.
Forthermore, it can also extract the detailed information about the route of traveling and corresponding longitude & latitude of the two locations.
Before using this command, a Baidu key from Baidu Map API is needed.
A typical Baidu key is an alphanumeric string. The option baidukey(string) is actually not optional.
If you have a Baidu key, which is, say CH8eakl6UTlEb1OakeWYvofh, the baidukey option must be specified as baidukey(CH8eakl6UTlEb1OakeWYvofh). 
You can get a secret key from Baidu Map's open platform (http://lbsyun.baidu.com). 
The process normally will take 3-5 days after you submit your application online.
Following information can be extract when using {cmd:cntraveltime}, conditional on the travel mode specified.
(1) time spent from one location to another.
(2) detail information of route chosen.
{p_end}

{pstd}
{cmd:cntraveltime} requires Stata version 14 or higher.
{p_end}

{marker options}{...}
{title:options for cntraveltime}

{dlgtab:Credentials(required)}

{phang}
{opt baidukey(string)} is required before using this command. 
You can get a secret key from Baidumap open platform(http://lbsyun.baidu.com). 
The process normally will take 3-5 days after you submit your application online.
{p_end}

{phang}
{opt startlat(varname)} & {opt startlng(varname)} specify the longitude and latitude of the origin
location.  
{p_end}

{phang}
{opt endlat(varname)} & {opt endlng(varname)} specify the longitude and latitude of the destination
location.
{p_end}

{dlgtab:Search options}

{phang}
{opt instruction:}: If users need detail information about the route chosen, option {opt instruction} helps. The default is not to show this information.
{p_end}

{phang}
{opt transport(string)} can change the travel mode. Based on the assumptions of this choice, BaiduMap will calculate the distance and duration between the specified place.
When the option {opt transport} is empty, the default is "bus". There are three specific options of transport that "car", "bus" and "bike". other input will give an error.
{p_end}

{phang}
{opt intercity(numlist)} can choose the detail preference when the given locations in different cities. This option can only be used when specify "bus" in {opt transport(string)}. 
you can enter two numbers in the option, like intercity(1 2), where the first number represents the priority requirement and the second number specifies the mode of transportation.
If the option is empty, both two numbers are 0.
{p_end}
{pmore}
The first number represents the priority requirement where 0 is "as quickly as possible", 1 is "Start as early as possible" and 2 is "as cheap as possible".
{p_end}
{pmore}
The second number specifies the mode of transportation where 0 is "train", 1 is "plane" and 2 is "bus"
{p_end}

{phang}
{opt tactic(real)} can choose the detail preference when the given locations in same cities. Please note that if the transport content is different, the effective range and meaning of the {opt tactic} are also different.
Enter the number in the option and the preferences represented by different numbers are as follows.
{p_end}
{pmore}
bus 0: default, recommendation
{p_end}
{pmore}
bus 1: Less transfer
{p_end}
{pmore}
bus 2: less walk
{p_end}
{pmore}
bus 3: no subway
{p_end}
{pmore}
bus 4: as quickly as possible
{p_end}
{pmore}
bus 5: subway
{p_end}
{pmore}
car 0: default
{p_end}
{pmore}
car 3: avoid high speed
{p_end}
{pmore}
car 4: high speed priority
{p_end}
{pmore}
car 5: avoid congested sections
{p_end}
{pmore}
car 6: avoiding toll stations
{p_end}
{pmore}
car 7: both 4 and 5
{p_end}
{pmore}
car 8: both 3 and 4
{p_end}
{pmore}
car 9: both 4 and 6
{p_end}
{pmore}
car 10: both 6 and 8 
{p_end}
{pmore}
car 11: both 3 and 6
{p_end}
{pmore}
bike 0: default, common
{p_end}
{pmore}
bike 1: electric bicycle
{p_end}

{marker example}{...}
{title:Example}

{pstd}
Input the address

{phang}
{stata `"clear"'}
{p_end}
{phang}
{stata `"input double startlat double startlng double endlat double endlng"'}
{p_end}
{phang}
{stata `"28.18561 112.95033 39.99775 116.31616"'}
{p_end}
{phang}
{stata `"43.85427 125.30057 28.18561 112.95033"'}
{p_end}
{phang}
{stata `"31.85925 117.21600 33.01379 119.36848"'}
{p_end}
{phang}
{stata `"end"'} 
{p_end}

{pstd}
Extracts the detail information of drving between the two place.

{phang}
{stata `"cntraveltime, baidukey(your secret key) startlat(startlat) startlng(startlng) endlat(endlat) endlng(endlng) transport("car") instruction tactic(4)"'}
{p_end}

{phang}
{stata `"list duration distance "'}
{p_end}


{pstd}
Extracts the detail information by bus between the two place.

{phang}
{stata `"cntraveltime, baidukey(your secret key) startlat(startlat) startlng(startlng) endlat(endlat) endlng(endlng) transport("bus") instruction intercity(1 1) tactic(4)"'}
{p_end}

{phang}
{stata `"list duration distance "'}
{p_end}


{title:Author}

{pstd}Chuntao LI{p_end}
{pstd}China Stata Club(爬虫俱乐部){p_end}
{pstd}Wuhan, China{p_end}
{pstd}chtl@zuel.edu.cn{p_end}

{pstd}Yuan Xue{p_end}
{pstd}China Stata Club(爬虫俱乐部){p_end}
{pstd}Wuhan, China{p_end}
{pstd}xueyuan@hust.edu.cn{p_end}

{pstd}Xueren Zhang{p_end}
{pstd}China Stata Club(爬虫俱乐部){p_end}
{pstd}Wuhan, China{p_end}
{pstd}zhijunzhang_hi@163.com{p_end}

