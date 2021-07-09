{smcl}
{* 12Dec2013}
help for {hi:mfxrcspline}
{hline}

{title:Title}

{p2colset 5 20 22 2}{...}
{p2col :{hi: mfxrcspline} {hline 2}}Displays the marginal effect of a restricted cubic spline.{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 15 2}
{cmd:mfxrcspline} {ifin} {cmd:,} 
[
{opt at(var = # [var = # [...]])}
{opt link(linkname)}
{opt cust:omdydxb(dydxb_specification)}
{opt sh:owknots}
{opt ciopts(rarea_options)}
{opt noci}
{opt level(#)}
{opt lineopts(line_options)}
{opt addplot(plot)}
{opt gen:erate(newvar1 [newvar2 newvar3])}
]


{title:Description}

{pstd}
{cmd:mfxrcspline} displays a graph of the marginal effect of a restricted
cubic spline. In other words, it shows for each value of the spline 
variable how much the expected value of your explained variable changes 
for a unit change in the spline variable. It is the first derivative
of the curve shown by {help adjustrcspline}.

{pstd}
{cmd:mfxrcspline} will automatically compute the appropriate marginal effects
(i.e. detect the appropriate link function) for the following commands: 
{cmd:regress}, {cmd:logit}, {cmd:logistic}, {cmd:betafit}, 
{cmd:probit}, {cmd:poisson}, {cmd:cloglog}, and {cmd:glm} (with the exception
of the negative binomial link function). For other commands users can specify
the appropriate link function using the {cmd:link()} option. With the {cmd:link()}
option you can specify the dentity, logit, probit, log, log-complement, log-log, 
complementary log-log, reciprocal, power, and the odds power links. If your 
model uses another link function you can manually specify the first derivative of 
the inverse link function (with respect to the linear predictor) in the 
{cmd:customdydxb()} option.

{title:Options}

{phang}
{opt at(var = # [var = # [...]])} specifies the values of the other
explanatory variables (and offset or exposure) at which the marginal 
effects are calculated. 

{pmore}
The default is to set all non-factor variables at their mean and all 
{help fvvarlist:factor variables} at the mode (if there is more then one mode, 
the mode with the smallest value will be chosen). If the {cmd: exposure()} 
option is specified in the estimation command, the default is to set the 
exposure equal to the exp(mean(offset)).

{phang}
{opt link(linkname)} specifies the link function used for computing
the marginal effects. The link functions that can be specified are: 
identity, logit, probit, log, logcomplement, loglog, cloglog, 
reciprocal, power #, opower #. These link functions are described
in {bf:[R] glm} and (Hardin and Hilbe 2001).

{phang}
{opt customdydxb(inv_link_specification)} specifies a user specified 
first derivative of the inverse link funtion. The syntax is the 
same as in {help predictnl}, in particular the linear predictor can be
specified with {cmd:xb()}.

{phang}
{opt showknots} specifies that the positions of the knots be shown on the 
graph by vertical lines.

{phang}
{opt ciopts(rarea_options)} specifies options of {help twoway rarea} to tune 
the display of the confidence interval.

{phang}
{opt noci} suppresses the display of the confidence interval.

{phang}
{opt level(#)}  specifies a confidence level to use for confidence 
intervals. See help on {help level}.

{phang}
{opt lineopts(line_options)} specifies options of {help twoway line} to tune 
the display of the point estimates of the marginal effect. These options
can also be added directly, which can be convenient to change for 
instance the legend, axis titles, etc.

{phang}
{opt addplot(plot)} provides a way to add other plots to the generated 
graph. See help on {help addplot_option}.

{phang}
{opt gen:erate(newvar1 [newvar2 newvar3])} specifies that the values of
the marginal effects and optionally the lower and upper bounds of the 
confidence interval be saved in {it:newvar1}, {it:newvar2} and 
{it:newvar3} respectively.


{title:Examples}


{cmd}
    sysuse nlsw88, clear
    recode grade 0/5=5
	
    mkspline2 grades = grade, cubic nknots(3)
    logit never_married grades*
	
    adjustrcspline, name(__ex_adjustrcspline1)	
    mfxrcspline, name(__ex_mfxrcspline1) 
{txt}
{phang}({stata "mfxrcspline_ex 1":click to run}){p_end}


{cmd}
    sysuse uslifeexp, clear
    
    mkspline2 ys = year, cubic
    reg le ys* if year != 1918
    	
    adjustrcspline if year != 1918,                             ///
        addplot(scatter le year if year != 1918, msymbol(Oh) || ///
                scatter le year if year == 1918, msymbol(X) )   ///
        ytitle("life expectancy")                               ///
        name(__ex_adjustrcspline 2)                              /// 
        note("1918 was excluded from the computations because of the Spanish flu")
    
    mfxrcspline if year != 1918, name(__ex_mfxrcspline2)
{txt}
{phang}({stata "mfxrcspline_ex 2":click to run}){p_end}


{cmd}
    sysuse nlsw88, clear
    recode grade 0/5=5
	
    mkspline2 grades = grade, cubic nknots(3)
    logit never_married grades*
	
    adjustrcspline, customdydxb("invlogit(xb())*invlogit(-1*xb())")
{txt}
{phang}({stata "mfxrcspline_ex 3":click to run}){p_end}


{cmd}
    sysuse nlsw88, clear
    recode grade 0/5=5
	
    mkspline2 grades = grade, cubic nknots(3)
    glm never_married grades* south, link(cloglog) family(binomial)
    
    mfxrcspline, at(south=0)
{txt}
{phang}({stata "mfxrcspline_ex 4":click to run}){p_end}


{cmd}
    sysuse cancer, clear
    gen long id = _n
    stset studytime, failure(died) id(id)
	
    stsplit t, every(1)

    mkspline2 ts=t, cubic nknots(3)
    xi: streg i.drug age ts*, dist(exp)
	
    mfxrcspline , at(_Idrug_2=0 _Idrug_3=0) ///
                  link("log")               ///
                  noci                      ///
                  ytitle(d hazard / d time)
{txt}
{phang}({stata "mfxrcspline_ex 5":click to run}){p_end}


{title:Author}

{p 4 4 2}
Maarten L. Buis{break}
Wissenschaftszentrum Berlin für Sozialforschung (WZB){break}
Research unit Skill Formation and Labor Markets{break}
maarten.buis@wzb.eu
{p_end}


{title:Acknowledgement}

{p 4 4 2}
Phil Clayton has given useful comments.


{title:Suggested citation if using mfxrcspline in published work}

{p 4 4 2}
{cmd:mfxrcspline} is not an official Stata command. It is a free contribution 
to the research community, like a paper. Please cite it as such.

{p 4 4 2}
Buis, Maarten L.  2009. "POSTRCSPLINE: Stata module containing 
post-estimation commands for models using a restricted cubic spline" 
{browse "http://ideas.repec.org/c/boc/bocode/s456928.html"}


{title:Also see}


{psee}If installed: {helpb mkspline2}, {helpb adjustrcspline}, {helpb rcspline}{p_end}
