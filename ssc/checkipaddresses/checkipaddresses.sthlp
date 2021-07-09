{smcl}
{* *! version 1.0.0  08jan2019}{...}
{p2colset 1 13 15 2}{...}
{p2col:{bf:checkipaddresses} {hline 2}}Detects Fraud in Online Surveys by Tracing and Scoring IP Addresses{p_end}
{p2colreset}{...}


{title:Description}

{pstd}
{bf:checkipaddresses} queries an IP address verification service ({browse "https://iphub.info/":iphub.info}) that returns the information on IP addresses, including the internet service provider (ISP) and whether it is likely a server farm being
used to disguise a respondent’s location.

{pstd}{bf:checkipadddresses} takes a list of IP addresses from the current dataset, checks them against iphub.info, 
and creates a dataset (specified with {bf:using}) with the information it returns. This dataset includes the ip (used for merging),
country code, country name, ASN, ISP, block, and hostname. Especially important in this is the variable "block", 
which gives a score indicating whether the IP address is likely from a server farm and therefore 
should be excluded from the data:

{p 8 16 2}{bf:0} {hline 2} Residential or unclassified IP and therefore likely safe{p_end}
{p 8 16 2}{bf:1} {hline 2} Non-residential IP (e.g., hosting provider, proxy, etc.); these should likely be excluded.{p_end}
{p 8 16 2}{bf:2} {hline 2} Non-residential and residential IPs (more stringent, may flag innocent respondents).{p_end}

{p 8 16 2}The recommendation from {it:https://iphub.info/} is to block or exclude those who score block = 1.{p_end}

{pstd}
Users must have an active iphub.info account with a valid X-key.  Free accounts allow up to 1,000 queries per day; more queries are available through paid plans.

{pstd}
For more background on the issue of fraudulent survey respondents and how to deal with them, see 

{p 16 16 5}Burleigh, Tyler, Ryan Kennedy, and Scott Clifford. 2019. 
"How to Screen Out VPS and International Respondents Using Qualtrics: A Protocol (October 12, 2018)." Available at SSRN: {browse "https://ssrn.com/abstract=3265459":https://ssrn.com/abstract=3265459} or 
{browse "http://dx.doi.org/10.2139/ssrn.3265459":http://dx.doi.org/10.2139/ssrn.3265459}.


{title:Syntax}

{p 8 16 2}
{opt checkipaddresses} {varname} {cmd:using} {it:{help filename}} 
{ifin} , {opt xkey(IPHub API key)} [{opt replace} {opt st:ub(varname_stub)} {opt noi:sily} {opt nocomp:ress}]

{title:Options}

{phang}
{it:varname} specifies the variable containing IP addresses for survey respondents.

{phang}
{opt using} {it:filename} specifies the output dataset to contain information on the IP addresses.

{phang}
{opt xkey(IPHub API key)} specifies your iphub API Key. This is not optional.

{phang}
{opt replace} specifies that the output dataset with information on IP addresses should be replaced if it exists.

{phang}
{opt st:ub(varname_stub)} specifies a stub that should be pre-pended to the created variables.  For example, with the option {bf:stub(IP)} the block variable would be named 'IPblock' rather than 'block'.  This can help avoid variable name conflicts with the original dataset.

{phang}
{opt noi:sily} specifies that extra output on the command's progress be displayed.

{phang}
{opt nocomp:ress} specifies that the output dataset {it:not} be compressed to minimize its size. 
The default is to compress the dataset. 
This compression involves a {help preserve} and {help restore} of the dataset in memory, 
so this option can save time for very large datasets.


{title:Examples}

{phang2}{cmd:. checkipaddresses IPAddr using ipinformation.dta , xkey(xxxxxxxxxxxxxxx)}{p_end}
{phang2}{cmd:. merge m:1 IPAddr using ipinformation.dta}{p_end}

{title:Acknowledgement}
{pstd}This program is adapted from the R package rIp, by  Ryan Kennedy, Tyler Burleigh and Scott Clifford.{p_end}


{title:Author}

{pstd}Nicholas J. G. Winter, Department of Politics, University of Virginia, nwinter@virginia.edu{p_end}

