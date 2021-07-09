{smcl}
{* 15Jun2013}{...}
{.-}
help for {cmd:distrate} 
{.-}

{title:Directly standardized rates with improved confidence interval}

{p 4 10 4}
{cmd:distrate}
{it:casevar} 
{it:popvar}
{cmd:using} {it:filename} 
[{cmd:if} {it:exp}]
[{cmd:in} {it:range}]
, 	
{cmdab:stand:strata}{cmd:(}{it:stratavars}{cmd:)}
[{cmdab:by}{cmd:(}{it:varlist}{cmd:)}
{cmd:popstand}{cmd:(}{it:varname}{cmd:)}
{cmdab:li:st}{cmd:(}{it:varlist}{cmd:)}
{cmd:sepby}{cmd:(}{it:varlist}{cmd:)}
{cmdab:f:ormat:(%}{it:fmt}{cmd:)}
{cmd:formatn}{cmd:(}{it:#}{cmd:)}
{cmd:mult}{cmd:(}{it:#}{cmd:)}
{cmd:fay}
{cmd:dobson}
{cmdab:ref:rate:(}{it:#}{cmd:)}
{cmdab:l:evel}{cmd:(}{it:#}{cmd:)}
{cmdab:sa:ving(}{it:filename}[{cmd:,replace}]{cmd:)} 
{cmdab:pre:fix}{cmd:(}{it:string}{cmd:)} 
{cmdab:post:fix}{cmd:(}{it:string}{cmd:)} ]



{title:Description}

{p}{cmd:distrate} estimates directly standardized rates and confidence intervals based on the
gamma distribution as proposed by Fay and Feuer (1997). Tiwari, Clegg and Zou (2006) modified the formula of the upper
confidence limit showing by simulations that this modified gamma confidence interval performs better 
than the gamma interval of Fay and Feuer and the other intervals.
This method produces valid confidence intervals even when the number of cases is very small.
When {cmd:by}{cmd:(}{it:varlist}{cmd:)} is specified ratios of directly standardized rates (SRR) are also computed. 
Modified F intervals of SRR are estimated as proposed by Tiwari.{p_end}


{p}Data must be in aggregate form, i.e. each record must contain the total number of deaths (or events)
and population for each stratum as follows

{center:{cmd:Age strata     death        pop}}
{center:{hline 40}}
{center: {cmd:   0-44        164       47346}}
{center:{cmd:   45-54        143       83173}}
{center:{cmd:   55-64        202      186108}}
{center:{cmd:   65-74        208      322065}}
{center:{cmd:     75+        283      362051}}
{center:{hline 40}}



{p}{cmd:using} {it:filename} specifies a file containing standard population weigths, typically stratified 
by age and optionally by other variables. This file must be sorted by the variable specified in {cmd:standstrata()}{p_end}



{title:Options}

{p 0 4}{cmdab:stand:strata}{cmd:(}{it:stratavars}{cmd:)} specifies the variables defining strata across which 
to average stratum-specific rates. These variables must be present in the study population and in the standard population
file. This is most often a unique variable containing age categories.{p_end}


{p 0 4}{cmd:by}{cmd:(}{it:varlist}{cmd:)} produces directly standard rates for each group identified by equal values of the
{cmd:by()} variables taking on integer or string values.{p_end}


{p 0 4}{cmdab:popstand}{cmd:(}{it:varname}{cmd:)} specifies the variable in the using file that contains 
the standard population weights. If not specified {cmd:distrate} assumes that it is named as {it:popvar} in the
study population.{p_end}


{p 0 4}{cmdab:list}{cmd:(}{it:varlist}{cmd:)} specifies the variables to be listed.{p_end}


{p 0 4}{cmd:sepby}{cmd:(}{it:varlist}{cmd:)} draws a separator line whenever {it:varlist} values change. {p_end}


{p 0 4}{cmdab:f:ormat:(%}{it:fmt}{cmd:)} specifies the {help format} for variables containing the estimates.{p_end}


{p 0 4}{cmd:formatn}{cmd:(}{it:#}{cmd:)} specifies the {it:#} of digits for the format of the N {it:(population)} variable.{p_end}


{p 0 4}{cmd:mult}{cmd:(}{it:#}{cmd:)} specifies the units to be used in reported results. For example, if the analysis time is in years,
specifying mult(100000) results in rates per 100,000 person-years.{p_end}


{p 0 4}{cmd:fay} additionally displays Fay and Feuer (1997) upper confidence limit. Note that Fay and Feuer lower confidence limit is 
equal to Tiwari, Clegg and Zou lower limit.{p_end}


{p 0 4}{cmd:dobson} additionally displays Dobson, Kuulasmaa, Eberle and Scherer (1991) confidence limits.{p_end}


{p 0 4}{cmd:refrate(}{it:#}{cmd:)} specifies the directly standardized rate (DSR) to be used in the denominator when standardized rate ratios 
(SRR) are computed. When DSR are required for each level of the variables in {cmd:by}{cmd:(}{it:varlist}{cmd:)}
SRR are calculated as ratio of each DSR in the numerator with the DSR listed as first in the denominator. 
{cmd:refrate(}{it:#}{cmd:)} allows to use a different DSR in the denominator.{p_end}


{p 0 4}{cmd:level}{cmd:(}{it:#}{cmd:)} specifies the confidence level, in percent, for the confidence 
interval of the adjusted rate; see help {help level}.{p_end}


{p 0 4}{cmdab:sa:ving}{cmd:(}{it:filename}[{it:,replace}]{cmd:)} allows to save the estimates in a file.{p_end}


{p 0 4}{cmdab:pre:fix}{cmd:(}{it:string}{cmd:)}  {it:or} {cmdab:post:fix}{cmd:(}{it:string}{cmd:)} adds a prefix or a 
suffix to the variable names when the estimates are saved.{p_end}



{title:Example}

{p 12 20}{inp:use "C:\Data\SuffolkCounty.dta", clear}{p_end}
{p 12 20}{inp:collapse (sum)  deaths pop,by(cindpov agegr)}{p_end}

{p 12 20}{inp:distrate deaths pop using year2000st, stand(agegr) by(cindpov) mult(100000)}{p_end}


{p}Further options{p_end}

{p 12 20}{inp:distrate deaths pop using year2000st, stand(agegr) by(cindpov) saving(DirectSuffolk,replace)}
{inp:format(%8.2f) mult(100000) fay dobson level(90) list(rateadj lb_gam ub_gam ub_f lb_d ub_d srr lb_srr ub_srr)}{p_end}



{p}Downloading ancillary files in one of your {cmd:`"`c(adopath)'"'} directory you can run this example.{p_end}

	  {it:({stata "distrate_example SuffolkCounty":click to run})}



{title:Saved results}

{pstd}
{cmd:distrate} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(k)}}number of groups identified by distinct values of the by() variables{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(Nobs)}}1 x k vector of study population{p_end}
{synopt:{cmd:r(NDeath)}}1 x k vector of number of events{p_end}
{synopt:{cmd:r(crude)}}1 x k vector of crude rates{p_end}
{synopt:{cmd:r(adj)}}1 x k vector of adjusted rates{p_end}
{synopt:{cmd:r(lb_G)}}1 x k vector of lower bound of Tiwari CI of adjusted rates{p_end}
{synopt:{cmd:r(ub_G)}}1 x k vector of upper bound of Tiwari CI of adjusted rates{p_end}
{synopt:{cmd:r(se_gam)}}1 x k vector of standard error of adjusted rates{p_end}
{synopt:{cmd:r(ub_F}}1 x k vector of upper bound of Fay CI of adjusted rates{p_end}
{synopt:{cmd:r(lb_D)}}1 x k vector of lower bound of Dobson CI of adjusted rates{p_end}
{synopt:{cmd:r(ub_D)}}1 x k vector of upper bound of Dobson CI of adjusted rates{p_end}
{synopt:{cmd:r(srr)}}1 x k vector of standardized rate ratios{p_end}
{synopt:{cmd:r(lb_srr)}}1 x k vector of lower bound of standardized rate ratios{p_end}
{synopt:{cmd:r(ub_srr)}}1 x k vector of upper bound of standardized rate ratios{p_end}
{p2colreset}{...}



{title:Authors}

{p} Enzo Coviello ({browse "mailto:enzo.coviello@tin.it":enzo.coviello@tin.it}){p_end}
{p} Dario Consonni{p_end}
{p} Carlotta Buzzoni{p_end}
{p} Carolina Mensi{p_end}


{title:References}

{p} Dobson AJ, Kuulasmaa K, Ederle E, Scherer J. Confidence intervals for weighted sums of Poisson parameters. {it: Statistics in Medicine} 1991;10: 457-462.{p_end}

{p} Fay MP, Feuer EJ. Confidence intervals for directly standardized rates: a method based on the gamma distribution. 
{it: Statistics in Medicine} 1997; 16:791-801.{p_end}

{p} Tiwari RC, Clegg LX, Zou Z. Efficient interval estimation for age-adjusted cancer rates. 
{it: Statistical Methods in Medical Research} 2006; 15: 547-569.{p_end}

{p} Consonni D, Coviello E, Buzzoni C, Mensi C. A command to calculate age-standardized rates with efficient interval estimation. 
{it: Stata Journal} 2012; 12: 688-701.{p_end}

{p}Public Health Disparities Geocoding Project Monograph.
{browse "http://www.hsph.harvard.edu/thegeocodingproject/webpage/monograph/case_example.htm":CASE EXAMPLE: Analysis of all cause mortality rates in Suffolk County, Massachusetts, 1989-1991, by CT poverty strata}


{title:Also see}

{p 0 19}On-line:  help for {help dstdize}
