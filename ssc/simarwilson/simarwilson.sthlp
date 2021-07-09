{smcl}
{* *! version 1.1  2may2016}{...}
{cmd:help simarwilson} 
{hline}

{title:Title}

{p2colset 5 20 22 2}{...} {phang} {bf:simarwilson} {hline 2} Simar & Wilson (2007) two-stage efficiency analysis{p_end} {p2colreset}{...} 

{title:Syntax}

{p 8 17 2} {cmd:simarwilson} [({it:{help varlist:outputs}} {cmd:=} {it:{help varlist:inputs}})] [{it:{help varname:depvar}}] {it:{help varname:indepvars}} {ifin} {weight}, [{cmd:}{it:{help simarwilson##options:options}}] 


{synoptset 28 tabbed}{...}
{marker DEA_socre_and_regressors}{...}
{synopthdr :DEA score and regressors}
{synoptline}
{syntab :Model}
{synopt :{it:{help varname:outputs}}}list of output variables for DEA{p_end}
{synopt :{it:{help varname:inputs}}}list of input variables for DEA{p_end}
{synopt :{it:{help varname:depvar}}}DEA efficiency scores estimated beforehand{p_end}
{synopt :{it:{help varname:indepvars}}}explanatory variables{p_end}

{synoptset 28 tabbed}{...}
{synopthdr :options}
{synoptline}
{syntab :Main}
{synopt :{opt alg:orithm(1|2)}}algorithm 1 or 2; algorithm({it:1}) is the default{p_end}
{synopt :{opt {ul on}notwo{ul off}sided}}always use one-sided truncated regression{p_end}
{synopt :{opt {ul on}log{ul off}score}}use log-efficiency as left-hand-side variable{p_end}
{synopt :{opt {ul on}nounit{ul off}}}{it:depvar} > 1 indicates inefficiency (rarely required){p_end}

{syntab :DEA/teradial}
{synopt :{cmdab:r:ts(}{ul on}{it:c}{ul off}{it:rs}|{ul on}{it:n}{ul off}{it:irs}|{ul on}{it:v}{ul off}{it:rs}{cmdab:)}}returns to scale assumption; rts({it:crs}) is the default{p_end}
{synopt :{cmdab:b:ase(}{ul on}{it:o}{ul off}{it:utput}|{ul on}{it:i}{ul off}{it:nput}{cmdab:)}}consider {it:output} or {it:input} oriented efficiency; base({it:output}) is the default{p_end}
{synopt :{cmdab:ref:erence(}{it:{help varname:varname}}{cmdab:)}}binary (0/1) indicator {it:varname} to specify refrence set{p_end}
{synopt :{cmdab:inv:ert}}calculate inverse Farrell, that is Shephard, efficiency scores{p_end}
{synopt :{opth te:name(newvar)}}generate variable {it:newvar} with DEA efficiency score{p_end}
{synopt :{opth te:bc(newvar)}}generate variable {it:newvar} with bias-corrected DEA efficiency score{p_end}
{synopt :{opth bias:te(newvar)}}generate variable {it:newvar} with estimated bias of DEA efficiency score{p_end}

{syntab :SE/Bootstrap}
{synopt :{opt {ul on}reps{ul off}(#)}}number of bootstrap replications; reps({it:1000}) is the default {p_end}
{synopt :{opt {ul on}bcr{ul off}eps(#)}}number of bootstrap replications for bias correction; bcreps({it:100}) is the default {p_end}
{synopt :{opt {ul on}savea{ul off}ll(name)}}save all bootstrap coefficient estimates as mata matrix {it:name}{p_end}
{synopt :{opt {ul on}bcsavea{ul off}ll(name)}}save all bootstrap efficiency scores as mata matrix {it:name}{p_end}
{synopt :{opt dot:s}}display replication dots{p_end}

{syntab :Reporting}
{synopt :{opt {ul on}cin{ul off}ormal}}display normal-approximate confidence intervals{p_end}
{synopt :{opt {ul on}bboot{ul off}strap}}display mean bootstrap coefficient vector{p_end}
{synopt :{opt lev:el(#)}}set confidence level; default as set by set level{p_end}
{synopt :{opt noomit:ted}}do not display omitted collinear variables{p_end}
{synopt :{opt basel:evels}}display base levels of factor variables{p_end}
{synopt :{opt {ul on}nopri{ul off}nt}}suppress display of a warnings{p_end}
{synopt :{opt {ul on}nodeap{ul off}rint}}suppress display of DEA output{p_end}
{synopt :{opt {ul on}trn{ul off}oisily}}display genuine output of initial truncated regressions{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{it:indepvars} may contain factor variables; see {help fvvarlist}.{p_end}
{p 4 6 2}{help truncreg##maximize_options :{it:maximize_options}} are the same as for {cmd:truncreg}.{p_end}
{p 4 6 2}{cmd:bootstrap} is technically allowed with externally estimated efficiency scores {it:depvar}, however using the prefix command is entirely counterproductive; {cmd:by} and {cmd:svy} are not allowed; see {help prefix}.{p_end}
{p 4 6 2}
{opt pweight}s and {opt iweight}s are allowed, with the former being the default. {opt fweight}s and {opt aweight}s are not allowed; see {help weight}. Unlike
{it:if} and {it:in}, which affect the samples used for truncated regression and DEA uniformly, {opt weight}s are immaterial for DEA within {cmd:simarwilson}
and only affect the truncated regressions within {cmd:simarwilson}. In consequence, zero weights can be used for excluding observations from the truncated regression steps of
{cmd:simarwilson} that are still considered in the DEA steps. If {opt iweight}s are used, numbers of observations are expressed in terms of rounded sums of weights.{p_end}
{p 4 6 2}The available postestimation commands are (almost) the same as for {cmd:truncreg}; see 
{help truncreg_postestimation :[R] truncreg postestimation}. One has to be careful in interpreting the results of the postestimation commands 
since the underlying models for {cmd:simarwilson} and {cmd:truncreg} are not the same.{p_end} 


{title:Description}

{pstd} {cmd:simarwilson} implements the procedures proposed by Simar and Wilson (2007) for regression analysis of DEA (data envelopment analysis) 
efficiency scores. Unlike naive two-step approaches, the Simar and Wilson procedure accounts for (i) DEA efficiency scores being bounded - depending 
on how inefficiency is defined - from above or from below at the value of one, and (ii) for DEA generating a complex and generally unknown 
correlation pattern among estimated efficiency scores. In technical terms a multi-step procedure is pursued that involves (i) estimation of a radial measure 
of technical efficiency, (ii) truncated regression analysis, (iii) simulating the unknown error correlation, and (iv) calculating bootstrap standard errors and CIs. From a purely technical perspective, one may interpret {cmd:simarwilson} 
as a procedure for correcting the standard errors one gets from using {cmd:truncreg} for regressing DEA scores on explanatory variables. Simar and Wilson (2007) propose two algorithms (alg. #1 and alg. #2) 
that differ in either using uncorrected (alg. #1) or bias-corrected (alg. #2) efficiency scores. Both algorithms are implemented. {cmd:simarwilson} allows for either using externally estimated 
DEA scores (spec. {it:depvar}) or for internally conducting the DEA (sepc. ({it:outputs} = {it:inputs})). For the latter {cmd:simarwilson} requires the user-written command {cmd:teradial} (Badunenko and Mozharovskyi, 2016).
Note that the procedure for bias correction suggested in Simar & Wilson (2007) - though similar - deviates from what is implemented in the user-written program 
{cmd:teradialbc} (Badunenko and Mozharovskyi, 2016) and is closely linked to the regression analysis on the second stage of the procedure.
For this reason, it is recommended not to use externally estimated scores, if one wants to apply algorithm #2.


{title:DEA, externally estimated efficiency scores, and regressors}

{dlgtab:Model}

{phang} {opt outputs} specifies the list of outputs from the production process under scrutiny. {opt outputs} may only include numeric, non-negative variables. Factor variables are not allowed in {opt outputs}.
The number of output and input variables must not exceed the number of considered DMUs. {opt outputs} and {opt inputs} must be mutually exclusive.

{phang} {opt inputs} specifies the list of inputs to the production process under scrutiny. {opt inputs} may only include numeric, non-negative variables. Factor variables are not allowed in {opt inputs}.
The number of output and input variables must not exceed the number of considered DMUs. {opt outputs} and {opt inputs} must be mutually exclusive.

{phang} {opt depvar} specifies an existing variable that contains an externally estimated efficiency measure (score), meant to enter the regression model as dependent variable.
Specifying {opt depvar} is only possible, if ({it:outputs} = {it:inputs}) is not specified. That means, with ({it:outputs} = {it:inputs}) specified,
any variable in the following {it: varlist} is interpreted as element of {it:indepvars}. {cmd:simarwilson} expects {it:depvar} to be a radial efficiency measure that is either bounded to the (0,1] interval
or to the [1,+inf) interval. If some values of {it:depvar} are smaller than one while others exceed one, {cmd:simarwilson} issues a warning and ignores observations, depending on how {opt nounit} is specified. This may 
happen if the DEA was carried out using a reference set that does not include all observations for which efficiency scores are estimated. 
Note that Simar & Wilson (2007) do not consider this case. Only numeric and strictly positive values are not allowed for {opt depvar}. 

{phang} {opt indepvars} specifies the list of regressors. 


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang} {opt algorithm(1|2)} specifies whether algorithm #1 or algorithm #2 is applied. In order to calculate bias-corrected efficiency scores, algorithm #2 involves another bootstrap procedure, that loops over DEA.
{opt algorithm(2)}, hence, requires ({it:outputs} = {it:inputs}) to be specified. If one uses external DEA scores as {it:depvar}, one has to opt for {opt algorithm(1)} even if the externally estimated scores are bias-corrected.
{opt algorithm(1)} is the default. 

{phang} {opt notwosided} makes {cmd:simarwilson} apply a one-sided truncated regression model, irrespective of whether (regular) efficiency scores are bounded to the (0,1] interval or in the [1,+infinity) interval.
For (regular) scores within (0,1] the default ({opt twosided}) is to use a two-sided truncated regression model and to sample from the two-sided truncated normal distribution. With {opt twosided}, the procedure
hence takes into account that (Farrell input oriented) efficiency scores are not only less than or equal to 1 but are also strictly positive. The latter is ignored with {opt notwosided}.
Hence, with {opt notwosided}, {cmd:simarwilson} mirror-inverted applies the procedure suggested in Simar and Wilson (2007), who only consider scores within [1,+infinity), to efficiency scores within (0,1].
For (regular) efficiency scores >= 1, specifying {opt notwosided} has no effect. {opt notwosided} is not recommended in with {opt algorithm(2)}.

{phang} {opt logscore} makes {cmd:simarwilson} use the natural logarithm of the efficiency score as left-hand-side variable in the truncated regressions. With {opt logscore} specified, truncation is at 0 rather than at 1 and is always one-sided.
If externally estimated scores are use, do not take the logarithm beforehand, but let the original score enter the estimation procedure as {it:depvar}.  

{phang} {opt nounit} specifies whether inefficiency is indicated by efficiency score < 1 ({opt unit}) or by efficiency score > 1 ({opt nounit}). Specifying this option will rarely be necessary.
If the DEA is carried out internally, {cmd:simarwilson} internally sets {opt nounit} depending on how {opt base()} and {opt invert} are specified. If externally estimated scores are used
and all observations of {it:depvar} are either in the (0,1] or in the [1,+infinity) interval, specifying the {opt nounit} option is also not required, 
since {cmd:simarwilson} recognizes which DMUs are inefficient and which are efficient. Only if external scores are used that are neither bounded to the (0,1] interval nor to the [1,+infinity) interval,
{opt nounit} is required to specify which observation of {it: depvar} are regular (inefficient) ones and which are irregular (super-efficient) ones. Note that Simar & Wilson (2007) do not consider irregular (super-efficient) DMUs.

{dlgtab:DEA/teradial}

{phang} {opt rts(crs|nirs|vrs)} specifies under which assumption regarding the returns to scale of the considered production process, the measure of technical efficiency is estimated.
{it:crs} requests constant returns to scale, {it:nirs} requests non-increasing returns to scale, and {it:vrs} requests variable returns to scale. {opt rts(crs)} is the default.
{opt rts()} is passed through to {cmd:teradial}.

{phang} {opt base(output|input)} specifies orientation/base of the radial measure of technical efficiency. {it:output} requests output orientation while {it:input} requests input orientation. 
{opt base(output)} is the default. {opt base()} is passed through to {cmd:teradial}. 

{phang} {opt reference(varname)} specifies the indicator variable that defines which data points of {it:outputs} and {it:inputs} (DMUs) form the technology reference set. 
{it:varname} may not take other values than 0 and 1, with the latter indicating being part of the reference set. Since for each reference DMU an efficiency score is required
when running {cmd:simarwilson}, the full set of DMUs or a subset of DMUs may serve as reference set. Yet, the reference set may not include any observations for which technical efficiency is not estimated.
This precludes the specification ({it:ref_outputs} = {it:ref_inputs}), which is allowed in {cmd:teradial}. Specifying a subset of observation as reference set will frequently result in
irregular (super-efficient) efficiency estimates. Note that Simar and Wilson (2007) consider the full set of observations as reference set. Specifying a subset as reference, hence, results in a DEA model
that substantially deviates from what is assumed in Simar and Wilson (2007). 

{phang} {opt invert} makes {cmd:simarwilson} calculate and use the Shephard instead of the Farrell (default) efficiency measure, i.e. efficiency scores are inverted.
With option {opt invert} scores smaller than one indicate inefficiency for the output-oriented efficiency measures
(i.e. the factor by which output generation proportionally fall short of what is technically feasible) and scores larger than one indicate
inefficiency for the input-oriented efficiency measure (i.e. the factor by which input utilization proportionally exceeds what is technically feasible).
{opt invert} is redundant for {opt base(crs)} since for constant returns to scale input-oriented efficiency is just the reciprocal of output-oriented efficiency.
Hence rather than specifying {opt invert} one can just switch the base. Yet, this does not hold for {opt base(nirs)} and {opt base(vrs)}.

{phang} {opt tename(newvar)} creates the new variable {it:newvar} that contains estimates of radial technical efficiency (DEA scores).

{phang} {opt tebc(newvar)} creates the new variable {it:newvar} that contains bias-corrected estimates of radial technical efficiency 
(bias-corrected DEA scores). {opt tebc(newvar)} requires {opt algorithm(2)}.

{phang} {opt biaste(newvar)} creates the new variable {it:newvar} that contains bootstrap bias estimate for original radial measures of technical efficiency.
{opt biaste(newvar)} requires {opt algorithm(2)}.

{dlgtab:SE/Bootstrap}

{phang} {opt reps(#)} specifies the number of bootstrap replications for estimating CIs for the regression coefficients; the default is 1000 replications. 

{phang} {opt bcreps(#)} specifies the number of bootstrap replications for bias correction of DEA scores; the default is 100 replications as suggested in Simar & Wilson (2007). 

{phang} {opt saveall(name)} makes {cmd:simarwilson} save all bootstrap estimates of the regression coefficients to the ({it:reps x K}+1) mata matrix {it:name}.
Any existing mata matrix {it:name} is replaced. 

{phang} {opt bcsaveall(name)} makes {cmd:simarwilson} save all bootstrap efficiency scores that are estimated in the bias-correction procedure to the ({it:bcreps x N_dea})
mata matrix {it:name}. Any existing mata matrix {it:name} is replaced. Depending on {opt bcreps(#)} and the number of considered DMUs, the saved mata matrix may be huge.

{phang} {opt dots} makes {cmd:simarwilson} display one dot character for each bootstrap replication. 

{dlgtab:Reporting}

{phang} {opt cinormal} makes {cmd:simarwilson} display normal-approximated confidence intervals rather than percentiles based bootstrap CIs
for the regression coefficients. One may change the reported type of CIs by retyping {cmd:simarwilson} without arguments and only
specifying the option {opt cinormal}.

{phang} {opt bbootstrap} makes {cmd:simarwilson} display mean bootstrap coefficients rather than the original coefficients from estimating the 
truncated regression model. One may change the type of the reported coefficient vector by retyping {cmd:simarwilson} without 
arguments and only specifying the option {opt bbootstrap}.  

{phang} {opt level(#)}; see {helpb estimation options##level():[R] estimation options}. One may change the reported confidence level by retyping 
{cmd:simarwilson} without arguments and only specifying the option {opt level(#)}. For percentiles based CIs this requires {opt saveall(name)}. 

{phang} {opt noomitted} specifies that variables that were omitted because of collinearity not be displayed. The default is to include in the table 
any variables omitted because of collinearity and to label them as omitted by the "o." prefix. 

{phang} {opt baselevels} makes {cmd:simarwilson} display base categories of factor variables in the table of results and label them as base by the "#b." prefix.

{phang} {opt noprint} prevents {cmd:simarwilson} from displaying warnings. Error messages are displayed irrespective of whether or not
{opt noprint} is specified.

{phang} {opt nodeaprint} prevents {cmd:simarwilson} from displaying DEA output. 

{phang} {opt trnoisily} makes {cmd:simarwilson} display genuine output of {cmd:truncreg} for the initial truncated regression(s) (not for truncated regressions within bootstrap procedures).
Specifying this option might be useful if {cmd:simarwilson} issues the error message 'truncated regression failed' or 'convergence not achieved in truncated regression' and one tries to figure out what makes {cmd:truncreg} fail.

{title:Examples}

{pstd}Preceding data envelopment analysis (input oriented, variable returns to scale){p_end}
{phang2}{cmd:. teradial output1 output2 = input1 input2, rts(vrs) base(i) tename(score)}{p_end}

{pstd}Simar and Wilson (2007) analysis using externally estimated dea scores (algorithm #1){p_end}
{phang2}{cmd:. simarwilson score size i.ownership, reps(2000) dots}{p_end}

{pstd}The same analysis as above (algorithm #1), with internal estimation of efficiency scores{p_end}
{phang2}{cmd:. simarwilson (output1 output2 = input1 input2) size i.ownership, reps(2000) dots rts(vrs) base(i)}{p_end}
 
{pstd}Simar and Wilson (2007) two-stage efficiency analysis with internal bias correction, i.e. algorithm #2{p_end}
{phang2}{cmd:. simarwilson (output1 output2 = input1 input2) size i.ownership, algorithm(2) reps(2000) bcreps(1500) dots rts(vrs) base(i) saveall(BBSTR) tebc(bcscore)}{p_end} 

{title:Saved results}

{pstd}
{cmd:simarwilson} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations (inefficient DMUs){p_end}
{synopt:{cmd:e(N_lim)}}number of limit observations (efficient DMUs){p_end}
{synopt:{cmd:e(N_irreg)}}number of irregular observations (super-efficient DMUs){p_end}
{synopt:{cmd:e(N_all)}}overall number of observations (DMUs){p_end}
{synopt:{cmd:e(wgtsum)}}sum of weights (only saved if weights are specified){p_end}
{synopt:{cmd:e(sigma)}}estimate of sigma{p_end}
{synopt:{cmd:e(ll)}}pseudo log-likelihood (initial truncated regression){p_end}
{synopt:{cmd:e(ic)}}number of iterations (initial truncated regression){p_end}
{synopt:{cmd:e(converged)}}1 if converged, 0 otherwise (initial truncated regression){p_end}
{synopt:{cmd:e(rc)}}return code{p_end}
{synopt:{cmd:e(k_eq)}}number of equations in e(b){p_end}
{synopt:{cmd:e(df_m)}}model degrees of freedom{p_end}
{synopt:{cmd:e(k_aux)}}number of auxiliary parameters{p_end}
{synopt:{cmd:e(chi2)}}model chi-squared{p_end}
{synopt:{cmd:e(p)}}model significance, p-value{p_end}
{synopt:{cmd:e(N_reps)}}number of complete bootstrap replications{p_end}
{synopt:{cmd:e(N_misreps)}}number of incomplete bootstrap replications{p_end}
{synopt:{cmd:e(level)}}confidence level{p_end}
{synopt:{cmd:e(algorithm)}}algorithm used (1 or 2){p_end}
{synopt:{cmd:e(noutps)}}number of output variables{p_end}
{synopt:{cmd:e(ninps)}}number of input variables{p_end}
{synopt:{cmd:e(N_dea)}}number of DMUs for which efficiency scores are estimated{p_end}
{synopt:{cmd:e(N_dearef)}}number of reference DMUs{p_end}
{synopt:{cmd:e(N_deaneg)}}number of negative bias corrected scores{p_end}
{synopt:{cmd:e(N_bc)}}number of complete bootstrap replications (bias correction){p_end}
{synoptset 20 tabbed}{...} {p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(title)}}{cmd:Simar & Wilson (2007) two-stage efficiency analysis}{p_end}
{synopt:{cmd:e(shorttitle)}}{cmd:Simar & Wilson (2007) eff. analysis}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(cmd)}}{cmd:simarwilson}{p_end}
{synopt:{cmd:e(unit)}}either {opt unit} or {opt nounit}{p_end}
{synopt:{cmd:e(truncation)}}either {opt onesided} or {opt twosided}{p_end}
{synopt:{cmd:e(logscore)}}{opt logscore} if option logscore is specified{p_end}
{synopt:{cmd:e(wtype)}}either {opt pweight} or {opt iweight} (only saved if weights are specified){p_end}
{synopt:{cmd:e(wexp)}}= {it:exp} (only saved if weights are specified){p_end}
{synopt:{cmd:e(depvarname)}}name of lhs variable (if provided as {it:depvar} or saved as {it:newvar}){p_end}
{synopt:{cmd:e(depvar)}}{opt efficiency} or {opt inefficiency}{p_end}
{synopt:{cmd:e(saveall)}}{it:name} if option saveall({it:name}) is specified{p_end}
{synopt:{cmd:e(bcsaveall)}}{it:name} if option bcsaveall({it:name}) is specified{p_end}
{synopt:{cmd:e(cinormal)}}{opt cinormal} (if option cinormal is specified){p_end}
{synopt:{cmd:e(bbootstrap)}}{opt bbootstrap} (if option bbootstrap is specified){p_end}
{synopt:{cmd:e(scoretype)}}either {opt score} or {opt bcscore}{p_end}
{synopt:{cmd:e(deatype)}}either {opt internal} or {opt external}{p_end}
{synopt:{cmd:e(invert)}}either {opt Farrell} or {opt Shephard}{p_end}
{synopt:{cmd:e(biaste)}}{it:varname} of estimated bias (if option biaste is specified}{p_end}
{synopt:{cmd:e(tebc)}}{it:varname} of estimated bias-corrected efficiency (if option tebc is specified){p_end}
{synopt:{cmd:e(tename)}}{it:varname} of estimated uncorrected efficiency (if option tename is specified){p_end}
{synopt:{cmd:e(rts)}}returns to scale (CRS or NIRS or VRS)(if DEA is internal){p_end}
{synopt:{cmd:e(base)}}base/orientation (output or input)(if DEA is internal){p_end}
{synopt:{cmd:e(outputs)}}list of output variables (if DEA is internal){p_end}
{synopt:{cmd:e(inputs)}}list of input variables (if DEA is internal){p_end}
{synopt:{cmd:e(marginsok)}}predictions allowed by {opt margins}{p_end}
{synopt:{cmd:e(marginsdefault)}}default {opt predict()} specification for {opt margins}{p_end}
{synopt:{cmd:e(predict)}}program used to implement {opt predict}{p_end}
{synopt:{cmd:e(properties)}}{opt b V}{p_end}
{synoptset 20 tabbed}{...} {p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}vector of estimated coefficients{p_end}
{synopt:{cmd:e(V)}}estimated coefficient variance-covariance matrix{p_end}
{synopt:{cmd:e(Cns)}}constraints matrix (if constraints are specified){p_end}
{synopt:{cmd:e(b_bstr)}}bootstrap estimates of coefficients{p_end}
{synopt:{cmd:e(bias_bstr)}}bootstrap estimated biases{p_end}
{synopt:{cmd:e(ci_percentile)}}bootstrap percentile CIs{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample (truncated regression){p_end}
{p2colreset}{...}


{title:References}

{pstd} Badunenko, O. and Mozharovskyi, P. (2016). Nonparametric frontier analysis using Stata. {it: Stata Journal} 16(3), 550-589.

{pstd} Ji, Y. and Lee, C. (2010). Data envelopment analysis. {it: Stata Journal} 10(2), 267-280. 

{pstd} Simar, L. and Wilson, P. W. (2007). Estimation and inference in two-stage semi-parametric models of production processes. {it: Journal of Econometrics} 136, 31-64. 


{title:Also see}

{psee} Manual:  {manlink R truncreg} 

{psee} {space 2}Help:  {manhelp truncreg R:truncreg}{break} 

{psee} Online:  {helpb dea}, {helpb teradial}, {helpb teradialbc}, {helpb nptestrts}{p_end} 


{title:Authors}

{psee} Oleg Badunenko{p_end}{psee} University of Portsmouth{p_end}{psee} Portsmouth, 
UK{p_end}{psee}E-mail: obadunenko@port.ac.uk {p_end}

{psee} Harald Tauchmann{p_end}{psee} Friedrich-Alexander-Universit{c a:}t Erlangen-N{c u:}rnberg (FAU){p_end}{psee} N{c u:}rnberg, 
Germany{p_end}{psee}E-mail: harald.tauchmann@fau.de {p_end}


{title:Disclaimer}
 
{pstd} This software is provided "as is" without warranty of any kind, either expressed or implied. The entire risk as to the quality and 
performance of the program is with you. Should the program prove defective, you assume the cost of all necessary servicing, repair or 
correction. In no event will the copyright holders or their employers, or any other party who may modify and/or redistribute this software, 
be liable to you for damages, including any general, special, incidental or consequential damages arising out of the use or inability to 
use the program.{p_end} 


{title:Acknowledgements}

{pstd} This work has been supported in part by the Collaborative Research Center "Statistical Modelling of Nonlinear Dynamic Processes" (SFB 823) of 
the German Research Foundation (DFG). We gratefully acknowledge the comments and suggestions of Ramon Christen, Rita Maria Ribeiro 
Bastiao, Akash Issar, Ana Claudia Sant'Anna, Jarmila Curtiss, Meir José Behar Mayerstain, Annika Herr, Hendrik Schmitz, Franziska Valder and participants of the German 
Stata Users Group Meeting 2015.{p_end} 
