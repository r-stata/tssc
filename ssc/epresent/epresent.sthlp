{smcl}
{* 03jun2014}{...}
{hline}
help for {hi:epresent} {right:(Till Ittermann)}
{hline}

{title:epresent - Presentation of non-linear relationships in regression models with log or logit-link}

{p 4 12 2}{cmd:epresent} {help varname:depvar} {help varname:transformedexposure} {help varname:exposure}  {help varname:confounder} [{help if:if}] [{help weight:pweight}] [{cmd:,} {it:options}]
  
{synoptset 16 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Mandatory options}
{synopt:{opt reg}}Choice of regression type{p_end}
{synopt:{opt center}}Level of exposure to which exp(beta) should be calculated{p_end}
{synopt:{opt output}}Specification whether exp(beta) should be reported for {cmd:percentiles} or {cmd:values} of the {help varname:exposure}) {p_end}
{syntab:Voluntary options}
{synopt:{opt nq}}If {cmd:output} = percentiles: Number of {cmd:percentiles} for which exp(beta) should be calculated; default is {cmd:10}{p_end}
{synopt:{opt tpoints}}If {cmd:output} = values: {cmd:Values} for which exp(beta) should be calculated {p_end}
{synopt:{opt crange}}Specification of the range around the center level; default is {cmd:0.001}{p_end}
{synopt:{opt plotres}}Restriction of the plot to a specific xrange{p_end}
{synopt:{opt ytitle}}Title option for the y axis{p_end}
{synopt:{opt xtitle}}Title option for the x axis{p_end}
{synopt:{opt xlabel}}Label option for the x axis{p_end}
{synopt:{opt ylabel}}Label option for the y axis{p_end}
{synopt:{opt format}}Formatting option for the exposure levels{p_end}
{synopt:{opt regopt}}Options for the regression model{p_end}
{synopt:{opt title}}Title option for the graphic{p_end}
{synopt:{opt legend}}Legend option for {help mlogit:mlogit}{p_end}
{synoptline}

{p2colreset}{...}		   
{p 4 6 2}
  {opt pweight}s are allowed;see {help weight}.
  {p_end}
		   
		   
{marker description}{...}
{title:Description}

{pstd}
{opt epresent} reports exp(beta) for non-linear associations between a previously transformed or untransformed exposure 
(specified in {help varname:transformedexposure}) and an outcome (specified by {help varname:depvar}) on the original scale 
of the exposure (specified in {help varname:exposure}). exp(beta)'s are calculated to a reference level of the {help varname:exposure}, 
the number of comparing levels is specified in the {cmd:nq} option. To model non-linear relationships between the previously transformed 
or untransformed exposure and the outcome the {help mfp:mfp} command is used. {opt epresent} reports a table including exp(beta)'s and 
its confidence intervals for the chosen quantiles of the {help varname:exposure} in comparison to the reference level of the {help varname:exposure}. 
Furthermore a graphic of the exp(beta)'s over the full range of the {help varname:exposure} is presented.

{pstd}

{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt reg}: Choice of the regression type. Allowed are {help logistic:logistic regression}, {help poisson:Poisson regression}, {help stcox:Cox regression},
{help nbreg:negative binomial regression}, {help glm:Gamma generalized linear model [Option: {cmd: f(gamma) link(log) eform}]}, and
{help mlogit:multinomial logistic regression}.

{phang}
{opt center}: Level of the {help varname:exposure} to which exp(beta) should be compared.

{phang}
{opt output}: exp(beta) can be either calculated for {cmd:percentiles} of the exposure or for {cmd:values} of the exposure.

{phang}
{opt nq}: Number of Quantiles of the {help varname:exposure} for which exp(beta) should be calculated in comparison to 
the reference level as specified in the {cmd:center} option; default is {cmd:10}. Should only be specified if {opt output(percentiles)}.

{phang}
{opt tpoints}: List of values for which exp(beta) should be calculated. No exotic values should be provided here; only values which have 
observed values in the range of the value +/- {opt crange}*SD. Should only be specified if {opt output(values)}.

{phang}
{opt crange}: It sometimes happens, that the level of the {help varname:exposure} specified in the {cmd:center} option is not observed in the 
dataset. Therefore, a small range around the center point is allowed, which is by default center +/- 0.001*SD(exposure). If this default range
is not sufficient you might specify larger range (e.g. {cmd:crange(0.01)}), which allows a range of center +/- 0.01*SD(exposure). The number 
of observations in this range as well as summary statistics of these observations are given as output of {opt epresent}. The mean level of 
these observations is used as center level.

{phang}
{opt plotres}: Sometimes you don't want to plot exp(beta) for the full range of the exposure. Then you could specify restrictions of the exposure
range by {cmd:plotres(if exposure < > number)}.

{phang}
{opt ytitle xtitle ylabel xlabel}: Title and label options for the y- and x-axis as specified in {help axis_options:axis options}.

{phang}
{opt format}: Formatting option for the exposure levels in the reported table, see {help format:format}, default is the original format.

{phang}
{opt regopt}: Regression options for the chosen regression type as specified in the respective regression commands. Also options for the 
{help mfp:mfp} command except the centering option can be used here. Note that {cmd: glm} should only be used with regression models having a log-link.

{phang}
{opt title}: Title for the graphic, see {help title_options: title options}

{phang}
{opt legend}: Positioning of the legend in {opt epresent} graphics using {help mlogit:multinomial logistic regression}, 
see {help legend_options:legend options}. For the other regression types the legend is disabled.



{marker examples}{...}
{title:Examples}

{title:previously untransformed exposure}

{phang}{cmd:. sysuse auto}{p_end}
{phang}{cmd:. epresent foreign price price length turn, reg(logistic) center(5079) output(percentiles) }{p_end}
{phang}{cmd:. epresent foreign price price length turn, reg(logistic) center(5079) output(percentiles) plotres(if price<6000) ylabel(0(1)7)}{p_end}
{phang}{cmd:. epresent foreign price price length turn, reg(logistic) center(5079) output(percentiles) nq(20) plotres(if price<6000) ylabel(0(1)7)}{p_end}
{phang}{cmd:. epresent foreign price price length turn, reg(poisson) center(5079) output(values) tpoints(4000(500)7000) crange(.1) regopt(vce(robust)) plotres(if price<6000) ylabel(0(1)7)}{p_end}

{title:previously power-transformed exposure by {help gdelta: gdelta}}

{phang}{cmd:. gdelta pprice = price}{p_end}
{phang}{cmd:. epresent foreign pprice price length turn, reg(poisson) center(5079) output(percentiles) nq(20) regopt(vce(robust)) plotres(if price<6000) ylabel(0(1)8)}{p_end}

{phang} If you have any issues with {help epresent:epresent} please contact me: till.ittermann@uni-greifswald.de
