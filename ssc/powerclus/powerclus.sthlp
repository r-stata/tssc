{smcl}
{* 02dec2013}{...}
{hline}
help for {cmd:powerclus}
{hline}

{title:Sample Size for Studies with Cluster Sampling}

{p 6 21 2}
{cmdab:powerclus} [
  {cmd:obsclus(}{it:#)}
  {cmd:numclus(}{it:#)}
  {cmd:rho(}{it:#)}
  ]

{title:Description}

{p 4 8 4}
{cmd:powerclus} calculates sample size and number of clusters for cluster sampled
    studies, correcting for any intraclass correlation. powerclus uses the
    estimates from the "power" command, which must precede it.(Note: this is an
    update from the program "samppclus" which worked with "sampsi")

 
{title:Options}  Note: must choose either "obsclus" or "numclus", but not both

{p 4 18 2} 
{cmd:obsclus(}{it:#)} -- number of observations in each cluster; will return corrected 
                         sample sizes and minimum number of clusters needed

             Example: obsclus(10) -- 10 patients per physician; powerclus 
                                     determines number of physicians needed


{p 4 8 2}
{cmd:numclus(}{it:#)} -- maximum number of clusters; will return corrected sample
               sizes and number of observations in each cluster. Number of obs.
               per cluster are rounded up so that the number of clusters will
               never exceed "numclus", but may be fewer. If too few clusters are
               requested for the other given parameters, "powerclus" will prompt
               for the minimum number of clusters possible.

             Example:  numclus(40) -- 40 physicians chosen; sampclus determines
                                      number of patients per physician

{p 4 8 2}
{cmd:rho(}{it:#)} -- intraclass correlation coefficient (default=0)
      

{title:Examples}

{p 4 8 2}{cmd:. power twomeans 200 185, alpha(.01) power(.8) sd(30)}

{p 4 8 2}{cmd:. powerclus, obsclus(10) rho(.2)}

{p 4 8 2}{cmd:. powerclus, obsclus(10) rho(.1)}

{p 8 8 2}
   Corrects sample size and computes number of clusters from a t-test; adjusts
   this sample size calculation for 10 observations per cluster and an
   intraclass correlation of 0.2; repeats for an intraclass correlation of 0.1.


{p 4 8 2}{cmd:. power twoprop .20 .30, power(.8) nratio(2)}

{p 4 8 2}{cmd:. powerclus, numclus(50) rho(.05)}

{p 8 8 2}  
   Calculates sample size and number of observations per cluster using the
   difference of two proportions with twice as many in the second group; assumes
   the number of clusters is 50, and an intraclass correlation of 0.05.


{title:Also see}

{p 4 13 2}
Manual: [R] power


{title:Author}

{p 4 8 2}
{hi:J.Garrett}, Professor, School of Medicine, University of North Carolina,
  Chapel Hill, NC. 
  Email: {browse "mailto:joanne_garrett@med.unc.edu":joanne_garrett@med.unc.edu}



