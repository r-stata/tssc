{smcl}
{* *! version 1.0.0 June 28, 2020}
{title:Title}

{p 4 4 2}
{cmdab:grvar} {hline 1} Applies a non-constant growth rate to a variable

{marker syntax}{...}
{title:Syntax}

{p 4 4 2}
{cmdab:grvar}
growthvar
var{cmd:,}
{it:generate(name)}
[{it:option}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{cmdab:gen:erate(}name{cmd:)}} Specifies the name of the new variable. This is required.
{p_end}
{synopt:{opt replace}} Specifies if you want to replace the variable; default is not replace.
{p_end}

{pstd}
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}

{pstd}
 {cmd:grvar} Calculate the future values of a variable from the initial value and a non-constant growth/decrease rate (e.g. inflation). 
 It is useful when we want to fit a variable with a growth rate in a time serie or panel data. 
 
{pstd} 
Creating a new variable using a growth rate is very simple to code, we just have to follow a specification like: x_t = x_0*(1+r)^t. 
But if the growth rate is not constant, we cannot use that specification, the solution is represented in the following table:

 	{txt}
	         {c TLC}{hline 50}{c TRC}
	         {c |}{res} time   growthvar   var   output{txt}                  {c |}
    	         {c LT}{hline 50}{c RT}
	         {c |}  1        .         x     x{txt}                      {c |}
	         {c |}  2        r1        .     x*(1+r1){txt}               {c |}
	         {c |}  3        r2        .     x*(1+r1)*(1+r2){txt}        {c |}
	         {c |}  4        r3        .     x*(1+r1)*(1+r2)*(1+r3){txt} {c |}	
	         {c BLC}{hline 50}{c BRC}
			 
    This is exactly what the command {cmdab:grvar} does in a time serie or panel data. 

{marker examples}{...}
{title:Examples}
{pstd}

{pstd}
We import panel data and define panel and time variable

{pstd}
.{stata webuse invest2.dta, clear}

{pstd}
.{stata xtset company time}

{pstd}
Now, we create a growth rate and a new investment variable; we only keep the first investment value.

{pstd}
.{stata gen GrowthInvest = (invest-L.invest)/L.invest}

{pstd}
.{stata gen Invest = invest if time==1}

{pstd}
Finally, just using the first value and the growth rate of the investment, we calculate the values for all periods.

{pstd}
.{stata grvar GrowthInvest Invest, gen(invest2)}

{title:Author}
{p}

Daniel Pailañir
Email {browse "mailto:daniel.pailanir@gmail.com":daniel.pailanir@gmail.com}
