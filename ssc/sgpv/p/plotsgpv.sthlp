{smcl}
{* *! version 1.00  20 Mar 2020}{...}
{viewerdialog plotsgpv "dialog plotsgpv"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "SGPV (Main Command)" "help sgpv"}{...}
{vieweralsosee "SGPV Value Calculations" "help sgpvalue"}{...}
{vieweralsosee "SGPV Power Calculations" "help sgpower"}{...}
{vieweralsosee "SGPV False Confirmation/Discovery Risk" "help fdrisk"}{...}
{viewerjumpto "Syntax" "plotsgpv##syntax"}{...}
{viewerjumpto "Description" "plotsgpv##description"}{...}
{viewerjumpto "Options" "plotsgpv##options"}{...}
{* viewerjumpto "Remarks" "plotsgpv##remarks"}{...}
{viewerjumpto "Examples" "plotsgpv##examples"}{...}
{title:Title}
{phang}
{bf:plotsgpv} {hline 2} Plotting Second-Generation P-Values

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:plotsgpv}
[{help if}]
[{help in}]
{cmd:,} estlo(string) esthi(string) nulllo(string) nullhi(string)
[{it:options}]

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt estlo(string)}}  lower bound of interval estimate. Values may be finite or infinite.
{p_end}
{synopt:{opt esthi(string)}}  upper bound of interval estimate. Values may be finite or infinite.
{p_end}
{synopt:{opt nulllo(string)}}  lower bound of null interval.
{p_end}
{synopt:{opt nullhi(string)}}  upper bound of null interval.
{p_end}

{syntab:Colors}
{synopt:{opt nullc:ol(string)}}  coloring of the null interval (indifference zone).
{p_end}
{synopt:{opt intcol1(string)}} color of the interval according to SGPV ranking for SGPV = {it:0}. 
{p_end}
{synopt:{opt intcol2(string)}} color of the interval according to SGPV ranking for {it:0} < SGPV < {it:1}. 
{p_end}
{synopt:{opt intcol3(string)}} color  of the interval according to SGPV ranking for SGPV = {it:1}. 
{p_end}

{syntab:Titles}
{synopt:{opt t:itle(string)}}  title of the plot.
{p_end}
{synopt:{opt xt:itle(string)}}  label of the x-axis label.
{p_end}
{synopt:{opt yt:itle(string)}}  label of the y-axis.
{p_end}

{syntab:Further options}
{synopt:{opt noploty:_axis}}  deactive showing the y-axis.
{p_end}
{synopt:{opt noplotx:_axis}}  deactive showing the x-axis.
{p_end}
{synopt:{opt noleg:end}}  deactivate plotting the legend.
{p_end}
{synopt:{opt noout:linezone}}  deactivate drawing a slim white outline around the null zone. Helpful visual aid when plotting many intervals. Default is on.
{p_end}
{synopt:{opt seto:rder(string)}} a variable giving the desired order along the x-axis. 
{p_end}
{synopt:{opt x:show(#)}}  a number representing the maximum ranking on the x-axis that is displayed. Default is to display all intervals.
{p_end}
{synopt:{opt nullpt(#)}} a number representing a point null hypothesis. {p_end}
{synopt:{opt nomata}}  do not use Mata for calculating the SGPVs if esthi() and estlo() are variables as inputs or if {cmd:c(matsize)} is smaller than the size of these options.
{p_end}
{synopt:{opt noshow}}  do not show the outcome of the SGPV calculations. Useful for larger calculations.
{p_end}
{synopt:{opt replace}}  replace existing variables in case the nomata-option was used.
{p_end}
{synopt:{opt two:way_opt(string asis)}}  any additional options for the plotting go here. 
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}
Plot the second-generation {it:p}-value (SGPV), as introduced in Blume et al. (2018), for user supplied interval estimates (support intervals, confidence intervals, credible intervals, etc.) according to its associated second-generation {it:p}-value ranking.
This command and its companions commands  ({cmd:sgpvalue}, {cmd:sgpower}, {cmd:fdrisk}) are based on the R-code for the sgpv-package from {browse "https://github.com/weltybiostat/sgpv"}.
A {dialog plotsgpv:dialog box} for easier usage is available.

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt estlo(string)}  lower bound of interval estimate. The lower limit is -infinity just specify the missing value . in this option. Multiple lower bounds can be entered. They must be separated by spaces. Typically the lower bound of a confidence interval can be used. A variable containing the lower bound can be also used.

{phang}
{opt esthi(string)}  upper bound of interval estimate. Values may be finite or infinite.
To specify that the upper limit is +infinity just specify the missing value . in this option. Must be of same length as in the option {it:estlo}. 
Multiple upper bounds can be entered. They must be separated by spaces.
 Typically the upper bound of a confidence interval can be used. A variable containing the upper bound can be also used.

{phang}
{opt nulllo(string)}     lower bound of null interval.

{phang}
{opt nullhi(string)}     upper bound of null interval.

{marker colors}
{dlgtab:Colors}

{phang}
{opt nullc:ol(string asis)}  coloring of the null interval (indifference zone). Default is the R-color "Hawkes Blue". You can see the color before plotting via 
{stata palette color 208 216 232 }.
You can set the color to any other available color in Stata. See {helpb colorstyle} for more information.

{phang}
{title:Interval colors}{break}
The coloring of the intervals according to SGPV ranking. Default are the R-colors ("cornflowerblue","firebrick3","darkslateblue") for SGPVs of {it:0}, in {it:(0,1)}, and {it:1} respectively. 
You can see the default color(s) before plotting via:
 
		{stata palette color 205 38 38 } 	firebrick3 	for SGPV = 0
		{stata palette color 100 149 237 } 	cornflowerblue 	for 0 < SGPV < 1 
		{stata palette color 72 61 139 } 	darkslateblue 	for SGPV = 1

{pstd}		
You can set the colors to any other available color in Stata. See {helpb colorstyle} for more information.{p_end}	
{phang}
{opt intcol1(string asis)}  color of the interval with the R-color "firebrick3" as the default for SGPV = {it:0}

{phang}
{opt intcol2(string asis)}  color of the interval with the R-color "cornflowerblue" as the default for {it:0} < SGPV < {it:1}

{phang}
{opt intcol3(string asis)}  color of the interval with the R-color "firebrick3" as the default for SGPV = {it:1}

{dlgtab:Title options}

{phang}
{opt t:itle(string)}     title of the plot.

{phang}
{opt xt:itle(string)}     label of the x-axis. Default is "Ranking according to <order>" where <order> can refer to the option {it:setorder()} or the original  sorting of the input. 

{phang}
{opt yt:itle(string)}     label of the y-axis.

{marker further_options}
{dlgtab:Further options}
{phang}
{opt noploty:_axis}     deactive showing the y-axis.

{phang}
{opt noplotx:_axis}    deactive showing the x-axis.

{phang}
{opt noout:linezone}     deactivate drawing a slim white outline around the null zone. Helpful visual aid when plotting many intervals. Default is on.

{phang}
{opt noleg:end}     deactivate plotting the legend.

{phang}
{opt seto:rder(string)}     a variable giving the desired order along the x-axis. If {bf:setorder} is set to {bf:"sgpv"}, the second-generation {it:p}-value ranking is used. If {bf:setorder} is empty, the original input ordering is used.

{phang}
{opt x:show(#)}    a number representing the maximum ranking on the x-axis that is displayed. Default is to display all intervals.

{phang}
{opt nullpt(#)} 	a number representing a point null hypothesis. If set, the command will draw a horizontal dashed red line at this location.

{phang}
{opt nomata}  deactivate the usage of Mata for calculating the SGPVs with large matrices or variables. If this option is set, an approach based on variables is used. Using variables instead of Mata will be faster, but new variables containing the results are created. If you don't want to create new variables and time is not an issue then don't set this option. Stata might become unresponsive when using Mata because it takes time to return a large matrix.

{phang}
{opt noshow}     do not show the outcome of the SGPV calculations. Useful for larger calculations.

{phang}
{opt replace}    replace existing variables in case the nomata-option was used.

{phang}
{opt two:way_opt(string asis)}     any additional options for the plotting go here. See {help twoway} for more information about the possible options. Options set here may override the values set in other options before.
{p_end}


{marker examples}{...}
{title:Examples}
{* pstd}
{bf:Replicate the example plot from the R-code with the example dataset provided with this command:}
(If you did not already install the example dataset, then you can download it {net "describe sgpv, from(https://raw.githubusercontent.com/skbormann/stata-tools/master/)":here} together with the file {it:plotsgpv-leukemia-example.do} which helps you run the example in Stata. )
Run following the lines with the help of {stata do plotsgpv-leukemia-example.do}

	. sysuse leukstats ,clear 
	. plotsgpv, esthi(ci_hi) estlo(ci_lo) nulllo(-0.3) nullhi(0.3) setorder(p_value) xshow(7000) title("Leukemia Example") ///
	xtitle("Classical p-value ranking") ytitle("Fold Change (base 10)") nullpt(0) nomata replace noshow  ///
	twoway_opt(ylabel(`=log10(1/1000)' "1/1000" `=log10(1/100)' "1/100" `=log10(1/10)' "1/10" `=log10(1/2)' "1/2" `=log10(2)' ///
	"2" `=log10(10)' "10" `=log10(100)' "100" `=log10(1000)'  "1000")) 
	
	The last option in twoway_opt(...) changes the labeling of the y-axis (See {help axis_label_options} for more information).
	

{title:References}
{pstd}
 Blume JD, D’Agostino McGowan L, Dupont WD, Greevy RA Jr. (2018). Second-generation {it:p}-values: Improved rigor, reproducibility, & transparency in statistical analyses. {it:PLoS ONE} 13(3): e0188299. 
 {browse "https://doi.org/10.1371/journal.pone.0188299"}

{pstd}
Blume JD, Greevy RA Jr., Welty VF, Smith JR, Dupont WD (2019). An Introduction to Second-generation {it:p}-values. {it:The American Statistician}. In press. {browse "https://doi.org/10.1080/00031305.2018.1537893"} 

{title:Author}
{p}
Sven-Kristjan Bormann, School of Economics and Business Administration, University of Tartu.

{title:Bug Reporting}
{psee}
Please submit bugs, comments and suggestions via email to:	{browse "mailto:sven-kristjan@gmx.de":sven-kristjan@gmx.de}{p_end}
{psee}
Further Stata programs and development versions can be found under {browse "https://github.com/skbormann/stata-tools":https://github.com/skbormann/stata-tools}{p_end}

{title:See Also}
Related commands:
 {help fdrisk}, {help sgpvalue}, {help sgpower}, {help sgpv}  

