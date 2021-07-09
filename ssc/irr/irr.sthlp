{smcl}
{* *! version 1  feb2013}{...}
{cmd:help irr}

{hline}

{title:Title}

{p2colset 8 15 21 2}{...}
{p2col:{hi:irr} {hline 2}}Calculates the (periodic) internal rate of return for a series of periodic cash flows{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 18 2}
{cmd:irr} {help varname:varname} 
{ifin}


{title:Description}

{pstd}
{cmd:irr} Calculates the (periodic) internal rate of return for a series of periodic cash flows.
These cash flows do not have to be constant, however, the cash flows must occur at regular intervals, 
such as months or years (if the cash flow payments are monthly, then the resulting rate of return 
is multiplied by 12 for the annual rate of return).


{title:Definitions}

{cmd:irr} uses the following conventions (for a {bf:unique} internal rate of return):

   ¤ Net Current Value should be greater than zero:

	-I0 + CF1/(1+0)^(1) + CF2/(1+0)^(2) + ... + CFN/(1+0)^(N) > 0

   ¤ Each Cash Flow value should be greater or equal to zero:

	CFi >= 0


{title:Input Arguments}

{bf:varname} must be a vector containing a stream of periodic cash flows.
The first entry in {bf:varname} should be the initial investment (I0) as a negative number.


{title:Example}

Find the internal rate of return for a simple investment with a unique positive rate of return. 
The initial investment is $100,000 and the following cash flows represent the yearly income from the investment.

{cmd:. list t cf if t<=5, sep(0) noobs}

	{txt}
	         {c TLC}{hline 7}{c -}{hline 8}{c TRC}
	         {c |}{res} t        cf    {txt}{c |}
    	         {c LT}{hline 7}{c -}{hline 8}{c RT}
	         {c |} 0   {c S|} -100,000 {txt}{c |}
	         {c |} 1   {c S|}   10,000 {txt}{c |}
	         {c |} 2   {c S|}   20,000 {txt}{c |}
	         {c |} 3   {c S|}   30,000 {txt}{c |}
	         {c |} 4   {c S|}   40,000 {txt}{c |}
	         {c |} 5   {c S|}   50,000 {txt}{c |}
	         {c BLC}{hline 7}{c -}{hline 8}{c BRC}

{cmd:. irr cf}
Internal Rate of Return = {res:0.12006} (12.006%)


{title:Saved results}

{pstd}
{cmd:irr} saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(irr)}}internal rate of return{p_end}
{synopt:{cmd:r(NPV)}}net present value{p_end}

{title:Author}

Maximo Sangiacomo
{hi:Email:  {browse "mailto:msangia@hotmail.com":msangia@hotmail.com}}

