{smcl}
{* 3June2013}{...}
{hline}
help for {hi:rsoort}{right:Jean-Benoit Hardouin}
{hline}

{title: Oort's Structural Equations Modeling (SEM) based procedure to detect Response Shift}

{p 8 14 2}{cmd:rsoort} {it:varlist} {ifin} [{cmd:,} {cmdab:meth:od}({it:string}) {cmdab:unif:ormrecalibration}({it:varlist}) {cmdab:nonunif:ormrecalibration}({it:varlist}) {cmdab:rep:rioritization}({it:varlist}) {cmdab:nos:earch}]

{p 8 14 2}{it:varlist} is a list of two or more existing variables. You must first enter the list of variables to first measurement followed by the list of variables (in the same order) in the second measurement time.

{title:Description}

{p 4 8 2}{cmd:rsoort} provides the Oort's procedure based on Structural Equation Modeling (SEM) in order to detect Response-Shift in a set of variables.

{title:Options}

{p 4 8 2}{cmd:method}. By default, maximum likelihood estimations of the models parameters are used. You can use alternative methods of estimation like {cmd:mlmv} for
maximum likelihood handling missing data or {cmd:adf} for asymptotic distribution free method.

{p 4 8 2}{cmd:uniformrecalibation} allows defining variables suspected to be affected by uniform recalibration (you should give the name of the variable to the first
measurement). In this case, the procedure force the concerned variable to be affected by uniform recalibration and this kind of response-shift is searched only on the
others variables.

{p 4 8 2}{cmd:nonuniformrecalibation} allows defining variables suspected to be affected by non uniform recalibration (you should give the name of the variable to the
first measurement). In this case, the procedure force the concerned variable to be affected by non uniform recalibration and this kind of response-shift is searched
only on the others variables.

{p 4 8 2}{cmd:reprioritization} allows defining variables suspected to be affected by reprioritization (you should give the name of the variable to the first
measurement). In this case, the procedure force the concerned variable to be affected by reprioritization and this kind of response-shift is searched only on the others 
variables.

{p 4 8 2}{cmd:nosearch} avoids the procedure to be run (this is usefull only if you precise the {cmd:uniformrecalibation}, {cmd:nonuniformrecalibation} or 
{cmd:reprioritization} options)



{title:Example}

	{p 8 8}{inp:. rsoort var1t1-var10t1 var1t2-var10t2}

	{p 8 8}{inp:. rsoort var1t1-var10t1 var1t2-var10t2, unif(var3t1 var7t1) rep(var8t1)}

	{p 8 8}{inp:. rsoort var1t1-var10t1 var1t2-var10t2, unif(var3t1 var7t1) rep(var8t1) nosearch}


{title:References}

{p 4 8 2}Oort F.J. Using structural equation modeling to detect response shifts and true change. {it: Quality of life Research}, vol.14(3), 2005, pp. 587-598.

{p 4 8 2}Oort F.J., Visser M.R., Sprangers M.A. An application of structural equation modeling to detect response shifts and true change in quality of life data from cancer patients undergoing invasive surgery. {it: Quality of life Research}, vol.14(3), 2005, pp. 599-609.

{p 4 8 2}Oort F.J. Towards a formal definition of response shift (in reply to G.W. Donaldson)., {it: Quality of life Research}, vol.14(10), 2005, pp. 2353-2355.

{title:Author}

{p 4 8 2}Jean-Benoit Hardouin, PhD, assistant professor{p_end}
{p 4 8 2}EA 4275-SPHERE "Team of Biostatistics, Pharmacoepidemiology and Subjective Measures in Health Sciences"{p_end}
{p 4 8 2}University of Nantes - Faculty of Pharmaceutical Sciences{p_end}
{p 4 8 2}1, rue Gaston Veil - BP 53508{p_end}
{p 4 8 2}44035 Nantes Cedex 1 - FRANCE{p_end}
{p 4 8 2}Email:
{browse "mailto:jean-benoit.hardouin@univ-nantes.fr":jean-benoit.hardouin@univ-nantes.fr}{p_end}
{p 4 8 2}Websites {browse "http://www.anaqol.org":AnaQol}

{title:Also see}

{p 4 13 2}Online: help for {help sem}{p_end}
