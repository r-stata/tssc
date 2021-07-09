{smcl}
{* *! version 1.0.0  02apr2020}{...}
{cmd:help epimodels}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col:{hi: epimodels} {hline 2} Implementation of epidemiological models and simulations.}
{p_end}
{p2colreset}{...}

The {cmd:epimodels} module for Stata allows calculation and calibration of 
SIR and SEIR models. 


{marker syntax}{...}
{title:Syntax}

{pin}
{cmdab:epimodels} ...

{pstd}
The commands are

{p2colset 9 33 35 2}{...}
{p2col :Command}Description{p_end}
{p2line}
{p2col :{helpb epimodels simulate}} epidemiological model simulation{p_end}
{p2col :{helpb epimodels fit}} epidemiological model calibration{p_end}
{p2line}
{p2colreset}{...}

{pstd}
The details are discussed for each model individually in the corresponding 
help files. {p_end}

See:

{phang}
{help epi_sir} for the instructions to the SIR model simulation
{p_end}

{phang}
{help epi_seir} for the instructions to the SEIR model simulation
{p_end}

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
