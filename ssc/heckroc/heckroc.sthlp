{smcl}
{* documented: Mar2017}{...}
{cmd:help heckroc}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col :heckroc {hline 2}}ROC curves for use with selected samples{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmd:heckroc}
{it:refvar}
{it:classvar}
{ifin}
{weight}
{cmd:,} {opt sel:ect}{cmd:(}[{it:depvar_s} {cmd:=}] {it:varlist_s}{cmd:)} [{it:{help heckroc##heckrocoptions:heckroc_options}}]


{marker heckrocoptions}{...}
{synoptset 27 tabbed}{...}
{synopthdr :heckroc_options}
{synoptline}
{syntab:Main}
{p2coldent :* {opt sel:ect()}}specify selection equation:  dependent and independent variables{p_end}
{synopt:{opt col:linear}}keep collinear variables{p_end}
{synopt :{opt table}}display the raw data in a 2 x k contingency table{p_end}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt :{opt noci}}do not display confidence intervals for inferred AUC curve{p_end}

{syntab :Plot}
{synopt :{opt cbands}}display confidence bands for inferred ROC curve{p_end}
{synopt :{opt noemp:irical}}do not include the empirical ROC curve in the plot{p_end}
{synopt :{opt nog:raph}}supress graphical output{p_end}
{synopt :{opt noref:line}}do not display a reference line{p_end}
{p2col:{cmdab:irocopts(}{it:{help cline_options}}{cmd:)}}affect rendition of inferred ROC curve{p_end}
{p2col:{cmdab:erocopts(}{it:{help cline_options}}{cmd:)}}affect rendition of empirical ROC curve{p_end}
{p2col:{cmdab:rlopts(}{it:{help cline_options}}{cmd:)}}affect rendition of reference line{p_end}
{p2col:{cmdab:cbands(}{it:{help cline_options}}{cmd:)}}affect rendition of the confidence bands{p_end}
{p2col:{it:{help twoway_options}}}any options other than {cmd:by()} documented in {manhelpi twoway_options G-3}{p_end}

{syntab :SE/Robust}
{synopt :{opth vce(vcetype)}}{it:vcetype} may be {opt oim},
{opt r:obust}, {opt cl:uster} {it:clustvar}, {cmd:opg}, {opt boot:strap}, or
{opt jack:knife}{p_end}

{syntab :Maximization}
{synopt :{it:{help heckroc##maximize_options:maximize_options}}}control the maximization process{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
* {opt select()} is required. The full specification is{p_end}
{p 10 10 2}
{opt sel:ect}{cmd:(}[{it:depvar_s} {cmd:=}] {it:varlist_s}{cmd:)}
{p_end}
{p 4 6 2}{it:indepvars} may contain factor variables; see {helpb fvvarlist}.
{p_end}
{p 4 6 2}{it:depvar} and {it:indepvars} may
contain time-series operators; see {help tsvarlist}.{p_end}
{p 4 6 2}
{opt bootstrap}, {opt by}, {opt jackknife}, {opt nestreg},
{opt rolling}, {opt statsby}, {opt stepwise}, and {opt svy}
are allowed; see {help prefix}.
{p_end}


{title:Description}

{pstd}
{cmd:heckroc} plots ROC curves that are robust to how the sample was selected. The ROC curves
 are inferred from the data under assumptions that are similiar to those of type II 
 Tobit models. Details on the procedure used to create the inferred ROC curve are provided in Cook (2017)
 and Cook and Rajbhandari (2017).
 
 
{title:Options}

{dlgtab:Main}

{phang}
{opt select()} specify selection equation:  dependent and independent variables; 
whether to have constant term and offset variable. This option is required.{p_end}

{phang}
{opt collinear} keep collinear variables.{p_end}

{phang}
{opt table} display the raw data in a 2 x k contingency table

{phang}
{opt level(#)}; see 
{helpb estimation options##level():[R] estimation options}.

{phang}
{opt noci} do not display confidence intervals for inferred AUC.


{dlgtab:Plot}

{phang}
{opt cbands} display confidence bands for inferred ROC curve.

{phang}
{opt noempirical} do not include empirical ROC curve in plot.

{phang}
{opt nograph} surpress graphical output.

{phang}
{opt norefline} do not include a reference line in plot.

{phang}
{opt irocopts(cline_options)} affect rendition of inferred ROC curve; see {manhelpi cline_options G-3}{p_end}

{phang}
{opt erocopts(cline_options)} affect rendition of empirical ROC curve; see {manhelpi cline_options G-3}{p_end}

{phang}
{opt rlopts(cline_options)} affect rendition of reference line; see {manhelpi cline_options G-3}{p_end}

{phang}
{opt cbands(cline_options)} affect rendition of empirical ROC curve; see {manhelpi cline_options G-3}{p_end}

{phang}
{opt twoway_options} are any of the options documented in {manhelpi twoway_options G-3}, excluding {cmd:by()}.


{dlgtab:SE/Robust}

{phang}
{opt vce(vcetype)} specifies the type of standard error reported, which
includes types that are derived from asymptotic theory, that are robust to
some kinds of misspecification, that allow for intragroup correlation, and
that use bootstrap or jackknife methods; see
{helpb vce_option:[R] {it:vce_option}}.
{p_end}

{pmore}
{cmd:vce(conventional)}, the default, uses the conventionally derived variance
estimators for first and second part models.


{marker maximize_options}{...}
{dlgtab:Maximization}

{phang}
{it:maximize_options}:
{opt dif:ficult}, {opt tech:nique(algorithm_spec)},
{opt iter:ate(#)}, [{cmd:{ul:no}}]{opt lo:g}, {opt tr:ace}, 
{opt grad:ient}, {opt showstep},
{opt hess:ian},
{opt showtol:erance},
{opt tol:erance(#)},
{opt ltol:erance(#)},
{opt nrtol:erance(#)},
{opt nonrtol:erance},
{opt from(init_specs)}; see {manhelp maximize R}.  These options are seldom
used.

 
{title:Examples}

{cmd:Using Mroz data}

{pstd}Setup{p_end}
{phang2}{cmd:. use http://fmwww.bc.edu/ec-p/data/wooldridge/mroz, clear}{p_end}
{phang2}{cmd:. gen high_wage = 0 if inlf}{p_end}
{phang2}{cmd:. replace high_wage = 1 if wage > 2.37 & inlf}{p_end}

{pstd}Plot ROC curves using educ to predict high_wage{p_end}
{phang2}{cmd:. heckroc high_wage educ, select(inlf= educ kidslt6 kidsge6 nwifeinc)}{p_end}
  
{pstd}After logit{p_end}
{phang2}{cmd:. quietly logit high_wage educ age exper if inlf}{p_end}
{phang2}{cmd:. predict predicted_xb, xb}{p_end}
{phang2}{cmd:. heckroc high_wage predicted_xb, select(inlf= predicted_xb educ kidslt6 kidsge6 nwifeinc)}{p_end}

{pstd}Including plot options{p_end}
{phang2}{cmd:. heckroc high_wage predicted_xb, select(inlf= predicted_xb educ kidslt6 kidsge6 nwifeinc) noempirical cbands irocopts(lcolor(black) lwidth(medthick)) rlopts(lcolor(gray))}{p_end}

{cmd:Using provided data}

{pstd}Setup{p_end}
{phang2}{cmd:. sysuse heckroc_example, clear}{p_end}
{phang2}{cmd:. replace outcome=. if !selected}{p_end}

{pstd}Calling the command{p_end}
{phang2}{cmd:. heckroc outcome rating_a, select(x rating_a rating_b) cbands}{p_end}
{phang2}{cmd:. heckroc outcome rating_b, select(x rating_a rating_b) cbands}{p_end}
  
{title:Saved results}


{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalar}{p_end}
{synopt:{cmd:e(AUC)}}AUC for the inferred ROC curve{p_end}
{synopt:{cmd:e(EmpAUC)}}AUC for the empirical ROC curve{p_end}
{synopt:{cmd:e(AUC_ub)}}Upper bound for AUC for the inferred ROC curve (not provided if option {opt noci} is used){p_end}
{synopt:{cmd:e(AUC_lb)}}Lower bound for AUC for the inferred ROC curve (not provided if option {opt noci} is used){p_end}

{title:Authors}

	Jonathan Cook, jacook@uci.edu
	
	Ashish Rajbhandari, arajbhandari@stata.com
	StataCorp LLC
	
{title:References}

{phang}
Cook, J. 2017. ROC curves and nonrandom data. {it:Pattern Recognition Letters} 85: 35-41. {browse "https://doi.org/10.1016/j.patrec.2016.11.015"}

{phang}
Cook, J. and A. Rajbhandari 2017. heckroc: ROC curves for selected samples. {it:Working paper}. {browse "https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3043847"}

