{smcl}
{* *! version 1.0.0 09may016}{...}
{vieweralsosee "streg" "help streg"}{...}
{vieweralsosee "stpm2" "help stpm2"}{...}
{viewerjumpto "Syntax" "msset##syntax"}{...}
{viewerjumpto "Description" "msset##description"}{...}
{viewerjumpto "Options" "msset##options"}{...}
{viewerjumpto "Examples" "msset##examples"}{...}
{title:Title}

{p2colset 5 14 16 2}{...}
{p2col :{hi:msset} {hline 2}}data preparation for multi-state and competing risks analysis{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{phang2}
{cmd: msset} {ifin} {cmd:,} {opt id(varname)} {opth states(varlist)} {opth times(varlist)} [{it:options}]

{synoptset 29 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opth id(varname)}}identification variable{p_end}
{synopt:{opth states(varlist)}}indicator variables for each state{p_end}
{synopt:{opth times(varlist)}}time variables for each state{p_end}
{synopt:{opt transm:atrix(matname)}}transition matrix{p_end}
{synopt:{opth cov:ariates(varlist)}}variables to expand into transition specific covariates{p_end}
{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{cmd:msset} is a data preparation tool for multi-state and competing risks analysis. It turns a dataset from wide format (one observation per subject) 
into long format (one line for each transition that a subject is at risk). All other variables are expanded appropriately.
{p_end}

{pstd}
The user can provide a transition matrix using {bf:transmatrix()}, which must be an upper triangular matrix, with transitions numbered as an increasing sequence of integers from 
1,...,K. If {bf:transmatrix()} is left empty, a complete upper triangular transition matrix is constructed, assuming all possible transitions, with the number of states 
equal to the number of variables specified in {bf:states()}. All subjects are assumed to start in state {bf:_from = 1}, at time {bf:_start = 0}.
{p_end}

{pstd}
A warning is displayed if the next transition cannot be uniquely identified, i.e. multiple events occur with the same smallest event time, in which 
case the state with the smallest transition number is chosen, with the other states changed to censored.
{p_end}

{pstd}
{cmd:msset} creates the following variables:
{p_end}

	{bf:_from}    starting state
	{bf:_to}      receiving state
	{bf:_trans}   transition number
	{bf:_start}   starting time for each transition
	{bf:_stop}    stopping time for each transition
	{bf:_status}  status variable, indicating a transition (coded 1) or censoring (coded 0)
	{bf:_flag}    indicator variable to show observations where changes to the original data have been made
	
{phang}
{cmd:predictms} is part of the {cmd:multistate} package by Michael Crowther and Paul Lambert. Further 
details here: {bf:{browse "https://www.mjcrowther.co.uk/software/multistate":mjcrowther.co.uk/software/multistate}}
{p_end}

	
{marker options}{...}
{title:Options}

{phang}
{opt id(varname)} defines the identification variable. Each observation should be identified by a unique integer.

{phang}
{opt states(varlist)} specifies the event indicator variables corresponding to each state.

{phang}
{opt times(varlist)} specifies the time variables for each state, i.e. the times at which each state was entered, or censored. The variables should 
be ordered to correspond to the states specified in {bf:states()}.

{phang}
{opt transmatrix(matname)} specifies a user-defined transition matrix. This must be an upper triangular matrix (with diagonal and lower triangle elements 
coded missing). Transition must be numbered as an increasing sequence of integers from 1,...,K. If {bf:transmatrix()} is left empty, a complete transition 
matrix is constructed, assuming all possible transitions, with the number of states equal to the number of variables specified in {bf:states()}. All 
subjects are assumed to start in state {bf:_from = 1}, at time {bf:_start = 0}.

{phang}
{opt covariates(varlist)} expands covariates into transition-specific variables, by forming an interaction between each covariate 
and the _trans# variables. For use when wanting to specify transition-specific covariate effects when fitting a model to the stacked data.


{marker examples}{...}
{title:Example 1:}

{pstd}
This dataset contains information on 2982 patients with breast cancer. Baseline is defined as time of surgery, and patients can experience 
relapse, relapse then death, or death with no relapse. Time of relapse is stored in {cmd:rf}, with event indicator {cmd:rfi}, and time of death 
is stored in {cmd:os}, with event indicator {cmd:osi}.
{p_end}

{pstd}Load example dataset:{p_end}
{phang}{stata "use http://fmwww.bc.edu/repec/bocode/m/multistate_example":. use http://fmwww.bc.edu/repec/bocode/m/multistate_example}{p_end}

{pstd}{cmd:msset} the data:{p_end}
{phang}{stata "msset, id(pid) states(rfi osi) times(rf os)":. msset, id(pid) states(rfi osi) times(rf os)}{p_end}


{title:Saved results}

{pstd}
{bf:msset} returns the following in {bf:r()}:
{p_end}

{synoptset 22 tabbed}{...}
{p2col 5 15 19 2: Matrices:}{p_end}
{synopt:{cmd:r(Nnextstates)}} number of possible next states from starting state (row number){p_end}
{synopt:{cmd:r(transmatrix)}} transition matrix{p_end}
{synopt:{cmd:r(freqmatrix)}} frequencies of transitions{p_end}


{title:Author}

{pstd}Michael J. Crowther{p_end}
{pstd}Department of Health Sciences{p_end}
{pstd}University of Leicester{p_end}
{pstd}E-mail: {browse "mailto:michael.crowther@le.ac.uk":michael.crowther@le.ac.uk}{p_end}

{phang}
Please report any errors you may find.{p_end}

{phang}
{cmd:msset} is part of the {cmd:multistate} package by Michael Crowther and Paul Lambert.
{p_end}


{title:References}

{phang}
Crowther MJ and Lambert PC. Parametric multi-state survival models: flexible modelling allowing transition-specific distributions with application to estimating clinically useful measures of effect differences (Submitted).
{p_end}

{phang}
de Wreede LC, Fiocco M and Putter H. mstate: An R Package for the Analysis of Competing Risks and Multi-State Models. {it:Journal of Statistical Software} 2011;38:1-30.
{p_end}

{phang}
Putter H, Fiocco M and Geskus RB. Tutorial in biostatistics: competing risks and multi-state models. {it:Statistics in Medicine} 2007;26:2389-2430.
{p_end}

