{smcl}
{* *! version 1.1 8jun2015}{...}
{vieweralsosee "Main network help page" "network"}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Examples" "examplehelpfile##examples"}{...}
{title:Title}

{phang}
{bf:network import} {hline 2} import data for network meta-analysis


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:network import} {ifin}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Compulsory 'options' describing the data}
{synopt:{opt stud:yvar(varname)}}The variable containing the study name{p_end}

{syntab:Compulsory 'options' describing the data - pairwise format}
{synopt:{opt tr:eat(varlist)}}The two variables containing the two treatments being compared{p_end}
{synopt:{opt eff:ect(varname)}}A stub  variable containing the point estimate of the comparison{p_end}
{synopt:{opt stde:rr(varname)}}The variable containing the standard error of the comparison{p_end}

{syntab:Compulsory 'options' describing the data - augmented format}
{synopt:{opt eff:ect(stub)}}Variables {it:stub}_* contain the point estimates
of the comparisons with reference, where * represents treatments{p_end}
{synopt:{opt var:iance(stub)}}Variables {it:stub}_*_* contain the variances and covariances 
of the estimates, where each * represents treatments{p_end}
{synopt:{opt ref(string)}}Specifies the reference treatment{p_end}

{syntab:Optional options for augmented format}
{synopt:{opt mult(#)}}A study is deemed not to contain the reference treatment
(i.e. to have been augmented)
if all its observed variances and covariances are larger than this multiple of the smallest variance. 
Default is 1000. {p_end}
{synopt:{opt trtlist(string)}}List of treatments to be included. 
Not usually needed.{p_end}

{syntab:Other options}
{synopt:{opt ref(string)}}Specifies the reference treatment (in case of future conversion to augmented format){p_end}
{synopt:{opt measure(string)}}Names the measure used (e.g. log odds ratio, mean difference). This is used only to label output.{p_end}
{synopt:{opt genp:refix(string)}}Prefix to be used before default variable names (e.g. y for treatment contrasts){p_end}
{synopt:{opt gens:uffix(string)}}Suffix to be used after default variable names{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}


{marker description}{...}
{title:Description}

{pstd}
{cmd:network import} imports a data set already formatted for network meta-analysis.
The data may be in 

{pmore}"pairs" format - a data set of pairwise comparisons as described at 
{browse "http://www.mtm.uoi.gr/index.php/stata-routines-for-network-meta-analysis"}.
Here, each two-arm study is represented by a single record in the usual way, 
but a multi-arm study is represented by one record for each pairwise contrast in that study. 
{cmd:network import} infers a set of contrasts with a baseline treatment, and 
using the standard errors of the pairwise contrasts, 
it also infers the correct variance-covariance matrix of the set of contrasts.

{pmore}"augmented" format - a data set of contrasts with a common reference treatment.

{pstd}Any other variables are kept. Usually this will be fine, 
but if you have a covariate which varies between data records
(as could happen when importing multi-arm studies in a "pairs" format)
then the results are likely to be wrong. 


{marker examples}{...}
{title:Examples}

{pstd}Use data stored at {browse "http://www.mtm.uoi.gr/images/example_datasets.rar"}:

{pin}. {stata use "coronary artery disease pairwise.dta", clear}

{pin}. {stata network import, tr(t1 t2) eff(logOR) study(study) stderr(se)}

{pin}. {stata network meta consistency}


{p}{helpb network: Return to main help page for network}


