{smcl}
{* *! version 1.1.0  16mar2014}{...}
{cmd:help vselect}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col :{hi:vselect} {hline 2}}Linear regression variable selection{p_end}
{p2colreset}{...}

{marker syntax}
{title:Syntax}

{phang}
All subsets variable selection

{p 8 17 2}
{cmd:vselect} {depvar} {indepvars} {ifin} {weight}, {opt best} [{opt fix}({help varlist:varlist_f}) {opt nm:odels(#)}] 

{phang}
Foward selection

{p 8 17 2}
{cmd:vselect} {depvar} {indepvars} {ifin} {weight}, {opt for:ward} {it:info_crit} [{opt fix}({help varlist:varlist_f})]

{phang}
Backward elimination

{p 8 17 2}
{cmd:vselect} {depvar} {indepvars} {ifin} {weight}, {opt back:ward} {it:info_crit} [{opt fix}({help varlist:varlist_f})]


{synoptset 22}{...}
{synopthdr:info_crit}
{synoptline}
{synopt:{opt r2adj}}use R^2 adjusted information criterion{p_end}
{synopt:{opt aic}}use Akaike's information criterion{p_end}
{synopt:{opt aicc}}use Akaike's corrected information criterion{p_end}
{synopt:{opt bic}}use Bayesian information criterion{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}{cmd:aweight}s, {cmd:fweight}s, and {cmd:pweight}s 
are allowed; see {help weight}.{p_end}
{p 4 6 2}{it:varlist_f} may 
contain factor variables; see {help fvvarlist}.{p_end}


{title:Description}

{pstd}
{cmd:vselect} performs variable selection for linear regression.  Through the
use of the Furnival-Wilson leaps-and-bounds algorithm, all-subsets variable
selection is supported.  This is performed when the user specifies the
{cmd:best} option.  The stepwise methods, forward selection  and backward
elimination, are also supported.  These methods are performed when
{cmd:forward} or {cmd:backward} are specified.

{pstd}All-subsets variable selection provides the R^2 adjusted, Mallows's C,
Akaike's information criterion, Akaike's corrected information criterion, and
Bayesian information criterion for the best regression at each quantity of
predictors.  For stepwise selection, the user must tell {cmd:vselect} which
information criterion to use.


{title:Options}

{phang} {cmd:fix(}{it:varlist}{cmd:)} specifies predictors that are to be used
in every regression.  Factor variables are allowed in {cmd:fix()}. 

{phang} {cmd:nmodels(}{it:#}{cmd:)} Report the best {it:#} models for each quantity of predictors. 

{phang} {cmd:best} gives the best model for each quantity of predictors.

{phang} {cmd:backward} selects a model by backward elimination.

{phang} {cmd:forward} selects a model by forward selection.

{phang} {cmd:r2adj} uses R^2 adjusted information criterion in stepwise
selection.

{phang} {cmd:aic} uses Akaike's information criterion in stepwise selection.

{phang} {cmd:aicc} uses Akaike's corrected information criterion in stepwise
selection.

{phang} {cmd:bic} uses Bayesian information criterion in stepwise selection.


{title:Examples}

{phang}{stata "sysuse auto":. sysuse auto}{p_end}
{phang}{stata "regress mpg weight trunk length foreign":. regress mpg weight trunk length foreign}{p_end}
{phang}{stata "estat ic":. estat ic}{p_end}
{phang}{stata "vselect mpg weight trunk length foreign, best":. vselect mpg weight trunk length foreign, best}{p_end}
{phang}{stata "regress mpg weight foreign length":. regress mpg weight foreign length}{p_end}
{phang}{stata "estat ic":. estat ic}{p_end}
{phang}{stata "vselect mpg weight trunk length, fix(i.foreign) best nmodels(2)":. vselect mpg weight trunk length, fix(i.foreign) best nmodels(2)}{p_end}
{phang}{stata "regress mpg i.foreign `r(best22)'":. regress mpg i.foreign `r(best22)'}{p_end}
{phang}{stata "estat ic":. estat ic}{p_end}
{phang}{stata "vselect mpg weight trunk length foreign, forward aicc":. vselect mpg weight trunk length foreign, forward aicc}{p_end}
{phang}{stata "vselect mpg weight trunk length foreign, backward bic":. vselect mpg weight trunk length foreign, backward bic}{p_end}
{phang}{stata "estat ic":. estat ic}{p_end}

{phang}{stata "webuse census13":. webuse census13}{p_end}
{phang}{stata "generate ne = region == 1":. generate ne = region == 1}{p_end}
{phang}{stata "generate n = region == 2":. generate n = region == 2}{p_end}
{phang}{stata "generate s = region == 3":. generate s = region == 3}{p_end}
{phang}{stata "generate w = region == 4":. generate w = region == 4}{p_end}
{phang}{stata "summarize medage":. summarize medage}{p_end}
{phang}{stata "generate tmedage = (medage-r(mean))/r(sd)":. generate tmedage = (medage-r(mean))/r(sd)}{p_end}
{phang}{stata "generate tmedage2 = tmedage^2":. generate tmedage2 = tmedage^2}{p_end}
{phang}{stata "vselect brate tmedage tmedage2 dvcrate n s w [aweight=pop], best fix(mrgrate)":. vselect brate tmedage tmedage2 dvcrate n s w [aweight=pop], best fix(mrgrate)}{p_end}
{phang}{stata "regress brate mrgrate `r(best5)' [aweight=pop]":. regress brate mrgrate `r(best5)' [aweight=pop]}{p_end}
{phang}{stata "estat ic":. estat ic}{p_end}


{title:Saved results}

{pstd}
When {cmd:nmodels()} < 2, {cmd:vselect, best} saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 25 29 2: Macros}{p_end}
{synopt:{cmd:r(bestk)}}variable list of predictors from best {it:k} predictor model{p_end}
{synopt:}.{p_end}
{synopt:}.{p_end}
{synopt:}.{p_end}
{synopt:{cmd:r(best1)}}variable list of predictors from best 1 predictor model{p_end}

{p2col 5 25 29 2: Matrices}{p_end}
{synopt:{cmd:r(info)}}contains the information criteria for the best models{p_end}
{p2colreset}{...}


{pstd}
When {it:m} = {cmd:nmodels()} > 1, {cmd:vselect, best} saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 25 29 2: Macros}{p_end}
{synopt:{cmd:r(bestk1)}}variable list of predictors from best {it:k} predictor model{p_end}
{synopt:}.{p_end}
{synopt:}.{p_end}
{synopt:}.{p_end}
{synopt:{cmd:r(best11)}}variable list of predictors from best 1 predictor model{p_end}
{synopt:}.{p_end}
{synopt:}.{p_end}
{synopt:}.{p_end}
{synopt:{cmd:r(bestkm)}}variable list of predictors from {it:m}th best {it:k} predictor model{p_end}
{synopt:}.{p_end}
{synopt:}.{p_end}
{synopt:}.{p_end}
{synopt:{cmd:r(best1m)}}variable list of predictors from {it:m}th best 1 predictor model{p_end}

{p2col 5 25 29 2: Matrices}{p_end}
{synopt:{cmd:r(info)}}contains the information criteria for the best models{p_end}
{p2colreset}{...}


{pstd}
{cmd:vselect, forward} and {cmd:vselect, backward} save the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 25 29 2: Macros}{p_end}
{synopt:{cmd:r(predlist)}}variable list of predictors from the optimal model{p_end}
{p2colreset}{...}


{title:Authors}

{pstd}Charles Lindsey{p_end}
{pstd}StataCorp{p_end}
{pstd}College Station, TX{p_end}
{pstd}clindsey@stata.com{p_end}

{pstd}Simon Sheather{p_end}
{pstd}Department of Statistics{p_end}
{pstd}Texas A&M University{p_end}
{pstd}College Station, TX{p_end}
