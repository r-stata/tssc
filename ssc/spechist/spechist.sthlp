{smcl}
{* *! Version 1.2.0 29 July 2014}{...}
{cmd:help spechist}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:spechist} {hline 2}}
	Specific histograms for continuous variables
{p_end}
{p2colreset}{...}

{title:Syntax}
{* p 8 17 2}
{phang}
	{cmd:spechist} {varname} {ifin} [{it:{help spechist##weight:weight}}] 
	{cmd:,}
	{opt me:thod}{bf:(}{it:{help spechist##method_options:method_options}}{bf:)}
	{bf:[}
	{opt metd:isplay}{bf:(}{it:{help spechist##dispopts:display_options}}{bf:)}
	{opt copt:ions}{bf:(}{it:{help spechist##coptions:combine_options}}{bf:)}
	{it:{help spechist##histopts:histogram_options}}
	{bf:]}
{p_end}

{title:Description}

{pstd}{cmd:spechist} produces a histogram, or combination of histograms, for the
variable specified in {it:varname} where either the bin width or the number of
bins are calculated by the specified method(s).{p_end}

{pstd}You can specify one or more methods in the {opt me:thod()} option, or
choose {it:all}. When you specify more than one option, or when you specify
{it:all} as your option, a combination of the histograms will be generated.
{p_end}

{title:Options}

{synoptset 15 tabbed}{...}
{syntab:{opt me:thod(method_options)}}
{synoptline}
{p 7 7 2}
	This is a required option. It specifies the method or methods you want to
	use. You can specify more than one option by simply passing them separated
	by spaces, e.g. {bf:method(}{it:wand doane}{bf:)}. When you do,
	{cmd: spechist} will create a combination of all the histograms generated
	with the different methods that you specified. When you just specify
	one method, {cmd:spechist} will generate just one histogram with the
	specified method. If you specify {it:all} as your method, {cmd:spechist}
	will produce a graph combining the histograms generated with all methods
	available, which is why you can only specify {it:all} as a method on its
	own.
{p_end}
{synoptline}
{p2colreset}{...}

{synoptset 15 tabbed}{...}
{marker method_options}{...}
{synopthdr: method_options}
{synoptline}
{p2colreset}{...}
{p2colset 7 21 22 2}{...}
{p2col:{it:sqrt}}
	This uses the ceiling of the minimum of either the square root of the number
	of observations or 50 as the number of bins. This is a technique used by
	several software packages, for example by Microsoft Excel.
{p_end}

{p2col:{it:sturges}}
	This uses Sturges (1926)'s method to calculate the number of bins.
{p_end}

{p2col:{it:rice}}
	This uses the method suggested by Rice University in its
	{browse "http://onlinestatbook.com/2/index.html":online statistics book},
	chapter II, graphing distributions, section 5, histograms, to calculate the
	number of bins.
{p_end}

{p2col:{it:doane}}
	This uses Doane (1976)'s calculation of the number of bins.
{p_end}

{p2col:{it:scott}}
	This uses Scott (1979)'s method to calculate the bin width.
{p_end}

{p2col:{it:freedman}}
	This uses Freedman and Diaconis (1981)'s method to calculate the bin width.
{p_end}

{p2col:{it:wand}}
	This uses Wand (1997)'s {it:zero-stage rule} to calculate the bin width.
{p_end}

{p2col:{it:stata}}
	This uses Stata's default method of calculating the number of bins.
{p_end}

{p2col:{it:all}}
	This option uses all of the previous mentioned methods to generate as many
	histograms.
{p_end}
{p2colreset}{...}
{synoptset 15 tabbed}{...}
{synoptline}
{p2colreset}{...}

{synoptset 15 tabbed}{...}
{syntab:{opt metd:isplay(display_options)}}
{synoptline}
{p 7 7 2}
	This option is not required. It allows you to specify where to display the
	method used in the histogram, or to specify that you don't want to display
	it. If you don't set this option it will default to showing the method in
	the subtitle.
{p_end}

{p 7 7 2}
	If you pass any additional text for the textbox you set in this option, by
	setting the option for the corresponding textbox, the method will be combined with the text
	thus: the method is displayed first, followed by a colon, and then followed
	by the text specified. For example, {cmd:spechist} {it:varname},
	{opt me(sturges)} {opt metd(title)} {opt title(First Section)} will display
	"Sturges (1926): First Section" as the title (without the double quotes, of
	course). See the {help spechist##examples:examples} below.
{p_end}
{synoptline}
{p2colreset}{...}

{synoptset 15 tabbed}{...}
{marker dispopts}{...}
{synopthdr: display_options}
{synoptline}
{p2colreset}{...}
{p2colset 7 21 22 2}{...}
{p2col:{it:title}}
	The method will be displayed as the title of the graph.
{p_end}

{p2col:{it:subtitle}}
	The method will be displayed as the subtitle of the graph. This is the
	default
{p_end}

{p2col:{it:note}}
	The method will be displayed as a note in the graph.
{p_end}

{p2col:{it:caption}}
	The method will be displayed as the caption of the graph.
{p_end}

{p2col:{it:none}}
	The method will not be displayed.
{p_end}
{p2colreset}{...}
{synoptset 15 tabbed}{...}
{synoptline}
{p2colreset}{...}

{marker coptions}{...}
{synoptset 15 tabbed}{...}
{syntab:{opt copt:ions(combine_options)}}
{synoptline}
{p 7 7 2}
	This option is available so that you specify the options you want to set for
	the {cmd:{ul:gr}aph} {cmd:combine} command that will combine the histograms
	when you specify more than one method of estimation. It is thus only allowed
	when you either specify more than one method, or when you specify {it:all}
	as your method option.
{p_end}
{synoptline}
{p2colreset}{...}

{marker histopts}{...}
{synoptset 19 tabbed}{...}
{syntab:{it:{help histogram##options:histogram_options}}}
{synoptline}
{p 7 7 2}
	All the options for {cmd:histogram} are allowed except: {opt bin(#)}
	{opt w:idth(#)} and {opt d:iscrete}.
{p_end}

{p 7 7 2}
	The options {opt nodraw}, {opt name(name, ...)}, and
	{opt saving(filename, ...)} are valid when specifying only one method of
	estimation. If you want to not display, to name the final combined graph, or
	to save the final combined graph when specifying more than one method, you
	should submit these options in the {opt copt:ions(combine_options)} option.
{p_end}
{synoptline}
{p2colreset}{...}

{marker weight}{...}
{synoptset 19 tabbed}{...}
{syntab:{it:{help weight}}}
{synoptline}
{p 7 7 2}
	Only {opt fweight}s are allowed.
{p_end}
{synoptline}
{p2colreset}{...}

{marker examples}{...}
{title:Examples}

{phang}Load a dataset to use the command:{p_end}
{phang}.{stata "sysuse citytemp, clear": sysuse citytemp, clear}{p_end}

{phang}Use the command:{p_end}
{phang}
.{stata "spechist tempjan, method(sturges)": spechist tempjan, method(sturges)}
{p_end}
{phang}
.{stata "spechist tempjan, me(doane) metd(none)": spechist tempjan, me(doane) metd(none)}
{p_end}
{phang}
.{stata "spechist tempjan, me(scott) subtitle(West Subsample)": spechist tempjan, me(scott) subtitle(West Subsample)}
{p_end}
{phang}
.{stata "spechist tempjan, me(sqrt wand doane scott) metd(caption) kden": spechist tempjan, me(sqrt wand doane scott) metd(caption) kden}
{p_end}
{phang}
.{stata "spechist tempjuly, me(all) kden copt(imargin(small))" : spechist tempjuly, me(all) kden copt(imargin(small))}
{p_end}

{title:Stored results}

{pstd}{cmd:spechist} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars:}{p_end}

{synopt:{cmd:r(start)}}The {opt start()} value or minimum value of
{it:varname}.{p_end}
{synopt:{cmd:r(N)}}The number of observations.{p_end}
{synopt:{cmd:r({it:method}_width)}}The common width of the bins for the
specified {it:method}.{p_end}
{synopt:{cmd:r({it:method}_bin)}}The number of bins for the specified
{it:method}.{p_end}
{synopt:{cmd:r({it:method}_max)}}The upper limit of the last bin for the
specified {it:method}.{p_end}
{synopt:{cmd:r({it:method}_min)}}The lower limit of the first non-empty bin for
the specified {it:method}.{p_end}
{synopt:{cmd:r({it:method}_area)}}The area of the bars for the specified
{it:method}.{p_end}

{p2col 5 20 24 2: Matrices:}{p_end}

{synopt:{cmd:r({it:method}_bins)}}The boundaries for the different bins used in
the specified {it:method}. It includes the {opt min} as the first value, and the
{opt max} as the last value in the matrix.{p_end}
{p2colreset}{...}

{pstd}The method specific scalars and matrices will only be available for those
{it:{help spechist##method_options:method_options}} specified in the
{opt me:thod()} option, and for all methods if {it:all} is specified for
{it:{help spechist##method_options:method_options}}.

{title:References}

{phang}
	Doane, David P. 1976. Aesthetic Frequency
	Classifications. {it:The American Statistician} 30(4): 181-183
{p_end}

{phang}
	Freedman, David and Diaconis, Persi. 1981. On the Histogram as a Density
	Estimator: L2 Theory. {it:Zeitschrift f{c u:}r Wahrscheinlichkeitstheorie und Verwandte Gebiete}
	57(4): 453-476
{p_end}

{phang}
	Scott, David W. 1979. On Optimal and Data-Based Histograms. {it:Biometrika}
	66(3): 605-610
{p_end}

{phang}
	Sturges, Herbert A. 1926. The Choice of a Class
	Interval. {it:Journal of the American Statistical Association} 21(153): 65-66
{p_end}

{phang}
	Wand, M. P. 1997. Data-Based Choice of Histogram Bin
	Width. {it:The American Statistician} 51(1): 59-64
{p_end}

{title:Acknowledgements/Comments}

{p 4 4 2}
	I would like to thank Joe Canner for several comments that helped in the
	development of this program, and Nicholas J. Cox for comments on SMCL
	formatting and {cmd:spechist}'s functionality.
{p_end}

{p 4 4 2}
	If you know of another method to calculate either the number of bins, or bin
	width, please email to notify me about it and a reference for me to be able
	to look it up at the address provided {help spechist##email:below}. I would
	love this program to grow and capture as many specific methods as possible
	so that it makes all our lives much easier.
{p_end}

{title:Author}

{phang}Alfonso S{c a'}nchez-Pe{c n~}alver{p_end}
{phang}Lock Haven University of Pennsylvania{p_end}
{phang}Lock Haven, PA USA{p_end}
{marker email}{...}
{phang}asp155@lhup.edu{p_end}

{title:Also see}

{psee}
Online: {manhelp histogram R}, {manhelp graph_combine G-2:graph combine}
{p_end}

{* Version 1.2.0 2014-07-29}
