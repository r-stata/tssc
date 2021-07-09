
{smcl}
{* 19April2019}{...}
{cmd:help biasselect}{right: ({browse "http://medical-statistics.dk/MSDS/epi/bias/bias.html":Quantitative Bais Aanlysis in Epidemiology})}
{hline}

{title:Title}

{p 4 4 2}{hi:biasselect} {hline 2} performs {it:bias analysis} for selection bias


{title:Syntax}

{p 4 4 2}
{cmd:biasselect}
{it:depvar indepvar}
{ifin}
[{cmd:,} {it:options}]

{synoptset 21 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opt pa(#)}}The selection proportion for {it:a} and the default is {it:0.90}{p_end}
{synopt :{opt pb(#)}}The selection proportion for {it:b} and the default is {it:0.80}{p_end}
{synopt :{opt pc(#)}}The selection proportion for {it:c} and the default is {it:0.76}{p_end}
{synopt :{opt pd(#)}}The selection proportion for {it:d} and the default is {it:0.60}{p_end}
{synopt :{opt gen:erate}}generate {it:newvar} containing {it:weight} for each individual;{p_end}
{synoptline}

{p 4 4 2}
{cmd:biasselecti}
{it:a b c d}
{ifin}
[{cmd:,} {it:options}]

{synoptset 21 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opt pa(#)}}The selection proportion for {it:a} and the default is {it:0.90}{p_end}
{synopt :{opt pb(#)}}The selection proportion for {it:b} and the default is {it:0.80}{p_end}
{synopt :{opt pc(#)}}The selection proportion for {it:c} and the default is {it:0.76}{p_end}
{synopt :{opt pd(#)}}The selection proportion for {it:d} and the default is {it:0.60}{p_end}
{synoptline}

{title:Description}

{pstd}
Command {helpb biasselect}, which is one of the commands among the package {helpb biasepi}, performs {it:bias analysis} for the {it:selection bias}.{p_end}
{pstd}
Combining the three commands ({helpb biasselect}, {helpb biascon}, {helpb biasmis}) is able to perform {it:bias analysis} for selection. 
Combining the existing Stata commands for probalistic distributions, {helpb biasselect} is able to perform {it:probalistic bias analysis}

{title:Options} 

{phang}

{phang}
{opt pa} specifies the selection proportion ({it:pa}>0 and {it:pa}<=1) for {it:a} and the default is {it:0.90}

{phang}
{opt pb} specifies the selection proportion ({it:pb}>0 and {it:pb}<=1) for {it:b} and the default is {it:0.80}

{phang}
{opt pc} specifies the selection proportion ({it:pc}>0 and {it:pc}<=1) for {it:c} and the default is {it:0.75}

{phang}
{opt pd} specifies the selection proportion ({it:pd}>0 and {it:pd}<=1) for {it:d} and the default is {it:0.60}

{phang}
{opt generate} generates {it:newvar} containing {it:weight}, which is the inverse of the selection proportion, for each individual

{title:Examples}


{phang}1. Simple bias analysis: {p_end}
{phang}{stata "biasselecti 232 133 4677 6031, pa(0.90) pb(0.80) pc(0.75) pd(0.60)": .biasselecti 232 133 4677 6031, pa(0.90) pb(0.80) pc(0.75) pd(0.60)} {p_end}


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
{cmd:biasselect} and {cmd:biasselecti} store the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(RR_Observed)}}Risk ratio for the observed 2*2 table{p_end}
{synopt:{cmd:r(OR_Observed)}}Odds ratio for the observed 2*2 table{p_end}
{synopt:{cmd:r(RD_Observed)}}Risk difference for the observed 2*2 table{p_end}
{synopt:{cmd:r(RR_Corrected)}}Risk ratio for the corrected 2*2 table{p_end}
{synopt:{cmd:r(OR_Corrected)}}Odds ratio for the corrected 2*2 table{p_end}
{synopt:{cmd:r(RD_Corrected)}}Risk difference for the corrected 2*2 table{p_end}
{synopt:{cmd:r(RR_Missed)}}Risk ratio for the missed 2*2 table{p_end}
{synopt:{cmd:r(OR_Missed)}}Odds ratio for the missed 2*2 table{p_end}
{synopt:{cmd:r(RD_Missed)}}Risk difference for the missed 2*2 table{p_end}
{p2colreset}{...}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(O)}}Observed 2*2 table{p_end}
{synopt:{cmd:r(C)}}Corrected 2*2 table{p_end}
{synopt:{cmd:r(B)}}Bias parameters 2*2 table{p_end}
{synopt:{cmd:r(M)}}Missed 2*2 table{p_end}
{synopt:{cmd:r(R)}}RR, OR, and RD{p_end}


