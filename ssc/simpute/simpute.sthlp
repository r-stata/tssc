{smcl}
{* *! version 1.0 15 Mar 2013}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "simpute##syntax"}{...}
{viewerjumpto "Description" "simpute##description"}{...}
{viewerjumpto "Options" "simpute##options"}{...}
{viewerjumpto "Remarks" "simpute##remarks"}{...}
{viewerjumpto "Examples" "simpute##examples"}{...}
{title:Title}
{phang}
{bf:simpute} {hline 2} Handling missing data in published results: A sensitivity analysis.

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:simpute}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt m:eans(# #)}} specifies the mean of the intervention arm and the mean of the reference arm.{p_end}
{synopt:{opt v:ariances(# #)}}  specifies the two variances in each arm.{p_end}
{synopt:{opt n:s(# #)}} specifies the two sample sizes in each arm.{p_end}
{synopt:{opt p:s(# #)}} specifies the proportion of complete data in each arm.{p_end}
{synopt:{opt r:ange(numlist)}} specifies the range of values to be imputed.{p_end}
{synopt:{opt saving(string)}} specifies to save the graph and its filename.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}
{cmd:simpute} takes the complete-case results from a published trial and looks at the effects of missing data on the results.
The results need to come from a two-arm parallel groups trial and the outcome should be a continuous outcome such as weight.
Missing values are replaced by single values per treatment arm and the test statistic is plotted over the range of imputation values. In the first plot the imputed value is the same for 
both treatment arms whereas in the second plot the imputed values are allowed to differ by arm.
Imputed values of 0 for both treatment arms corresponds to a baseline observation carried forward analysis.

{pstd}
A second set of results is similar to the above but the values imputed come from a normal distribution with arm-specific means and variance fixed at the arm-specific estimates.
This allows for a more realistic value of the test statistic. In the single value imputation the variance becomes smaller as the proportion of missing data increases and hence
will lead to overly precise results.

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt m:eans(# #)} specifies the mean of the intervention arm and the mean of the reference arm.

{phang}
{opt v:ariances(# #)} specifies the two variances in each arm.  

{phang}
{opt n:s(# #)} specifies the two sample sizes in each arm.

{phang}
{opt p:s(# #)} specifies the proportion of complete data in each arm.{

{phang}
{opt r:ange(numlist)} specifies the range of values to be imputed.

{phang}
{opt saving(string)} specifies to save the graph and its filename.


{marker examples}{...}
{title:Examples}

{pstd}
Consider a trial for a weight loss intervention versus standard care. At the end of the trial the mean(variance) of weight loss in the
intervention arm is 7.5(6.76)kg and in the standard care arm it is 6.2(8.41)kg. The number of participants that entered the study was 57 in the 
intervention arm and 50 in the standard care arm but outcome data is only available for 52 observations in the intervention arm and
47 in the standard care arm.

{pstd}
To do the sensitivity analysis in this case click the command below

{phang}
{stata simpute, m(7.5 6.2) v(6.76 8.41) n(57 50) p(0.912 0.940) r(-2(2)6)}

{pstd}
The contour plots show a baseline observation carried forward analysis would give a non-significant result at the 5%
two-sided test level. It also shows that if missing patients actually gained 4kg then this trial would be significant.

{title:Authors}

Adrian Mander, MRC Biostatistics Unit, Cambridge.
Lynne Cresswell, MRC Biostatistics Unit, Cambridge.

Email {browse "mailto:adrian.mander@mrc-bsu.cam.ac.uk":adrian.mander@mrc-bsu.cam.ac.uk}
