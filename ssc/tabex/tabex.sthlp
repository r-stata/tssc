{smcl}
{* 13nov2015}{...}
{hline}
help for {hi:tabex}
{hline}


{title:Basic syntax}

{pstd}
{cmd:tabex var}

{pstd}
or

{pstd}
{cmd:tabex, reset}

{title:Advanced syntax}

{pstd}
{cmd:tabex var1 [var2] [{it:{help if}}] [{cmd:using} {it:{help filename}}], [cname(string)] [reset]} 


{title:Description}

{pstd}
{cmd:tabex} does a single variable tabulate and exports the result to an Excel document in your current
directory, or to a specified file path.  It can export multiple tabs to the same spreadsheet.
{cmd:tabex} can also perform a sum of a numeric variable if you choose to include a second variable. 


{title:Remarks}

{pstd}
Unless you specify another filename and path with {cmd:using}, {cmd:tabex} will create and modify an Excel document called
"tabex.xlsx" in your current directory.  If you are going to do multiple sessions of tabs, take time to rename
this document after each session so it does not get overwritten. 

{pstd} 
Stata will keep track of how many {cmd:tabex} you have run and exports each one to the next available column in
the output file.  You can {cmd:tabex} up to 50 times, after which Stata will return an error and tell you to reset {cmd:tabex}.

{pstd} 
To reset {cmd:tabex} just type: {cmd:tabex, reset} or include the {cmd:reset} option in your 50th (or last)
{cmd:tabex}.  Remember to rename or change your output file after resetting or your output will be overwritten!

{title:Arguments and options}

{pstd}{cmd:var1} is required unless you use the {cmd:reset} option. This {cmd:var} is basically your "by" or
"level" variable. {cmd:tabex} calculates a frequency within each unique value of this variable.

{pstd}{cmd:var2} is optional. This {cmd:var} must be numeric because tabex will sum this variable by var1.
 

{pstd}{cmd:[if]} specifies which subset of your data you are interested in tabulating. 

{pstd}{cmd:using} is optional and will tell Stata where to save your {cmd:tabex} output.
If you do not specify a path and filename, Stata will create an Excel document
called "tabex.xlsx" in your current directory and export to that file.

{pstd}{cmd:cname(string)} is optional and gives you a way to title each column in your output.
If you choose to forgo the {cmd:cname()} option, {cmd:tabex} will title the output column with
whatever letter corresponds to that column in Excel. It is highly recommended that you do not
forgo the {cmd:cname()} option, but if you must, please keep careful track of what you are
{cmd:tabex}ing so you can properly label your output later.


{pstd}{cmd:[reset]} is optional. It resets {cmd:tabex} back to the first column of the output file, kind of like
a typewriter.  You MUST {cmd:reset} after 50 {cmd:tabexes} but you may {cmd:reset} earlier than that if you wish.
{cmd:reset} can be invoked either as an option with any {cmd:tabex} command or by itself by typing: {cmd:tabex, reset}.



{title:Examples}

sysuse nlsw88,clear

tabex age if collgrad == 0 using "nlsw_tabs.xlsx",cname(hs)
tabex age if collgrad == 1 using "nlsw_tabs.xlsx",cname(coll)
tabex age if married == 0 using "nlsw_tabs.xlsx",cname(single)
tabex age if married == 1 using "nlsw_tabs.xlsx",cname(married) reset

tabex industry using "nslw_ind_tabs.xlsx",cname(all)
tabex industry if union == 0 using "nslw_ind_tabs.xlsx",cname(non-union)
tabex industry if union == 1 using "nslw_ind_tabs.xlsx",cname(union)
tabex industry if union == . using "nslw_ind_tabs.xlsx",cname(miss_union)
tabex industry if collgrad == 0 & occupation != 3 using "nslw_ind_tabs.xlsx",cname(hs_non_sales)
tabex industry if collgrad == 0 & occupation == 3 using "nslw_ind_tabs.xlsx",cname(hs_sales) reset

{pstd}
Running the above code would output two Excel documents, one with four exported tabulates and one with six.
Each tabulate being a frequency, by age in the first example and industry in the second, based on {cmd:if} logic.

{pstd}
The {cmd:reset} options are used to insure that subsequent {cmd:tabex}es appear at the beginning of the output document.



{title:Acknowledgements} 

{pstd}Lyz Gaumer provided this problem and inspired the solution. 

{p_end}