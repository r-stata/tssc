{smcl}
{* *! version 1.0.1  14apr2020}{...}

{title:Title}

{p2colset 5 19 19 2}{...}
{p2col :{hi:plotprocess} {hline 2}}Visualizing sequences of quantile regressions or distribution regression coefficients{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 13 2}
{cmd:plotprocess} [{it:namelist}] [{cmd:,} {it:{help plotprocess##interval:intervaltype}} {cmd:level(#)} {it:{help plotprocess##graphical:graph_options}} ] 

 where {it: namelist} is a list of variables that appear in the current estimation results.
	
{synoptset 30 tabbed}{...}
{marker interval}{...}
{synopthdr :intervaltype}
{synoptline}
{synopt :{opt p:ointwise}}requires that only the pointwise confidence intervals are added to the plot, the default if the functional bands have not been estimated.{p_end}
{synopt :{opt u:niform}}requires that only the uniform confidence bands are added to the plot.{p_end}
{synopt :{opt b:oth}}requires that only the uniform confidence bands are added to the plot, the defulat if the functional bands have been estimated.{p_end}
{synopt :{opt n:one}}requires that only the uniform confidence bands are added to the plot.{p_end}
{synoptline}
{p2colreset}{...}

{synoptset 30 tabbed}{...}
{marker level}{...}
{synopthdr :level}
{synoptline}
{synopt: {opt level(#)}}specifies the confidence level, as a percentage, for confidence intervals.{p_end}
{synoptline}
{p2colreset}{...}

{synoptset 30 tabbed}{...}
{marker graphical}{...}
{synopthdr :graph_options}
{synoptline}
{synopt :{cmdab:lcolor:(}{it:{help colorstyle}}{cmd:)}}color of the line showing the point estimates.{p_end}
{synopt :{cmdab:pcolor:(}{it:{help colorstyle}}{cmd:)}}color of the pointwise confidence interval.{p_end}
{synopt :{cmdab:ucolor:(}{it:{help colorstyle}}{cmd:)}}color of the uniform confidence bands.{p_end}

{synopt :{cmdab:legend:(}{it:{help legend_options}}{cmd:)}}legend for the uniform bands, pointwise intervals and coefficients; "off" to suppress the legend.{p_end}

{synopt :{cmdab:title:(}{it:title}{cmd:)}}title(s); the titles for different coefficients can be separated by ||; "off" to suppress titles.{p_end}
{synopt :{cmdab:xtitle:(}{it:axis_title}{cmd:)}}specify x axis title(s); the titles for different coefficients can be separated by ||; "off" to suppress titles.{p_end}
{synopt :{cmdab:ytitle:(}{it:axis_title}{cmd:)}}specify y axis title(s); the titles for different coefficients should be separated by ||; "off" to suppress titles.{p_end}

{synopt :{cmdab:other:_graph_options:(}{it:options}{cmd:)}}options that will be passed directly to {help graph_twoway:twoway}.

{synopt :{cmdab:combine:_options:(}{it:options}{cmd:)}}options that will be passed directly to {help graph combine:graph combine}.

{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:plotprocess} conveniently plots the
estimated quantile regression or distribution regression coefficients with their confidence intervals and uniform
bands. The display of the results in form of graphs is more informative than
tabulation when a large number of QR or DR has been estimated. A single call
of this function will automatically combine the values saved by the last
call of {it:{help qrprocess}} or {it:{help drprocess}} and produce a graphic that
visualizes the coefficients and allows for testing directly hypotheses. Many
options can be used to customize the figures.

{pstd}  
For more detailed information about the Stata commands, please refer to {helpb qrprocess##CFM_Stata: Chernozhukov, Fernández-Val and Melly (2020b)}. 

{marker examples}{...}
{title:Examples}

    {hline}
 
{pstd}Use the cps91 dataset{p_end}
{phang2}{cmd:. use http://www.stata.com/data/jwooldridge/eacsap/cps91}{p_end}
 
{pstd}Estimate the discretized quantile regression process for the 0.1,0.02,...,0.9 quantiles, do not print the results{p_end}
{phang2}{cmd:. qrprocess lwage c.age##c.age i.black i.hispanic educ, quantile(0.1(0.01)0.9) noprint}{p_end}

{pstd}Plot all the coefficients{p_end}
{phang2}{cmd:. plotprocess}{p_end}

{pstd}Plot the coefficient on education, change the title, suppress the legend, change the colors{p_end}
{phang2}{cmd:. plotprocess educ, title("Education (in years)") legend(off) pcolor(midblue) lcolor(edkblue)}{p_end}

{pstd}Plot the coefficient on education, change the axis options by passing them to the option {cmd:other_graph_options}{p_end}
{phang2}{cmd:. plotprocess educ, title("Education") other(xlabel(0.1(0.1)0.9))}{p_end}

{pstd}Plot the coefficients on age and age squared, change the way both graphs are displayed by passing them to the option {cmd:combine}{p_end}
{phang2}{cmd:. plotprocess age c.age#c.age, title("Age (in years)"||"Age squared") combine(rows(2) iscale(0.6))}{p_end}

{pstd}Estimate the same process, activate functional inference, use the multiplier bootstrap with 500 replications{p_end}
{phang2}{cmd:. qrprocess lwage c.age##c.age i.black i.hispanic educ, quantile(0.1(0.01)0.9) functional vce(multiplier, reps(500)) noprint}{p_end}

{pstd}Plot the coefficient for education with uniform and pointwise confidence bands{p_end}
{phang2}{cmd:. plotprocess educ, ytitle("QR coefficent") title("Years of education")}{p_end}

{pstd}Plot the coefficient for education with only the uniform confidence bands{p_end}
{phang2}{cmd:. plotprocess educ, uniform ytitle("QR coefficent") title("Years of education")}{p_end}

{pstd}Estimate 100 distribution regression with the logit one-step estimator with functional inference based on the multiplier bootstrap and 500 replications{p_end}
{phang2}{cmd:. drprocess lwage c.age##c.age i.black i.hispanic educ, functional method(logit, onestep) vce(multiplier, reps(500))}{p_end}

{pstd}Plot all the coefficients{p_end}
{phang2}{cmd:. plotprocess}{p_end}

{pstd}Plot the coefficient on education{p_end}
{phang2}{cmd:. plotprocess educ, ytitle("DR coefficent") title("Years of education")}{p_end}

	{hline}



{title:References}


{phang}
{marker CFM_Stata}
Chernozhukov, V., I. Fernández-Val, and  B. Melly. 2020b. Quantile and distribution regression in Stata: algorithms, pointwise and functional inference. {it:Working paper}.
{p_end}




{title:Remarks}

{p 4 4}This is a preliminary version. Please feel free to share your comments, reports of bugs and
propositions for extensions.

{p 4 4}If you use this command in your work, please cite {helpb qrprocess##CFM_Stata: Chernozhukov, Fernández-Val and Melly (2020)}.


{title:Authors}

{p 4 6}Victor Chernozhukov, Iván Fernández-Val and Blaise Melly{p_end}
{p 4 6}MIT, Boston University and University of Bern{p_end}
{p 4 6}mellyblaise@gmail.com{p_end}

