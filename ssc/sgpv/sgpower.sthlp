{smcl}
{* *! version 1.00  19 Mar 2020}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "SGPV (Main Command)" "help sgpv"}{...}
{vieweralsosee "SGPV Value Calculations" "help sgpvalue"}{...}
{vieweralsosee "SGPV False Confirmation/Discovery Risk" "help fdrisk"}{...}
{vieweralsosee "SGPV Plot Interval Estimates" "help plotsgpv"}{...}
{viewerjumpto "Syntax" "sgpower##syntax"}{...}
{viewerjumpto "Description" "sgpower##description"}{...}
{viewerjumpto "Options" "sgpower##options"}{...}
{* viewerjumpto "Remarks" "sgpower##remarks"}{...}
{viewerjumpto "Examples" "sgpower##examples"}{...}
{title:Title}
{phang}
{bf:sgpower} {hline 2} Power functions for Second-Generation P-Values

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:sgpower}
{cmd:,} true(#) nulllo(#) nullhi(#) {cmdab:intt:ype(interval_type)} {cmdab:intl:evel(#)}
[{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt true(#)}}  the true value for the parameter of interest at which to calculate power. 			
{p_end}
{synopt:{opt nulllo(#)}}  the lower bound of the indifference zone (null interval) upon which the second-generation {it:p}-value is based.
{p_end}
{synopt:{opt nullhi(#)}}  the upper bound for the indifference zone (null interval) upon which the second-generation {it:p}-value is based.
{p_end}
{synopt:{opt intt:ype(string)}}  class of interval estimate used for calculating the SGPV. 
{p_end}
{synopt:{opt intl:evel(#)}}  level of interval estimate. 
{p_end}

{syntab:Further options}
{synopt:{opt std:err(#)}}  standard error for the distribution of the estimator for the parameter of interest. 
{p_end}
{synopt:{opt b:onus}}  display the additional diagnostics for error type I.
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}
Compute power/type I error for Second-Generation P-Values approach. See {help sgpvalue##description:here} for more information about the Second-Generation P-Values.{p_end}

{pstd}
An additional {stata db sgpower:GUI} makes using this command easier.
To make the GUI available from the User-menubar, you have to run {stata sgpv menu}.{p_end}

{pstd}
The power functions are the following based on the equations (S4), (S6), (S8) and (S9) 
from {browse "https://journals.plos.org/plosone/article/file?id=10.1371/journal.pone.0188299.s001&type=supplementary":the supplementary material} to Blume et al.(2018): {p_end}
		P_θ(p_δ = 0) 	   = ϕ[(θ_0 - δ) /SE - θ/SE + Z_α/2 ] + ϕ[ -(θ_0 + δ) /SE + θ/SE - Z_α/2 ] 
		P_θ(p_δ = 1) 	   = ϕ[(θ_0 + δ) /SE - θ/SE - Z_α/2 ] - ϕ[  (θ_0 - δ) /SE - θ/SE + Z_α/2 ] 
		P_θ(0 < p_δ < 1) = 1 - ϕ[ (θ_0 - δ) /SE - θ/SE - Z_α/2 ] + ϕ[ -(θ_0 + δ) /SE + θ/SE - Z_α/2 ]
				     - ϕ[ (θ_0 + δ) /SE - θ/SE - Z_α/2 ] - ϕ[  (θ_0 - δ) /SE - θ/SE + Z_α/2 ] 
							when δ > Z_α/2 * SE 				 
		P_θ(0 < p_δ < 1) = 1 - ϕ[ (θ_0 - δ) /SE - θ/SE - Z_α/2 ] + ϕ[ -(θ_0 + δ) /SE + θ/SE - Z_α/2 ] 
					 when δ <= Z_α/2 * SE					 

		SE denotes the standard error, (θ_0 - δ) and (θ_0 + δ) denote the lower and upper bound of the null interval.


{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt true(#)}     the true value for the parameter of interest at which to calculate power. 
			Note that this is on the absolute scale of the parameter, and not the standard deviation or standard error scale.
			
{phang}
{opt nulllo(#)}     the lower bound of the indifference zone (null interval) upon which the second-generation {it:p}-value is based.

{phang}
{opt nullhi(#)}     the upper bound for the indifference zone (null interval) upon which the second-generation {it:p}-value is based.

{phang}
{opt intt:ype(string)}     class of interval estimate used for calculating the SGPV. 
Options are "confidence" for a (1-α)100% confidence interval and "likelihood" for a 1/k likelihood support interval ("credible" not yet supported).

{phang}
{opt intl:evel(#)}     level of interval estimate. If "inttype" is "confidence", the level is α. 
				If "inttype" is "likelihood", the level is 1/k (not k). 
				
{pstd}
{p_end}

{dlgtab:Further options}
{phang}
{opt std:err(#)}     standard error for the distribution of the estimator for the parameter of interest. 
			Note that this is the standard deviation for the estimator, not the standard deviation parameter for the data itself. 
			This will be a function of the sample size(s).
			
{pstd}
{p_end}
{phang}
{opt b:onus}     display the additional diagnostics for error type I. {* Move here descriptions of the bonus statistics}

{pstd}
{p_end}

{marker examples}{...}
{title:Examples}
{pstd}

{stata . sgpower,true(2) nulllo(-1) nullhi(1) stderr(1) inttype("confidence") intlevel(0.05)}
{stata . sgpower,true(0) nulllo(-1) nullhi(1) stderr(1) inttype("confidence") intlevel(0.05)}

Plot the power curve examples (view the {view sgpower-plot-example.do:code} if installed; if not, you can download it {net "describe sgpv, from(https://raw.githubusercontent.com/skbormann/stata-tools/master/)":here})
{stata . do sgpower-plot-example.do}


{title:Stored results}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(poweralt)}}  probability of SGPV = 0 calculated assuming the parameter is equal to {cmd:true}.	 That is, {cmd:poweralt} = P(SGPV = 0 | θ = {cmd:true}).  {p_end}
{synopt:{cmd:r(powernull)}}  probability of SGPV = 1 calculated assuming the parameter is equal to {cmd:true}. 	That is, {cmd:powernull} = P(SGPV = 1 | θ = {cmd:true}). {p_end}
{synopt:{cmd:r(powerinc)}}  probability of 0 < SGPV < 1 calculated assuming the parameter is equal to {cmd:true}. 	That is, {cmd:powerinc} = P(0 < SGPV < 1 | θ = {cmd:true}). {p_end}
{synopt:{cmd:r(minI)}}  is the minimum type I error over the range ({cmd:"nulllo"}, {cmd:"nullhi"}), which occurs at the midpoint of ({cmd:"nulllo"}, {cmd:"nullhi"}). {p_end}
{synopt:{cmd:r(maxI)}}  is the maximum type I error over the range ({cmd:"nulllo"}, {cmd:"nullhi"}), which occurs at the boundaries of the null hypothesis, {cmd:"nulllo"} and {cmd:"nullhi"}.  {p_end}
{synopt:{cmd:r(avgI)}}  is the average type I error (unweighted) over the range ({cmd:"nulllo"}, {cmd:"nullhi"}). 
If 0 is included in the null hypothesis region, then "type I error summaries" also contains at 0, the type I error calculated assuming the true parameter value θ is equal to 0. {p_end}


{title:References}
{pstd}
 Blume JD, D’Agostino McGowan L, Dupont WD, Greevy RA Jr. (2018). Second-generation {it:p}-values: Improved rigor, reproducibility, & transparency in statistical analyses. {it:PLoS ONE} 13(3): e0188299. 
 {browse "https://doi.org/10.1371/journal.pone.0188299"}

{pstd}
Blume JD, Greevy RA Jr., Welty VF, Smith JR, Dupont WD (2019). An Introduction to Second-generation {it:p}-values. {it:The American Statistician}. In press. {browse "https://doi.org/10.1080/00031305.2018.1537893"} 


{title:Author}
{p}
Sven-Kristjan Bormann, School of Economics and Business Administration, University of Tartu.

{title:Bug Reporting}
{psee}
Please submit bugs, comments and suggestions via email to:	{browse "mailto:sven-kristjan@gmx.de":sven-kristjan@gmx.de}{p_end}
{psee}
Further Stata programs and development versions can be found under {browse "https://github.com/skbormann/stata-tools":https://github.com/skbormann/stata-tools}{p_end}



{title:See Also}
Related commands:
 {help fdrisk}, {help plotsgpv}, {help sgpvalue}, {help sgpv}

