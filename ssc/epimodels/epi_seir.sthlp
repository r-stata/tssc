{smcl}
{* *! version 1.0.0  02apr2020}{...}
{cmd:help epi_seir}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col:{hi: epi_seir} {hline 2} Implementation of SEIR epidemiological model and simulations.}
{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 12 2}
{cmd: epi_seir ,}
{it:options}


{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Model parameters (if any of the options below is not specified, value 0 is assumed)}

{synopt :{opt beta(#)}}The model parameter controlling how often a 
susceptible-infected contact results in a new infection{p_end}
{synopt :{opt gamma(#)}}The model parameter controlling for the rate of recovery{p_end}
{synopt :{opt sigma(#)}}The model parameter controlling the rate 
at which an exposed individual becomes infected{p_end}
{synopt :{opt mu(#)}}The model parameter reflecting natural mortality 
rate unrelated to the epidemic. The model assumes constant population 
size, so mortality is compensated by the equivalent fertility 
replenishing the susceptible population.{p_end}
{synopt :{opt nu(#)}}The model parameter controlling vaccination rate 
transferring a susceptible individual directly to recovered state.{p_end}

{syntab :Initial conditions (if any of the options below is not specified, value 0 is assumed)}
{synopt :{opt susceptible(#)}}Number of susceptible individuals at t0{p_end}
{synopt :{opt exposed(#)}}Number of exposed individuals at t0{p_end}
{synopt :{opt infected(#)}}Number of infected individuals at t0{p_end}
{synopt :{opt recovered(#)}}Number of recovered individuals at t0{p_end}

INCLUDE help epimodels_common_options

{synoptline}
{p2colreset}{...}

{title:Description}

{pstd}
{cmd: epi_seir} calculates the deterministic SEIR model (susceptible-exposed-
infected-recovered), which is a theoretical model of the number of infected
individuals in a closed population over time. The model is commonly used for
modeling the development of directly transmitted infectious diseases (spread 
through contacts between individuals). The model differs from SIR by the 
introduction of another state ({it:Exposed}). The persons in this state have 
had a contact with an infected person, but are not infectious themselves.{p_end}

{pstd}
The initial conditions must be specified in absolute numbers, (not as shares, or in percent).{p_end}

{pstd}
The output can be produced in absolute numbers, or in percentages.{p_end}

{pstd}
The model is solved numerically by applying the fourth-order Runge-Kutta algorithm.{p_end}

INCLUDE help epimodels_common_output

{title:Examples}

    {hline}
	
{pstd}Simulation{p_end}
{phang2}
{cmd:. epi_seir , days(15) beta(0.9) gamma(0.2) sigma(0.5) susceptible(10) infected(1) } {p_end}

{pstd}Perform SEIR model simulation for a population of 10 susceptible and 1
infected individuals over 15 days, and with specified values of the model
parameters. Then draw a graph of the number of individuals in each state.
{p_end}

{phang2}
{cmd:. epi_seir , days(15) beta(0.9) gamma(0.2) sigma(0.5) susceptible(10) infected(1) recovered(2) clear}
{p_end}

{pstd}Same as above, but start also with 2 recovered individuals, and clear the 
data in memory (if any).{p_end}

{phang2}
{cmd:. epi_seir , days(15) beta(0.9) gamma(0.2) sigma(0.5) susceptible(10) infected(1) recovered(2) clear nograph}
{p_end}

{pstd}Same as above, but without plotting any graph.{p_end}

{phang2}
{cmd:. epi_seir , days(15) day0("2020-02-29") beta(0.9) gamma(0.2) sigma(0.5) susceptible(10) infected(1) recovered(2) clear}
{p_end}

{pstd}Same as above, but with plotting of the graph and indicating that day zero 
of the simulation corresponds to February 29, 2020.{p_end}

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
{p_end}
