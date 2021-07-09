{smcl}
{* *! version 1.0.1  6FEB2014}{...}
{* *! version 1.0.2  8MAY2014}{...}
{* *! version 1.0.3  26JUN2014}{...}
{title:Title}
{p2colset 8 14 18 2}{...}

{p2col :{cmd:qv} {hline 2}} Quasi variances{p_end}
{p2colreset}{...}
	
{marker syntax}{...}
{title:Syntax} 

{p 8 34 2}
{cmd:qv}
{varlist} 
[{it:, options}]
{p_end}
	

{p2colset 8 20 38 4}{...}
{synoptset 28}{...}
{p2col:options}description{p_end}
{p2line 0 10}
{...}
{p2col:{opt ref(string)}}{...}names the reference group; {it:ref_grp} if not specified{p_end}
{p2col:{opt lev:el(#)}}{...}sets the confidence interval between 0 to 100; default is 95{p_end}
{p2col:{opt plot}}{...}a basic graph for variables in {it:varlist}{p_end}
{p2col:{opt saving(filename[, replace])}}{...}save graph {p_end}
{p2line 0 10}

	
{title:Description}

{p 4 4 2}
{cmd:qv} is a post-estimation command. It uses e(V) from the most recently fit model to compute
quasi variances (Firth 2003) for all categories in a multi-category variable.
{p_end}

{p 4 4 2}
The {it:varlist} accepts either the (n-1) dummy variables of the multi-category variable,
or its equivalent factor variable in the form of {it:i.group}. In both cases,
{it:varlist} has to be part of the most recently fit estimation command.
{p_end}

{p 4 4 2}
In addition to the tabulated output, {cmd:qv} also returns results with better precision 
in the stored matrices {hilite:e(qv)}, {hilite:e(qvub)}, and {hilite:e(qvlb)}.
{p_end}

{p 4 4 2}
The user-written {cmd:glm} link function {cmd:glm_exp} is required to execute {cmd:qv}.
{p_end}
 
{title:Options}

{p 4 6 2}
{opt ref(string)} names the reference category when the {it: varlist} contains (n-1) dummy 
variables . If not specified, {it:ref_grp} is assigned.
{p_end}

{p 4 6 2}
{opt lev:el(#)} specifies the level of confidence interval. It accepts numeric values between 
0 and 100. The default is 95.
{p_end}

{p 4 6 2}
{opt plot} generates a standard graph for the point estimate and confidence intervals based 
on quasi standard errors. For making customizable graphs, use {cmd: qvgraph} or refer to the 
example below.
{p_end}
 
{p 4 6 2}
{opt saving(filename,[replace,])} saves the graph produced by the option {opt plot}.
{p_end}

{title:Examples}

{col 10}{cmd:. sysuse census, clear}
{col 10}{cmd:. gen dpop=death/pop*1000}

{pstd}Use the factor variable{p_end}
{col 10}{cmd:. reg dpop i.region medage}
{col 10}{cmd:. qv i.region, level(95) plot}

{pstd}Or use the (n-1) dummy variables{p_end}
{col 10}{cmd:. gen NC=region==2}
{col 10}{cmd:. gen SO=region==3}
{col 10}{cmd:. gen WS=region==4}
{col 10}{cmd:. reg dpop NC SO WS medage}
{col 10}{cmd:. qv NC SO WS, ref(NE) level(95) plot}

{pstd}Create graph from the stored matrices{p_end}
{col 10}{cmd:. mat lb=e(qvlb)}
{col 10}{cmd:. mat ub=e(qvub)}
{col 10}{cmd:. svmat lb, names(lb)}
{col 10}{cmd:. svmat ub, names(ub)}
{col 10}{cmd:. gen b=(lb1+ub1)/2}

{col 10}{cmd:. gen group=_n in 1/4}
{col 10}{cmd:. label variable group "Region"}
{col 10}{cmd:. label define region 1 "NE" 2 "NC" 3 "SO" 4 "WS"}
{col 10}{cmd:. label value group region}

{col 10}{cmd:. graph twoway scatter b group || rspike ub1 lb1 group, vert   ///}
{col 18}{cmd:legend(off) ytitle("") xlabel(, valuelab) }

{pstd}Graphic comparison with regular standard errors{p_end}
{col 10}{cmd:. gen lb2=0}
{col 10}{cmd:. gen ub2=0}
{col 10}{cmd:. replace lb2=b-1.96*_se[NC] if _n==2}
{col 10}{cmd:. replace ub2=b+1.96*_se[NC] if _n==2}
{col 10}{cmd:. replace lb2=b-1.96*_se[SO] if _n==3}
{col 10}{cmd:. replace ub2=b+1.96*_se[SO] if _n==3}
{col 10}{cmd:. replace lb2=b-1.96*_se[WS] if _n==4}
{col 10}{cmd:. replace ub2=b+1.96*_se[WS] if _n==4}

{col 10}{cmd:. graph twoway scatter b group || rspike ub2 lb2 group, vert   ///}
{col 18}{cmd:legend(off) ytitle("") xlabel(, valuelab)              ///}
{col 18}{cmd:title("regular standard errors") name(regular)}

{col 10}{cmd:. graph combine regular qv}
{col 18}{it:({stata "qv_example 0":click to reproduce graphs})}

{title:Stored results}

{pstd}
{cmd:qv} adds the following to existing matrices:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(qv)}}quasi variances{p_end}
{synopt:{cmd:e(qvlb)}}qv-based lower-bound estimates{p_end}
{synopt:{cmd:e(qvub)}}qv-based upper-bound estimates{p_end}

{title:Technical details}

{pstd}{cmd:qv} first estimates the generalized linear model using iterative reweighted least 
square (irls) methods. If an error is returned, maximum likelihood methods are attempted. {p_end}

{pstd}Users can also use the {it:Quasi Variance Caculator} hosted at the Unversity of Warwick.
(http://www2.warwick.ac.uk/fac/sci/statistics/staff/academic-research/firth/software/qvcalc/kuvee/) {p_end}

{title:References}

{marker AP2009}{...}
{phang}
Firth, David. 2003. ¡§Overcoming the Reference Category Problem in the Presentation of Statistical Models.¡¨{it:Sociological Methodology} 33(1): pp 1¡V18.
{p_end}

{title:Contact}

{phang}
For questions and comments, please email aspenchensoc@gmail.com.
{p_end}
