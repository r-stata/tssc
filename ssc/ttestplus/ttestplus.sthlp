{smcl}
{* February 6th 2012}{...}
{hline}
Help for {hi:ttestplus}
{hline}

{title:Description}

{p}{cmd:ttestplus} automates and tabulates t-tests on one or more dimensions across two populations indicated by a categorical variable. It can also cut a continuous variable at a specified value to serve as a categorical.

{p}Alternatively, {cmd:ttestplus} automates and tabulates t-tests on one analysis dimension across a population with characteristics defined by two or more binary categories.

{title:Syntax}

{cmd:ttestplus} {it:varlist} [{help if}] [{help in}], 
	{opt by:(groupvar | varlist)} 
	[{opt cut(value | mean | median)}]
	[{opt cl:uster(groupvar)}]
	[{opt t}] [{opt se}]

{synoptset}{...}
{marker Options}{...}
{synopthdr:Options}
{synoptline}
{p2coldent:* {opth by:(varlist:groupvar)}}Variable defining groups for comparison by {it:varlist}.{p_end}
{p2coldent:* {opth by:(varlist:varlist)}}List of binary variables for comparison. Cannot be combined with multiple analysis dimensions or with {opt cut}.{p_end}
{synopt:{opt cut()}}Cuts a continuous {it:groupvar} at the specified value, at its mean, or at its median.{p_end}
{synopt:{opt cl:uster}}Cluster results using the specified categorical variable. Requires the most recent version of {help clttest}.{p_end}
{synopt:{opt t}}Returns t-statistics instead of p-statistics.{p_end}
{synopt:{opt se}}Returns standard errors below group means.{p_end}
{synoptline}
{p 4 6 2}* Exactly one version of {opt by()} is required.{p_end}

{title:Examples}

{cmd:. sysuse nlsw88}
(NLSW, 1988 extract)

{cmd:. ttestplus married grade wage, by(collgrad)}

             |   Group 1    Group 2     p-Stat 
-------------+---------------------------------
     married |  .6406068   .6466165   .4003468 
       grade |  11.97371   16.71992          0 
        wage |  6.910561   10.52606   2.63e-38 

{cmd:. ttestplus married grade wage, by(hours) cut(median) se}

hours cut at 40 (median)

             |   Group 1    Group 2     p-Stat 
-------------+---------------------------------
     married |  .7220026   .6021578   9.53e-09 
          SE |  .0162725   .0127141          . 
       grade |  12.88801   13.20999     .00209 
          SE |  .0869087   .0669262          . 
        wage |  6.492085   8.430878   1.58e-14 
          SE |  .1552967   .1631842          . 

{cmd:. ttestplus married grade wage, by(hours) cut(median) cl(race) se}
 
hours cut at 40 (median)
Standard errors clustered by race

             |   Group 1    Group 2     p-Stat 
-------------+---------------------------------
     married |  .7220026   .6021578   .2720061 
          SE |   .131747   .1240575          . 
       grade |  12.88801   13.20999   .3269942 
          SE |  .4856302   .4555908          . 
        wage |  6.492085   8.430878   .0790578 
          SE |  .8183053   .7628162          . 

{cmd:. ttestplus wage, by(collgrad married union)}

             |   Group 1    Group 2     p-Stat 
-------------+---------------------------------
    collgrad |  6.910561   10.52606   2.63e-38 
     married |  8.080765   7.591978   .0268258 
       union |  7.204669   8.674294   1.91e-11

{cmd:. ttestplus wage, by(collgrad married union) cl(race)}
 
Standard errors clustered by race

             |   Group 1    Group 2     p-Stat 
-------------+---------------------------------
    collgrad |  6.910561   10.52606   .0120197 
     married |  8.080766   7.591978   .3471417 
       union |  7.204669   8.674294   .1185467 


{title:Saved Results}

{p}{cmd:ttestplus} saves its output in the matrix {cmd:results}.

{title:Author}

Benjamin Daniels
bbdaniels@gmail.com

{title:Acknowledgements}

{p}Thanks to Jeph Herrin, author of {cmd:cltest}, for updating his program for compatability and suggesting a correction for stratified data.

{p_end}