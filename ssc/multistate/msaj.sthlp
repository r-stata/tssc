{smcl}
{* *! version 0.2 28Dec2017}{...}
{cmd:help msaj} 
{right:also see:  {help msset}, {help predictms}}

{title:Title}

{p2colset 5 14 16 2}{...}
{p2col :{hi:msaj} {hline 2}}Aalen-Johansson estimates of transition probabilities{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 16 2}{cmd:msaj} {ifin} {cmd:,} [{opt transmatrix(matrix)} {it:options}]

{marker options}{...}
{synoptset 29 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt id(varname)}}identification variable{p_end}
{synopt :{opt by(varname)}}calculate by {it:varname}{p_end}
{synopt :{opt gen(varlist)}}names of variables to be created{p_end}
{synopt :{opt transm:atrix(matrix)}}name of transition matrix{p_end}
{synopt :{opt ci}}calculate confidence intervals{p_end}
{synopt :{opt cr}}shortcut for competing risks{p_end}

{synoptline}
{p 4 6 2}

{title:Description}

{pstd}
{cmd:msaj} calculates the Aalen-Johansson estimates of the transition probabilities. Before using {cmd:msAJ} 
you should use {cmd:msset} and then {cmd:stset}. See the example below.{p_end}


{title:Options}

{phang}
{opt id(varname)} defines the identification variable. This should be the same variables defined when using {cmd:msset}.

{phang}
{opt by(varname)} will create estimates separately by {it:varname}. 

{phang}
{opt ci} calculate confidence intervals for the transition probabilities.

{phang}
{opt cr} states that it is a competing risks analysis, i.e. all transitions are in first row of transition matrix. 
This means that it is not necessary to specify the {opt transmatrix()} option.

{phang}
{opt gen(stub | newvarnames)} gives the new variables to create. This can be specified as a {it	:varlist} equal to the number of states in the transition matrix or a {it:stub} where new variables are named {it:stub1 - stubn}. If this option is not specified, the names default to {cmd:P_AJ_1} to {cmd:P_AJ_n}.

{phang}
{opt transmatrix(matrix)}  specifies the transition matrix used in the multi-state model that was fitted. This must be an upper triangular matrix (with diagonal and lower triangle elements coded missing). Transitions must be numbered as an increasing sequence of integers from 1,...,K. This transition matrix should be the same as that used/produced by msset.

{title:Remarks}

{pstd}
Any remarks

{title:Examples}


{pstd}Load example dataset:{p_end}
{phang}{stata "use http://fmwww.bc.edu/repec/bocode/m/multistate_example":. use http://fmwww.bc.edu/repec/bocode/m/multistate_example}{p_end}

{pstd}{cmd:msset} the data:{p_end}
{phang}{stata "msset, id(pid) states(rfi osi) times(rf os)":. msset, id(pid) states(rfi osi) times(rf os)}{p_end}

{pstd}Store the transition matrix:{p_end}
{phang}{stata "mat tmat = r(transmatrix)":. mat tmat = r(transmatrix)}{p_end}

{pstd}stset the data using the variables created by {cmd:msset}{p_end}
{phang}{stata "stset _stop, enter(_start) failure(_status=1)":. stset _stop, enter(_start) failure(_status=1)}{p_end}

{pstd}Calculate transition probabilities using {cmd:msaj}{p_end}
{phang}{stata "msaj, id(pid) transmat(tmat) ci":. msaj, id(pid) transmat(tmat) ci}{p_end}

{pstd}Probability in State 1 (alive){p_end}
{phang}{stata "line P_AJ_1* _t, sort connect(stairstep)":. line P_AJ_1* _t, sort connect(stairstep)}{p_end}

{pstd}Probability in State 2 (recurrance){p_end}
{phang}{stata "line P_AJ_2* _t, sort connect(stairstep)":. line P_AJ_2* _t, sort connect(stairstep)}{p_end}

{pstd}Probability in State 3 (dead){p_end}
{phang}{stata "line P_AJ_3* _t, sort connect(stairstep)":. line P_AJ_3* _t, sort connect(stairstep)}{p_end}


{title:Author}

{pstd}
Paul Lambert, University of Leicester, UK and Karolinska Institutet, Stockholm, Sweden.
({browse "mailto:paul.lambert@leicester.ac.uk":paul.lambert@leicester.ac.uk})

{pstd}
Michael Crowther, University of Leicester, UK.
({browse "michael.crowther@le.ac.uk":michael.crowther@le.ac.uk})

{title:References}

{phang}
Andersen PK, Borgan O, Gill RD, Keiding N. {it:Statistical models based on counting processes}. Springer Sreies in Statistics 1992.

{phang}
Putter H, Fiocco M, Geskus RB. Tutorial in biostatistics: competing risks and multi-state models. 
{it:Statistics in Medicine} 2007;26:2389-2430.{p_end}


{title:Also see}

{psee}
Online:  {manhelp msset ST}; 
{p_end}
