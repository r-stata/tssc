{smcl}
{* Februar 9, 2010 @ 15:44:14 UK}{...}
{hline}
help for {cmd:egen apport()}
{hline}

{title:Egen-function for apportionment methods}

{p 8 17 2}{cmd:egen}
[{it:type}]
{it:newvar}
{cmd:=}
{cmd:apport(}{it:votesvar}{cmd:)}
[{cmd:if} {it:exp}]
[{cmd:in} {it:range}]
[{cmd:,} {it:options}]

{synoptset 25}{...}
{synopthdr}
{synoptline}
{synopt:{opt m:ethod(keyword)}}apportionment method{p_end}
{synopt:{opt s:ize(#|varname)}}seats to be allocated{p_end}
{synopt:{opt t:hreshold(#|varname)}}barrier clause{p_end}
{synopt:{opth e:xceptions(exp)}}Exceptions from barrier clause{p_end}
{synopt:{opth by(varname)}}apply method by groups{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}

{p 0 0 4}The {help egen}-function {cmd:apport(}{it:varname}{cmd:)}
creates a new variable holding the number of seats on the basis of the
absolute number of valid votes in {cmd: varname}. The apportionment
can be done by using either a quota method or five different divisor
methods are introduced. A detailed description of these methods
is given in the Stata Journal article regarding this program. 

{title:Options}

{phang}{opt method(keyword)} is used to select the
apportionment method. The apportionment methods described above can be
specified using one of the following keywords:
{p_end}
{p2colset 10 20 20 10}
{p2line}
{p2col:Method}Keyword and synonyms
{p_end}{p2line}
{p2col:Hamilton}{cmd:hamilton} {cmd:hare-niemeyer} {cmd:remainder} {cmd:vinton}
{p_end}{p2col:Jefferson}{cmd:jefferson} {cmd:dhondt} {cmd:hagenbach-bischoff} {cmd:greatest}
{p_end}{p2col:Webster}{cmd:webster} {cmd:stlague} {cmd:majorfraction}
{p_end}{p2col:Hill}{cmd:hill} {cmd:huntington} {cmd:geometric}
{p_end}{p2col:Dean}{cmd:dean} {cmd:harmonic}
{p_end}{p2col:Adam}{cmd:adam} {cmd:smallest}
{p_end}{p2line}
{p 9}The default is {opt method(jefferson)}.

{phang}{opt size(#|varname)} is used to specify the number of
seats to be allocated. Either use a positive integer number or the
name of a variable holding the number of seats to be allocated. In the
latter case, the variable should be constant within one apportionment
problem (i.e., for one election). Size defaults to 100.

{phang}{opt by(varlist)} is used when the data set holds several
apportionment problems (i.e., several elections), or when seats should
be allocated separately for regional subdivisions. Specifying
{opt by(varlist)} is equivalent to using {cmd: by varlist:} as a prefix.

{phang}{opt threshold(#|varname)} is used to set the barring
clause. Within the parentheses put the size for the barring clause as
a percentage or specify the name of a variable holding the value for
the barring clause. The variable must be constant within one
apportionment problem (i.e., for one election).

{phang}{opt exception(exp)} is used to specify exceptions from the
barring clause. Within the parentheses specify an expression
indicating the exempted observations (see help {help exp}).

{title:Examples}

{phang}{cmd:. use uspop if year==1790, clear}{p_end}
{phang}{cmd:. egen ham = apport(pop), method(hamilton) size(105)}{p_end}

{phang}{cmd:. use uspop, clear}{p_end}
{phang}{cmd:. egen jeff = apport(pop), method(jefferson) size(size) by(year)}{p_end}

{title:Author}

{pstd}Ulrich Kohler, WZB, kohler@wzb.eu{p_end}

{title:Also see}

{psee}
Manual:  {manlinki D egen}

{psee} Online: {helpb egen}, {helpb egenmore} (if installed)
{p_end}

