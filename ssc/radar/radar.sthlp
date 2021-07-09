{smcl}
{* *! version 1.0 28 Aug 2018}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "radar##syntax"}{...}
{viewerjumpto "Description" "radar##description"}{...}
{viewerjumpto "Options" "radar##options"}{...}
{viewerjumpto "Remarks" "radar##remarks"}{...}
{viewerjumpto "Examples" "radar##examples"}{...}
{title:Title}
{phang}
{bf:radar} {hline 2} Radar plots or Spider plots

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:radar}
[{help varlist}]
[{help if}]
[{help in}]
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt lc(string)}}  the string argument is a {help colorstyle}list and specifies the colors for the observations (not axes). {p_end}
{synopt:{opt lp(string)}}  the string argument is a {help linepatternstyle}list and specifies the patterns for the observations (not axes). {p_end}
{synopt:{opt lw(string)}}  the string argument is a {help linewidthstyle}list and specifies the line widths for the observations (not axes). {p_end}
{synopt:{opt ms(string)}}  the string argument is a {help symbolstyle}list and specifies the marker symbols to use for observations BUT must be used in conjunction with the connected option (not axes). {p_end}
{synopt:{opt mc:olor(string)}}  the string argument is a {help symbolstyle}list and specifies the marker colors to use for observations BUT must be used in conjunction with the connected option (not axes). {p_end}
{synopt:{opt r:label(numlist)}}  specifies the ticks and labels of the spokes. {p_end}
{synopt:{opt labsize(string)}}  the string argument is a {help textsizestyle} and specifies the text size of the node labels (not axes). {p_end}
{synopt:{opt radial(varname)}}  specifies a variable to be plotted as spikes along the spokes of the plot. {p_end}
{synopt:{opt axelaboff}}  specifies that axes labels are removed. {p_end}
{synopt:{opt axelc(string)}}  the string argument is a colorlist and specifies the colors for the axes. {p_end}
{synopt:{opt axelw(string)}}  the string argument is a linewidthlist and specifies the line widths for the axes. {p_end}
{synopt:{opt axelp(string)}}  the string argument is a patternlist and specifies the patterns for the axes. {p_end}
{synopt:{opt connected}}  specifies that rather than a line graph of observations but a connected line graph is drawn. {p_end}
{synopt:{opt *}}  additional {help twoway_options} can be specified, for example titles() and notes(), but not every possible option is allowed.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}

{pstd}
{cmd:radar} produces a radar plot from at least two variables. The first variable must always contain the label for the axes
and the second variable must be numeric. 

{pstd}
The axes of the radar plot will start at the top of the diagram and proceed in a clockwise direction. With the above dataset
the first axes will be labelled beer.

{pstd}
Missing values are included in the radar plot as gaps in the line joining observations.
This option is implemented using the {opt cmiss(n)} option of the twoway line graph, see help {help connect_options}.

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt lc(string)}  the string argument is a {help colorstyle}list and specifies the colors for the observations (not axes). {p_end}

{phang}
{opt lp(string)}  the string argument is a {help linepatternstyle}list and specifies the patterns for the observations (not axes). {p_end}

{phang}
{opt lw(string)}  the string argument is a {help linewidthstyle}list and specifies the line widths for the observations (not axes). {p_end}

{phang}
{opt ms(string)}  the string argument is a {help symbolstyle}list and specifies the marker symbols to use for observations BUT must be used in conjunction with the connected option (not axes). {p_end}

{phang}
{opt mc:olor(string)}  the string argument is a {help symbolstyle}list and specifies the marker colors to use for observations BUT must be used in conjunction with the connected option (not axes). {p_end}

{phang}
{opt r:label(numlist)}  specifies the ticks and labels of the spokes. The default is to have 5 values displayed, note that the 
value that is the centre or smallest tick is suppressed but the value is included as a note below the graph. The note can
be overwritten by using the {hi: note()} option.
{p_end}

{phang}
{opt labsize(string)}  the string argument is a {help textsizestyle} and specifies the text size of the node labels (not axes). {p_end}

{phang}
{opt radial(varname)}  specifies a variable to be plotted as spikes along the spokes of the plot. {p_end}

{phang}
{opt axelaboff}  specifies that axes labels are removed. {p_end}

{phang}
{opt axelc(string)}  the string argument is a colorlist and specifies the colors for the axes. {p_end}

{phang}
{opt axelw(string)}  the string argument is a linewidthlist and specifies the line widths for the axes. {p_end}

{phang}
{opt axelp(string)}  the string argument is a patternlist and specifies the patterns for the axes. {p_end}

{phang}
{opt connected}  specifies that rather than a line graph of observations but a connected line graph is drawn. {p_end}

{phang}
{opt *}  additional {help twoway_options} can be specified, for example titles() and notes(), but not every possible option is allowed. {p_end}


{marker examples}{...}
{title:Examples}
{pstd}

{pstd}

{pstd}
The examples below highlight the use of the {hi:radar} plot on the Auto dataset. The only limitation
is the number of "spokes" hence the commands are limited to just the foreign cars. Technical note: the limitation on
the number of spokes is unknown because the limit is due to the size of macros being returned as
part of a rclass program. The aspect ratio should be set to 1 but occassionally Stata's scaling of the plotregion can give
skewed plots so the aspect() option can adjust any skew.

{pstd}
Click below to load dataset 

{pstd}
{stata sysuse auto}

{pstd}
Click below (after the dataset is loaded to see the distribution of weight for the foreign makes of car

{pstd}
{stata radar make weight if foreign, aspect(1)}

{pstd}
Click below to see the distribution of turn mpg and trunk for each foreign make of car.

{pstd}
{stata radar make turn mpg trunk if foreign, aspect(1)} {p_end}

{pstd}
{stata radar make turn mpg trunk if foreign, title(Nice Radar graph) aspect(1)} {p_end}

{pstd}
{stata radar make turn mpg trunk if foreign, title(Nice Radar graph) lc(red blue green) lp(dash dot dash_dot) aspect(1)}

{pstd}
{stata radar make turn mpg trunk if foreign, title(Nice Radar graph) lc(red blue green) r(0 12 14 18 50) aspect(1)}

{pstd}
{stata radar make turn mpg trunk if foreign, title(Nice Radar graph) lc(red blue green) lw(*1 *2 *4) r(0 12 14 18 50) aspect(1)}

{pstd}
{stata radar make turn mpg trunk if foreign, title(Nice Radar graph) lc(red blue green) lw(*1 *2 *4) r(0 12 14 18 50) labsize(*.5) aspect(1)}

{pstd}
{stata radar make turn mpg trunk if foreign, title(Nice Radar graph) lc(red blue green) lw(*1 *2 *4) r(0 12 14 18 50) connected ms(D Oh S) labsize(*.5) aspect(1)}

{pstd}
There is no real advantage of a radar diagram compared to a scatter plot unless there was some sort of directional data.

{pstd}
To add extra spikes for trunk instead of the contour

{pstd}
{stata radar make turn mpg if foreign,radial(trunk) title(Nice Radar graph) lc(red blue green) lw(*1 *2 *4) r(0 12 14 18 50) labsize(*.5) aspect(1)}

{pstd}
If you want to remove the labels from the axes use the axelaboff option

{pstd}
{stata radar make turn mpg if foreign,radial(trunk) title(Nice Radar graph) lc(red blue green) lw(*1 *2 *4) r(0 12 14 18 50) labsize(*.5) axelaboff aspect(1)}

{pstd}

{title:Stored results}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Locals}{p_end}
{synopt:{cmd:r(maxarea)}}  is the returned maximum area of the radar polygon given the maximum and minimum values on the plot {p_end}{synopt:{cmd:r(area_)}}  is the return area of the radar plot, the name of variable will be in the return name e.g. area_weight {p_end}

{title:Author}
{p}

Dr Adrian Mander, MRC Biostatistics Unit, University of Cambridge.

Email {browse "mailto:adrian.mander@mrc-bsu.cam.ac.uk":adrian.mander@mrc-bsu.cam.ac.uk}



{title:See Also}
Related commands:


{pstd}
Other Graphic Commands I have written: {p_end}

{synoptset 27 }{...}
{synopt:{help batplot} (if installed)} {stata ssc install batplot}   (to install) {p_end}
{synopt:{help cdfplot} (if installed)} {stata ssc install cdfplot}   (to install) {p_end}
{synopt:{help contour} (if installed)}   {stata ssc install contour}     (to install) {p_end}
{synopt:{help drarea}  (if installed)}   {stata ssc install drarea}      (to install) {p_end}
{synopt:{help graphbinary} (if installed)}   {stata ssc install graphbinary} (to install) {p_end}
{synopt:{help metagraph} (if installed)}   {stata ssc install metagraph}   (to install) {p_end}
{synopt:{help palette_all} (if installed)}   {stata ssc install palette_all} (to install) {p_end}
{synopt:{help plotbeta} (if installed)}   {stata ssc install plotbeta}    (to install) {p_end}
{synopt:{help plotmatrix} (if installed)}   {stata ssc install plotmatrix}  (to install) {p_end}
{synopt:{help surface}  (if installed)}   {stata ssc install surface}     (to install) {p_end}
{synopt:{help trellis}  (if installed)}   {stata ssc install trellis}     (to install) {p_end}
{p2colreset}{...}

