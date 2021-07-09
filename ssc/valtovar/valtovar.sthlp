{smcl}
{* version 1.0.0 14mai2012}{...}
{hline}
help for {hi:valtovar}
{hline}

{title:Title}

{pstd}{hi:valtovar} {hline 2} Rename value labels to match variable names


{title:Syntax}

{pstd}{cmd:valtovar} [{it:varlist}] [{cmd:,} {opt dis:play} {opt no:report}] {opt d:rop}]


{title:Description}

{phang}For each variable a new value label becomes generated which matches the corresponding variables name. 
Whilst this behaviour needs more memory, it can sometimes be needed or be helpful for eg. merging data 
sets generated with the help of Stattransfer. It is highly recommended to clean up the memory using the drop
option.{p_end}


{title:Options}

{phang} {cmdab:dis:play} displays changes made to value labels.{p_end}
{phang} {cmdab:no:report} suppresses the ValToVar report.{p_end}
{phang} {cmdab:d:rop} drops unused labels after using valtovar.{p_end}


{title:Examples}

{phang}Variable foreign got the value label origin. Using valtovar generates a new value label set based on origin,
names it foreign and assigns it to the variable foreign.{p_end}

{phang} {cmd:. sysuse auto}{p_end}
{phang} {cmd:. valtovar foreign, dis}{p_end}
{phang} {cmd:. valtovar _all, no d}{p_end}


{title:Acknowledgement}

{phang}The ado is based on a {browse "http://www.stata.com/statalist/archive/2010-05/msg00832.html":suggestion by Martin Weiss on Statalist.}{p_end}


{title:Author}

{pstd} Johannes N. Blumenberg{break}
Mannheim Centre for European Social Research{break}
University of Mannheim (Germany){break} 
johannes.blumenberg@uni-mannheim.de{p_end}

