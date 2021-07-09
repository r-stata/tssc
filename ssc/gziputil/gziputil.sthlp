{smcl}
{* *! version 0.3.0 03apr2019}{...}
{vieweralsosee "appendgz" "help appendgz"}{...}
{vieweralsosee "check7z" "help check7z"}{...}
{vieweralsosee "mergegz" "help mergegz"}{...}
{vieweralsosee "savegz" "help savegz"}{...}
{vieweralsosee "usegz" "help usegz"}{...}

{bf:gziputil} {hline 2} Work with gzip compressed Stata datasets

{hline}

{pstd}
{cmd: NEW IN VERSION 0.3.0 FROM 2019-09-25:}

{pstd}
In case you work on Windows and PeaZip is installed in the standard
directory (C:\Program Files\PeaZip), you can start using the commands provided 
by {help gziputil} without {help gziputil##setup:Initial Setup}.

{hline}

{title:Description}{marker general}

{pstd}
{opt gziputil} allows you to work with gzip compressed Stata datasets
({it:.dta.gz}) just as if they were plain Stata files. This has some advantages:

{phang}
1.  You need less disk space. The gzip compression algorithm reduces Stata file
size {it:by about 90%}.
{p_end}

{phang}
2.  If your data is located on a slow (e.g. network) drive, working with
compressed files reduces access times. The performance gain is especially large 
if there is an SSD drive available for storing temporary files and when the 
drive holding the data is very slow. Depending on your system, 
{it:performance may improve by up to 80%}.
{p_end}

{pstd}
{opt gziputil} provides the following commands: {help usegz}, {help savegz}, 
{help mergegz} and {help appendgz}. Each of these commands is a wrapper around 
the corresponding original command (without {it:gz}). To facilitate the switch 
to using gzip compressed Stata files, each of the commands in this package 
mimics the original syntax exactly.


{title:Initial Setup}{marker setup}

{pstd}
Unless you work on Windows and PeaZip is installed in the standard directory
(C:\Program Files\PeaZip), you need a little setup to use {cmd:gziputil}:

{phang}
1.  Download and install {browse "https://www.7-zip.org/":7-Zip} on your 
machine.
{p_end}

{phang}
2.  Add the path of the newly installed 7z.exe to your system's PATH environment
variable.
{p_end}

{phang}
3.  Restart Stata.
{p_end}

{pstd}
To check if 7-Zip is installed and found by gziputil, use the command 
{help check7z} which also comes in this package.


{title:Author}

{pstd}
Matthias Gomolka, Deutsche Bundesbank, Research Data and Service Centre{break}
{browse "mailto:matthias.gomolka@bundesbank.de":matthias.gomolka@bundesbank.de}
{p_end}
