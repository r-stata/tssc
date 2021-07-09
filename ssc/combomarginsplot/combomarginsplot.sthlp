{smcl}
{* *! version 1.0 16jan2014 }{...}
{viewerjumpto "Syntax" "marginsplot##syntax"}{...}
{viewerjumpto "Menu" "marginsplot##menu"}{...}
{viewerjumpto "Description" "marginsplot##description"}{...}
{viewerjumpto "Options" "marginsplot##options"}{...}
{viewerjumpto "Examples" "marginsplot##examples"}{...}
{viewerjumpto "Video examples" "marginsplot##video"}{...}
{viewerjumpto "Addendum: Advanced uses of dimlist" "marginsplot##dimlist2"}{...}
{title:Title}

{p2colset 5 26 28 2}{...}
{p2col :{cmd:combomarginsplot} {hline 2}}Combine multiple marginsplots
{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 21 2}{cmd:combomarginsplot} {help combomarginsplot##filelist:{it:margins_file_list}} [{cmd:,} 
{it:combomarginsplot_options} {help marginsplot##options:{it:marginsplot_options}}]

{synoptset 37 tabbed}{...}
{synopthdr:combomarginsplot_options}
{synoptline}
{syntab:Margins file handling}
{synopt:{cmdab:l:abels(}{it:label_list}{cmd:)}}list of quoted strings to label the margins in each file{p_end}
{synopt :{cmdab:filev:arname(}{it:newvarname}{cmd:)}}Specify variable name for file index. The default is "_filenumber".{p_end}

{syntab:Plot & CI Plots}
{synopt :{cmdab:file:}{ul:{it:#}}{cmd:opts(}{it:{help combomarginsplot##plotopts:plot_options}}{cmd:)}}affect 
        rendition of all plots from {it:#}th margins file{p_end}
{synopt :{cmdab:lplot:}{ul:{it:#}}{cmd:opts(}{it:{help combomarginsplot##plotopts:plot_options}}{cmd:)}}affect 
        rendition of each {it:#}th logical plot; i.e., the {it:#}th plot from each margins file{p_end}

{synopt :{cmdab:fileci:}{ul:{it:#}}{cmd:opts(}{it:{help rcap_options}}{cmd:)}}affect 
        rendition of all confidence interval plots from {it:#}th margins file{p_end}
{synopt :{cmdab:lci:}{ul:{it:#}}{cmd:opts(}{it:{help rcap_options}}{cmd:)}}affect 
        rendition of each {it:#}th logical confidence interval plot; i.e., the {it:#}th 
        confidence interval plot from each margins file{p_end}

{syntab:Other}
{synopt :{cmd:savefile(}{it:filename} [, replace]{cmd:)}}Save combined margins file. (Note that the {cmd:saving()} option, if 
		specified, applies to {cmd:marginsplot} and saves the resulting graph.) {p_end}
{synoptline}
{marker filelist}{...}
{phang}
    {it:margins_file_list} is a list of saved files created by the 
    {help margins_saving:saving} option of the {help margins:margins} command.

{marker description}{...}
{title:Description}

{pstd}
{cmd:combomarginsplot} combines the saved results from multiple calls to {cmd:margins} 
	into one {cmd:marginsplot}.
	
{pstd}{cmd:combomarginsplot} works by appending the saved margins file, treating
	each as a distinct level of a factor variable. By default the variable that indexes the file number 
	is {cmd:_filenumber}, though an alternative variable name can be specified with the {cmd:filevarname()}
	option{p_end}

{pstd}Note that it is possible to create a combined margins file that is incoherent, which will either
	cause {cmd:marginsplot} to return an error or create a nonsensical graph.  If you encounter a situation
	where you do not get what you expect, however, please contact me!{p_end}


{marker options}{...}
{title:Options}

{dlgtab:Margins file handling}

{phang}
{opt filevarname()} specifies a variable name to index the multiple appended
		margins files. {cmd:combomarginsplot} combines the margins files
		specified in {it:margins_file_list}, creating a combined margins file
		that appears to {cmd:marginsplot} to have come from a single margins command. 
		The multiple margins files appear to {cmd:marginsplot} to correspond
		to the levels of a factor variable, which is named by default "_filenumber".
		This option changes the name of that new factor variable.

{phang}		
{opt labels()} contains a list of labels for each combined file. These are used to label the
		values of the new factor variable that indexes the individual margins 
		file, thereby allowing the multiple margins to be labeled in the 
		plot.  If the labels contains spaces, they must be enclosed in quotation
		marks.
		
{dlgtab:Plot & CI Plot}

{phang}
{opt file}{cmd:{it:#}}{opt opts()} specifies formatting options to be applied to all 
		the plots associated with the {it:#}th margins file.

{phang}
{opt fileci}{cmd:{it:#}}{opt opts()} specifies formatting options to be applied to all 
		the confidence interval plots associated with the {it:#}th margins file.
	
{phang}
{opt lplot}{cmd:{it:#}}{opt opts()} specifies formatting options to be applied to all 
		the {it:#}th logical plot from each margins file.  Thus, for example, 
		{opt lplot1opts()} would apply formatting options to the first plot
		from each margins file.

{phang}
{opt lci}{cmd:{it:#}}{opt opts()} specifies formatting options to be applied to all 
		the {it:#}th logical confidence interval plot from each margins file.  

{dlgtab:Saving}

{phang}
{opt savefile()} specifies that the combined margins file should be saved. The saved file
		corresponds with the format of margins files saved with the margins command,
		meaning that multiple saved files can then be re-combined at a second
		hierarchical level by {cmd:combomarginsplot}.  Note that this option is 
		distinct from the {cmd:saving()} option, which tells {cmd:marginsplot} to 
		save the resulting graph.
		


{marker examples}{...}
{title:Examples}

{pstd}Combining results from multiple parallel models{p_end}
{phang2}. {stata sysuse auto}{p_end}

{phang2}. {stata oprobit rep78 i.foreign mpg price weight}{p_end}
{phang2}. {stata margins foreign, at(mpg=(10(5)50)) predict(outcome(3)) saving(file1, replace)}{p_end}

{phang2}. {stata oprobit rep78 i.foreign mpg}{p_end}
{phang2}. {stata margins foreign, at(mpg=(10(5)50)) predict(outcome(3)) saving(file2, replace)}{p_end}

{phang2}. {stata oprobit rep78 i.foreign mpg gear}{p_end}
{phang2}. {stata margins foreign, at(mpg=(10(5)50)) predict(outcome(3)) saving(file3, replace)}{p_end}

{phang2}. {stata combomarginsplot file1 file2 file3, labels("Full model" "Restricted model" "Gear Model") noci}{p_end}
	
{phang2}Using {cmd:file{it:#}opts()} and {cmd:lplot{it:#}opts()} to make plot clearer{p_end}
{phang2}. {stata combomarginsplot file1 file2 file3, labels("Full model" "Restricted model" "Gear Model") noci file1opts(pstyle(p1)) file2opts(pstyle(p2)) file3opts(pstyle(p3)) lplot1(mfcolor(white)) legend(colfirst)}{p_end}

{phang2}Separating plots from each file using {cmd:marginsplots}'s {cmd:by()} option{p_end}
{phang2}. {stata combomarginsplot file1 file2 file3, labels("Full model" "Restricted model" "Gear Model") noci by(_filenumber)}{p_end}

{phang2}Separating plots by a different variable{p_end}
{phang2}. {stata combomarginsplot file1 file2 file3, labels("Full model" "Restricted model" "Gear Model") noci by(foreign)}{p_end}

	
{pstd}Combining plots for multiple outcomes from one model{p_end}
{phang2}. {stata sysuse auto}{p_end}
{phang2}. {stata oprobit rep78 i.foreign mpg price weight}{p_end}
{phang2}. {stata margins foreign, at(mpg=(10(5)50)) expression(predict(outcome(1))+predict(outcome(2))) saving(file4, replace)}{p_end}
{phang2}. {stata margins foreign, at(mpg=(10(5)50)) expression(predict(outcome(4))+predict(outcome(5))) saving(file5, replace)}{p_end}

{phang2}. {stata combomarginsplot file4 file5 , labels("Outcomes 1&2" "Outcomes 4&5") noci file1opts(pstyle(p1)) file2opts(pstyle(p2)) lplot1(mfcolor(white))}{p_end}

{marker author}{...}
{title:Author}

{phang2}Nicholas Winter, University of Virginia, USA{p_end}
{phang2}nwinter@virginia.edu{p_end}


