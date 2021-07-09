{smcl}
{* Mars 2012}{...}
{hline}
help for {hi:pcmtest}
{hline}


{title:Global and item specific tests of fit for a Partial Credit Model or a Rating Scale Model}

{p 8 14 2}{cmd:pcmtest}, [{cmdab:g:roup}({it:numlist})
{cmdab:ne:w}
{cmdab:nf:it}(#)
{cmdab:p:ower}(#)
{cmdab:a:lpha}(#)
{cmdab:ap:proximation}
{cmdab:s:itest}
{cmdab:graph:ics}
{cmdab:file:graph}({it:filegraph[, replace])]


{title:Description}

{p 8 14 2}{cmd:pcmtest} allows testing the fit between observed data and a
 partial credit model or a rating scale model.{p_end}
{p 14 14 2}The global test of fit (test R1m) can only be computed if the data
 contains at least two items. Item specific test of fit (Si tests) can only be
  computed if the data contains at least three items. {p_end}
{p 14 14 2}{cmd:pcmtest} is only performed if item difficulties have been
  estimated using {cmd:pcmodel}. {cmd:pcmtest} can be performed whether covariates
   have been included in {cmd:pcmodel} or not.


{title:Options}

{p 4 8 2}{cmd:group} specifies groups of scores, by defining the upper limit of
 each group

{p 4 8 2}{cmd:new} allows changing the computation methodology of the pattern 
response probabilities between several tests of fit, rather than using the pattern 
response probabilities stored in Stata memory.

{p 4 8 2}{cmd:nfit} specifies the size of a virtual sample with items response
 distribution strictly identical to that observed ({cmd:nfit} can deal with
  over-power problems when fit tests are performed on large samples).

{p 4 8 2}{cmd:power} specifies the desired power for a R1m test, and estimates the
 corresponding size of a virtual sample with items response distribution strictly
  identical to that observed.

{p 4 8 2}{cmd:alpha} specifies the type I error used to perform the test of fit
 (default: 0.05).

{p 4 8 2}{cmd:approximation} Computation of the pattern response probabilities using 
simulation instead of Gauss Hermitte quadratures. Computation should be quicker for 
high number of items or responses categories.

{p 4 8 2}{cmd:sitest} performs item specific test of fit (Si tests).

{p 4 8 2}{cmd:graphics} displays several graphs (Distribution of the latent trait 
depending on the individual scores, graphic of MAP, graphic of
 the groups contributions to the R1m statistic, and graphic of the observed and expected
   score distribution).

{p 4 8 2}{cmd:filegraph} indicates the filename and path for saving the graphs 
(four graphs are store: {it:filegraph}_LT_Sc, {it:filegraph}_MAP, {it:filegraph}_Contrib 
and {it:filegraph}_Score_Distrib.)


{title:Outputs}

{p 4 8 2}{cmd:e(globalFitTot)}: Results of the R1m test performed on the observed sample.

{p 4 8 2}{cmd:e(itemFitTot)}: Results of the Si tests performed on the observed sample.

{p 4 8 2}{cmd:e(globalFitPo)}: Results of the R1m test corresponding 
to the indicated power.

{p 4 8 2}{cmd:e(itemFitPo)}: Results of the Si tests corresponding 
to the indicated power.

{p 4 8 2}{cmd:e(globalFitTot)}: Results of the R1m test corresponding 
to the indicated sample size.

{p 4 8 2}{cmd:e(itemFitTot)}: Results of the Si tests corresponding 
to the indicated  sample size.


{title:Author}

{p 4 8 2}Jean-François Hamel{p_end}
{p 4 8 2}Email:
{browse "mailto:jeanfrancois.hamel@chu-angers.fr":jeanfrancois.hamel@chu-angers.fr}{p_end}


{title:Also see}

{p 4 13 2}Online: help for {help pcmodel}, {help gllamm}, {help simirt}
, {help raschtest}.{p_end}
