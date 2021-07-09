{smcl}
{cmd:help xls2dta old syntax}
{hline}


{p 5 8 2}
{cmd:xls2dta} has a {help xls2dta:new syntax}. Old syntax 
continues to work. This is the original help file for the 
old syntax and it is included to assist with understanding 
old code. Also old syntax might be slightly more convenient 
to type.


{title:Title}

{p 5}
{cmd:xls2dta} {hline 2} Save Excel files as Stata datasets


{title:Syntax}

{p 8}
{cmd:xls2dta} [{it:{help import_excel##extvarlist:extvarlist}}] 
[{helpb using} {it:{help filename}}] [{cmd:,} {it:options}]


{p 5 5}
where {it:filename} specifies the Excel file/s to be converted to 
Stata datasets. If {it:filename} is not specified, it defaults to 
the current working directory. See {help xls2dta##r:Remarks}.


{title:Description}

{pstd}
{cmd:xls2dta} converts Excel files to Stata datasets using 
{helpb import excel}. Names for Stata datasets are derived from 
the names of the Excel files (see {help xls2dta##r:Remarks}). The 
program is a convenient tool to import and convert more than one 
Excel file and/or worksheet at a time.


{title:Options}

{phang}
{opt sa:ve(dirc)} specifies the directory to store Stata datasets. 
Default {it:dirc} is the current working directory ({hi:{ccl pwd}}). 
Double quotes may be omitted.

{phang}
{opt allsh:eets}[{cmd:(}{it:{help numlist}} | 
[{cmd:"}]{it:pattern}[{cmd:"}] {it:...}{cmd:)}] saves all worksheets 
in the Excel files as Stata datasets. If {hi:foo.xls} contains three 
sheets, {hi:Sheet1}, {hi:Sheet2} and {hi: Sheet3}, Stata datasets 
{hi:foo_Sheet1.dta}, {hi:foo_Sheet2.dta} and {hi:foo_Sheet3.dta} will 
be saved. If specified, only worksheets {it:numlist}, or worksheets 
matching {it:patterns} (see {help strmatch():strmatch}) are converted.

{phang}
{opt replace} allows Stata datasets to be replaced if they already 
exist.

{phang}
{it:{help import excel:import excel options}} are options allowed 
with {cmd:import excel}. Option {opt sh:eet("sheetname")} may not be 
combined with {opt allsheets}. Option {opt desc:ribe} may not be 
combined with any other option. Option {opt clear} is ignored.

{phang}
{opt respect:case} specifies that {cmd:xls2dta} respect case in 
{it:filename} (Windows only). Uppercase characters in {it:filename} 
imply {opt respectcase}. See extended macro function 
{help extended_fcn:dir}.

{phang}
{opt nostop} prevents {cmd:xls2dta} from stopping if one of the 
internal calls to {cmd:import excel} returns an error. This 
option should rarely be specified.

{phang}
{opt mkdir}[{cmd:(}{opt pub:lic}{cmd:)}] creates new directory 
{it:dirc}, as specified in {opt save} (see {help mkdir}).

{marker r}
{title:Remarks}

{pstd}
In {it:filename} one specific file, or more than one file in a 
directory may be specified.

{pstd}
Specifying 

{phang2}{cmd:. xls2dta using c:/myxlsfiles/foo.xls}{p_end}

{pstd}
converts (the first sheet of) {hi:foo.xls} to {hi:foo.dta} and saves 
it in the current working directory. 

{pstd}
If {hi:c:/myxlsfiles} contains more than one {hi:.xls} file, we can 
convert all of them to Stata datasets typing

{phang2}{cmd:. xls2dta using c:/myxlsfiles/*.xls}{p_end}

{pstd}
To convert all {hi:.xls} and {hi:.xlsx} files in {hi:c:/myxlsfiles}, 
we would type

{phang2}{cmd:. xls2dta using c:/myxlsfiles}{p_end}

{pstd}
If {hi:foo.xls} contains more than one worksheet, and we want to 
convert all worksheets to Stata datasets, we type

{phang2}{cmd:. xls2dta using c:/myxlsfiles/foo.xls ,allsheets}{p_end}

{pstd}
To only convert worksheets starting with {hi:Sheet}, we specify

{phang2}{cmd:. xls2dta using c:/myxlsfiles/foo.xls ,allsheets(Sheet*)}
{p_end}


{title:Example}

{phang2}{cmd:. xls2dta using c:/myxlsfiles ,save(c:/mydtafiles)}{p_end}


{title:Saved results}

{pstd}
{cmd:xls2dta} saves the following in {cmd:r()}:

{pstd}
Macros{p_end}
{synoptset 15 tabbed}{...}
{synopt:{cmd:r(n_dta)}}number of saved {hi:.dta} files{p_end}
{synopt:{cmd:r(dta_}{it:#}{cmd:)}}filename of {hi:.dta} file {it:#}
{p_end}


{title:Author}

{pstd}Daniel Klein, University of Kassel, klein.daniel.81@gmail.com


{title:Also see}

{psee}
Online: {help import excel}, {help extended_fcn:extended functions}, 
{help foreach}, {help mkdir}
{p_end}

{psee}
if installed: {help xls2stata}
{p_end}
