{smcl}
{* *! version 1.0.1 29.10.2017}{...}

{title:Title}

{phang}
{bf:colorscatter} {hline 2} Draw scatter plots with marker colors varying by a third variable.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:colorscatter}
{ifin}{cmd: x y c [if] [in],} [legendoff] [scatter_options( ... )]  [twoway_options] 


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt keeplegend}} do not overwrite the legend, the user can then do so manually by adding twoway options.{p_end}
{synopt:{opt scatter_options}} are passed to twoway scatter.{p_end}
{syntab:Colors}
{synopt:{opt cmin(#)}} which value should get the lowest value for color.{p_end}
{synopt:{opt cmax(#)}} which value should get the lowest value for color.{p_end}
{synopt:{opt rgb_low(# # #)}} specify color low values of c. (default: red) {p_end}
{synopt:{opt rgb_high(# # #)}} specify color high values of c. (default: blue) {p_end}
{synopt:{opt symbol_opacity(#%)}} specify opacity. (default: blue) {p_end}
{synopt:{opt tw_pre(twoway graph)}} draw another twoway graph underneath.  {p_end}
{synopt:{opt tw_post(twoway graph)}} draw another twoway graph on top. {p_end}
{marker description}{...}
{title:Description}

{pstd}
{cmd:colorscatter} Draws a scatter plot using x and y as coordinates; c is visualized as color gradient.
{p_end}

{marker example}{...}
{title:Example}

{pstd}
This example generates a data set of 3 variables and plots a colored scatter plot of these.
{p_end}

{phang}
{stata `"set obs 1000"'}
{p_end}
{phang}
{stata `"gen x = rnormal()"'}
{p_end}
{phang}
{stata `"gen y = rnormal()"'}
{p_end}
{phang}
{stata `"gen c = min(abs(x),abs(y))"'}
{p_end}
{phang}
{stata `"colorscatter x y c, scatter_options(msymb(Oh)) title("Twowaytitle") rgb_low(255 0 0) rgb_high(0 255 0) tw_pre(line x y, lc(gray))"'}
{p_end}

{title:See also}

{pstd}
{help twoway},
{help twoway scatter},

{title:Acknowledgements}
Eric Melse suggested and implemented the symbol_opacity option 
{pstd}
{p_end}
{title:Author}

{pstd}
Simon Heß, Goethe University Frankfurt.{p_end}

{pstd}
The latest version of colorscatter can always be obtained from {browse "https://github.com/simonheb/colorscatter"} or {browse "http://HessS.org"}.{p_end}

{pstd}
I am happy to receive comments and suggestions regarding bugs or ideas for improvements/extensions via {browse "https://github.com/simonheb/colorscatter/issues"}.{p_end}
