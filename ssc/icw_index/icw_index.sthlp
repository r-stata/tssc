{smcl}
{* *!version 1.1.0 07/08/2020}{...}
{cmd:help index}
{hline}
{title:Title}

{phang}
{bf:icw_index} {hline 2} aggregates the variables included in the varlist into an index. 




{title:Syntax}
{p 8 17 3}
{cmdab:index}
 {varlist} , option


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opth gen:erate(name)}} gen a new variable that contains the index. {p_end} 


{title:Description}

{pstd}
 {cmd:icw_index } creates an index from a list of variables included in varlist. icw_index stands for inverse covariance index and follows Anderson (2008). Importantly, variables in varlist must be standardized and centered before running the command. 
 Following Anderson, the index is calculated from the inverse covariance matrix. As suggested, we use the inverse covariance matrix of non-missing observations. 
 In case of missing data, we calculate for each pattern of missing observation a specific covariance matrix. {p_end} 
 {pstd}
 Beware that if varlist contains lots of missing values (or rather if each observation has a specific pattern of missing values) the code can take a long time as the number of potential combinaison can be exponential.  For instance, an index composed of 5 variables has max 31 combinations but an index of 10 1023. Typically when your varlist is composed of more than 10 vairables it could be useful to verify if your missing values are equally spread out (if every observation has the same number of missing values) or if each observation have a unique missing pattern. In the latter case, the code can take a long time.  
 

	
{title:Examples}

{phang}
Create an index GPA from grades in math economics and biology: {break}
{cmd:. index math economics and biology, gen(GPA)}

{title:Author}
{pstd}

Adrien Bouguen, Santa Clara University {break} 
Tereza Varejkova, University of Maryland


{title:References}
{pstd}
Michael L. Anderson Multiple Inference and Gender Differences in the Effects of Early Intervention: AReevaluation of the Abecedarian, Perry Preschool, and Early Training Projects Journal of the American Statistical Association, Vol. 103, No. 484 (Dec., 2008), pp.1481-1495

