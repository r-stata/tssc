{smcl}
{* 14July2016}{...}
{hline}
help for {hi:labone}
{hline}

{title:Label varibles}

{cmd:labone } labels the variables (If not specified, varlist defaults to _all) using the contents from the specified rows in the data. 
        It is useful to save detailed information about variables as their labels when importing files (eg.,xls,csv) into Stata. 
{marker syntax}{...}
{title:Syntax}

{p 4 10 2}
{cmd:labone }[{it:varlist}] 
[,{it:options}]

{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}

{synopt :{opt n:row(numlist)}}specify the rows for using their contents to label the variables;if not specified,the first row is used{p_end}
{synopt :{opt c:oncat(concat_strings)}}concatenate the contents from different rows by specified strings; default is to concatenate by blank spaces{p_end}
{synopt :{opt nos:pace}}do not concatenate by spaces {p_end}

{synoptline}
 

{marker examples}{...}
{title:Examples}

{phang}
1.Import an excel file, put the contents in Row 3 of all variables in their labels:

{p 12 16 2}
{cmd:.import excel using http://www.stats.gov.cn/tjsj/ndsj/2014/zk/html/Z0916E.xls,clear}{break}

{p 12 16 2}
{cmd:.labone,nrow(3)}

{phang}
2.Import an excel file, put the contents in Rows 3-4 of variables A, B and C in their labels. The contents from Rows 3 and 4 are concatenated by a blank space:

{p 12 16 2}
{cmd:.import excel using http://www.stats.gov.cn/tjsj/ndsj/2014/zk/html/Z0916E.xls,clear}{break}

{p 12 16 2}
{cmd:.labone A B C,nrow(3 4)}

{phang}
3.Import an excel file, put the contents in Lines 3-4 of variables A, B and C in their labels. The contents from Rows 3 and 4 are directly concatenated without spaces:

{p 12 16 2}
{cmd:.import excel using http://www.stats.gov.cn/tjsj/ndsj/2014/zk/html/Z0916E.xls,clear}{break}

{p 12 16 2}
{cmd:.labone A B C,nrow(3/4)  nospace}


{phang}
4. Import an excel file, put the contents in Rows 5, 3 and 4 of all variables in their labels. The contents from Rows 5, 3 and 4 are concatenated by {cmd:":"} and a blank space£º

{p 12 16 2}
{cmd:.import excel using http://www.stats.gov.cn/tjsj/ndsj/2014/zk/html/Z0916E.xls,clear}{break}

{p 12 16 2}
{cmd:.labone,nrow(5 3 4) concat(:)}

{phang}
5. Import an excel file, put the contents in Rows 5, 3 and 4 of all variables in their labels. The contents from Rows 5, 3 and 4  are concatenated by {cmd:":"} and {cmd:"+"}£º

{p 12 16 2}
{cmd:.import excel using http://www.stats.gov.cn/tjsj/ndsj/2014/zk/html/Z0916E.xls,clear}{break}

{p 12 16 2}
{cmd:.labone,nrow(5 3 4) concat(: +)}


{hline}


{title:Authors}
{phang}
{cmd:Kerry Du}, Center for Economic Research, Shandong University, China.{break}
 E-mail: {browse "mailto:kerrydu@sdu.edu.cn":kerrydu@sdu.edu.cn}. {break}


{title:Also see}
{p 7 14 2}Help:  {help label}, {helpb rename}, {help renvars} (if installed){p_end}
