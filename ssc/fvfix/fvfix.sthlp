{smcl}
{* *! version 1  jan2013}{...}
{cmd:help fvfix}

{hline}

{title:Title}

{p2colset 8 20 21 2}{...}
{p2col:{hi:fvfix} {hline 2}}Returns the future value of a series of equal payments (cash flows){p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 18 2}
{cmd:fvfix} 
{cmd:, cf(#) nper(#)} 
{cmdab:freq:uency(}{help tsset:timeunit}{cmd:)}
{cmd:rate(#)}
[ {it:options} ]

{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{cmd:cf(#)}}Value of the constant cash flows (positive number)
{p_end}
{synopt:{cmd:nper(#)}}Number of payment periods (positive integer)
{p_end}
{synopt:{cmdab:freq:uency:(}{it:timeunit}{cmd:)}}Time unit of payments (m, q, h, y)
{p_end}
{synopt:{cmd:rate(#)}}Nominal annual interest rate (in decimal form) 
{p_end}

{syntab:Options}
{synopt:{cmdab:presentval:ue(#)}}Starting balance other than {cmd:cf(#)} (positive number)
{p_end}
{synopt:{cmd:due(#)}}When payments are due or made: 0 = end of period (default), or 1 = beginning of period
{p_end}
{synopt:{cmdab:res:ult(}{it:mymatrix}{cmd:)}}Set the capitalized cash flows' schedule matrix name
{p_end}
{synoptline}
{p2colreset}{...}

{marker statname}{...}
{synoptset 17}{...}
{synopt:{space 4}{it:timeunit}}definition{p_end}
{space 4}{synoptline}
{synopt:{space 4}{opt m}} monthly payments{p_end}
{synopt:{space 4}{opt q}} quarterly payments{p_end}
{synopt:{space 4}{opt h}} halfyearly payments{p_end}
{synopt:{space 4}{opt y}} yearly payments{p_end}
{space 4}{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
{cmd:fvfix} Returns the future value of a series of equal payments (based on a compounded constant interest rate). {cmd:fvfix} generates 
a three column matrix (rows = nper) containing the entire schedule of capitalized cash flows 
distinguishing between: period number, capitalization factor and cash flows.


{dlgtab:Options}

{phang}
{opt cf(#)} Value of the constant cash flows.

{phang}
{opt nper(#)} Number of payment periods.
For example, if you want the future value of five-year monthly cash flows, it will have 5*12 = 60 periods. The formula {opt nper(60)}.

{phang}
{cmdab:freq:uency:(}{it:timeunit}{cmd:)} Time unit of payments (m, q, h, y).
Used to convert the annual interest rate into a periodic rate.

{phang}
{opt rate(#)} Nominal annual interest rate (in decimal form). {it:i.e.} an annual 5.24% interest rate should be written 0.0524. 

{phang}
{cmdab:presentval:ue(#)} Starting balance other than {cmd:cf(#)}, default is 0.

{phang}
{opt due(#)} When payments are due or made: 0 = end of period (default), or 1 = beginning of period. 

{phang}
{cmdab:res:ult(}{it:mymatrix}{cmd:)} Set the capitalized cash flows' schedule matrix name saved in results, default is {bf:matfvcf}


{title:Examples}

{phang}{cmd:. fvfix, cf(10000) nper(60) frequency(m) rate(.1125) due(1)}{p_end}
{phang}{cmd:. fvfix, cf(1500) nper(5) frequency(y) rate(.125) res(cf1)}{p_end}
{phang}{cmd:. mat list r(cf1)}{p_end}


{title:Saved results}

{pstd}
{cmd:fvfix} saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(cf)}}cash flow value{p_end}
{synopt:{cmd:r(nper)}}total number of payment periods{p_end}
{synopt:{cmd:r(freq)}}number of payment within a year{p_end}
{synopt:{cmd:r(iy)}}annual interest rate{p_end}
{synopt:{cmd:r(due)}}due value{p_end}
{synopt:{cmd:r(presentval)}}Starting balance value{p_end}
{synopt:{cmd:r(FV)}}future value of constant cash flows{p_end}

{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(matfvcf)}}schedule of capitalized cash flows{p_end}
{p2colreset}{...}


{title:Author}

Maximo Sangiacomo
{hi:Email:  {browse "mailto:msangia@hotmail.com":msangia@hotmail.com}}

