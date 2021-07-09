{smcl}
{* *! version 1.0.0  02apr2020}{...}
{cmd:help epimodels}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col:{hi: epi_sir} {hline 2} Implementation of SIR epidemiological model and simulations.}
{p_end}
{p2colreset}{...}



{title:Syntax}

{p 8 12 2}
{cmd: epi_sir ,}
{it:options}


{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Model parameters (optional, assumed to be zero if not specified)}
{synopt :{opt beta(#)}}The model parameter controlling how often a 
susceptible-infected contact results in a new infection{p_end}
{synopt :{opt gamma(#)}}The model parameter controlling for the rate of recovery.{p_end}

{syntab :Initial conditions (optional, assumed to be zero if not specified)}
{synopt :{opt susceptible(#)}}Number of susceptible individuals at t0{p_end}
{synopt :{opt infected(#)}}Number of infected individuals at t0{p_end}
{synopt :{opt recovered(#)}}Number of recovered individuals at t0{p_end}

INCLUDE help epimodels_common_options

{synoptline}
{p2colreset}{...}

{title:Description}

{pstd}
{cmd: epi_sir} calculates the deterministic SIR model 
(susceptible-infected-recovered), which is a theoretical model of the number of 
infected individuals in a closed population over time.{p_end}

{pstd}
{it: "The SIR (susceptible-infected-removed) model was developed by Ronald Ross, William Hamer, and others in the early twentieth century." {browse "http://mat.uab.cat/matmat/PDFv2013/v2013n03.pdf":online}}{p_end}

{pstd}
The model is commonly 
used for modeling the development of directly transmitted infectious disease 
(spread through contacts between individuals). See {it:Kermack-McKendrick (1927)} 
for the model description and assumptions.{p_end}

{pstd}
The initial conditions must be specified in absolute numbers, 
(not as shares, or percentages).{p_end}

{pstd}
The output can be produced in absolute numbers, or in percentages.{p_end}

INCLUDE help epimodels_common_output

{title:Examples}

    {hline}
{pstd}Simulation{p_end}

{phang2}{cmd:. epi_sir , days(100) beta(0.9) gamma(0.3) susceptible(10) infected(1) }{p_end}

{pstd}Perform SIR model simulation for a population of 10 susceptible and 1 
infected individuals, with infection rate 0.9 and recovery rate 0.3 over 100 
days, and display graph{p_end}

{phang2}{cmd:. epi_sir , days(100) beta(0.9) gamma(0.3) susceptible(10) infected(1) recovered(2) clear}{p_end}

{pstd}Same as above, but start also with 2 recovered individuals, and clear 
the data in memory (if any).{p_end}

{phang2}{cmd:. epi_sir , days(100) beta(0.9) gamma(0.3) susceptible(10) infected(1) recovered(2) clear day0(2020-02-29)}{p_end}

{pstd}Same as above, but indicate dates on the graph starting from 
Feb.29, 2020 corresponding to day0 of the simulation.{p_end}

{phang2}{cmd:. epi_sir , days(100) beta(0.9) gamma(0.3) susceptible(10) infected(1) recovered(2) clear nograph}{p_end}

{pstd}Same as above, but without plotting any graph.{p_end}

{title:References}

{pstd}
Carlos Castillo-Chavez, Fred Brauer, Zhilan Feng (2019). Mathematical Models in Epidemiology. New York: Springer.{p_end}

{pstd}
Kermack, W. O. and McKendrick, A. G. (1927). Contributions to the mathematical 
theory of epidemics, part i. Proceedings of the Royal Society of Edinburgh. Section A. Mathematics. 115 700-721
{browse "https://royalsocietypublishing.org/doi/10.1098/rspa.1927.0118":online}{p_end}

{pstd}
The SIR Model for Spread of Disease. Mathematical Association of America. {browse "https://www.maa.org/press/periodicals/loci/joma/the-sir-model-for-spread-of-disease-the-differential-equation-model": online}{p_end}


{title:Authors}

{phang}
{it:Sergiy Radyakin}, The World Bank
{p_end}

{phang}
{it:Paolo Verme}, The World Bank
{p_end}

{title:Also see}

{psee}
Online: {browse "http://www.radyakin.org/stata/epimodels/": epimodels homepage}

