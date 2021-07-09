{smcl}
{* *! version 0.3.0 25sep2019}{...}
{vieweralsosee "gziputil overview" "help gziputil"}{...}
{cmd:check7z} {hline 2} Check if {cmd:gziputil} finds 7-Zip


{title:Syntax}

{phang}
{cmd:check7z}

{phang}
{cmd:display r(sevenz_available)}

{phang}
{cmd:display $gziputil_path_7z}


{title:Description}

{pstd}
{cmd:check7z} checks if 7-Zip is installed and can be found in the standard
PeaZip directory or the system's PATH environment variable. It returns 
{cmd:r(sevenz_available)} which equals 1 if 7-Zip is ready to go and 0 if it is
not available or cannot be found.

{pstd}
{cmd:check7z} also sets the global macro {cmd:gziputil_path_7z}. If you did not
install PeaZip in the standard directory and do not want to change the PATH
environment variable, you may want to set {cmd:gziputil_path_7z} to a 7-Zip path
which can be understood by Windows PowerShell.


{title:Author}

{pstd}
Matthias Gomolka, Deutsche Bundesbank, Research Data and Service Centre{break}
{browse "mailto:matthias.gomolka@bundesbank.de":matthias.gomolka@bundesbank.de}
{p_end}
