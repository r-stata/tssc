{smcl}
{* *! version 1.0 01jul2020}{...}

{title:Title}

{pstd}{hi:powermap} {hline 2} Power heat maps for experimental design using multiple periods


{title:Syntax}

{p 8 15 2}
{cmd:powermap}
[{cmd:,} {it:options}]

{synoptset 18 tabbed}
{synopthdr}
{synoptline}
{syntab:Main}
{p2coldent:* {opt n(#)}}study sample size (total number of data points during 
the study period); must be a positive integer
{p_end}
{p2coldent:* {opt pow:er(#)}}desired statistical power of the experiment 
(1-type II error); must be between 0 and 1
{p_end}
{synopt:{opt mde(#)}}minimum detectable effect (expected treatment effect assuming 
a zero mean for the control group)
{p_end}
{synopt:{opt me:thod(method)}}estimation method where {it:method} is: {opt post},
 {opt change}, {opt ancova}
{p_end}
{synopt:{opt rho(#)}}serial correlation of the outcome variable
{p_end}
{synopt:{opt sd(#)}}standard deviation of the outcome variable
{p_end}

{syntab:Optional}
{synopt:{opt ro:unds(#)}}total pre/post treatment rounds; default is {cmd:{ul:ro}unds(20)}
{p_end}
{synopt:{opt pt:reat(#)}}proportion of the study sample allocated to the 
treatment group; must be between 0 and 1; default is {cmd:{ul:pt}reat(0.5)}
{p_end}
{synopt:{opt alp:ha(#)}}significance level (type I error); must be between 0 and
 1; default is {cmd:{ul:alp}ha(0.05)}
{p_end}
{synopt:{opt one:sided}}one-sided hypothesis test; default is a {opt two-sided test}
{p_end}
{synopt:{opth sav:ing(filename)}}store the inputs and outputs of the power/sample
 calculations into a .dta file
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}* Only 1 of {opt n(#)} and {opt pow:er(#)} is required. If {opt n(#)} 
is specified, {cmd:powermap} plots the statistical power of all the pre-post 
rounds combinations for the given study sample size {opt n(#)}. If {opt pow:er(#)}
is specified, the program plots the study sample size required by each pre-post
rounds combination to achieve a power of {opt power(#)}.
{p_end}


{title:Description}

{pstd}
{cmd:powermap} creates power/sample heat maps for experimental designs with 
multiple periods. {cmd:powermap} conducts analytical power/sample calculations
and plots a heat map for all the combinations of pre-post treatment periods, 
hence illustrating the trade-offs of multiple measurements for experimental 
design. The program allows two approaches: (i) a heat map of the statistical
power of all the pre-post rounds combinations for a given study sample size
{opt n(#)}; (ii) a heat map of the total study sample size required by each
pre-post rounds combination to achieve a power of {opt power(#)}. See some 
{help powermap##examples:examples} below.

	
{title:Dependencies}

{pstd}
{cmd:powermap} uses the {help sampsi:sampsi} command to conduct analytical 
power/sample calculations. Even though {help sampsi:sampsi} is no longer an 
officially supported Stata package, it allows to estimate power/sample under 
multiple periods, relative to the more recent {help power:power} command 
(see {browse "https://dimewiki.worldbank.org/wiki/Power_Calculations_in_Stata#sampsi":DIME's guide to conduct power calculations in Stata}). 
{p_end}
 {pstd}
 {cmd:powermap} also requires {cmd:heatplot} (Jann, 2019), which in turn requires {cmd:palettes} (Jann, 2018), and {cmd:colrspace} (Jann 2019a). To install these packages, type:
	
	. {stata ssc install heatplot, replace}
	. {stata ssc install palettes, replace}
	. {stata ssc install colrspace, replace}{txt}
		
		
{title:Options}

{dlgtab:Main}

{phang}
{opt n(#)} is the total study sample size (cannot be combined with {opt pow:er(#)}). This 
is, the total number of surveys/data points to be conducted throughout the
study. It should not be confused with the {ul:cross-sectional sample size} (i.e. the 
total number of observations that can be surveyed in each period). Using this
fixed {opt n(#)} illustrates the trade-offs between less measurements with larger
cross-sectional samples vs. more measurements with smaller cross-sectional samples.
If {opt n(#)} is specified, {cmd:powermap} plots the statistical power of all the
pre-post rounds combinations for the given study sample size {opt n(#)}. Must be
a positive integer

{phang}
{opt pow:er(#)} is the desired power of the experimental design and equivalent to 
(1-type II error) (cannot be combined with {opt n(#)}). If {opt pow:er(#)} is
specified, {cmd:powermap} plots the study sample size required by each pre-post
rounds combination to achieve a power of {opt power(#)}. Must be between
 0 and 1 and, if not specified, the default is {cmd:{ul:pow}er(0.8)}.
 
{phang}
{opt mde(#)} is the minimum detectable effect. This is, the expected treatment effect
assuming a zero mean for the control group. {opt mde(#)} can also be negative, 
in case the treatment is expected to have a negative effect.

{phang}
{opt me:thod(post change ancova)} is the approach to estimate the treatment effects.
The {it:post} option ignores the pre-treatment periods and allocates all the study
sample size to the post-treatment periods (i.e. a design with 1 pre and 1 post 
periods will produce the same heat map as a design with 10 pre and 1 post periods,
as the {it:post} option only considers the latter).
{p_end}

{phang}
{opt ro:unds(#)} is the total pre/post treatment periods. This is, the extent of
the x-axis and y-axis of the heat map including all the combinations of pre/post
rounds. (e.g. {cmd:{ul:ro}unds(10)} will produce a 10x10 grid with the power/sample
calculations for each combination between {it:pre} = 1,2,3,...,10 and {it:post} 
= 1,2,3,...,10. If not specified, the default is {cmd:{ul:ro}unds(20)}.

{phang}
{opt rho(#)} is the serial correlation of the outcome variable. {opt powermap} assumes
constant serial correlation rather than arbitrary non-i.i.d. or more complex
autocorrelation structures (see {browse "https://www.sciencedirect.com/science/article/abs/pii/S030438781200003X":McKenzie (2012)} and {browse "https://www.sciencedirect.com/science/article/pii/S030438782030033X":Burlig et. al, 2020}).

{phang}
{opt sd(#)} is the standard deviation of the outcome variable.

{dlgtab:Optional}

{phang}
{opt pt:reat(#)} is the proportion of the study sample allocated to the treatment group; must be between 0 and 1; default is {cmd:{ul:pt}reat(0.5)}.

{phang}
{opt alp:ha(#)} is the significance level (type I error); must be between 0 and 1; default is {cmd:{ul:alp}ha(0.05)}.

{phang}
{opt one:sided} assumes a one-sided hypothesis test; default is a {opt two-sided hypothesis test}.

{phang}
{opth sav:ing(filename)} stores the input and output of the power/sample calculations into a .dta file. If not specified, the data is not stored.
	
		
{title:Examples}

{dlgtab:Power heat maps}

{pstd}
    Power for an experiment with a budget of 2000 surveys; an MDE and s.d. of 10 and 100, respectively; ρ = 0.5; using an ANCOVA estimation:

        . {stata powermap, n(2000) mde(10) sd(100) rho(0.5) method(ancova)}

{pstd}
    Power for different serial correlation levels:
	
        . {stata powermap, n(2000) mde(10) sd(100) rho(0.1) method(ancova)}
        . {stata powermap, n(2000) mde(10) sd(100) rho(0.9) method(ancova)}
		
{pstd}
    Power for different estimation approaches:
	
        . {stata powermap, n(2000) mde(10) sd(100) rho(0.1) method(post)}
        . {stata powermap, n(2000) mde(10) sd(100) rho(0.1) method(change)}
					
{pstd}
    Power for shorter-longer panels:

        . {stata powermap, n(2000) mde(10) sd(100) rho(0.1) method(ancova) rounds(10)}
        . {stata powermap, n(2000) mde(10) sd(100) rho(0.1) method(ancova) rounds(30)}
		
{pstd}
    Power assuming (i) uneven sample allocation to the treatment group, (ii) one-sided hypothesis test:

        . {stata powermap, n(2000) mde(10) sd(100) rho(0.1) method(ancova) ptreat(.75)}
        . {stata powermap, n(2000) mde(10) sd(100) rho(0.1) method(ancova) onesided}

{pstd}
    Storing inputs/outputs of the power calculations:

        . {stata powermap, n(2000) mde(10) sd(100) rho(0.1) method(ancova) saving(powermaps_data)}

{dlgtab:Sample heat maps}

{pstd}
    Study sample for an experiment with 80% power; an MDE and s.d. of 5 and 20, respectively; ρ = 0.5; using an ANCOVA estimation:

        . {stata powermap, power(0.8) mde(5) sd(20) rho(0.5) method(ancova)}
		
{pstd}
    Study sample for different serial correlation levels:
	
        . {stata powermap, power(0.8) mde(5) sd(20) rho(0.1) method(ancova)}
        . {stata powermap, power(0.8) mde(5) sd(20) rho(0.9) method(ancova)}		
		
        . {stata powermap, power(0.8) mde(5) sd(20) rho(0.5) method(post)}
        . {stata powermap, power(0.8) mde(5) sd(20) rho(0.9) method(post)}
		
{pstd}
    Study sample for different estimation approaches:
	
        . {stata powermap, power(0.8) mde(5) sd(20) rho(0.1) method(post)}
        . {stata powermap, power(0.8) mde(5) sd(20) rho(0.1) method(change)}
					
{pstd}
    Study sample for shorter-longer panels:

        . {stata powermap, power(0.8) mde(5) sd(20) rho(0.1) method(ancova) rounds(10)}
        . {stata powermap, power(0.8) mde(5) sd(20) rho(0.1) method(ancova) rounds(30)}
		
{pstd}
    Study sample assuming (i) uneven sample allocation to the treatment group, (ii) one-sided hypothesis test:

        . {stata powermap, power(0.8) mde(5) sd(20) rho(0.1) method(ancova) ptreat(.25)}
        . {stata powermap, power(0.8) mde(5) sd(20) rho(0.1) method(ancova) onesided}

{pstd}
    Storing inputs/outputs of the power calculations:

        . {stata powermap, power(0.8) mde(5) sd(20) rho(0.1) method(ancova) saving(samplemaps_data)}


{hline}

{title:Contact}

{pstd}
    Cristhian Pulido{break}
	Department of Economics{break}
	University of Sussex{break}
	E-mail: {browse "mailto: c.pulido@sussex.ac.uk":c.pulido@sussex.ac.uk}    {p_end}

{hline}
	
{title:References}

{phang}
    Burlig, F., Preonas, L., & Woerman, M. (2020). Panel data and experimental design. Journal of Development Economics, 102458. {p_end}

	{phang}
    Jann, B. (2019b). Heat (and hexagon) plots in Stata. Presentation at London 
    Stata Conference 2019. Available from {browse "http://ideas.repec.org/p/boc/usug19/24.html"}.
    {p_end}

	{phang}
    McKenzie, D. (2012). Beyond baseline and follow-up: The case for more T in experiments. Journal of development Economics, 99(2), 210-221.	{p_end}

	{phang}
    Pulido, C. (2020). How Efficient are Panel RCTs? The Case for Simulation-Based Methods for Experimental Design (forthcoming){p_end}

	
	
