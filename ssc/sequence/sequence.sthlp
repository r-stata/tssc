{smcl}
{* *! version 1.0.0 14feb2019}{...}

{title:Title}

{p2colset 5 17 18 2}{...}
{p2col:{hi:sequence} {hline 2}} Generates versatile numerical sequences {p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 14 2}
{cmd:sequence}
{it: newvarname}
{cmd:,}
[ {opt f:rom(#)}
{opt t:o(#)}
{opt by(#)}
]


{synoptset 14 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt f:rom(#)}}the starting (lowest) value of the sequence. {cmd:from()} accepts negative and fractional values {p_end}
{synopt :{opt t:o()}}the ending (highest) value of the sequence. {cmd:to()} is required when the data contain no observations (_N == 0), and {cmd:to()} must be larger than {cmd:from()}{p_end}
{synopt:{opt by(#)}}the increment by which the sequence increases. {cmd:by()} must be a positive value. {cmd:by()} cannot be specified when there are observations in the current data (_N > 0) {p_end}
{synoptline}



{marker description}{...}
{title:Description}

{pstd}
{opt sequence} is a versatile alternative to official Stata's {helpb egen seq()} for generating numerical sequences. In contrast to {helpb egen seq()}, 
{opt sequence} can generate sequences when there are currently no observations in the data (_N == 0), and {opt sequence} accepts non-integer values for 
{cmd:from()}, {cmd:to()}, and {cmd:by()} options, thereby generating non-integer sequences. Like {helpb egen seq()}, {opt sequence} can generate 
sequences which are negative, or span from negative to positive values.



{title:Options}

{p 4 8 2}
{cmd:from(}{it:#}{cmd:)} specifies the starting (lowest) value of the sequence. Negative and fractional values may be specified.  

{p 4 8 2}
{cmd:to(}{it:#}{cmd:)} specifies the ending (highest) value of the sequence. Negative and fractional values may be specified but {cmd:to()} 
must be larger than {cmd:from()}. {cmd:to()} is required when the data contain no observations (_N == 0).

{p 4 8 2}
{cmd:by(}{it:#}{cmd:)} specifies the increment by which the sequence increases. {cmd:by()} must be a positive value but can take on fractional values. {cmd:by()} 
cannot be specified when _N > 0.



{title:Remarks}

{pstd}
{cmd:When _N == 0 (no observations)}:{p_end}

        and {cmd:from()} is not specified but {cmd:by()} is specified, {cmd:from()} is set to the modulus of {cmd:to()} and {cmd:by()}; 

        or when both {cmd:from()} and {cmd:by()} are not specified, {cmd:from()} and {cmd:by()} are set to 1; 

        or when {cmd:from()} is specified but {cmd:by()} is not specified, {cmd:by()} is set to abs(({cmd:to} - {cmd:from}) / ({cmd:to} - 1)).  


{pstd}
{cmd:When _N > 0 (observations exist in the data)}:{p_end}

        and {cmd:from()} is not specified, {cmd:from()} is set to 1;

        or when {cmd:to()} is not specified, {cmd:to()} is set to equal _N.



{title:Examples}

{pstd}
{opt 1) When _N == 0 (no observations in the data):}{p_end}
	
{pmore}Clear the data{p_end}
{pmore2}{bf:{stata "clear": . clear}} {p_end}

{pmore} Generate a sequence named "test" that ranges from -30 to 30 in increments of 0.5. We then run {helpb summarize} to see the results{p_end}
{pmore2}{bf:{stata "sequence test, from(-30) to(30) by(0.5)": . sequence test, from(-30) to(30) by(0.5)}} {p_end}
{pmore2}{bf:{stata "sum test": . sum test}} {p_end}

{pmore} Same as above but we do not specify {cmd:by()} {p_end}
{pmore2}{bf:{stata "clear": . clear}} {p_end}
{pmore2}{bf:{stata "sequence test, from(-30) to(30)": . sequence test, from(-30) to(30)}} {p_end}
{pmore2}{bf:{stata "sum test": . sum test}} {p_end}

{pmore} Same as above but we do not specify {cmd:from()} {p_end}
{pmore2}{bf:{stata "clear": . clear}} {p_end}
{pmore2}{bf:{stata "sequence test, to(30) by(0.5)": . sequence test, to(30) by(0.5)}} {p_end}
{pmore2}{bf:{stata "sum test": . sum test}} {p_end}

{pmore} Same as above but we specify only {cmd:to()} {p_end}
{pmore2}{bf:{stata "clear": . clear}} {p_end}
{pmore2}{bf:{stata "sequence test, to(30)": . sequence test, to(30)}} {p_end}
{pmore2}{bf:{stata "sum test": . sum test}} {p_end}


{pstd}
{opt 2) When _N > 0 (i.e. observations in the data):}{p_end}
	
{pmore}Use an existing dataset {p_end}
{pmore2}{bf:{stata "sysuse auto, clear": . sysuse auto, clear}} {p_end}

{pmore} Generate a sequence named "test1" that ranges from -30 to 30. We then run {helpb summarize} to see the results{p_end}
{pmore2}{bf:{stata "sequence test1, from(-30) to(30)": . sequence test1, from(-30) to(30)}} {p_end}
{pmore2}{bf:{stata "sum test1": . sum test1}} {p_end}

{pmore} Generate a sequence named "test2", specifying only {cmd:from()}{p_end}
{pmore2}{bf:{stata "sequence test2, from(-30)": . sequence test2, from(-30)}} {p_end}
{pmore2}{bf:{stata "sum test2": . sum test2}} {p_end}

{pmore} Generate a sequence named "test3", specifying only {cmd:to()}{p_end}
{pmore2}{bf:{stata "sequence test3, to(30)": . sequence test3, to(30)}} {p_end}
{pmore2}{bf:{stata "sum test3": . sum test3}} {p_end}

{pmore} Generate a sequence named "test4", with no options specified{p_end}
{pmore2}{bf:{stata "sequence test4": . sequence test4}} {p_end}
{pmore2}{bf:{stata "sum test4": . sum test4}} {p_end}



{marker citation}{title:Citation of {cmd:sequence}}

{p 4 8 2}{cmd:sequence} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{p 4 8 2}
Linden A. (2019). SEQUENCE: Stata module for generating versatile numeric sequences.
{p_end}



{title:Author}

{p 4 4 2}
Ariel Linden{break}
President, Linden Consulting Group, LLC{break}
alinden@lindenconsulting.org{break}



{title:Also see}

{p 4 8 2} Online: {helpb egen seq()}{p_end}

