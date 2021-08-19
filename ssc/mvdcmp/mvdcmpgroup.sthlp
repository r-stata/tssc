{smcl}
{* 22APR2010}{...}
{right: also see: {help mvdcmp}}
{hi:help mvdcmpgroup}
{hline}

{title:Title}

{pstd}{hi:mvdcmpgroup} {hline 2}  covariate grouping after multivariate decomposition for nonlinear response models


{title:Syntax}
{p 8 16 2}
{cmd:mvdcmpgroup} ({it:aggregate_var} {cmd: :} {it:varlist})  [({it:aggregate_var} {cmd: :} {it:varlist})], {it:options}
{p_end}

{p 4 4 2} where

{p 8 8 2} {it:aggregate_var} specifies the name of a coarser decomposion quantity comprised by 
aggregating the individual contributions of the variables appearing in in {it:varlist}.  



{synoptset 25 tabbed}{...}
{marker opt}{synopthdr:options}
{synoptline}
{synopt :{opt nocons}}omit constant term from aggregate decomposition
    {p_end}
    
    
{title:Description}

{pstd} {cmd:mvdcmpgroup} is a companion routine to {cmd:mvdcmp}. It is used as a postestimation 
command to generate a coarser decomposition based on grouping several covariates, such as a 
collection of socioeconomic variables, that may be informative when considered together as a single 
component. This is similar to what is provided by Jann's {it:fairlie} 
module.  

{title:Examples}

{p 0 15 2} {bf:grouping after decomposition} {p_end}

{pstd} mvdcmpgroup (SES: medu inc1000) 


{title:References}

{phang} Jann, B. (2006). fairlie: Stata module to generate nonlinear decomposition of binary outcome
        differentials. Available from: {browse "http://ideas.repec.org/c/boc/bocode/s456727.html"}.{p_end}


{title:Authors}



{p 4 4 2}
Daniel A. Powers, University
of Texas at Austin, dpowers@austin.utexas.edu 
{p_end} 
{p 4 4 2}
Hirotoshi Yoshioka, University of Texas at Austin,
hiro12@prc.utexas.edu 
{p_end} 
{p 4 4 2}
Myeong-Su Yun, Tulane University, msyun@tulane.edu 
{p_end}

{title:Also see}

{p 4 13 2} Online:  help for {helpb mvdcmp}, {helpb oaxaca},  and {helpb fairlie}
{p_end}

