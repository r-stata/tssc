{smcl}
{* 1 Dec 2011}{...}
{cmd:help mcmcsummarize}
{hline}

{title:Syntax}

{p 8 12 2}
{cmd:mcmcsummarize} {varlist} {ifin} {cmd:,} {opth saving(filename)} [{it:options}]

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opth saving(filename)}}location to save file of results{p_end}
{synopt :{opt replace}}overwrite existing results file{p_end}
{synopt :{opth addpctiles(numlist)}}additional percentiles to report{p_end}
{synopt :{opt nopctiles}}do not report the percentiles calculated by {helpb summarize:summarize, detail}

{title:Description}

{p 4 4 2}
{cmd:mcmcsummarize} calculates summary statistics of draws from Markov chains in Markov Chain Monte Carlo (MCMC) estimation. 

{p 4 4 2}
The command assumes that you begin with a dataset in memory containing sequences of draws from one or more Markov chains. 
Each variable in {varlist} should contain draws of a different scalar estimand. 
The order of the draws is irrelevant. 

{p 4 4 2}
The command saves results in the file specified by {opth saving(filename)}. 
Each observation in the results file corresponds to a different scalar estimand. 
Each variable in the results file contains a different summary statistic.

{p 4 4 2}
By default, the summary statistics are the mean, the standard deviation, and all of the percentiles reported by {helpb summarize:summarize, detail}. 
To obtain additional percentiles, use {opth addpctiles(numlist)}. To skip the percentiles reported by {helpb summarize:summarize, detail}, specify {opt nopctiles}.

{title:Author}

{p 4 4 2}
Sam Schulhofer-Wohl, Federal Reserve Bank of Minneapolis, sschulh1.work@gmail.com. 
The views expressed herein are those of the author and not necessarily those of the Federal Reserve Bank of Minneapolis or the Federal Reserve System. 


