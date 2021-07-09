{smcl}
{hline}

{hline}
help for {hi:mi_twoway}{right:Jean-François HAMEL}
{hline}

{title:Two-way imputations: imputing missing item responses in questionnaires for computing scores}

{p 8 14 2}{cmd:mi_twoway} {it:varlist}, [{cmdab:sc:orename}({it:newvarname}) 
{cmdab:rep:lace}
{cmdab:add:}({it:#}) 
{cmdab:st:yle}({it:keyword}) 
{cmdab:clear}
{cmdab:da} 
{cmdab:it:erate}({it:#})]

{title:Description}

{p 8 14 2}{cmd:mi_twoway} is an implementation of the multiple imputation procedure 
proposed by Van Ginkel for computing scores on questionnaires containing missing item responses.{p_end}
{p 14 14 2}Two methods are available: imputations based on a fixed effects two-way ANOVA, and imputations 
generated using data augmentation based on a mixed effect two-way ANOVA (with a random person effect 
assumed to follow a Normal distribution and a fixed item effect.{p_end}
{p 14 14 2}{cmd:mi_twoway} is fully compatible with the Sata {help mi} procedures. The data is {help mi_set:set} 
and {help mi_impute:imputed} using {cmd:mi_twoway}, but all the estimations using multiple imputations are 
performed using the standard mi {help mi_estimate:estimate} procedures.

{p 4 8 2}{it:varlist} is the list of the variables containing the item responses of the questionnaire 
(with possible missing data).

{title:Options}

{p 4 14 2}{cmd:scorename} specifies the name of the new variable containing, for each individual, the value of the 
score computed as the sum of the item responses. {it:scorename} is missing for each individual with at least one item 
missing response.

{p 4 14 2}{cmd:replace}         allows to replace individual scores in existing variables

{p 4 14 2}{cmd:add} specifies the number of imputations to add; required with no imputations

{p 4 14 2}{cmd:style} specifies in which style should be recorded the data: wide, mlong, flong,
 or flongsep; see {help mi_styles:[MI] styles}.

{p 4 14 2}{cmd:clear} allows performing new imputations by remouving the previous one.

{p 4 14 2}{cmd:da} generates imputations using data augmentation based on a mixed effect two-way 
ANOVA (with a random person effect and a fixed item effect. By default, imputations are generated 
using a fixed effects two-way ANOVA.

{p 4 14 2}{cmd:iterate} defines the number of iterations of the data augmentation algorithm. 
By default, this number is fixed to 10.

{marker example}{...}
{title:Example}

{pstd}
Simulation of the data (using {help simirt}):

	{cmd:. simirt, nbobs(200) dim(5) group(0.5) deltagroup(0.4) clear}{right:(1)    }

{pstd}
Creating the missing data, with a non-response rate of 10%:

	. {cmd:set more off }{right:(2)    }
	. {cmd:forvalues j=1/5{c -(}}{right:(3)    }
	2. {cmd:replace item`j'=. if runiform()<0.1}{right:(4)    }
	3. {cmd:{c )-}}{right:(5)    }


{pstd}
Generating 10 multiple imputations using a fixed effects two-way ANOVA:

	. {cmd:mi_twoway item*, scorename(score) add(10) style(wide)}{right:(6)    }

{pstd}
Modeling score depending on {it:group} covariate using multiple imputations estimates ({help mi_estimate}):

	. {cmd:mi estimate: regress score i.group}{right:(7)    }

{pstd}
Changing the way to impute data, using data augmentation based on a mixed effect two-way ANOVA:

	. {cmd:mi_twoway item*, scorename(score) replace add(10) style(wide) da clear}{right:(8)    }

{pstd}
Changing the style of the data from {it:wide} to {it:mlong} ({help mi_convert}):

	. {cmd:mi convert mlong}{right:(9)    }

{pstd}
Removal of the multiple imputations ({help mi_set##unset:mi_unset}):

	. {cmd:mi extract 0, clear}{right:(10)    }

{marker ref}{...}
{title:References}

{p 4 8 2}Van Ginkel JR, Van der Ark LA, Sijtsma K & Vermunt JK. Two-way imputation: A Bayesian method for estimating missing scores in tests and questionnaires, and an accurate approximation. Computational Statistics & Data Analysis (2007) 51: pp. 4013-4027.

