{smcl}
{* 02apr2015}{...}
{* version 1.0}{...}
{viewerjumpto "Syntax" "speedergles##syn"}{...}
{viewerjumpto "Options" "speedergles##opt"}{...}
{viewerjumpto "Description" "speedergles##des"}{...}
{viewerjumpto "Examples" "speedergles##exa"}{...}
{viewerjumpto "References" "speedergles##ref"}{...}
{viewerjumpto "Author" "speedergles##aut"}{...}
{viewerjumpto "Acknowledgments" "speedergles##ack"}{...}

{title:Title}

{p 4 4 2}{hi:speedergles} {hline 2} Computation of the GLES response speed index

{marker syn}	
{title:Syntax}

{p 8 8 2}{cmd:speedergles} {it:{help varlist:varlist}} [{it:{help if:if} exp}] [{it:{help in:in} range}]
[{it:, }{it:{help uas##opt:options}}]

{p 4 8 2}where {it:{help varlist:varlist}} is a list of numeric response time 
variables. 

{synoptset 21 tabbed}{...}
{marker opt}
{synopthdr}
{synoptline}
{syntab:Required}
{synopt :{opth dur:ation(varname)}}variable containing the interview duration{p_end}
{synopt :{opth index:name(newvar)}}generates a variable for the GLES response speed index{p_end}
{synopt :{opth flag:name(newvar)}}generates a flag variable for speeding respondents 
(i.e., respondents in the lowest decile of the response speed index){p_end}
{syntab:Optional}
{synopt :{opth miss:ing(numlist)}}list of missing values in response time and/or duration variables {p_end}
{synopt :{opt qui:etly}}suppresses the output of additional descriptives{p_end}
{synoptline}
{p2colreset}{...}

{marker des}
{title:Description}

{p 4 4 2} The {cmd:speedergles} command computes the response speed index of 
the German Longitudinal Election Study (GLES) developed by Roﬂmann (2012). The 
GLES response speed index is computed on the basis of question block, page or item 
level response times and the overall interview duration. The index values can be 
interpreted as a measure of the mean response speed of a respondent. 
An index value of 1 is equivalent to the mean of the respondents¥ mean response 
speed in the selected sample of respondents. Index values close to 0 indicate a 
very fast mean response speed, whereas values close to 2 indicate a very 
slow mean response speed. 

{p 4 4 2} The response times variables specified in {it:{help varlist:varlist}} are 
preferably question block, page or item level measures. Ideally, response times 
are measured on the item level, have a high resolution (s or ms), and are 
available for every item in the survey. 

{marker exa}
{title:Examples}

{p 4 4 2} Noisily computing the response speed index with data from  
the GLES Long-term Online Tracking, T25 (ZA5725) for respondents who completed 
the interview. 

	{com}. speedergles zstart-zende if compl==1, dur(duration) index(speederindex) 
	{com}flag(speederflag)
	{txt}

{p 4 4 2} Quietly computing the response speed index with scientific 
use file data from the GLES Saxony state election survey (ZA5738).

	{com}. speedergles zstart-zende, dur(duration) index(speederindex) 
	{com}flag(speederflag) quietly
	{txt}

{p 4 4 2} Quietly computing the response speed index with data from wave 2 
of the GLES Short-term Campaign Panel(ZA5704). The values -99 and 0 in the 
response time and duration variables are set to missing. 

	{com}. speedergles T_kp2_Startseite-T_kp2_4270s if w2b==1, dur(duration) 
	{com}index(speederindex) flag(speederflag) miss(-99 0) quietly
	{txt}
	
{marker ref}
{title:References}

{p 4 8 2} Roﬂmann, J. (2012): Zeitunterschreiter in Web-Befragungen der GLES: 
Messung und Bedeutung f¸r die Identifikation von Satisficern. [Speeding 
respondents in web surveys of the GLES: Measurement and implications for 
the identification of satisficing respondents.] Unpublished paper. 

{marker aut}
{title:Author}

{p 4 8 2} Joss Roﬂmann, GESIS - Leibniz Institute for the Social Sciences, joss.rossmann@gesis.org 

{p 4 8 2} Recommended citation (APA Style, 6th ed.): {break}
Roﬂmann, J. (2015): SPEEDERGLES: Stata module for the computation 
of the GLES response speed index (Version: 1.0) [Computer Software].
Chestnut Hill, MA: Boston College.

{marker ack}
{title:Acknowledgments}

{p 4 8 2} The author would like to acknowledge the support of GESIS - Leibniz 
Institute for the Social Sciences and the pricipal investigators of the German 
Longitudinal Election Study (GLES) for their support in the creation of this 
Stata module. 

