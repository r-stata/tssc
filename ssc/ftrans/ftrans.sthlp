{smcl}
{* 19Jan2010}{* 28Jan2010}{* 1Oct2010}{...}
{hline}
help for {hi:ftrans}{right: version 2.0}
{right:{stata ssc install ftrans, replace: get the newest version}}
{hline}


{title:Batch File Format Converter}


{title:Description}


{p 4 4 2}
{cmd:ftrans} provides a {cmd:batch process} to exchange data of {cmd:current directory} between different spreadsheet and statistics programs.

{title:Syntax}


{p 4 8 2}{cmd:ftrans} {it:old_file_extension} {it:new_file_extension} [{cmd:options}]{p_end}


{pstd}
These are prefixed by {cmd:/} under Windows and by {cmd:-} under Unix.
A list of these options(switches) can be found in the Stat/Transfer manual for the user's installation.
The Windows options for Version 9 of Stat/Transfer are as follows:

{synoptset 20 tabbed}{...}
{marker options}{...}
{synopthdr}
{synoptline}
{p2coldent :{cmd:/o-}}specifies that Stat/Transfer will not optimize the output data set to be as small as possible (as Stat/Transfer does by default).
 {p_end}
{p2coldent :{cmd:/oc}}specifies that Stat/Transfer will optimize the output data set to be as small as possible, 
					and automatically drop constant or missing variables.{p_end}
{p2coldent :{cmd:/od}}specifies that Stat/Transfer will optimize the output data set to be as small as possible, 
					but produce double precision variables where appropriate.{p_end}
{p2coldent :{cmd:/ocd}}specifies that Stat/Transfer will optimize the output data set to be as small as possible, 
					and automatically drop constant or missing variables, but produce double precision variables where appropriate.{p_end}
{p2coldent :{cmd:/q}}specifies that Stat/Transfer will execute quietly, producing no messages, 
					with the exception of error messages and warnings that a file is about to be overwritten.{p_end}
{p2coldent :{cmd:/r}[page!]{it:coor}}specifies a worksheet range, limited to page {it:page} and coordinates specified by {it:coor}, 
					in an input worksheet file. The coordinates specify a top left and bottom right cell in the worksheet. 
					For instance, {cmd:/r2!b5:e75} specifies that the data are on page 2 of the input file, 
					between the top left cell {cmd:b5} and the bottom right cell {cmd:e75}.{p_end}
{p2coldent :{cmd:/s}}will turn on messages and leave the Stat/Transfer window open until the return key is pressed.  
					This may be useful if Stat/Transfer appears not to be working.{p_end}
{p2coldent :{cmd:/t}{it:tablename}}is used in order to specify a table (or worksheet)
					within a data source containing multiple tables (or worksheets).{p_end}
{p2coldent :{cmd:/v}{it:version_number}}specifies that Stat/Transfer will write the output dataset
					in the version of the appropriate format specified by the {it:version_number}, which should be a positive integer.
					If this switch is not specified, then Stat/Transfer writes the output dataset in the latest version of the appropriate format.{p_end}
{p2coldent :{cmd:/y}}specifies that files with the {it:old_file_extension}{cmd:.}{it:ext} will be overwritten, if it already exists.
					(If {cmd:/y} is not specified, then Stat/Transfer consults the user before overwriting files.){p_end}
{synoptline}
{p2colreset}{...}


{title:Examples}


{pstd} Convert all files in {cmd:current directory (d:\temp)} with {it:old_file_extension} {cmd:.dta} to {it:new_file_extension} {cmd:.sav}, or {cmd:.sav} to {cmd:.sas7bdat}:

{p 4 8 2}. cd d:\temp{p_end}

{p 4 8 2}. {stata ftrans dta sav}{p_end}

{p 4 8 2}. {stata ftrans sav sas7bdat}{p_end}

{pstd} Convert all files with the file extension {cmd:.sas7bdat} to {cmd:.dta}, old {cmd:.dta} files will be overwritten with version 7.0 stata files:

{p 4 8 2}. {stata ftrans sas7bdat dta /y /v7}{p_end}


{title:Technical note}


{pstd} Before using {cmd:ftrans}, you have to (1) install {cmd:Stat/Transfer} in your computer, and (2) set the {help macro:global macro} {cmd:StatTransfer_path}
 for the path of the Stat/Transfer {cmd:st} command, 
which is done easily by inserting a line into the user's {help profile:profile do-file}
to initialize this path every time you starts Stata (if your {cmd:Stat/Transfer} has been installed in the directory of "{it:c:\Program Files\StatTransfer10\}" ):

{p 8 12 2}{cmd:global StatTransfer_path `"c:\Program Files\StatTransfer10\st.exe"'}{p_end}

{pstd}
Note that, when the user upgrades to a new version of Stat/Transfer, the upgrade creates a new directory,
containing the new version of {hi:st.exe}.
Therefore, when Stat/Transfer is upgraded,
either the user's default directory search path should be altered,
or the line of code in the user's profile do-file setting the global macro {hi:StatTransfer_path} should be altered. 


{title:Remarks}


{pstd}
{cmd:Stat/Transfer} can be installed on Microsoft Windows, MacOS, and some Unix platforms.
It is available from {browse "http://www.stata.com/":Stata Corporation}
and developed by {browse "http://www.stattransfer.com/":Circle Systems}.


{title:References}


{pstd} 
{cmd:ftrans supports the following file formats: }

{p 4 8 2} (If you have installed {cmd:Stat/Transfer 10} in your computer){p_end}


{p 4 8 2} 1-2-3 {it:(*.wk?)} {p_end}
{p 4 8 2} Microsoft Access (Versions 2.0 through Office XP version) {it:(*.MDB; ACCDB)} {p_end}
{p 4 8 2} dBASE (all versions) {it:(*.DBF)} {p_end}
{p 4 8 2} Delimited ASCII {it:(*.CSV; *.TXT)} {p_end}
{p 4 8 2} Delimited ASCII with a Stat/Transfer SCHEMA file {it:(*.STS*)} {p_end}
{p 4 8 2} Epi Info {it:(*.REC)} {p_end}
{p 4 8 2} Excel worksheets (all versions, including Excel 2007) {it:(*.XLS)} {p_end}
{p 4 8 2} Fixed format ASCII {it:(*.dat)} {p_end}
{p 4 8 2} FoxPro {it:(*.DBF)} {p_end}
{p 4 8 2} GAUSS (Windows and Unix) {it:(*.DAT)} {p_end}
{p 4 8 2} JMP {it:(*.JMP)} {p_end}
{p 4 8 2} LIMDEP {it:(*.LPJ)} {p_end}
{p 4 8 2} MATLAB {it:(*.MAT)} {p_end}
{p 4 8 2} MATLAB Seven Datasets {p_end}
{p 4 8 2} Mineset {it:(*.sch*)} {p_end}
{p 4 8 2} Minitab {it:(*.mtw)} {p_end}
{p 4 8 2} NLOGIT {it:(*.LPJ)} {p_end}
{p 4 8 2} ODBC data sources (Oracle, Sybase, Informix, etc.) {it:(*.DBF; *.XLS; *.MDB)} {p_end}
{p 4 8 2} OSIRIS (read-only) {it:(*.dic*; dct)} {p_end}
{p 4 8 2} Paradox {it:(*.DB)} {p_end}
{p 4 8 2} Quattro Pro for DOS and Windows {it:(*.WQ?; *.WB?)} {p_end}
{p 4 8 2} R {it:(*.RData)} {p_end}
{p 4 8 2} S-PLUS (now supported through version 7) {it:(*. )} {p_end}
{p 4 8 2} SAS CPORT datasets and catalogs (read only) {it:(*.stc)} {p_end}
{p 4 8 2} SAS for Unix¡ªHP, IBM, Sun {it:(*.SSD*; *.sas7bdat)} {p_end}
{p 4 8 2} SAS for Unix¡ªDEC Alpha {p_end}
{p 4 8 2} SAS for Windows and OS/2 {it:(*.sd*; *.sas7bdat; *.ssd)} {p_end}
{p 4 8 2} SAS PC/DOS 6.04 (read only) {p_end}
{p 4 8 2} SAS Transport {it:(*.STX; *.TPT; *.XPT)} {p_end}
{p 4 8 2} SAS Value Labels {p_end}
{p 4 8 2} SAS Version 7¨C9 {p_end}
{p 4 8 2} SPSS Version 17 {it:(*.SAV)} {p_end}
{p 4 8 2} SPSS Datafiles (Windows and Unix) {it:(*.SAV)} {p_end}
{p 4 8 2} SPSS Portable Files {it:(*.POR)} {p_end}
{p 4 8 2} Stata (all versions, including 11) {it:(*.DTA)} {p_end}
{p 4 8 2} Statistica Versions 7¨C8 (Windows only) {it:(*.STA)} {p_end}
{p 4 8 2} SYSTAT (Windows and Mac) {it:(*.SY?)} {p_end}
{p 4 8 2} Triple-S Survey Interchange Format {it:(*.xml; *.sss)} {p_end}

{p 4 8 2} HTML Table (Output) {it:(*.HTM*)} {p_end}
{p 4 8 2} SPSS Program + ASCII Data (Output) {it:(*.SPS)} {p_end}
{p 4 8 2} Stata Program + ASCII Data (Output) {it:(*.DO)} {p_end}


{title:Acknowledgements}


{pstd}
The codes to run Stat/Transfer st command are traced back to {cmd: Roger Newson}'s {help stcmd}, and
 the codes to get directory information are traced back to {cmd: Morten Andersen}'s {help dirlist}. 


{title:For problems and suggestions}


{pstd}
{cmd:Author: Liu wei}, The School of Sociology and Population Studies, Renmin University of China. {cmd:Address: }Zhongguancun Street No. 59, Haidian District, Beijing, China. {cmd:ZIP Code:} 100872. 
{cmd:E-mail:} {browse "mailto:liuv@ruc.edu.cn":liuv@ruc.edu.cn} {break}


{title:Also see}


{pstd}
Other Commands I have written: {p_end}

{synoptset 30 }{...}
{synopt:{help curvefit} (if installed)} {stata ssc install curvefit} (to install){p_end}
{synopt:{help deci} (if installed)} {stata ssc install deci} (to install){p_end}
{synopt:{help fdta} (if installed)} {stata ssc install fdta} (to install){p_end}
{synopt:{help elife} (if installed)} {stata ssc install elife} (to install){p_end}
{synopt:{help freplace} (if installed)} {stata ssc install freplace} (to install){p_end}
{synopt:{help ftree} (if installed)} {stata ssc install ftree} (to install){p_end}
{synopt:{help fren} (if installed)} {stata ssc install fren} (to install){p_end}
{synopt:{help equation} (if installed)} {stata ssc install equation} (to install){p_end}
{p2colreset}{...}

