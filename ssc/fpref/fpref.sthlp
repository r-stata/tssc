{smcl}
{* *! version 1.0  18sep2010}{...}
{hline}
help for {hi:fpref}
{hline}

{p2colset 5 16 21 2}{...}
{p2col : fpref} {hline 2} Adds a prefix or a suffix, or both, to file names by batch {p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 8 2}
{opt fpref} {it:file_extension}, {it:option}

{p 15 8 2}
where {it:option} can be {opt pref:ix}({it:prefix}) or {opt suff:ix}({it:suffix}), or both 


{title:Description}

{p 8 8 2}
{cmd:fpref} adds the prefix {it: prefix} or the suffix {it:suffix}, or both, to existing filenames with file
extension {it:file_extension} in the current directory 

{p 8 8 2}
{it:prefix} or {it:suffix} can be any numeric or string (without blank spaces) that are
allowed as part of file names

{p 8 8 2}
{it:file_extension} can be any file extension, e.g., {it:doc}, {it:xls}, {it:txt}. 

{title:Examples}

{p 8 8 2}{cmd:. fpref dta, pref(_)}

{p 8 8 2}{cmd:. fpref doc, suff(X)}

{p 8 8 2}{cmd:. fpref txt, pref(_) suff(X)}


{title:Acknowledgement}

{p 8 8 2}
Thanks to Christopher Baum for his advice on how to make it work on other OS besides Windows (Mac OS X / Linux / Unix)

{title:Author} 

{p 8 8 2} Arnelyn Abdon {break}
	University of the Philippines {break}
    mitchaabdon@gmail.com
{p_end}
