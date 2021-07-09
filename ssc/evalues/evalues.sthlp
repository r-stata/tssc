

{smcl}
{* 8mar2018/3july2018/28Nov2018}{...}
{cmd:help evalue}{right: ({browse "http://medical-statistics.dk/MSDS/epi/evalue/evalue.html":E-value in Epidemiology})}
{hline}

{title:Title}

{p 4 4 2}{hi:evalue} {hline 2} calculate E-values


{title:Syntax}

{p 8 17 2}
{cmd:evalue}
{it:theObservedEffect}
{ifin}
[{cmd:,} {it:options}
]

{synoptset 21 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opt m:easurement}}The effect measurement (risk ratio, odds ratio, and hazard ratio); Default is risk ratio.{p_end}
{synopt :{opt l:owlimit}}The low limite of 95%CI{p_end}
{synopt :{opt u:plimit}}The up limite of 95%CI{p_end}
{synopt :{opt r:areoutcome}}Rare outcome assumption, for example the prevalence <= 0.15{p_end}
{synoptline}

{title:Description}

{pstd}
Command {helpb evalue} calculate E-value for an observed risk ratio, odds ratio, and hazard ratio.{p_end}

{title:Options} 

{phang}
{opt measurement} specifies the effect measurement, including 1 (risk ratio), 2 (odds ratio), and 3 (hazard ratio). Default is 1 (risk ratio). 

{phang}
{opt lowlimit} specifies the value for the low limit of 95%CI 

{phang}
{opt uplimit} specifies the value for the low limit of 95%CI  

{phang}
{opt rareoutcome} the rare outcome assmption; Default value=1 assumes the outcome is relatively rare (the prevalence<=0.15), otherwise, input 0 if the the outcome is relatively common. 

       
{title:Examples: click on the text in blue}

{pstd}

{phang}1. E-value for an observed risk ratio {p_end}
{phang}{stata "evalue 1.61, m(1)": .evalue 2.95, m(1)} {p_end}

{phang}1. E-value for an observed risk ratio and the low limit of 95%CI {p_end}
{phang}{stata "evalue 1.61, m(1) l(1.06) ": .evalue 1.61, m(1) l(1.06) } {p_end}

{phang}1. E-value for an observed odds ratio if the outcome is relatively rare (the prevalence <=0.15) {p_end}
{phang}{stata "evalue 2.02, m(2)": .evalue 2.02, m(2)} {p_end}

{phang}1. E-value for an observed odds ratio and the low limit of 95%CI if the outcome is relatively rare (the prevalence <=0.15){p_end}
{phang}{stata "evalue 2.02, m(2) l(1.08) ": .evalue 2.02, m(2) l(1.08) } {p_end}

{phang}1. E-value for an observed odds ratio if the outcome is common (the prevalence >0.15) {p_end}
{phang}{stata "evalue 2.02, m(2) r(0)": .evalue 2.02, m(2) r(0)} {p_end}

{phang}1. E-value for an observed odds ratio andthe low limit of 95%CI if the outcome is common (the prevalence >0.15){p_end}
{phang}{stata "evalue 2.02, m(2) l(1.08)  r(0)": .evalue 2.02, m(2) l(1.08)  r(0)} {p_end}

{phang}1. E-value for an observed hazard ratio if the outcome is relatively rare (the prevalence <=0.15) {p_end}
{phang}{stata "evalue 0.10, m(3)": .evalue 0.10, m(3)} {p_end}

{phang}1. E-value for an observed hazard ratio and the uplimit of 95%CI  if the outcome is relatively rare (the prevalence <=0.15){p_end}
{phang}{stata "evalue 0.10, m(3)  u(0.26)": .evalue 0.10, m(3)  u(0.26)} {p_end}

{phang}1. E-value for an observed odds ratio if the outcome is common (the prevalence >0.15) {p_end}
{phang}{stata "evalue 0.10, m(3) r(0)": .evalue 0.10, m(3) r(0)} {p_end}

{phang}1. E-value for an observed odds ratio and the up limit of 95%CI if the outcome is common (the prevalence >0.15){p_end}
{phang}{stata "evalue 0.10, m(3)  u(0.26) r(0)": .evalue 0.10, m(3)  u(0.26) r(0)} {p_end}


{title:More examples} click on {browse "http://medical-statistics.dk/MSDS/epi/evalue/evalue.html":her}


{title:References} 

{phang}VanderWeele TJ, Ding P.{p_end}
{phang}{browse "https://www.ncbi.nlm.nih.gov/pubmed/28693043":Sensitivity Analysis in Observational Research: Introducing the E-Value.}


{title:Author}

{pstd}
Chunsen Wu, the University of Southern Denmark; Odense University Hospital, Denmark{break} 
{browse cwu@health.sdu.dk}{break} 
{browse chunsen.wu@rsyd.dk}

{title:Also see}

{p 7 14 2}
Help: {helpb dag}, {helpb biasepi}
{p_end}
