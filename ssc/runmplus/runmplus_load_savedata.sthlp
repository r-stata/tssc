{smcl}
{hline}
Help file for {hi:runmplus_load_savedata}
{hline}

{p 4 4 2}
Reads in data saved by Mplus using the SAVEDATA command. Uses as
input the name of the output file from Mplus. By output file, I mean 
the file that Mplus uses to present data and model information, parameter
estimates, and other results. This program will read that output file and
extract the file name and variable names, and load the saved data into STATA.

{hline}

{p 8 17 2}
{cmd: runmplus_load_savedata} , out(string) [clear]

{title:Required commands}

{p 0 8 2}
{cmd:out} - name the output file. Include the extension. Include the 
entire path if you'd like. 

{title:Optional commands}

{p 0 8 2}
{cmd:clear} - clears the active data file before loading the SAVEDATA.

{title:Examples}

{p 8 8 2}
. {hi:runmplus_load_savedata , out(c:\trash\log.out) clear}

{title:Author}
{p 8 8 2}Richard N Jones, ScD{break}
Brown University{break}
richard_jones@brown.edu{break}


{title:Also see}

{p 0 19}On-line: help for {help stata2mplus} {help runmplus} {help infile} {help strparse } {p_end}
