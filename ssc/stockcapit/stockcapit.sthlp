{smcl}
{* *! version 1.0.2  }{...}
{cmd:help stockcapit}
{hline}

{title:Title}

    {hi: Calculates physical capital stock by the perpetual-inventory method}



{title:Syntax}

{p 8 17 2}
{cmd:stockcapit}
investvar
gdpvar
{ifin}
[{cmd:,} {it:options}]


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt capit:al(newvar)}}specifies the new capital variable to be created {p_end}
{synopt:{opt delta:(#)}}specifies the constant depreciation rate; default is {hi:delta(0.05)} {p_end}
{synoptline}
{p2colreset}{...}

{p 4 6 2}
You must {cmd:tsset} your data before using {cmd:stockcapit}; see {helpb tsset}.
The {hi:stockcapit} command works for both Time series and Panel data. {p_end}
{p 4 6 2}
{varlist} must not contain time-series operators; see {help tsvarlist}.{p_end}
{p 4 6 2}
{cmd:by} is not allowed with {hi:stockcapit}; see {manhelp by D} for more details on {cmd:by}.{p_end}



{title:Description}

{pstd}
{cmd:stockcapit} calculates physical capital stock by the perpetual-inventory method
using {hi:investvar} (Investment variable) and {hi:gdpvar} (GDP variable). The initial 
capital stock is computed as in {it:Harberger (1978)}. See {it:Nehru and Dhareshwar (1993)}
and {it:King and Levine (1994)} for more details concerning the measurement of initial 
capital stock. As pointed by {it:Barro and Sala-i Martin (2004)} the calculated capital
stock for the first years depends on the initial guess of initial capital stock and
hence is unreliable. But as initial capital depreciates, the computed stocks become
more and more precise.



{title:Options}

{dlgtab:Main}

{phang}
{opt capital(newvar)} specifies the name of the new capital variable to be created.
 You must provided this variable name, otherwise {hi:stockcapit} will abort
 with an error message.

{phang}
{opt delta(#)} indicates the constant depreciation rate; default is {hi:delta(0.05)}.
Some authors like {it:Nehru and Dhareshwar (1993)} state that the choice of the
depreciation rate is more important than the initial capital stock. They argue that
an error in the depreciation rate have an effect on both initial and final capital stocks
and these errors have a propensity to reinforce one another. The choice of the default
as {hi:0.05} is based on {it:Bosworth and Collins (2003)}.



{title:Citation}

{pstd}
{hi:stockcapit} is not an official Stata command. The usual disclimers apply: all errors
and imperfections in this package are mine and all comments are very welcome.



{title:Remarks}

{pstd}
The package {hi:stockcapit} rely on the package {bf:{help tsspell}}. Hence you must install
{bf:{help tsspell}} to make {hi:stockcapit} work. To install the package {bf:{help tsspell}}
from within {hi:Stata}, please click on: {stata "ssc install tsspell, replace"}. Note that
you must be connected to Internet for this action to work.



{title:Return values}

{col 4}Macros
{col 8}{cmd:r(capital)}{col 27} Created capital stock variable



{title:Examples}

{p 4 8 2} We open the dataset {hi:stockcapitdatapand.dta}. The data are panel data from
Penn World Table 7.0 which contain 190 countries from 1950 to 2009.

{p 4 8 2}{stata "use http://fmwww.bc.edu/repec/bocode/s/stockcapitdatapand.dta, clear"}{p_end}

{p 4 8 2} We compute the capital stock by placing first the investment variable and then the GDP
variable. We enter the name of the capital stock variable to be created as {it:capital}.

{p 4 8 2}{stata "stockcapit invest gdp, capit(capital)"}{p_end}

{p 4 8 2} This creates the capital stock variable named {it:capital}. By default it is labeled as
{it:"Calculated Physical Capital Stock"}. To see this, we type:

{p 4 8 2}{stata "des capital"}{p_end}

{p 4 8 2} The {hi:stockcapit} command can also be applied on a single time series data.
To illustrate this, we open the following dataset containing a time series data.

{p 4 8 2}{stata "use http://fmwww.bc.edu/repec/bocode/s/stockcapitdatatimes.dta, clear"}{p_end}

{p 4 8 2}{stata "stockcapit invest gdp, capit(capital)"}{p_end}

{p 4 8 2} We observe that the capital stock variable named {it:capital} is created. By default 
it is labeled as {it:"Calculated Physical Capital Stock"}.



{title:References}

{pstd}
Barro, R.J. and Sala-i-Martin, X.: 2004, (Second Edition) "Economic Growth", McGraw-Hill.
{p_end}

{pstd}
Bosworth, B.P. and Collins, S.M.: 2003, "The empirics of Growth: An Update", Brookings Papers on Economic Activity 2:113-206.
{p_end}

{pstd}
Harberger,  A.: 1978, "Perspectives on Capital and Technology in Less Developed Countries" in M.J. Artis and A.R. Nobey (eds.),
Contemporary Economic Analysis (London: Croom Helm).
{p_end}

{pstd}
Heston, A., Summers, R. and Aten, B.: 2011, "Penn World Table Version 7.0", Center for International Comparisons of Production,
Income and Prices at the University of Pennsylvania, March.
{p_end}

{pstd}
King, R. G. and Levine R.: 1994, "Capital Fundamentalism, Economic Development, and Economic Growth", Carnegie-Rochester Conference
Series on Public Policy, Vol. 40.
{p_end}

{pstd}
Nehru, V. and Dhareshwar, A.:  1993, "A New Database on Physical Capital Stock: Sources, Methodology and Results", Rivista de Analisis
Economico 8 (1): 37-59.
{p_end}



{title:Author}

{p 4}Diallo Ibrahima Amadou, {browse "mailto:zavren@gmail.com":zavren@gmail.com} {p_end}



{title:Also see}

{psee}
Online:  help for  {bf:{help generate}}, {bf:{help egen}}, {bf:{help tsspell}} (must be installed)
{p_end}
