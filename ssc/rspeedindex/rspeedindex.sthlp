{smcl}
{* 24apr2015}{...}
{* version 0.4}{...}
{viewerjumpto "Syntax" "rspeedindex##syn"}{...}
{viewerjumpto "Options" "rspeedindex##opt"}{...}
{viewerjumpto "Description" "rspeedindex##des"}{...}
{viewerjumpto "Examples" "rspeedindex##exa"}{...}
{viewerjumpto "References" "rspeedindex##ref"}{...}
{viewerjumpto "Author" "rspeedindex##aut"}{...}
{viewerjumpto "Acknowledgments" "rspeedindex##ack"}{...}

{title:Title}

{p 4 4 2}{hi:rspeedindex} {hline 2} Computation of a response speed index and outlier identification

{marker syn}	
{title:Syntax}

{p 8 8 2}{cmd:rspeedindex} {it:{help varlist:varlist}} [{it:{help if:if} exp}] [{it:{help in:in} range}]
[{it:, }{it:{help rspeedindex##opt:options}}]

{p 4 8 2}where {it:{help varlist:varlist}} is a list of numeric response time 
variables. 

{synoptset 21 tabbed}{...}
{marker opt}
{synopthdr}
{synoptline}
{syntab:Required}
{synopt :{opth index:name(newvar)}}generates a variable for the response speed index{p_end}
{synopt :{opth flag:name(newvar)}}generates a flag variable for response speed outliers{p_end}
{synopt :{opth cut:offmethod(string)}}defines the method for the identification of response 
speed outliers. It can either be {it:percent}, {it:mean}, or {it:absolute}.{p_end}
{syntab:Optional}
{synopt :{opth lo:wercutoff(numlist)}}defines a lower cutoff for the identification of response 
speed outliers (i.e., fast respondents).
If {opt cutoffmethod} is {it:percent}, cutoff values are percentiles. Valid values are 1, 5, 10, or 25. 
If it is {it:mean}, cutoff values are standard deviations from the mean of the distribution
and have to be in the range of 0 >= x <= 5. 
If it is {it:absolute}, cutoff values are absolute index values and have to be in the range of 0 >= x <= 1.{p_end}
{synopt :{opth up:percutoff(numlist)}}defines an upper cutoff for the identification of response 
speed outliers (i.e., slow respondents).
If {opt cutoffmethod} is {it:percent}, cutoff values are percentiles. Valid values are 75, 90, 95, or 99. 
If it is {it:mean}, cutoff values are standard deviations from the mean of the distribution 
and have to be in the range of 0 >= x <= 5. 
If it is {it:absolute}, cutoff values are absolute index values and have to be in the range of 1 >= x <= 2.{p_end}
{syntab:Optional}
{synopt :{opth miss:ing(numlist)}}list of missing values in response time variables {p_end}
{synopt :{opt qui:etly}}suppresses the output of additional descriptives{p_end}
{synoptline}
{p2colreset}{...}

{marker des}
{title:Description}

{p 4 4 2} The {cmd:rspeedindex} command computes a response speed index on the 
basis of question block, page or item level response times in survey data. 
The index values can be interpreted as a measure of the mean response speed of 
survey respondents. An index value of 1 is equivalent to the mean of the 
respondents´ mean response speed over the variables in {it:{help varlist:varlist}} 
in the selected sample of respondents. Index values close to 0 indicate a very 
fast mean response speed, whereas values close to 2 indicate a very slow mean 
response speed. 

{p 4 4 2} Furthermore, the {cmd:rspeedindex} command generates a variable to flag 
response speed outliers. Thereby, it can be specified whether response speed outliers 
in the lower (i.e., fast respondents), the upper (i.e., slow respondents), or both 
directions are detected. Three different methods to generate cutoff values for the 
identification of response speed outliers are available. These include the use of 
percentiles, standard deviations from the mean of the distribution, and absolute 
values of the response speed index. 

{p 4 4 2} The response times variables specified in {it:{help varlist:varlist}} are 
preferably question block, page or item level measures. Ideally, response times 
are measured on the item level, have a high resolution (s or ms), and are 
available for every item in the survey. 

{marker exa}
{title:Examples}

{p 4 4 2} Quietly computing the response speed index for all respondents on the basis of 
ten response time variables. Respondents in the lower decile of the response speed index
are flagged as response speed outliers. 

	{com}. rspeedindex rtvar1-rtvar10, index(rspeedindex) 
	{com}flag(outlier) cut(percent) lo(10) quietly
	{txt}
	
{p 4 4 2} Quietly computing the response speed index for respondents who completed 
the survey on the basis of thirty response time variables. Respondents with index values 
that are (more than) two standard deviations below or above the mean are flagged as 
response speed outliers. 

	{com}. rspeedindex rtvar1-rtvar30 if complete==1, index(rspeedindex) 
	{com}flag(outlier) cut(mean) lo(2) up(2) quietly
	{txt}

{p 4 4 2} Quietly computing the response speed index for all respondents on the basis of 
a single response time variable. Respondents with index values lower than .5 are 
flagged as response speed outliers. 

	{com}. rspeedindex rtvar1, index(rspeedindex) 
	{com}flag(outlier) cut(absolute) lo(.5) quietly
	{txt}

{marker ref}
{title:References}

{p 4 8 2} Roßmann, J. (2010): Data Quality in Web Surveys of the German 
Longitudinal Election Study 2009. Paper presented at the 3rd ECPR Graduate 
Conference, Dublin, 30.08.-01.09.2010.

{p 4 8 2} Roßmann, J. (2012): Zeitunterschreiter in Web-Befragungen der GLES: 
Messung und Bedeutung für die Identifikation von Satisficern. [Speeding 
respondents in web surveys of the GLES: Measurement and implications for 
the identification of satisficing respondents.] Unpublished paper. 

{marker aut}
{title:Author}

{p 4 8 2} Joss Roßmann, GESIS - Leibniz Institute for the Social Sciences, joss.rossmann@gesis.org 

{p 4 8 2} Recommended citation (APA Style, 6th ed.): {break}
Roßmann, J. (2015): RSPEEDINDEX: Computation of a response speed index and 
outlier identification (Version: 0.4) [Computer Software]. 
Chestnut Hill, MA: Boston College.

{marker ack}
{title:Acknowledgments}

{p 4 8 2} The author would like to acknowledge the support of GESIS - Leibniz 
Institute for the Social Sciences for the support in the creation of this 
Stata module. 

