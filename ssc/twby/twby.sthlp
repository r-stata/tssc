{smcl}
{* *! version 1.0.0 MLB 20Sep2018}{...}
{cmd:help twby}
{hline}

{title:Title}

{phang}
{bf:twby} {hline 2} Creates a cross-tabulation of graphs

{title:Syntax}

{p 8 17 2}
{cmd:twby} 
{help varname:rowvar} 
{help varname:colvar}
{cmd:,} [{it:options}]
{cmd::} {it:{help twoway: twoway graph}}

{synoptset 15 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt left}}specifies that the row labels appear on the left of the graph{p_end}
{synopt:{opt xoffset(#)}}specifies that the rowlabels move # to the left 
(negative numbers) or right (positive numbers){p_end}
{synopt:{it:{help by_option:by options}}}All the options normally used in a 
{cmd:by} option, except {cmd:total}, {cmd:rows()}, {cmd:cols()}, {cmd:holes()}, 
and {cmd:colfirst}, are allowed.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
The {cmd:twoway} graph should not contain a {cmd:by()} option. Anything one would
want to specify there, should be entered in the {cmd:twby} prefix instead.


{title:Description}

{pstd}
{cmd:twby} repeats a {help twoway : twoway graph} for each combination of values 
from two variables; it creates a table of graphs. By aligning the graphs 
appropriately,  one does not need to label each individual graph, so instead 
{cmd:twby} labels the columns at the top and the rows on the side. It automates 
the process discussed in (Buis and Weiss 2009)

{pstd}
In its simplest form it requires the two variables representing the rows and 
columns of the table of graphs followed by a colon followed by the graph that
is to appear in each cell of the table.

{cmd}
    . preserve
    . webuse auto2, clear
	
    . twby foreign rep78 : scatter price weight
	
    . restore
{txt}
{p 4 4 2}({stata "twby_ex 1":click to run}){p_end}

{pstd}
Within the {cmd:twby} prefix one can specify options that one would normally 
specify in the {help by_option: by()} option, except for options that would 
intervere with the allignment of graphs ( {cmd:total}, {cmd:rows()}, 
{cmd:cols()}, {cmd:holes()}, and {cmd:colfirst}), as {cmd:twby} needs to control 
that. We can use those options to make the basic example above a bit more pretty.

{cmd}
    . preserve
    . // open example data
    . webuse auto2, clear
    
    . // use some more sensible units
    . replace weight = 0.00045359237*weight
    . label variable weight "Weight (tonnes)"
    . replace price = price / 1000
    . label variable price "Price (1000s {c S|})"
    
    . // the graph
    . twby foreign rep78, compact :    ///
    >     scatter price weight,        ///
    >     ylab(,angle(0)) xlab(1(.5)2)
          
    . restore
{txt}
{p 4 4 2}({stata "twby_ex 2":click to run}){p_end}

{pstd}
We can also use {cmd:twby} to visualize a three-way cross-tabulation in a way 
similar to {cmd:tabplot} (Cox 2016).

{cmd}
    . preserve
    . // open example data  
    . sysuse nlsw88, clear

    . // create the necessary categorical variables
    . gen byte urban = c_city + smsa if !missing(c_city,smsa)
    . label define urban 2 "central city" ///
    >                    1 "suburban"     ///
    >                  0 "rural"
    . label value urban urban
    . label variable urban "urbanicity"
     
    . gen byte marst = !never_married + married if !missing(never_married,married)
    . label define marst 0 "never married" ///
    >                    1 "widowed/divorced" ///
    >                    2 "married"
    . label value marst marst
    . label var marst "marital status"
                       
    . gen byte edcat = cond(grade <  12, 1,     ///
    >                  cond(grade == 12, 2,     ///
    >                  cond(grade <  16, 3,4))) ///
    >                  if !missing(grade)
    . label variable edcat "education"
    . label define edcat 1 "< highschool"    ///
    >                    2 "highschool"      ///
    >                    3 "some college"    ///
    >                    4 "college"            
    . label value edcat edcat                  
     
    . // the three way table we want to visualize
    . bys edcat: tab urban marst, row nofreq
     
    . // recreate that table as variables
    . contract edcat marst urban, zero nomiss
    . egen tot = total(_freq), by(urban edcat)
    . gen perc = _freq / tot *100
     
    . // variables that helps display the numbers in the graph
    . gen lab = strofreal(perc, "%5.0f")
    . gen y = -5
     
    . // the graph
    . twby urban marst ,                                             ///
    >         compact left xoffset(0.5) legend(off)                  ///
    >         title("Percentage in each marital status"              ///
    >               "given education and urbanicity") :              ///
    >     twoway bar perc edcat ,                                    ///
    >         xlab(1/4, val alt) yscale(range(0 75))                 ///
    >         ylab(none) ytitle("") barw(.5)                      || ///
    >     scatter y edcat ,                                          ///
    >         msymbol(none) mlab(lab) mlabpos(0) mlabcolor(black) 
    
    . restore
{txt}
{p 4 4 2}({stata "twby_ex 3":click to run}){p_end}


{title:Options}

{phang}
{cmd:left} specifies that the row labels appear on the left side the table of 
graphs. The default is the right.{p_end}

{phang}
{opt xoffset(#)} Moves the row labels {it:#} to the left (negative number) or
right (positive number).{p_end}

{phang}
{help by_option:by options} All the options normally used in a {cmd:by} option, 
except {cmd:total}, {cmd:rows()}, {cmd:cols()}, {cmd:holes()}, and 
{cmd:colfirst}, are allowed.{p_end}


{title:Author}

{pstd}
Maarten L. Buis,{break}University of Konstanz,{break}maarten.buis@uni.kn


{title:References}

{pstd}
Buis, M.L and Weiss, M. (2009) Stata tip 81: A table of graphs, 
{it:The Stata Journal}, 9(4): 643-647.

{pstd}
Cox, N.J. (2016) Speaking Stata: Multiple bar charts in tableform, 
{it:The Stata Journal}, 16(2): 491-510.


