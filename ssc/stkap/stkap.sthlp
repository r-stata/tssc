{smcl}
{* 22apr2003}{...}
{hline}
help for {cmd:stkap}
{hline}

{title:Adjusted Kaplan-Meier Curves }   

{p 6 21 2} 
{cmdab:stkap} [{cmd:if} {it:exp}] [{cmd:in} {it:range}]{cmd:,}
  [{cmd:by(}{it:varlist}{cmd:)}
  {cmdab:str:ata(}{it:varlist}{cmd:)}
  {cmdab:adj:ust(}{it:covlist}{cmd:)} 
  {it:graph_options}]


{title:Description}

{p 4 8 4}
{cmd:stkap} graphs the Kaplan-Meier survivor function by categories of one or
  more nominal X variables adjusted for covariates. The only difference
  between this and {help sts graph} is the covariates are centered by default
  based on the observations used in the analysis, or can be set to specified
  values. If the {cmd:adjust} option is not specified, {cmd:stkap} reduces
  to unadjusted KM plots; You must have {help stset} your data before using
  this command.


{title:Options} 

{p 4 8 2}   
{cmd:by(}{it:varlist}{cmd:)} graphs separate curve for each category of
   {it:varlist}; produces separate survivor functions by making separate
   calculations for each group identified by equal values of the {cmd:by()}
   variables.

{p 4 8 2}   
{cmd:strata(}{it:varlist}{cmd:)} graphs separate curve for each category of
   {it:varlist}; stratified estimates (equal coefficients across strata but
   baseline hazard unique to each stratum) are then estimated. May be used
   with {cmd:adjust()} in place of {cmd:by()}

{p 4 8 2}   
{cmd:adjust(}{it:covlist}{cmd:)} lists any covariates. If none are specified,
   unadjusted estimates are reported. Covariates are set to their mean, based
   on observations used in the analysis, or can be set to user specified
   values (e.g., age=50 gender=1). 


{title:Examples}
 
    {cmd:. stset weeks, failure(relapse)}
    {cmd:. stkap, strata(trtment) adj(wbcc)}

{p 8 8 2}
   Plots the Kaplan-Meier curves for weeks to relapse for leukemia
   patients by categories of treatment, adjusted for white blood cell count

    {cmd:. stset days, failure(died)}
    {cmd:. stkap, by(celltype) adj(trt=1 severity)}

{p 8 8 2}
   Plots the Kaplan-Meier curves for days until death for lung cancer
   patients by cancer cell type, adjusted for treatment=1 and mean severity


{title:Also see}

    Manual:  {hi:[R] sts graph}

{p 4 13 2}
Online:  help for {help st}, {help stset}, {help sts graph}


{title:Author}

{p 4 8 2}
{hi:J.M.Garrett}, Professor, Department of Medicine, University of North Carolina,
  Chapel Hill, NC. 
  Email: {browse "mailto:joanne_garrett@med.unc.edu":joanne_garrett@med.unc.edu}
