{smcl}
{* *! version 1  jan2013}{...}
{cmd:help payper}

{hline}

{title:Title}

{p2colset 8 20 21 2}{...}
{p2col:{hi:payper} {hline 2}}Returns the periodic payment and the entire schedule of a loan or annuity{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 18 2}
{cmd:payper} 
{cmd:, pv(#) nper(#)} 
{cmdab:freq:uency(}{help tsset:timeunit}{cmd:)}
{cmd:rate(#)}
[ {it:options} ]

{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{cmd:pv(#)}}Present value of the instrument (positive number)
{p_end}
{synopt:{cmd:nper(#)}}Number of payment periods in the life of the instrument (positive integer)
{p_end}
{synopt:{cmdab:freq:uency:(}{it:timeunit}{cmd:)}}Time unit of payments (m, q, h, y)
{p_end}
{synopt:{cmd:rate(#)}}Nominal annual interest rate (in decimal form) 
{p_end}

{syntab:Options}
{synopt:{cmdab:res:ult(}{it:mymatrix}{cmd:)}}Set the payment's schedule matrix name
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
{cmd:payper} Returns the periodic constant payment of a loan or annuity (based on a constant interest rate). {cmd:payper} generates 
a five column matrix (rows = nper) containing the entire schedule of (end of period) periodic constant payments 
distinguishing between: period number, principal, interest, balance and payment.


{dlgtab:Options}

{phang}
{opt pv(#)} Present value of the loan or instrument.

{phang}
{opt nper(#)} Number of payment periods in the life of the instrument.
For example, if you get a five-year loan and make monthly payments, the loan will have 5*12 = 60 periods. The formula {opt nper(60)}.

{phang}
{cmdab:freq:uency:(}{it:timeunit}{cmd:)} Time unit of payments (m, q, h, y).
Used to convert the annual interest rate into a periodic rate.

{phang}
{opt rate(#)} Nominal annual interest rate (in decimal form). {it:i.e.} an annual 5.24% interest rate should be written 0.0524. 

{phang}
{cmdab:res:ult(}{it:mymatrix}{cmd:)} Set the payment's schedule matrix name saved in results, default is {bf:matpay}.


{title:Examples}

{phang}{cmd:. payper, pv(10000) nper(60) frequency(m) rate(.1125)}{p_end}
{phang}{cmd:. payper, pv(1500) nper(5) frequency(y) rate(.125) res(loan1)}{p_end}
{phang}{cmd:. mat list r(loan1)}{p_end}


{title:Saved results}

{pstd}
{cmd:payper} saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(pv)}}present value{p_end}
{synopt:{cmd:r(nper)}}total number of payment periods{p_end}
{synopt:{cmd:r(freq)}}number of payment within a year{p_end}
{synopt:{cmd:r(iy)}}annual interest rate{p_end}
{synopt:{cmd:r(PMT)}}periodic constant payment{p_end}

{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(matpay)}}schedule of payments{p_end}
{p2colreset}{...}


{title:Author}

Maximo Sangiacomo
{hi:Email:  {browse "mailto:msangia@hotmail.com":msangia@hotmail.com}}

