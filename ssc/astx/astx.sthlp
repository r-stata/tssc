{smcl}
{right:version:  1.0.0}
{cmd:help astx} {right:2 APR 2017}
{hline}
{viewerjumpto "Options" "astx##options"}{...}

{title:Title}

{p 4 8}{cmd:astx}  -  Creates a table of descriptive statistics by a grouping variable. {p_end}


{title:Syntax}

{p 8 15 2}
{cmd:astx}
{help varlist,}  stat{it:(options)}
{it:{help by}}({it:varlist})


{title:Description}

{p 4 4 2} {cmd: astx} finds descriptive statistics for a specific variable over a grouping variable. Further, it estimates t-statistics and sends the output file to MS Excel File.
{p_end}


{marker astx_options}{...}
{title:Statistics Options}

{p 4 4 2} 
{cmd:astx} has the following options for reporting statistics. {p_end}

{p 4 4 2} 1. {cmd:sd} 		: for standard deviation {p_end}
{p 4 4 2} 2. {cmd:mean} 	: for mean 				 {p_end}
{p 4 4 2} 3. {cmd:semean} 	: for standard error of mean {p_end}
{p 4 4 2} 4. {cmd:median} 	: for median {p_end}
{p 4 4 2} 5. {cmd:count} 	: for counting non-missing values {p_end}
{p 4 4 2} 6. {cmd:sum}		: for running sum {p_end}
{p 4 4 2} 7. {cmd:range}	: for range {p_end}
{p 4 4 2} 8. {cmd:min} 		: for minimum {p_end}
{p 4 4 2} 9. {cmd:var}		: for maximum {p_end}
{p 4 4 2} 10. {cmd:cv} 		: for coefficient of variation {p_end}
{p 4 4 2} 11. {cmd:skewness}: for skewness {p_end}
{p 4 4 2} 12. {cmd:kurtosis}: for kurtosis {p_end}
{p 4 4 2} 13. {cmd:iqr }	: for interquartile range {p_end}
{p 4 4 2} 14. {cmd:p1} 		: for 1st percentile {p_end}
{p 4 4 2} 15. {cmd:p5} 		: for 5th percentile {p_end}
{p 4 4 2} 16. {cmd:p10} 	: for 10th percentile {p_end}
{p 4 4 2} 17. {cmd:p25} 	: for 25th percentile {p_end}
{p 4 4 2} 18. {cmd:p50} 	: for 50th percentile {p_end}
{p 4 4 2} 19. {cmd:p75} 	: for 75th percentile {p_end}
{p 4 4 2} 20. {cmd:p99} 	: for 99th percentile {p_end}
{p 4 4 2} 21. {cmd:tstat} 	: for t-statistics {p_end}

 
{title:Example 1}

{p 4 8 2}{stata "sysuse auto, clear" :. sysuse auto, clear}{p_end}
{p 4 8 2}{stata "astx price, stat(sd mean median max min) by( foreign)" :. astx price, stat(sd mean median max min) by( foreign)} {p_end}


 {title:Example 2: Report t-statistics} 
 
{p 4 8 2}{stata "astx price, stat(sd mean tstat) by( foreign)" :. astx price, stat(sd mean tstat) by( foreign)} {p_end}

 

{title:Author}

*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: *
*                                                                   *
*            Dr. Attaullah Shah                                     *
*            Institute of Management Sciences, Peshawar, Pakistan   *
*            Email: attaullah.shah@imsciences.edu.pk                *
*           {browse "www.OpenDoors.Pk": www.OpenDoors.Pk}                                       *
*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*


{marker also}{...}
{title:Also see}

{psee}
{stata "ssc desc astile":astile},
{stata "ssc desc asreg":asreg},
{stata "ssc desc asrol":asrol},
{stata "ssc desc searchfor":searchfor}





