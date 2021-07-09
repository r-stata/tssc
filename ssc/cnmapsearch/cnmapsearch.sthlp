{smcl}
{* 20Dec2018}{...}
{hi:help cnmapsearch}
{hline}

{title:Title}

{phang}
{bf:cnmapsearch} {hline 2} This Stata module helps to extract the specified information by keyword in a certain geographic range.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:cnmapsearch}{cmd:,} baidukey(string) latitude(varname) longitude(varname) keyword(string) [{it:options}]

Extracts the information that is searched by keyword in a certain circular range.


{marker description}{...}
{title:Description}

{pstd}
Baidu Map API is widely used in China.
{cmd:cnmapsearch} use Baidu Map API to extract the specified information by keyword around the specified location.
The keyword and the size of range could be specified by users.
Before using this command, a Baidu secret key from Baidu Map API is needed. 
A typical Baidu secret key is an alphanumeric string. 
The option baidukey(string) is actually not optional. 
If you have a Baidu key, which is, say CH8eakl6UTlEb1OakeWYvofh, the baidukey option must be specified as baidukey(CH8eakl6UTlEb1OakeWYvofh). 
You can get a secret key from Baidu Map open platform (http://lbsyun.baidu.com). 
The process normally will take 3-5 days after you submit your application online.
There are some information can be extracted when using {cmd:cnmapsearch}.
(1) The name of the place in the searching range.
(2) The address and latitude & longitude of the place.
(3) The telephone number of the place if it has.
(4) If this place is a hotel or a restaurant, command can provide the score of service quality.{p_end}

{pstd}
{cmd:cnmapsearch} require Stata version 14 or higher. {p_end}

{marker options}{...}
{title:Options for cnmapsearch}

{dlgtab:Credentials(required)}

{phang}
{opt baidukey(string)} is required before using this command. 
You can get a secret key from Baidumap open platform(http://lbsyun.baidu.com). 
The process normally will take 3-5 days after you submit your application online.
{p_end}


{phang}
{opt latitude(varname)} & {opt longitude(varname)} is required when users using this command. This option specify the longitude and latitude of the address.
Further more, it determines the center of searching circle and command searches the relevant information users specified within this circle.
{p_end}


{phang}
{opt keyword(string)} is required to search relational infomation in Baidumap. Please input the keyword as accurate as possible.
{p_end}

{dlgtab:Search options}

{phang}
{opt number(int)} determines that how many objects will be extract, the range of {opt number} is 1-20. The default is 10.
{p_end}

{phang} 
{opt radius(int)} can specify the radius of circle that is used in searching relevant objects.
{p_end}

{phang} 
{opt filter(string)} can adjust the preference of searching so that users can extract more accurate information.
The syntax of this option is {opt filter(category preference)}. 
There are three kinds of {opt category}: cater, hotal and life. 
Users can input different {opt preference} in different {opt category}.
The specified {opt category} could narrow the range of searching so that it can improve the accuracy of searching.
{p_end}
{phang}
When the {opt category} is cater, there are five types of {opt preference} can be selected:
{p_end}
{pmore}
{opt distance}: sorting by distance, from close to distant.
{p_end}
{pmore}
{opt price}: sorting by price, from lowest to highest.
{p_end}
{pmore}
{opt overall_rating}: sorting by the score that customers give from Internet.
{p_end}
{pmore}
{opt taste_rating}: sorting by the score that taste of food.
{p_end}
{pmore}
{opt service_rating}: sorting by the quality of service.
{p_end}
{phang}
When the {opt category} is life, there are four types of {opt preference} can be selected:
{p_end}
{pmore}
{opt distance}, {opt price} and {opt overall_rating} had been listed before.
{p_end}
{pmore}
{opt comment_rating}: sorting by the number of comment about this place.
{p_end}
{phang}
When the {opt category} is hotel, there are five types of {opt preference} can be selected:{p_end}
{pmore}
{opt distance} and {opt price} had been listed before.
{p_end}
{pmore}
{opt total_score} is equal to {opt overall_rating}.
{p_end}
{pmore}
{opt level} sorting by the level of hotel.
{p_end}
{pmore}
{opt health_score} sorting by the quality of hygienic condition.
{p_end}

{dlgtab:Respondent preference}

{phang}
{opt seefilter:} can extract the information in the option {opt filter(string)} used in this searching automatically.
{p_end}

{phang}
{opt prefix(string)} add a specified prefix of variable name.
{p_end}

{phang}
{opt result(varlist):} When you do not need all variables. By using {opt: result}, the user can specify a list of variables that will eventually be returned.
These are all variables that are available for return: "name lat lng address province city area telephone tag detail_url distance overall_rating service_rating environment_rating hygiene_rating facility_rating".
The default is result(name address telephone tag distance).
{p_end}

{marker example}{...}
{title:Example}

{pstd}
Input the longitude and latitude of the address

{phang}
{stata `"clear"'}
{p_end}
{phang}
{stata `"input double lat double lng"'}
{p_end}
{phang}
{stata `"30.50695 114.38494"'}
{p_end}
{phang}
{stata `"30.54414 114.36921"'}
{p_end}
{phang}
{stata `"30.43655 114.42726"'}
{p_end}
{phang}
{stata `"end"'} 
{p_end}

{pstd}
Change the radius of searching range and extracts the information of object.

{phang}
{stata `"cnmapsearch, baidukey(your secret key) latitude(lat) longitude(lng) keyword("酒") radius(4000) seefilter"'}
{p_end}

{phang}
{stata `"list"'}
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
