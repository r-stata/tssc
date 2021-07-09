{smcl}
{* 9dec2015/7mar2016}{...}
{cmd:help wallplot} 
{hline}

{title:Stacked plot of one or more variables with depth as vertical axis}


{title:Syntax}

{p 8 18 2}
{cmd:wallplot} {it:depthvar xvarlist} 
{ifin} 
[{cmd:,}
{opt varallopts(graph_options)} 
{opt var1opts(graph_options)} 
{opt var2opts(graph_options)} 
{opt var3opts(graph_options)} 
...
{opt var20opts(graph_options)} 
{it:graph_options} 
]


{title:Description}

{pstd}
{cmd:wallplot} is intended primarily for researchers with environmental
data to be plotted with depth below surface as vertical axis. The depth
variable {it:depthvar} must always be specified first and by default
will be shown with a reversed scale, low values at the top and high
values at the bottom.  Other numeric variables should be specified
afterwards and will be plotted as stacked areas or bars against the {it:x} axis.
Each distinct depth value should occur just once in the data provided. 

{pstd} 
The name {cmd:wallplot} is a little fanciful. Not every distinct kind of
graph has a specific dedicated name, which is on balance a good thing,
but every program needs a specific name, ideally not too lengthy nor too
cryptic. In this case you are asked to imagine that you are looking at a
{it:wall}, tiled or bricked in some pattern. 


{title:Remarks} 

{pstd}
The tacit assumption is that the variable(s) shown are parts of a whole
with zero or positive values, and hence or otherwise may meaningfully
be stacked or cumulated to show a total for each depth as well as
individual components. There is no assumption that values add to a
constant; any such scaling should be produced in advance when desired. 

{pstd} 
Each other variable is by default shown as a area plot added
horizontally to all previously mentioned variables. The first other variable 
is by default shown using {cmd:twoway area} and subsequently mentioned
variables are by default shown using {cmd:twoway rarea}, stacking or 
cumulation being ensured by calculation.  

{pstd}
Use {cmd:recast()} to recast to equivalent {cmd:twoway} graphs, most
obviously {cmd:recast(rbar)}. (The equivalent recast from 
{cmd:twoway area} to {cmd:twoway bar} is handled automatically.) 

{pstd} 
Note that variable labels will be echoed to the graph when they exist,
but typically they should be very concise as well as informative. 
Units of measurement common to several variables are better 
specified by a {cmd:note()} or {cmd:caption()} or {cmd:subtitle()}
option. 

{pstd}
If the vertical scale is in effect a height scale, then specify
{cmd:ysc(noreverse)} to override the default. 


{title:Options}

{phang}
{cmd:varallopts()} specify any options to be applied repeatedly to the
plot elements for all individual variables. 

{phang} 
{cmd:var1opts()},
{cmd:var2opts()},
{cmd:var3opts()},
...
{cmd:var20opts()} 
specify any options to be applied repeatedly to the 
plot elements for the 1st, 2nd, 3rd, ..., 20th variable plotted against
the {it:x} axis. The limit of 20 is plucked out of the air as presumably
being large enough for foreseeable needs. Users needing more should edit
the code and then take full responsibility for that edit. Any such
option always overrrides {cmd:varallopts()}. 

{phang}
{it:graph_options} are any options allowed for {help twoway rarea} or for 
any equivalent graph command invoked using {cmd:recast()} that are
to be applied to the graph as a whole. The option {cmd:horizontal} is automatic.


{title:Examples} 

{phang}{cmd:. clear }{p_end}
{phang}{cmd:. input levels freqcores freqblanks freqtools}{p_end}
{phang}{cmd:     25 21 32 70}{p_end}
{phang}{cmd:     24 36 52 115}{p_end}
{phang}{cmd:     23 126 650 549}{p_end}
{phang}{cmd:     22 159 2342 1633}{p_end}
{phang}{cmd:     21 75 487 511}{p_end}
{phang}{cmd:     20 176 1090 912}{p_end}
{phang}{cmd:     19 132 713 578}{p_end}
{phang}{cmd:     18 46 374 266}{p_end}
{phang}{cmd:     17 550 6182 1541}{p_end}
{phang}{cmd:     16 76 846 349}{p_end}
{phang}{cmd:     15 17 182 51}{p_end}
{phang}{cmd:     14 4 51 14}{p_end}
{phang}{cmd:     13 29 228 130}{p_end}
{phang}{cmd:     12 135 2227 729}{p_end}
{phang}{cmd:end }{p_end}
{phang}{cmd:. gen total = freqc + freqb + freqt }{p_end}
{phang}{cmd:. foreach t in cores blanks tools {c -(} }{p_end}
{phang}{cmd:. 	gen p`t' = freq`t' / total }{p_end}
{phang}{cmd:. 	label var p`t' "`t'" }{p_end}
{phang}{cmd:. {c )-}}{p_end}
{phang}{cmd:. }{p_end}
{phang}{cmd:. wallplot levels p*, ysc(noreverse) yla(12/25) }{p_end}

{phang}{cmd:. more }{p_end}

{phang}{cmd:. wallplot levels p*, ysc(noreverse) yla(12/25) ///}{p_end}
{phang}{cmd:var1opts(fcolor(red*0.5) lcolor(red*0.8)) ///}{p_end}
{phang}{cmd:var2opts(fcolor(magenta*0.5) lcolor(magenta*0.8)) ///}{p_end}
{phang}{cmd:var3opts(fcolor(blue*0.5) lcolor(blue*0.8)) }{p_end}

{phang}{cmd:. more }{p_end}

{phang}{cmd:. wallplot levels p*, ysc(noreverse) yla(12/25) ///}{p_end}
{phang}{cmd:var1opts(fcolor(red*0.5) lcolor(red*0.8)) ///}{p_end}
{phang}{cmd:var2opts(fcolor(magenta*0.5) lcolor(magenta*0.8)) ///}{p_end}
{phang}{cmd:var3opts(fcolor(blue*0.5) lcolor(blue*0.8)) ///}{p_end}
{phang}{cmd:recast(rbar) legend(cols(3)) aspect(1) plotregion(margin(zero))}{p_end}


{title:Author} 

{pstd}Nicholas J. Cox, Durham University{break} 
      n.j.cox@durham.ac.uk 


{title:Acknowledgments}

{pstd}This command was stimulated by discussions with Jeff Warburton. 
The data used in the examples are from Doran and Hodson (1975, p.259). 


{title:Reference}

{p 4 8 2}Doran, J.E. and Hodson, F.R. 1975. 
{it:Mathematics and computers in archaeology.} 
Edinburgh: Edinburgh University Press. 


{title:Also see}

{psee}
Manual: 
{bf:[G-2] graph twoway rarea}, 
{bf:[G-2] graph twoway rbar}, 
{bf:[G-2] graph bar}, 
{bf:[G-3] advanced_options} 

{psee}
User-written: 
{help depthplot} (if installed), 
{help tabplot} (if installed) 

