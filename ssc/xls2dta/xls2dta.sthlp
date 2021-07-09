{smcl}
{cmd:help xls2dta}
{hline}

{title:Title}

{p 5}
{cmd:xls2dta} {hline 2} Excel files to Stata datasets


{title:Basic syntax overview}

{p 8}
{cmd:xls2dta :} {helpb import excel} 
{it:{help xls2dta##filename:filename}}

{p 8}
{cmd:xls2dta ,} {{cmd:clear}|{opt save(filename)}}
{cmd::} {helpb append}

{p 8}
{cmd:xls2dta ,} {{cmd:clear}|{opt save(filename)}}
{cmd::} {helpb merge} {it:mtype} {it:varlist}

{p 8}
{cmd:xls2dta ,} {{cmd:clear}|{opt save(filename)}}
{cmd::} {helpb joinby}

{p 8}
{cmd:xls2dta :} {cmd:xeq} {it:command}

{p 8}
{cmd:xls2dta :} {{helpb do} {sf:|} {helpb do:run}}
{it:{help filename:dofile}}

{p 8}
{cmd:xls2dta , eraseok :} {helpb erase}


{title:Full syntax}

{p 5}
Convert Excel files to Stata datasets

{p 8 36 2}
{cmd:xls2dta} 
[{cmd:,} {it:{help xls2dta##convert_opts:convert_options}}]
{cmd::} {help import excel:{bf:import} [{bf:{ul:exc}el}]}
[[{it:{help import_excel##extvarlist:extvarlist}}] 
{helpb using}] {it:{help xls2dta##filename:filename}} [{cmd:,} 
{it:{help import_excel##importoptions:import_excel_options}}]


{p 5}
Combine datasets

{p 8 36 2}
{cmd:xls2dta} 
[{cmd:,} {it:{help xls2dta##combine_opts:combine_options}}]
{cmd::} {help xls2dta##combine_combine_cmd:{it:combine_cmd}} 
[{helpb using} {it:{help xls2dta##filename:filename}}] 
[{cmd:,} {help xls2dta##combine_cmd_options:{it:combine_cmd_options}}]


{marker filename}{...}
{p 5 5 2}
where {it:filename} is typically a directory and specifies one 
or more Excel files to be converted to Stata datasets (see 
{help filename}).

{marker cmd}{...}
{p 5 5 2}
{it:combine_cmd} is one of

{p 16 16 2}
{help append:{bf:{ul:ap}pend}}

{p 16 16 2}
{help merge:{bf:{ul:mer}ge}} {it:mtype} {varlist}

{p 16 16 2}
{helpb joinby} [{varlist}]

{marker combine_cmd_options}{...}
{p 5 5 2}
and {it:combine_cmd_options} are 
{it:{help append##options:append_options}}, 
{it:{help merge##options:merge_options}} or
{it:{help joinby##options:joinby_options}}, respectively.


{p 5}
Execute commands on converted datasets

{p 8 36 2}
{cmd:xls2dta}
[{cmd:,} {it:{help xls2dta##execute_opts:execute_options}}]
{cmd::} {cmd:xeq} {it:command} 
[{cmd:;} {it:command} [{cmd:;} {it:...}]]

{p 8 36 2}
{cmd:xls2dta}
[{cmd:,} {it:{help xls2dta##execute_opts:execute_options}}]
{cmd::} {{help do:{bf:do}} | {help do:{bf:{ul:ru}n}}} 
{it:{help filename:dofile}} [{it:arguments}] 
[{cmd:, nostop}]


{p 5}
Erase previously converted datasets

{p 8 36 2}
{cmd:xls2dta} {cmd:,} {opt erase:ok}
{cmd::} {helpb erase}


{synoptset 36 tabbed}{...}
{synopthdr:convert options}
{synoptline}
{synopt:{cmd:{ul:sa}ve(}[{it:directory}] [{cmd:,} {it:{help xls2dta##save:save_options}}]{cmd:)}}save 
converted Excel files in {it:directory}
{p_end}
{synopt:{cmd:{ul:sh}eets(}{it:{help xls2dta##sheets:sheetsspec}} [{cmd:, not}]{cmd:)}}convert 
worksheets {it:sheetsspec}
{p_end}
{synopt:{opt allsh:eets}}convert all worksheets
{p_end}
{synopt:{opt recur:sive}[{opt (maxdeep)}]}search 
{it:filename} recursively
{p_end}
{synopt:{cmd:{ul:gen}erate(}{it:{help newvar:newvar1}} [{it:{help newvar:newvar2}}]{cmd:)}}create 
variables with {it:filename}, {it:sheetname}
{p_end}
{synopt:{opt respect:case}}respect case in {it:filename} (Windows only)
{p_end}
{synopt:{opt nostop}}continue if {cmd:import excel} fails
{p_end}
{synoptline}


{synopthdr:combine options}
{synoptline}
{synopt:{cmd:clear}}replace data in memory
{p_end}
{synopt:{cmd:{ul:sa}ve(}{it:{help filename}}{cmd:.dta} [{cmd:,} {it:{help xls2dta##save:save_options}}]{cmd:)}}save 
combined files as {it:filename}{cmd:.dta}
{p_end}
{synopt:{cmd:dta(}{it:{help numlist}}{cmd:)}}combine 
{cmd:s(dta_}{it:#}{cmd:)} only; not with {cmd:using} syntax
{p_end}
{synopt:{cmd:{ul:import}opts(}{it:{help import_excel##importoptions:import_excel_options}}{cmd:)}}options 
for {cmd:import excel}; only with {cmd:using} syntax
{p_end}
{synopt:{it:convert options}}same as above; only with {cmd:using} syntax
{p_end}
{synoptline}
{p 5}one of {opt clear} or {opt save()} must be specified


{synopthdr:execute options}
{synoptline}
{synopt:{cmd:dta(}{it:{help numlist}}{cmd:)}}execute commands or 
{it:dofile} for {cmd:s(dta_}{it:#}{cmd:)} only
{p_end}
{synopt:{opt noi:sily}}echo commands and output ({cmd:xeq} only)
{p_end}
{synopt:{opt save}}save unchanged datasets; seldom used
{p_end}
{synoptline}


{title:Description}

{pstd}
{cmd:xls2dta} is a {help prefix:prefix command} and converts multiple Excel 
files and/or worksheets to Stata datasets. Names for Stata datasets are 
derived from the names of Excel files and left behind in {cmd:s()}.

{pstd}
Used with {cmd:import excel}, {cmd:xls2dta} converts all Excel files and/or 
worksheets found in {it:filename} to Stata datasets. {it:filename} is 
typically a directory and may be {cmd:./}, meaning the current working 
directory ({bf:{ccl pwd}}). If no file extension is specified, {cmd:xls2dta} 
converts all {cmd:.xls} and {cmd:.xlsx} files.

{pstd}
Used with {cmd:append}, {cmd:merge} or {cmd:joinby}, {cmd:xls2dta} combines 
all previously converted datasets or, if {cmd:using} {it:filename} is 
specified, all Excel files found in {it:filename}.

{pstd}
{cmd:xls2dta : xeq} and {cmd:xls2dta :} {{cmd:do}|{cmd:run}} execute the 
specified commands or {it:dofile} on each previously converted dataset. Do 
{ul:not} specify {cmd:use} or {cmd:save} commands. Let {cmd:xls2dta} 
load and save the modified datasets.

{pstd}
{cmd:xls2dta , eraseok : erase} erases previously converted 
datasets. Option {opt eraseok} is required and files are 
removed from disk, permanently.


{marker convert_opts}{...}
{title:Options for converting Excel files}

{phang}
{cmd:{ul:sa}ve(}[{it:directory}] [{cmd:,} {it:save_options}]{cmd:)} 
specifies the directory where Stata datasets be stored. If not 
specified, {it:directory} defaults to the current working 
directory. The {it:save_options} are

{marker save}{...}
{phang2}
{opt replace} allows Stata datasets to be replaced if they 
already exist. Be warned: specifying {opt replace} will 
usually overwrite more than one file if {it:directory} is 
specified or implied.

{phang2}
{it:{help save##save_options:save_options}} are options 
allowed with {helpb save}.

{phang2}
{cmd:mkdir}[{cmd:(}{opt pub:lic}{cmd:)}] creates new directory 
{it:directory} on-the-fly. See {helpb mkdir}. 

{marker sheets}{...}
{phang}
{cmd:{ul:sh}eets(}{it:sheetsspec} [{cmd:, not}]{cmd:)} 
converts only worksheets {it:sheetsspec} to Stata datasets, 
where {it:sheetsspec} is one of {cmd:"}{it:pattern}{cmd:"} 
[{it:...}] or {it:{help numlist}}. In {it:pattern}, wildcard 
characters {cmd:*} and {cmd:?} are allowed, where the former 
means 0 or more characters and the latter means exactly one 
character (see {helpb strmatch}). In {it:numlist}, only 
integer values greater 0 are allowed. Suboption {cmd:not} 
converts all but the specified worksheets.

{p 8 8 2}
Excel worksheets are saved as 
separate Stata datasets and named as 
{it:Excelfilename}{cmd:_}{it:worksheet#}{cmd:.dta}.

{phang}
{opt allsh:eets} converts all worksheets to Stata 
datasets. {opt allsheets} is the same as {cmd:sheets(*)}. See 
above.

{phang}
{opt recur:sive}[{opt (maxdeep)}] seraches {it:filename} 
recursively, meaning all subdirectories are searched. This 
option requires {helpb filelist} (Picard, SSC) to be 
installed. {it:maxdeep} specifies how many levels be 
searched (cf. {help filelist:filelists} {opt maxdeep(#)} 
option).

{phang}
{cmd:{ul:gen}erate(}{it:newvar1} [{it:newvar2}]{cmd:)} 
generates {it:newvar1}, holding the name of the Excel 
file and, thus, marking the source of each observation. 
If specified, {it:newvar2} records the sheetname, additionally. 
This option is espcially useful if datasets are to be appended, 
because for each single Stata dataset both variables will be 
constants. 

{phang}
{opt respect:case} specifies that case be respected in 
{it:filename}. Uppercase characters in {it:filename} 
imply {opt respectcase}. Option {opt respectcase} is 
ignored if {cmd:recursive} is specified.

{phang}
{opt nostop} prevents {cmd:xls2dta} from stopping if one of the 
internal calls to {cmd:import excel} returns an error. This 
option should rarely be specified.


{marker combine_opts}{...}
{title:Options for combining datasets}

{phang}
{opt clear} clears the data in memory and loads the combined dataset.

{phang}
{cmd:{ul:sa}ve(}{it:filename}{cmd:.dta} [{cmd:,} {it:save_options}]{cmd:)} 
saves the combined files in {it:filename}. The {it:save_options} are the 
same as described in {help xls2dta##save:Options for converting Excel files}.

{marker dta_opt}{...}
{phang}
{opt dta(numlist)} combines the files, selected from {cmd:s()}. If 
not specified, all {cmd:s(dta_{it:#})} files are combined.

{phang}
{cmd:{ul:import}opts(}{it:import_excel_options}{cmd:)} are options 
passed thru to {cmd:import excel}. This option may only be specified 
with the {cmd:using} {it:filename} syntax.

{phang}
{it:{help xls2dta##convert_opts:convert_options}} are options for 
converting Excel files. These options may only be specified with the 
{cmd:using} {it:filename} syntax.


{marker execute_opts}{...}
{title:Options for executing commmands on converted datasets}

{phang}
{opt dta(numlist)} 
executes commands or {it:dofile} on selected datasets only 
(also see {help xls2dta##dta_opt:combine opions}).

{phang}
{opt noi:sily} echos commands and output and may only be specified 
with {cmd:xeq}. Dafault is to execute the commands {help quietly}.

{phang}
{opt save} saves the datasets after commands or {it:dofile} were 
executed even when the datasets have not been changed according 
to {helpb creturn##currentdta:c(changed)}. This option is seldom 
used.


{title:Old syntax}

{pstd}
As of version 2.0.0, {cmd:xls2dta} has a new 
syntax. {help xls2dta_old_syntax:Old syntax} 
continues to work.


{title:Examples}

{pstd}
Convert the first worksheet in all Excel files stored in 
{cmd:c:/my_xls_files} to Stata datasets and save the files 
in {cmd:c:/my_dta_files}.

{phang2}
{cmd:. xls2dta , save(c:/my_dta_files) : import excel c:/my_xls_files}
{p_end}

{synoptline}

{pstd}
Append the Stata datasets converted above and save the resulting 
dataset as {cmd:c:/my_dta_files/complete.dta}.

{phang2}
{cmd:. xls2dta , save(c:/my_dta_files/complete.dta) : append}
{p_end}

{synoptline}

{pstd}
Merge all worksheets in {cmd:c:/my_xlsx_files/foo.xlsx} 
to one Stata datasets and load this file. Perform a
one-to-one merge, using {cmd:A} as the key variable.

{phang2}
{cmd:. xls2dta , clear allsheets : merge 1:1 A using c:/my_xlsx_files/foo.xlsx}
{p_end}

{synoptline}

{pstd}
Convert the first ten worksheets in any Excel file stored 
in {cmd:c:/my_xls_files} or its subdirectories to Stata 
datasets and save the files in the current working 
directory.

{phang2}
{cmd:. xls2dta , sheets(1/10) recursive : import excel using c:/my_xls_files}
{p_end}

{synoptline}

{pstd}
In each Stata dataset converted above, convert string variable 
{cmd:A} to numeric variable {cmd:numeric_A}

{phang2}
{cmd:. xls2dta : xeq destring A , generate(numeric_A)}
{p_end}

{synoptline}


{title:Saved results}

{pstd}
{cmd:xls2dta}, used with {cmd:import excel}, saves the following in 
{cmd:s()}:

{pstd}
Macros{p_end}
{synoptset 15 tabbed}{...}
{synopt:{cmd:s(cmd)}}{cmd:xls2dta}{p_end}
{synopt:{cmd:s(n_dta)}}number of saved {cmd:.dta} files{p_end}
{synopt:{cmd:s(dta_}{it:#}{cmd:)}}filename of {cmd:.dta} file {it:#}
{p_end}


{pstd}
Used with {cmd:append}, {cmd:merge} or {cmd:joinby}, {cmd:xls2dta} 
saves in {cmd:s()}:

{pstd}
Macros{p_end}
{synoptset 15 tabbed}{...}
{synopt:{cmd:s({it:cmd}_dta)}}filename of combined {cmd:.dta} file
{p_end}


{title:Author}

{pstd}Daniel Klein, University of Kassel, klein.daniel.81@gmail.com


{title:Also see}

{psee}
Online: {help import excel}, {help append}, {help merge}, 
{help joinby}, {help foreach}
{p_end}

{psee}
if installed: {help filelist}, {help xls2stata}
{p_end}
