{smcl}
{* *! version 1.0.2 26Jul2015}{...}
{cmd:help genstack}{right:Gregorio Impavido}
{hline}

{viewerjumpto "Syntax" "genstack##syntax"}{...}
{viewerjumpto "Description" "genstack##description"}{...}
{viewerjumpto "Examples" "genstack##examples"}{...}
{viewerjumpto "Authors" "genstack##authors"}{...}
{title:Title}

{p2colset 5 22 24 2}{...}
{p2col:genstack {hline 2}}Utility to generate stacked variables{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 12 2}
{cmdab: genstack} {it:varlist},
{opt gen:erate(stub)}
[{it:double}]


{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt gen:erate(stub)}}The mandatory option is needed to 
generate the stacked variables whose name starts with {it: stub}.{p_end}
{synopt:{opt double}}forces genstack to generate variables with double rpecision.{p_end}
{synoptline}
{p2colreset}{...}

{pstd}

{marker description}{...}
{title:Description}

{pstd}
{cmd:genstack} generates variables that can be displayed in a {cmd: graph twoway}
bar chart.

{pstd}
STATA can only produce oneway stacked charts. These however, do not allow you to 
layer other charts. Indeed, STATA is notoriously unfriendly in producing a twoway
stacked chart where you have the freedom of layering different chart styles. 
{cmd:genstack} helps you prepare the data for such charts. 

{pstd}
Version 1.0.1 of {cmd:genstack} now copies the labels of original variables to the 
stacked variables for better identification.

{pstd}
Version 1.0.2 of {cmd:genstack} now uses only a stub in the option {opt gen:erate()}
and checks that the the names of the stacked variables generated are permissible.

{marker examples}{...}
{title:Examples}

{pstd}
Assume you want to display k=4 variables ({cmd:genstack} can do this for an 
unlimited k but typically, anything with k>4 produces rather confusing charts) 
with positive and/or negative observations adding up to some total as stacked bars 
and then superimpose the total as line and/or dots. For all positive and negative 
observations separastely, {cmd:genstack} calculates for you the cumulative 
contribution of each variable to the row total. It then generates the cumulative 
variables in such an order so that they do not hide each other wahen layered 
in a {cmd:graph twoway}. 

{pstd}
The following is a basic example with k=4:

	********* start code here
	clear all
	local k 4  // Number of vars in the chart}
	set obs 20
	gen n = _n
	forval i = 1/`k' {
		gen v`i' = invnormal(uniform())
		label var v`i' "var `i'"
		}
	egen total = rowtotal(v*)
	genstack v1 v2 v3 v4, generate(c_) double
	graph twoway (bar c_v4 c_v3 c_v2 c_v1 n) (scatter total n) (line total n)
	********* end code here

{pstd}
NB: the order of the variables in -graph twoway- must be inverse of the order
used in -genstack-. In this example: (v1 v2 v3 v4) -> (c_v4 c_v3 c_v2 c_v1).  

{title:Authors}

{pstd}
Gregorio Impavido (gimpavido@imf.org){break}

