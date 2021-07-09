{smcl}
{* *! version 1.0.0 23Sep2018}{...}
{title:Title}

{p2colset 5 17 22 2}{...}
{p2col:{hi:genidseq} {hline 2}} Generates numeric sequence to represent long identifiers {p_end}
{p2colreset}{...}



{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:genidseq} 
{it:ID-varname} 
{cmd:,} 
{opth g:enerate(newvarname)}
[ {opt s:tart}{it:(#)}
{opt i:ncrement}{it:(#)}
{opt nos:ort} ]



{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{p2coldent :* {opth g:enerate(newvarname)}}generate {it:newvar} to represent {it:ID-varname} {p_end}
{synopt :{opt s:tart(#)}}set starting value for the sequence; default is {cmd:1}{p_end}
{synopt :{opt i:ncrement(#)}}set increment value for the sequence; default is {cmd:1}{p_end}
{synopt :{opt nos:ort}}do not sort the data by {it:ID-varname}; default is to sort by {it:ID-varname}{p_end}
{synoptline}
{pstd}* {opt generate(newvarname)} is required.

{p 4 6 2}
{p2colreset}{...}                               
        
{title:Description}

{pstd}
{cmd:genidseq} generates a numeric sequence of values to better represent an existing identifier variable that may be too long to be visually helpful (this is
typical in health care data where patient identifiers are purposely generated to be long and scrambled). The new ID sequence can be specified to start at any integer
value and increase in any integer increment (with the default to start at 1 and increase in an increment of 1). 


{title:Examples}

    {pstd}Assume the following existing identifier:{p_end}

	patientID
	---------------
	259000401100365
	259000401100365
	259000401100365
	260000407995214
	260000407995214
	260000407995214
	271000408055062
	271000408055062
	271000408055062
	301000408997734
	301000408997734
	301000408997734
	330000411484007
	330000411484007
	330000411484007
	259504413317405
	259504413317405
	259504413317405

	{pstd}Typing:{p_end}

	{phang2}{cmd:. genidseq patientID, gen(id)}{p_end}
	
    {pstd}will produce:{p_end}

	patientID		id
	---------------		---
	259000401100365		1
	259000401100365		1
	259000401100365		1
	260000407995214		2
	260000407995214		2
	260000407995214		2
	271000408055062		3
	271000408055062		3
	271000408055062		3
	301000408997734		4
	301000408997734		4
	301000408997734		4
	330000411484007		5
	330000411484007		5
	330000411484007		5
	259504413317405		6
	259504413317405		6
	259504413317405		6


	{pstd}while typing:{p_end}

	{phang2}{cmd:. genidseq patientID, gen(id) start(10) incr(10)}{p_end}
	
    {pstd}will produce:{p_end}

	patientID		id
	---------------		---
	259000401100365		10
	259000401100365		10
	259000401100365		10
	260000407995214		20
	260000407995214		20
	260000407995214		20
	271000408055062		30
	271000408055062		30
	271000408055062		30
	301000408997734		40
	301000408997734		40
	301000408997734		40
	330000411484007		50
	330000411484007		50
	330000411484007		50
	259504413317405		60
	259504413317405		60
	259504413317405		60



{marker citation}{title:Citation of {cmd:genidseq}}

{p 4 8 2}{cmd:genidseq} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{p 4 8 2}
Linden, Ariel (2018). genidseq: Stata module for generating a numeric sequence to represent long identifiers.{p_end}


{title:Author}

{p 4 8 2}	Ariel Linden{p_end}
{p 4 8 2}	President, Linden Consulting Group, LLC{p_end}
{p 4 8 2}{browse "mailto:alinden@lindenconsulting.org":alinden@lindenconsulting.org}{p_end}
{p 4 8 2}{browse "http://www.lindenconsulting.org"}{p_end}

         

{title:Also see}

{p 4 8 2} Online: {helpb encode}, {helpb recode}{p_end}

