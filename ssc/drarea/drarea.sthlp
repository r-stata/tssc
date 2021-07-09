{smcl}
{* 12 May 2014}{...}
{cmd:help drarea}
{hline}

{title:Title}

    {hi: Draw an overlapping range area plot}

{title:Syntax}

{p 8 17 2}
{cmdab:drarea} hi1 lo1 hi2 lo2 x
[{cmd:,} {it:options}]

{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt c:olor}({help colorstyle}list)} specifies the two colours for the two separate range areas.{p_end}
{synopt:{opt a:dd}} specifies that markers are plotted in addition to the range plots.{p_end}
{synopt:{opt twoway:}()} specifies that the user adds another twoway graph to the plot.{p_end}
{synopt:{help twoway_options}} specifies additional options in the graphic.{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}

{pstd}
Multiple graphics are produced in Stata by the rule "last drawn first seen". So the objects that are drawn last are the ones that
are observed. The implication of this principle is that when overlapping two rarea graphs the overlapping area is hidden by the second rarea graph.
This command {cmd:drarea} overlays two range area plots by merging the two colours and hence highlighting the true overlap. There are numerous
graphics that could benefit from the same principles but at the moment the graphics engine does not remember what is beneath the plots that are
observed.

{pstd}
{bf:drarea} is short for {bf:d}ouble {bf:rarea} plot

{title:Options}

{dlgtab:Main}

{phang}
{opt c:olor}({help colorstyle}list) specifies the two colours for the two separate range areas. The option requires the same colorstyle be used
and can handle both the words or the RGB format (CYMK is not supported at the moment). {bf:Note:} if a third colour is specified then this
will be the colour of the overlapping area.

{phang}
{opt a:dd}  specifies that markers are plotted in addition to the range plots.

{phang}
{opt twoway:}(twoway commands) specifies that the user adds other twoway graphs to the plot.{p_end}

{title:Examples}

{pstd}
By using a Stata dataset and generating some new random highs and lows the drarea command shows off the basic plot.
{p_end}
{phang}
{stata sysuse sp500, clear}

{phang}
{stata gen high2 = high+15*uniform()}

{phang}
{stata gen low2 = low+15*uniform()}

{phang}
{stata drarea high low high2 low2 date in 1/20}

{pstd}
In this example two additional twoway plots are added. Note that each additional twoway graph must be enclosed with brackets
{p_end}

{phang}
{stata drarea high low high2 low2 date in 1/20, twoway((rspike high low date)(scatter high2 date, ms(green)))}

{pstd}
To add a legend to the above graph add the following command, note the third graph is actually the overlapping range area and is dropped 
from the order

{phang}
{stata drarea high low high2 low2 date in 1/20, twoway((rspike high low date)(scatter high2 date, ms(green))) legend(on order(1 2 4 5))}

{title:Author}

Adrian Mander, MRC Biostatistics Unit, Cambridge, UK.

Email {browse "mailto:adrian.mander@mrc-bsu.cam.ac.uk":adrian.mander@mrc-bsu.cam.ac.uk}

{title:See Also}

Related commands:

{help twoway rarea}

Other Graphic Commands I have written:
{help trellis}     (if installed)   {stata ssc install trellis}     (to install this command)
{help cdfplot}     (if installed)   {stata ssc install cdfplot}     (to install this command)
{help contour}     (if installed)   {stata ssc install contour}     (to install this command)
{help surface}     (if installed)   {stata ssc install surface}     (to install this command)
{help batplot}     (if installed)   {stata ssc install batplot}     (to install this command)
{help plotbeta}    (if installed)   {stata ssc install plotbeta}    (to install this command)
{help graphbinary} (if installed)   {stata ssc install graphbinary} (to install this command)
{help palette_all} (if installed)   {stata ssc install palette_all} (to install this command)
{help plotmatrix}  (if installed)   {stata ssc install plotmatrix}  (to install this command)
{help metagraph}   (if installed)   {stata ssc install metagraph}   (to install this command)



