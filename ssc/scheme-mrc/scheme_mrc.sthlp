{smcl}
{* *! version 1.1  29apr2016}{...}
{vieweralsosee "[G-4] schemes intro" "help schemes"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[G-3] scheme_option" "help scheme_option"}{...}
{viewerjumpto "Syntax" "scheme_mrc##syntax"}{...}
{viewerjumpto "Description" "scheme_mrc##description"}{...}
{viewerjumpto "Colours" "scheme_mrc##colours"}{...}
{viewerjumpto "Fonts" "scheme_mrc##fonts"}{...}
{title:Title}

{pstd}
Scheme description: mrc graph scheme


{marker syntax}{...}
{title:Syntax}

{pstd}
To use the {cmd: mrc} scheme, you might specify it as an option in your graph command:

{p 8 16 2}
{cmd:. graph}
...{cmd:,}
...
{cmd:scheme(mrc)}

{pstd}
or set the scheme before running your graph command:

{p 8 16 2}
{cmd:. set}
{cmd:scheme}
{cmd:mrc}
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
The {cmd:mrc} scheme follows the UK Medical Research Council's {browse "http://www.mrc.ac.uk/about/information-standards/mrc-brand-guidelines/":branding guidelines}
(re-vamped in 2016), interpreting these for use in Stata graphs. It was written as
a quick way to use the MRC's corporate palette of colours, and released on SSC in
case it is of use to other MRC employees.

{pstd}
In writing this scheme I made some opinionated alterations to some of the defaults
and quirks from Stata's own schemes. This scheme is fairly
minimal in style. Colours used are from the MRC's (RGB) specification of seven
colours, white, black or grey. There are faint horizontal grid lines. A
vertical axis line is given but no vertical gridlines. There are no ticks. Dots
in scatterplots are hollow by default. The height-to-width ratio of plots
is 4:5 by default.

{pstd}
Graph schemes are skeletons, giving default specfications for general graphs;
any defaults can be changed within graph commands. For example, if ticks and
vertical grid lines are desired, these can always be included.


{marker colours}{...}
{title:Colours}

{pstd}
The mrc scheme includes seven non-standard colours named mrcblue, mrcpurple,
mrcred, mrcorange, mrcyellow, mrcgreen, and mrcgrey. These colours are packaged
with the scheme and can be referred to in the same way as with Stata's base colours.


{marker fonts}{...}
{title:Fonts}

{pstd}
There are elements to the UK Medical Research Council's branding beyond
colour. The corporate typefaces are Arial in general or Helvetica Neue
for more professional materials. See {help graph_set} for details of how
to change the font. Note that this cannot be set within a graph scheme
and setting the font will need setting explicitly for your desired output
format. For example, to draw a graph and export it as .svg, Windows users
would first need to type

{p 8 16 2}
{cmd:. graph}
{cmd:set}
{cmd:svg}
{cmd:fontface}
{cmd:"Arial"}
 
{pstd}
to retain Arial as the font in the .eps figure. (The name of the font
may be different for different operating systems.) Similar code does the
same thing replacing eps with 'window', 'print', 'ps' or 'svg'.

{pstd}
The code for setting a font when exporting as pdf is slightly different:

{p 8 16 2}
{cmd:. translator}
{cmd:set}
{cmd:Graph2pdf}
{cmd:fontface}
{cmd:"Arial"}


{title:Author}

{pstd}
Tim P. Morris, MRC Clinical Trials Unit at UCL, London UK
{break}
Email: {browse "mailto:tim.morris@ucl.ac.uk":tim.morris@ucl.ac.uk}
{break}
Twitter: {browse "https://twitter.com/tmorris_mrc":@tmorris_mrc}

{...} 