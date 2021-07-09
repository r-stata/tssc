{smcl}
{* *! version 1.0.0 04Sep2019}{...}

{title:Title}

{p2colset 5 16 17 2}{...}
{p2col:{hi:seqfind} {hline 2}} Finds the sequence of a numeric character within a variable list {p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 14 2}
{cmd:seqfind}
{newvar}
{ifin}
{cmd:,}
{opth vars(varlist)}
{opt char:val(#)}
{opt len:gth(#)}


{title:Options}

{p 4 8 2}
{opth vars(varlist)} specifies the {it:varlist} in which the sequence is to be evaluated. All variables in the {it:varlist} must be numeric, therefore string variables must be converted to numeric or encoded (see {help encode}); 
{cmd:vars() is required}.

{p 4 8 2}
{opt char:val(#)} specifies the numeric character value to be evaluated;  {cmd:charval() is required}.

{p 4 8 2}
{opt len:gth(#)} specifies the length of the sequence to be evaluated. {cmd:length()} must be greater than 0 and less than the count of variables in {cmd:vars()}; {cmd:length() is required}.



{marker description}{...}
{title:Description}

{pstd}
{opt seqfind} generates a {newvar} indicating whether a specified numeric character appears in a sequence of a specified length within a {varlist}.



{title:Examples}

{pmore}Setup{p_end}
{pmore2}{bf:{stata "use seqfinddata.dta": . use seqfinddata.dta}} {p_end}

{pmore} Create a variable indicating whether the character value 1 appears in a sequence of 3 within the varlist t1 through t6. {p_end}
{pmore2}{bf:{stata "seqfind seq1, vars(t1-t6) char(1) len(3)": . seqfind seq1, vars(t1-t6) char(1) len(3)}} {p_end}

{pmore} Create a variable indicating whether the character value 2 appears in a sequence of 2 within the varlist t1 through t6. {p_end}
{pmore2}{bf:{stata "seqfind seq2, vars(t1-t6) char(2) len(2)": . seqfind seq2, vars(t1-t6) char(2) len(2)}} {p_end}

{pmore} Create a variable indicating whether the character value 1 appears in a sequence of 2 within the varlist t1 through t6 for age < 50. {p_end}
{pmore2}{bf:{stata "seqfind seq3 if age <50, vars(t1-t6) char(1) len(2)": . seqfind seq3 if age <50, vars(t1-t6) char(1) len(2)}} {p_end}



{marker citation}{title:Citation of {cmd:seqfind}}

{p 4 8 2}{cmd:seqfind} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{p 4 8 2}
Linden A. (2019). SEQFIND: Stata module to find the sequence of a numeric character within a variable list {p_end}


{title:Authors}

{p 4 4 2}
Ariel Linden{break}
President, Linden Consulting Group, LLC{break}
alinden@lindenconsulting.org{break}



{title:Also see}

{p 4 8 2} Help: {helpb randtreatseq} (if installed) {p_end}

