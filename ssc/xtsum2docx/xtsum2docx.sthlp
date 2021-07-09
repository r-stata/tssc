{smcl}
{* *! version 1.7.2 3apr2019}{...}
{vieweralsosee "Help sum2docx" "help sum2docx "}{...}
{vieweralsosee "[P] putdocx" "help putdocx "}{...}
{viewerjumpto "Syntax" "xtsum2docx##syntax"}{...}
{viewerjumpto "Description" "xtsum2docx##description"}{...}
{viewerjumpto "Options" "xtsum2docx##options"}{...}
{viewerjumpto "Examples" "xtsum2docx##examples"}{...}
{viewerjumpto "Acknowledgment" "xtsum2docx##acknowledgment"}{...}
{viewerjumpto "Author" "xtsum2docx##author"}{...}
{title:Title}

{phang}
{bf:xtsum2docx} {hline 2} Report summary statistics of panel data to a formatted table in the DOCX format.


{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:xtsum2docx} {it:varlist} [{it:if}] [{it:in}] {it:using filename} [, {it:options}]

where {it:varlist} is a list of numerical variables.


{marker description}{...}
{title:Description}

{pstd}
{cmd:xtsum2docx} can report all statistics that can be reported by {help xtsum} and by {help summarize} with the option {opt detail}. 
{p_end}

{pstd}
This is an extension of the user-written command {help sum2docx} (instead of a wrapper, so {help sum2docx} is not required to be installed). 
{p_end}

{pstd}
{cmd:xtsum2docx} has an additional feature to re-order the resulting table columns using the option {opt order()}. The names of statistics (e.g., {opt mean}, {opt xtn}, etc.) should be listed in the order that you would like.
{p_end}


{marker options}{...}
{title:Options: added to xtsum2docx}

{phang}
{opt order(string)} lists the outputs in the specified order in the resulting table. {p_end}

{phang}
{opt xtn}{opt [}{opt (fmt)}{opt ]} outputs the number of panels (i.e., r(n)) and specifies the format. {p_end}

{phang}
{opt xttbar}{opt [}{opt (fmt)}{opt ]} outputs the average T (i.e., r(Tbar)) and specifies the format. {p_end}

{phang}
{opt xtmaxb}{opt [}{opt (fmt)}{opt ]} outputs the between-maximum (i.e., r(max_b)) and specifies the format. {p_end}

{phang}
{opt xtmaxw}{opt [}{opt (fmt)}{opt ]} outputs the within-maximum (i.e., r(max_w)) and specifies the format. {p_end}

{phang}
{opt xtminb}{opt [}{opt (fmt)}{opt ]} outputs the between-minimum (i.e., r(min_b)) and specifies the format. {p_end}

{phang}
{opt xtminw}{opt [}{opt (fmt)}{opt ]} outputs the within-minimum (i.e., r(min_w)) and specifies the format. {p_end}

{phang}
{opt xtsdb}{opt [}{opt (fmt)}{opt ]} outputs the between-standard deviation (i.e., r(sd_b)) and specifies the format. {p_end}

{phang}
{opt xtsdw}{opt [}{opt (fmt)}{opt ]} outputs the within-standard deviation (i.e., r(sd_w)) and specifies the format. {p_end}

{title:Options: inherited from sum2docx}

{phang}
{opt replace} permits to overwrite an existing file. {p_end}

{phang}
{opt append} permits to append the output to an existing file. {p_end}

{phang}
{opt title(string)} specifies the title of the table. {p_end}

{phang}
{opt obs}{opt [}{opt (fmt)}{opt ]} outputs the number of the observations and specifies the format. {p_end}

{phang}
{opt mean}{opt [}{opt (fmt)}{opt ]} outputs the mean and specifies the format. {p_end}

{phang}
{opt var}{opt [}{opt (fmt)}{opt ]} outputs the variance and specifies the format. {p_end}

{phang}
{opt sd}{opt [}{opt (fmt)}{opt ]} outputs the standard deviation and specifies the format. {p_end}

{phang}
{opt skewness}{opt [}{opt (fmt)}{opt ]} outputs the skewness and specifies the format. {p_end}

{phang}
{opt kurtosis}{opt [}{opt (fmt)}{opt ]} outputs the kurtosis and specifies the format. {p_end}

{phang}
{opt sum}{opt [}{opt (fmt)}{opt ]} outputs the sum and specifies the format. {p_end}

{phang}
{opt min}{opt [}{opt (fmt)}{opt ]} outputs the minimum and specifies the format. {p_end}

{phang}
{opt median}{opt [}{opt (fmt)}{opt ]} outputs the median and specifies the format. {p_end}

{phang}
{opt max}{opt [}{opt (fmt)}{opt ]} outputs the maximum and specifies the format. {p_end}

{phang}
{opt p1}{opt [}{opt (fmt)}{opt ]} outputs the 1st percentile and specifies the format. {p_end}

{phang}
{opt p5}{opt [}{opt (fmt)}{opt ]} outputs the 5th percentile and specifies the format. {p_end}

{phang}
{opt p10}{opt [}{opt (fmt)}{opt ]} outputs the 10th percentile and specifies the format. {p_end}

{phang}
{opt p25}{opt [}{opt (fmt)}{opt ]} outputs the 25th percentile and specifies the format. {p_end}

{phang}
{opt p50}{opt [}{opt (fmt)}{opt ]} outputs the 50th percentile (i.e., the median) and specifies the format. {p_end}

{phang}
{opt p75}{opt [}{opt (fmt)}{opt ]} outputs the 75th percentile and specifies the format. {p_end}

{phang}
{opt p90}{opt [}{opt (fmt)}{opt ]} outputs the 90th percentile and specifies the format. {p_end}

{phang}
{opt p95}{opt [}{opt (fmt)}{opt ]} outputs the 95th percentile and specifies the format. {p_end}

{phang}
{opt p99}{opt [}{opt (fmt)}{opt ]} outputs the 99th percentile and specifies the format. {p_end}


{marker examples}{...}
{title:Examples}

{phang}
{stata `"webuse abdata.dta, clear"'}
{p_end}

{pstd}
Report summary statistics for variable n, w, and k, saving the table as "temp.docx":

{phang}
{stata `"xtsum2docx n w k using temp.docx, replace obs mean sd p25 p50 p75 xtn xttbar title("Summary statistics")"'}
{p_end}

{pstd}
Re-order the statistics, with additional formatting (some statistics are now reported in %9.2f):

{phang}
{stata `"xtsum2docx n w k using temp.docx, replace obs mean(%9.2f) sd(%9.2f) p25 p50 p75 xtn xttbar(%9.2f) order(p25 p50 p75 mean sd xtbar xtn obs) title("Summary statistics")"'}
{p_end}

{pstd}
Append another table (a feature inherited from {help sum2docx}):

{phang}
{stata `"xtsum2docx n w k using temp.docx, append xtminw xtmaxw xtsdw(%9.2f) xtminb xtmaxb xtsdb(%9.2f) order(xtminw xtmaxw xtsdw xtminb xtmaxb xtsdb) title("Additional statistics")"'}
{p_end}


{marker acknowledgment}{...}
{title:Acknowledgment}

{pstd}
I am so grateful to the original authors of {help sum2docx}, Chuntao Li (China Stata Club) and Yuan Xue (China Stata Club), for developing such a nice command. I also thank Li Tang (IMF) for her kind and very helpful support. I am deeply thankful to Professor Christopher F. Baum to maintain the Statistical Software Components (SSC) archive, hosted by Boston College (United States).
{p_end}


{marker author}{...}
{title:Author}

{pstd}Futoshi Narita{p_end}
{pstd}International Monetary Fund{p_end}
{pstd}Washington, DC, United States{p_end}
{pstd}fnarita@imf.org{p_end}
