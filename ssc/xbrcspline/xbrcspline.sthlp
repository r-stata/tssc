{smcl}
{* *! version 1.0.0  2nov2009}{...}
{cmd:help xbrcspline} 
{hline}

{title:Title}

{p2colset 5 20 23 2}{...}
{p2col :{hi: xbrcspline} {hline 1}}Differences in predicted responses after restricted cubic spline models{p_end}
{p2colreset}{...}

{title:Syntax}


{p 8 17 2}
{cmd:xbrcspline}
{it:stubname}
{cmd:,} {opt matk:nots(matname)} {opt v:alues(numlist)} {opt r:eference(#)} [ {opt ls:plines} {opt level(#)} {opt eform} 
{cmdab:f:ormat(%}{it:fmt}{cmd:)}  ] 

{title:Description}

{pstd}
{opt xbrcspline} displays differences in the predicted responses (linear combinations of coefficients)
after estimating a restricted cubic spline model. 
The location and spacing of the knots is determined by the specification of the
{opt matknots()} option. 
The list of covariate values at which calculate differences is specified with the {opt v:alues(numlist)} option.
The reference value is specified with the {opt reference(#)} option. 

{title:Options}

{dlgtab:Options}

{phang}
{opt matk:nots(matname)} specifies the matrix of knots used to create the splines. This can be easily obtained from the saved results of the 
mkspline command.

{phang}
{opt v:alues(numlist)} specifies the values of the original covariate at which the {opt xbrcspline} calculates differences in predicted responses.

{phang}
{opt r:eference(#)} specifies the reference covariate value (not necessarily included in {opt v:alues(numlist)}). 

{phang}
 {opt ls:plines} displays the values of the restricted cubic splines corresponding to {opt v:alues(numlist)}. 

{phang}
 {opt eform} specifies that all report coefficient estimates as exp(b) rather than b. 
 
{phang}
{cmdab:f:ormat(%}{it:fmt}{cmd:)} specifies the display format for presenting numbers.
{cmd:format(%3.2f)} is the default; see help {help format}.{p_end}

{phang}
{opt level(#)}  specifies a confidence level to use for confidence 
intervals. The default is 95%. See help on {help level}.

{phang}
{opt gen:erate(newvar1 newvar2 newvar3 newvar4)} specifies that the specified {opt v:alues(numlist)} of the continuous covariate , 
the differences in predicted responses, lower and upper confidence limits to be be saved in {it:newvar1}, {it:newvar2},
{it:newvar3}, and {it:newvar4} respectively.


{title:Example}

{phang2}{stata "use http://nicolaorsini.altervista.org/data/whitehall1, clear"}{p_end}

{phang2}{bf:// Step 1. Create the restricted cubic splines and save the knots.}

{phang2}{stata "mkspline sysbps = sysbp , nknots(4) cubic displayknots"}{p_end}
{phang2}{stata "mat knots = r(knots)"}{p_end}

{phang2}{bf:// Step 2. Fit the model.}

{phang2}{stata "logit all10 sysbps* age"}{p_end}

{phang2}{bf:// Step 3. Display the results in a tabular or graphical form.}

{phang2}{bf:* Display odds ratios and 95% CI for a set of exposure values of interest.}

{phang2}{stata "xbrcspline sysbps , values(89 98 107 116 126 135 148 167 188 211) ref(107) eform matknots(knots)"}{p_end}

{phang2}{bf:* Display and save as new variables odds ratios and 95% CI for each distinct observed value of the exposure.}

{phang2}{stata "levelsof sysbp"}{p_end}
{phang2}{stata "xbrcspline sysbps , values(`r(levels)') ref(107) matknots(knots) eform gen(sbp or lb ub)"}{p_end}

{phang2}{bf:* Plot the results. Below is an example suitable for publication that you can copy and paste in the do-file editor:}

        twoway (line lb ub or sbp, lp(- - l) lc(black black black) ) ///
                if inrange(sbp,98,200)  , ///
                                scheme(s1mono) legend(off) ///
                                ylabel(0(.5)4, angle(horiz) format(%2.1fc) ) ///
                                xlabel(100(10)200) ///
                                ytitle("Odds ratio of death within 10-years") ///
				xtitle("Systolic blood pressure, mm Hg")

{title:More examples and information}

{p 4 4}The command {opt xbrcspline} was introduced at the 2009 Nordic and Baltic Stata Users Group meeting.{break}
The slides of the talk are here {browse "http://www.stata.com/meeting/sweden09/se09_orsini.pdf"} {p_end}

{title:Author}

{p 4 12}{browse "mailto:nicola.orsini@ki.se?subject=info xbrcspline":nicola.orsini@ki.se}, Karolinska Institutet{p_end}
{p 4 12}{browse "http://nicolaorsini.altervista.org"}{p_end}

{title:Also see}

{psee}
Manual:  {manlink R mkspline}

{psee}
{space 2}Help:  {manhelp mkspline R}

SSC Archive:  {helpb postrcspline} (if installed)
 
