{smcl}
{* version 1.0.0 14december2012}{...}
{hline}
help for {hi:preparation}
{hline}

{title:Title}

{pstd}{hi:preparation} {hline 2} module which allows an one-by-one observation of varlist to make it easier to control data and labels or just to have a closer look at it.


{title:Syntax}

{pstd}{cmd:preparation} [{it:varlist}] [{cmd:,} {opt num:labels} {opt str:ings} {opt nom:iss} {opt lim:it(numlist)}] 


{title:Description}

{phang}Preparation loops through all variables in the varlist and displays a table of contents of each of those variable. Since display of the output breaks after each variable this script makes it easier to control data and labels of the dataset or just to take a closer look at data. The ado also automatically leaves out string variables and displays missing values. Both options can be switched on and off of course. Furthermore it allows to leave out variables which consist of more than a user defined number of rows.{p_end}


{title:Options}

{phang} {cmdab:num:labels} temporarily adds numlabels to the output of each of the variables.{p_end}
{phang} {cmdab:str:ings} By default string variables become omitted. By choosing the strings option string variables will be included again.{p_end}
{phang} {cmdab:nom:iss} By default missing values are display. Choosing this option will hide them.{p_end}
{phang} {cmdab:lim:it(numlist)} Do not want lengthy variables? Add a numlist with the limit options and only variables with a lower equal number of rows will be displayed.{p_end}


{title:Acknowledgement}

{phang}The page clearing part of the ado is based on {browse "http://www.stata.com/statalist/archive/2005-12/msg00147.html":Nick J. Cox code on Statalist.}{p_end}


{title:Author}

{pstd} Johannes N. Blumenberg{break}
University of Mainz (Germany){break} 
Department of Political Science{break} 
Methods of Empirical Political Science{break}
blumenberg@politik.uni-mainz.de{p_end}

