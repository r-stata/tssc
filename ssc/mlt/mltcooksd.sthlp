{smcl}
{* 18Jan2013}{...}
{hline}
help {cmd:mltcooksd} {right: {browse "mailto:moehring@wiso.uni-koeln.de": Katja Moehring} and {browse "mailto:alex@alexanderwschmidt.de": Alexander Schmidt}}
{hline}

{title:Cook's D and DFBETAs after mixed models (beta version)}

{p 4}Syntax

{p 8 14}{cmd:mltcooksd} 
[ {cmd:,} ]
[ {cmd:keepvar(}{it:prefix}{cmd:)} ]
[ {cmd:counter} ]
[ {cmd:graph} ]
[ {cmd:slabel} ]
[ {cmd:fixed} ]
[ {cmd:random} ]
[ {cmd:approx} ]



{p 4 4} {cmd:mltcooksd} is part of the {helpb mlt:mlt} (multilevel tools) package.

{title:Description}

{p 4 4} {cmd:mltcooksd} estimates Cook's D and DFBETAs for the second level units in two-level mixed models estimated with 
{help xtmixed: xtmixed}, {help xtmelogit: xtmelogit} or {help xtmepoisson: xtmepoisson} (Stata Version 11 or above). 
Cook's D describes the influence that the exclusion of a single level-two unit has on the estimated model parameters. DFBETAs describes the influence
that a single level-two unit has on each of the independent variables in the model. 

{p 4 4} By default {cmd:mltcooksd} reports Cook's D for the whole model (random+fixed part).
The options {cmd: fixed} and {cmd: random} add separate estimates of Cook's D for the random and the fixed part of the model. See Snijders and Berkhof (2008: 158) for the formulas of Cook's D.

{p 4 4} For models with a random part, Cook's D and DFBETAs cannot be estimated from the matrices stored after the regression. The Ado {cmd:mltcooksd} goes the 
empirical way and calculates Cook's D and DFEBTAs by estimating a series of models, excluding each level-two unit one at a time. We follow Van der Meer et. al. (2006) in this approach. 

{p 4 4} mltcooksd will show and use cutoff values for Cook's D and DFBETAs. These cutoff values are based on Belsley et. al. (1980: 13). 
The cutoff value for Cook's D is 4/n, with n= number of level-two units. 
The cutoff value for DFBETAs is 2/sqrt(n), with n = number of level-two units. 

{p 4 4} {cmd:mltcooksd} stores each estimated model. The command {cmd:mltshowm} produces an estimation table for all models that produce a Cook's D value above the cutoff. 
If you want to display other models estimated by {cmd:mltcooksd}, have a look at the list of stored models (estimates dir). All models stored by {cmd:mltcooksd} begin with the letters WJ, followed by the 
number of the left out level-two unit, e.g. WJ1 is the model estimated without (Unit) J=1. 


{title:Options}

{p 4 8} {cmd:keepvar(}{it:prefix}{cmd:)} specifies whether {cmd:mltcooksd} should keep the variables containing Cook's D and DFBETAs values.  
You have to specify a prefix which is used in the variable names.  

{p 4 8} {cmd:counter} specifies that {cmd:mltcooksd} displays the estimated time until the program finishes. Depending on your model {cmd:mltcooksd} can run quite a long time, so it might be interesting to see how long it will run.
The first estimate will be given after estimating the first model. Then, {cmd:mltcooksd} gives a new refined estimate after each new estimation.  

{p 4 8} {cmd:graph} specifies that {cmd:mltcooksd} produces a box plot showing the distribution of DFBETAs for each independent variable in the model.

{p 4 8} {cmd:slabel} suppresses the value labels of the level-two units in the graph (if specified) and in the listing of Cook's D and DFBETAs. 

{p 4 8} {cmd:fixed} lists Cook's D for the fixed part of the model separately.

{p 4 8} {cmd:random} lists Cook's D for the random part of the model separately.

{p 4 8} {cmd:approx} computes an approximation of Cook's D and DFBETAs (following Snijders and Berkhof 2008, Snijders and Bosker 1999). 
The approximation can be derived much faster than the complete computation. The option is for use after {cmd:xtmelogit} and {cmd:xtmepoisson}.
Details: We perform only one iteration for each model, starting from the coefficient vector of the full model (one-step estimator).
More iterations are only done if the model does not converge. We do not use the algorithms proposed in Snijders and Berkhof 2008 (IGLS, RIGLS, Fisher scoring), but
 the same algorithm that has been used to compute the full model (in most cases the default: Stata's modified Newton-Raphson).  

 
 {title:Examples}
 
{p 4 8} Load data set (ISSP 2006){p_end}
{p 4 8} {cmd:. net get mlt}{p_end}
{p 4 8} {cmd:. use redistribution.dta}{p_end}

{p 4 8} Multilevel regression of "Support for income redistribution"{p_end}
{p 4 8} {cmd:. xtmixed gr_incdiff sex age incperc rgdppc gini || Country: , mle var }{p_end}

{p 4 8} Estimate Cook's D and DFBETAs (fixed and random part seperately){p_end}
{p 4 8} {cmd:. mltccoksd, fixed random counter }{p_end}


{title:References}

{p 4 8} David Belsley, Edwin Kuh, Roy Welsch (1980): Regression Diagnostics: Identifying Influential Data and Sources of Collinearity. New York: John Wiley. 

{p 4 8} ISSP (2006): International Social Survey Programme - Role of Government IV, GESIS StudyNo: ZA4700, Edition 1.0, doi:10.4232/1.4700.

{p 4 8} Tom Snijders and Johannes Berkhof (2008): Diagnostic Checks for Multilevel Models. In {it:Handbook of Multilevel Analysis}, edited by J. De Leeuw and E. Meijer. New York: Springer. 

{p 4 8} Tom A.B. Snijders and Roel J. Bosker (1999): Multilevel Analysis. An Introduction to Basic and Advanced Multilevel Modeling. London: Sage.

{p 4 8} Tom Van der Meer, Manfred Te Grotenhuis and Ben Pelzer (2006): Influential Cases in Multilevel Modeling: A Methodological Comment. {it:American Sociological Review} 75(1), 173-178.


{title:Authors}

{p 4 6} Katja Moehring, GK SOLCIFE, University of Cologne, {browse "mailto:moehring@wiso.uni-koeln.de":moehring@wiso.uni-koeln.de}, {browse "www.katjamoehring.de":www.katjamoehring.de}.

{p 4 6} Alexander Schmidt, GK SOCLIFE and Chair for Empirical Economic and Social Research, University of Cologne, {browse "mailto:alex@alexanderwschmidt.de":alex@alexanderwschmidt.de}, 
{browse "www.alexanderwschmidt.de":www.alexanderwschmidt.de}.


{title:Also see}

{p 4 8}  {helpb mlt: mlt}, {helpb mltshowm: mltshowm}, {helpb mltrsq: mltrsq}, {helpb mltl2scatter: mltl2scatter}, {helpb mlt2stage: mlt2stage}
