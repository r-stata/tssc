{smcl}
{* October 2009}{...}
{hline}
help for {hi:cnormp}{right:Austin Nichols (Oct 2009)}
{hline}

{title:Program to calculate parameters for creating a censored normal random variable with specified mean and variance}

{p 8 17 2}{cmd:cnormp} {it:mean} {it:sd} [, {cmdab:c:enspoint(}{it:real}{cmd:)} ]

{title:Description}

{p 4 4 2}
{cmd:cnormp} calculates the mean and standard deviation of the underlying uncensored normal distribution
that when left censored at {it:censpoint} will have the specified {it:mean} and {it:sd}.  The default value
for {it:censpoint} when unspecified is zero.


{title:Examples}

{p 4 4 2}drawnorm x, mean(20) sd(20) n(1000) clear{p_end}
{p 4 4 2}cnormp 20 20{p_end}
{p 4 4 2}forv i=1/9 { {p_end}
{p 4 4 2} g y`i'=max(0,rnormal(r(m),r(s))){p_end}
{p 4 4 2}}{p_end}
{p 4 4 2}su	{p_end}
{p 4 4 2}drawnorm x, mean(20) sd(20) n(1000) clear{p_end}
{p 4 4 2}cnormp 20 20, c(10){p_end}
{p 4 4 2}forv i=1/9 { {p_end}
{p 4 4 2} g y`i'=max(10,rnormal(r(m),r(s))){p_end}
{p 4 4 2}}{p_end}
{p 4 4 2}su	{p_end}

{title:Author}

{p 4 4 2}Austin Nichols {p_end}
{p 4 4 2}<austinnichols@gmail.com> {p_end}
{p 4 4 2}Urban Institute{p_end}

{title:Also see}

{p 4 13 2}
Online: help for {help functions}. 

