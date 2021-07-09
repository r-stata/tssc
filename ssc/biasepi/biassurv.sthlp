
{smcl}
{* 19April2019}{...}
{cmd:help biassurv}{right: ({browse "http://medical-statistics.dk/MSDS/epi/bias/bias.html":Quantitative Bais Aanlysis in Epidemiology})}
{hline}

{title:Title}

{p 4 4 2}{hi:biassurv} {hline 2} performs {it:bias analysis} for survival analysis


{title:Syntax}

{p 4 4 2}
{cmd:biassurv}
{it:indepvar}
{ifin}
[{cmd:,} {it:options}]

{synoptset 21 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opt lostp1(#)}}Number of person who were lost follow-up among the exposed{p_end}
{synopt :{opt lostp0(#)}}Number of person who were lost follow-up among the unexposed{p_end}
{synopt :{opt avet1(#)}}Follow-up time for the {it: lostp1} is in relative to the average follow-up time among the observed-exposed populaton{p_end}
{synopt :{opt avet0(#)}}Follow-up time for the {it: lostp0} is in relative to the average follow-up time among the observed-unexposed populaton{p_end}
{synopt :{opt ftime1(#)}}Assumed follow-up time for {it: lostp1}{p_end}
{synopt :{opt ftime0(#)}}Assumed follow-up time for {it: lostp0}{p_end}
{synopt :{opt aver1(#)}}Incidence Rate for the {it: lostp1} is in relative to the average incidence rate among the observed-exposed populaton{p_end}
{synopt :{opt aver0(#)}}Incidence rate for the {it: lostp0} is in relative to the average incidence rate among the observed-unexposed populaton{p_end}
{synopt :{opt rate1(#)}}Assumed incidence rate for {it: lostp1}{p_end}
{synopt :{opt rate0(#)}}Assumed incidence rate for {it: lostp0}{p_end}
{synopt :{opt case1(#)}}Number of cases among  {it: lostp1}{p_end}
{synopt :{opt case0(#)}}Number of cases among  {it: lostp0}{p_end}
{synoptline}

{p 4 4 2}
{cmd:biassurvi}
{it:case1num persons1num persontime1 case0num persons0num persontime0}
{ifin}
[{cmd:,} {it:options}]

{synoptset 21 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opt lostp1(#)}}Number of person who were lost follow-up among the exposed{p_end}
{synopt :{opt lostp0(#)}}Number of person who were lost follow-up among the unexposed{p_end}
{synopt :{opt avet1(#)}}Follow-up time for the {it: lostp1} is in relative to the average follow-up time among the observed-exposed populaton{p_end}
{synopt :{opt avet0(#)}}Follow-up time for the {it: lostp0} is in relative to the average follow-up time among the observed-unexposed populaton{p_end}
{synopt :{opt ftime1(#)}}Assumed follow-up time for {it: lostp1}{p_end}
{synopt :{opt ftime0(#)}}Assumed follow-up time for {it: lostp0}{p_end}
{synopt :{opt aver1(#)}}Incidence Rate for the {it: lostp1} is in relative to the average incidence rate among the observed-exposed populaton{p_end}
{synopt :{opt aver0(#)}}Incidence rate for the {it: lostp0} is in relative to the average incidence rate among the observed-unexposed populaton{p_end}
{synopt :{opt rate1(#)}}Assumed incidence rate for {it: lostp1}{p_end}
{synopt :{opt rate0(#)}}Assumed incidence rate for {it: lostp0}{p_end}
{synopt :{opt case1(#)}}Number of cases among  {it: lostp1}{p_end}
{synopt :{opt case0(#)}}Number of cases among  {it: lostp0}{p_end}
{synoptline}

{title:Description}

{pstd}
Command {helpb biassurv}, which is one of the command among the package {helpb biasepi}, performs {it:bias analysis} for survival analysis.{p_end}
{pstd}
Combining the existing Stata commands for probalistic distributions, {helpb biascon} is able to perform {it: probalistic bias analysis}

{title:Options} 


{phang} 
{opt lostp1} Number of person who were lost follow-up among the exposed.

{phang} 
{opt lostp1} Number of person who were lost follow-up among the unexposed.

{phang} 
{opt avet1} Follow-up time for the {it: lostp1} is in relative to the average follow-up time among the observed-exposed populaton. 
            If avet1=1, it means the follow-up for {it: lostp1} on average equals to the average follow-up time among the observed-exposed populaton.

{phang} 
{opt avet0} Follow-up time for the {it: lostp0} is in relative to the average follow-up time among the observed-exposed populaton. 
            If avet0=1, it means the follow-up for {it: lostp1} on average equals to the average follow-up time among the observed-unexposed populaton.

{phang} 
{opt ftime1} Assumed follow-up time for {it: lostp1}, which will overwrite {it: avet1}.

{phang} 
{opt ftime0} Assumed follow-up time for {it: lostp0}, which will overwrite {it: avet0}.

{phang} 
{opt aver1} Incidence Rate for the {it: lostp1} is in relative to the average incidence rate among the observed-exposed populaton.
            If aver1=1, it means the incidence rate for {it: lostp1} equals to the incidence rate among the observed-exposed populaton.

{phang} 
{opt aver0} Incidence Rate for the {it: lostp0} is in relative to the average incidence rate among the observed-unexposed populaton.
            If aver0=1, it means the incidence rate for {it: lostp1} equals to the incidence rate among the observed-exposed populaton.

{phang} 
{opt rate1} Assumed incidence rate for {it: lostp1}, which will overwrite {it: aver1}.

{phang} 
{opt rate0} Assumed incidence rate for {it: lostp0}, which will overwrite {it: aver0}.

{phang} 
{opt case1} Number of cases among  {it: lostp1}

{phang} 
{opt case0} Number of cases among  {it: lostp0}

{title:Examples}

{pstd}

{title:More examples} click on {browse "http://medical-statistics.dk/MSDS/epi/bias/bias.html":her}

{title:References} 

{phang}Lash, Timothy L., Fox, Matthew P., Fink, Aliza K. 2009.{p_end}
{phang}Applying Quantitative Bias Analysis to Epidemiologic Data {p_end}
{phang}{browse "https://sites.google.com/site/biasanalysis/": The online resource for the reference textbook.}


{title:Author}

{pstd}
Chunsen Wu, the University of Southern Denmark; Odense University Hospital, Denmark{break} 
{browse cwu@health.sdu.dk}{break} 
{browse chunsen.wu@rsyd.dk}


{title:Also see}

{p 7 14 2}
Help: {helpb biasepi}, {helpb biasselect}, {helpb biascon}, {helpb biasmis}, {helpb biassurv}, {helpb biastab2}
{p_end}



{marker results}{...}
{title:Stored results}

{pstd}
{cmd:biassurv} and {cmd:biassurvi} store the following in {cmd:r()}:


{synoptset 10 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(O)}}Results among the observed population{p_end}
{synopt:{cmd:r(C)}}Results among the whole population combining both the observed population and the lost follow-up{p_end}
{synopt:{cmd:r(L)}}Results among the lost follow-up{p_end}


