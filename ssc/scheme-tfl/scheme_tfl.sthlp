{smcl}
{* *! version 1.0  16sep2015}{...}
{vieweralsosee "[G-4] schemes intro" "help schemes"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[G-3] scheme_option" "help scheme_option"}{...}
{viewerjumpto "Syntax" "scheme_tfl##syntax"}{...}
{viewerjumpto "Description" "scheme_tfl##description"}{...}
{viewerjumpto "Colours" "scheme_tfl##colours"}{...}
{viewerjumpto "Fonts" "scheme_tfl##note"}{...}
{title:Title}

{pstd}
Scheme description: tfl graph scheme, based on Transport for London's corporate colour pallette.


{marker syntax}{...}
{title:Syntax}

{pstd}
To use the {cmd: tfl} scheme, you might specify it as an option in your graph command

{p 8 16 2}
{cmd:. graph}
...{cmd:,}
...
{cmd:scheme(tfl)}

{pstd}
Alternatively, set the scheme before running your graph command

{p 8 16 2}
{cmd:. set}
{cmd:scheme}
{cmd:tfl}
[{cmd:,}
{cmdab:perm:anently}]

{pstd}
See {manhelpi scheme_option G-3} and {manhelp set_scheme G-2:set scheme}.


{marker description}{...}
{title:Description}

{pstd}
Schemes determine the overall look of a graph; see
{manhelp schemes G-4:schemes intro}.

{pstd}
The {cmd:tfl} scheme uses Transport for London's corporate colour pallette
applied to Stata graphs. It is an easily recognised, vibrant colour scheme. The
scheme was written for those who wish to use something other than the standard schemes
and colours in Stata.

{pstd}
The {cmd:tfl} scheme changes some of the quirks in Stata's base schemes and is
minimal in style. Colours come from TFL's RGB specification of corporate colours,
available from {browse "https://tfl.gov.uk/cdn/static/cms/documents/tfl-colour-standard.pdf":tfl.gov.uk}. Dots in scatterplots are hollow by default. The height-to-width
ratio is 4:5 by default but can be changed using xsize(#) and ysize(#).

{pstd}
Graph schemes are skeletons, giving default specfications for general graphs;
any specific changes required can still be made within graph commands.


{marker colours}{...}
{title:Colours}

{pstd}
The tfl scheme includes eight non-standard colours named tflblue, tflbrown,
tflgreen, tflgrey, tflorange, tflpurple, tflred and tflyellow.
Users can refer to these colours as they would to Stata's base colours,
regardless of the graph scheme being used.


{marker note}{...}
{title:Note}

{pstd}
There are elements to TFL's branding beyond colour, but this graph scheme
does not intend to go beyond colour and some author-preferred options for graphs.


{title:Author}

{pstd}
Tim Morris
{break}
MRC Clinical Trials Unit at UCL, London, UK.
{break}
Email: {browse "mailto:tim.morris@ucl.ac.uk":tim.morris@ucl.ac.uk}
{break}
Twitter: {browse "https://twitter.com/tmorris_mrc":@tmorris_mrc}

{...} 