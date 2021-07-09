{smcl}
{* *! version 1.0 20 September 2018}{...}
{vieweralsosee "sydir" "help sysdir"}{...}
{vieweralsosee "adopath" "help adopath"}{...}
{vieweralsosee "getcmds (if installed)" "help getcmds"}{...}
{viewerjumpto "Syntax" "statacmds##syntax"}{...}
{viewerjumpto "Description" "statacmds##description"}{...}
{viewerjumpto "Options" "statacmds##options"}{...}
{viewerjumpto "Remarks" "statacmds##remarks"}{...}
{viewerjumpto "Examples" "statacmds##examples"}{...}
{viewerjumpto "Author" "statacmds##author"}{...}
{viewerjumpto "Also see" "statacmds##alsosee"}{...}
help for {cmd:statacmds}  {right:version 1.0  (20 September 2018)}
{hline}


{title:Title}

{phang}
{bf:statacmds} {hline 2} get list of all commands known to Stata, including (Stata/Mata/egen) functions and built-ins


{title:Table of contents}

	{help statacmds##syntax:Syntax}
	{help statacmds##description:Description}
	{help statacmds##options:Options}
	{help statacmds##remarks:Remarks}
	{help statacmds##examples:Examples}
	{help statacmds##author:Author}
	{help statacmds##results:Saved results}
	{help statacmds##alsosee:Also see}


{marker syntax}
{title:Syntax}

{p 8 17 2}
{cmd:statacmds} [, {it:options}]{p_end}

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Search paths}
{synopt:{cmd:no}{opt personal:files}}don't search in Stata's PERSONAL directory{p_end}
{synopt:{cmd:no}{opt plus:files}}don't search in Stata's PLUS directory{p_end}
{synopt:{cmd:no}{opt oldplace:files}}don't search in Stata's OLDPLACE directory{p_end}
{synopt:{cmd:no}{opt user:files}}don't search in Stata's PERSONAL, PLUS or OLDPLACE directories{p_end}
{synopt:{cmd:no}{opt base:files}}don't search in Stata's BASE directory{p_end}
{synopt:{cmd:no}{opt site:files}}don't search in Stata's SITE directory{p_end}
{synopt:{opt adopath}}search in Stata's complete adopath, not just system directories{p_end}

{syntab:Results}
{synopt:{cmd:no}{opt b:uiltins}}don't return built-in commands{p_end}
{synopt:{cmd:no}{opt ado:commands}}don't return commands implemented as ADO files{p_end}
{synopt:{cmd:no}{opt f:unctions}}don't return Stata functions{p_end}
{synopt:{cmd:no}{opt m:atafunctions}}don't return Mata functions{p_end}
{synopt:{cmd:no}{opt e:genfunctions}}don't return {cmd:egen} functions{p_end}
{synopt:{cmd:no}{opt abb:reviations}}don't return command abbreviations{p_end}

{syntab:Other}
{synopt:{cmd:no}{opt alias:files}}don't parse alias help files{p_end}
{synopt:{opt unclassified}}also return commands that could not be classified as one of the above{p_end}
{synopt:{opt v:erbose}}give verbose output{p_end}

{syntab:Output}
{synopt:{opt sav:ing(filename [, savingoptions])}}save results to {it:filename} in addition to returning them in {it:r()}{p_end}

{syntab:Options for {opt saving()}}
{synopt:{opt replace}}replace {it:filename} if it already exists{p_end}
{synopt:{cmd:no}{opt cat:egories}}don't write categories to output file{p_end}
{synopt:{opt sep:arator(string)}}use {it:string} as separator between results and categories (default: " "){p_end}
{synoptline}
{p2colreset}{...}


{marker description}
{title:Description}

{pstd}
{cmd:statacmds} searches for Stata commands or functions (including Mata and {cmd:egen} functions){...}
alongside Stata's system directories (see {help sysdir:help sysdir}). It is inspired by the search{...}
Jeff Pitblado's {cmd:getcmds} (available from {browse "https://www.stata.com/users/jpitblado"}).

{phang}In addition, {cmd:statacmds} adds more flexibility to {cmd:getcmds}' approach:{break}
{c -} categorize each command in built-in vs. ado-command{break}
{c -} disable search in alias help-files{break}
{c -} disable returning abbreviations{break}
{c -} return results in {it:r()}{break}
{c -} customization of the file paths that are searched{break}
{c -} find Stata functions, Mata functions, and {cmd:egen} functions (some restrictions apply, see {help statacmds##remarks:remarks})
{p_end}


{marker options}
{title:Options}

{dlgtab:Search paths}

{phang}By default, {cmd:statacmds} searches for commands in Stata's system directories (see {help sysdir:help sysdir}).{...}
You can find out where these directories are on your own machine by executing {stata sysdir list}).{break}
The search path can be fine-tuned by excluding single system directories via the options {cmd:no}{opt personalfiles},{...}
{cmd:no}{opt plusfiles}, {cmd:no}{opt oldplacefiles}, {cmd:no}{opt basefiles} or {cmd:no}{opt sitefiles} (or a combination of them).{...}
The additional option {cmd:no}{opt userfiles} is a convenience shorthand to specifying the three of {cmd:no}{opt personalfiles} {cmd:no}{opt plusfiles} {cmd:no}{opt oldplacefiles}.{p_end}

{phang}There is a difference between Stata's system directories and the complete list of directories Stata searches for commands; the latter is called the {hilite:adopath} (see {help adopath:help adopath}).{...}
Option {opt adopath} makes {cmd:statacmds} search alongside the complete adopath instead of Stata's system directories only.{...}
This option can be combined with the other options to change the list of directories to search (e.g. {opt adopath nopersonal}).{p_end}

{dlgtab:Results}

{phang}After finding all possible commands, {cmd:statcmds} classifies each into one of the five categories{...}
{hilite:built-in}, {hilite:adocommand}, {hilite:Stata function}, {hilite:Mata function}, or {hilite:egen function}{...}
(details on the classification heuristic can be found in {help statacmds##remarks:remarks}).{...}
Returned results can be filtered by adding one or more of the options {cmd:no}{opt builtins}, {cmd:no}{opt adocommands},{...}
{cmd:no}{opt functions}, {cmd:no}{opt matafunctions}, {cmd:no}{opt egenfunctions}.{...}
Each of them will disable returning the elements of their respective category.{p_end}

{phang}Additionally, the option {cmd:no}{opt abbreviations}, if specified, will disable returning command abbreviations.{p_end}


{dlgtab:Other}

{phang}With option {cmd:no}{opt aliasfiles} specified, {cmd:statacmds} will not read and parse alias help files;{...}
specifying this option most likely will lead to a speed up in search time,{...}
to the price of not finding functions, built-in commands and command abbreviations. Seldomly used.{p_end}

{phang}The special option {opt unclassified} will make {cmd:statacmds} return elements of a residual category:{...}
Any command that can not be classified by the heuristic will be returned as category {hilite:unclassified}. Seldomly used.{p_end}

{phang}{cmd:statacmds} will show details on what it is doing if option {opt verbose} is specified.{p_end}

{dlgtab:Output}

{phang}The option {opt saving(filename , savingoptions)} makes {cmd:statacmds}, in addition to returning results in {it:r()},{...}
save the results to {it:filename}; {it:savingoptions} can be used to customize details of the saved file (see below).{p_end}

{dlgtab:Savingoptions}

{phang}When saving the output file, {opt replace} will overwrite the file if it already exists.{p_end}

{phang}Writing each command's category to the outputfile can be suppressed with {cmd:no}{opt categories};{...}
this will produce roughly the same output file as {cmd:getcmds}.{break}
Note that the sort order of commands inside of the file may be different to {cmd:getcmds}' result.{p_end}

{phang}When writing the outputfile, {opt separator(string)} will make {cmd:statacmd} use {it:string}{...}
as separator between results and categories in the file;{...}
default is to use a space character as delimiter: "generate builtin".{break}
This option will be ignored if {cmd:no}{opt categories} is specified.{p_end}


{marker remarks}
{title:Remarks}

{pstd}
In order to retrieve all command names that Stata is aware of, {cmd:statacmds} searches for ado files and help files.{...}
Additionally, it reads and parses the alias files of Stata's help file system to find even more files.{break}
After scraping these sources, the results are classified according to the following heuristic:{p_end}

{pin}
- any file with file extension .mata is a {hilite:matafunction}{break}
- any help file, or help alias entry, that is accompanied by an ado file with the same name is an {hilite:ado command}{break}
- any other help file or help alias entry that starts with "mf_", or "f_m4_", or "f_m5_", or "mata_" is a {hilite:mata function}{break}
- any other help file or help alias entry that starts with "f_egen" is an {hilite:egen function}{break}
- any other help file or help alias entry that starts with "f_" is a {hilite:function}{break}
- any file with file extension .ado that is accompanied by a help file with the same name is an {hilite:ado command}{break}
- any other file with file extension .ado that starts with "_gsem", "_gs", "_gr" or "_gset" is an {hilite:ado command}{break}
- any other file with file extension .ado that starts with "_g" and is not accompanied by a help file with the same name is an {hilite:egen function}{break}
- any other entry that is found is tested to be a command; if a file with file extension .ado is found in the search path,{...}
it is an {hilite:ado command}, otherwise it is a {hilite:built-in command}.{p_end}

{pstd}
Executing the above heuristical classification necessarily has its shortcomings.{...}
Some of the rules pointed out here may lead to erroneous classifications.{...}
All but the very last rule lack a good method for cross-checking if the class assignmeht in fact is correct.{...}
Finally, all but the last rule make the assignment by certain file naming conventions.{...}
If the convention is badly formulated, the assignment has to be wrong.{...}
The same applies if, for whatever reason, files do misobey the said convention.{p_end}

{pstd}
This program currently is not capable of detecting multi-word commands (e.g. {cmd:duplicates report}, {cmd:graph twoway}, {cmd:odbc query}).{...}
Feedback with ideas for implementing this, or for other further improvement, as well as feature requests, are of course very welcome.{p_end}

{pstd}
The source code of the program is licensed under the GNU General Public License version 3 or later.{...}
The corresponding license text can be found on the internet at {browse "http://www.gnu.org/licenses/"} or in {help gnugpl}.{p_end}


{marker examples}
{title:Examples}

{phang}Find all commands in Stata's BASE and SITE directories:{p_end}
{phang}{cmd:. statacmds , nouserfiles}{p_end}

{phang}Find all commands in Stata's adopath, but skip BASE and PERSONAL directories:{p_end}
{phang}{cmd:. statacmds , nobasefiles nopersonalfiles adopath}{p_end}

{phang}Do the same, but don't return command abbreviations:{p_end}
{phang}{cmd:. statacmds , nobasefiles nopersonalfiles adopath noaabreviations}{p_end}

{phang}Find all commands in Stata's system directories, and save into CSV file {it:commands.csv}:{p_end}
{phang}{cmd:. statacmds , saving(commands.csv , separator(","))}{p_end}

{phang}Mimic {cmd:getcmds using commands.txt}:{p_end}
{phang}{cmd:. statacmds , nofunctions nomatafunctions noegenfunctions saving(commands.txt , nocategory)}{p_end}

{phang}Mimic {cmd:getcmds using commands.txt , nonado}:{p_end}
{phang}{cmd:. statacmds , nofunctions nomatafunctions noegenfunctions noadocommands saving(commands.txt , nocategory)}{p_end}

{phang}Mimic {cmd:getcmds using commands.txt , adoonly}:{p_end}
{phang}{cmd:. statacmds , nofunctions nomatafunctions noegenfunctions nobuiltins saving(commands.txt , nocategory)}{p_end}


{marker author}
{title:Author}

{pstd}
Daniel Bela ({browse "mailto:daniel.bela@lifbi.de":daniel.bela@lifbi.de}), Leibniz Institute for Educational Trajectories (LIfBi), Germany.{p_end}


{marker results}
{title:Saved results}

{pstd}
{cmd:statacmds} saves the following in {cmd:r()}:{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Locals}{p_end}
{synopt:{cmd:r(builtins)}}list of built-in commands (unless {cmd:no}{opt builtins} is specified){p_end}
{synopt:{cmd:r(adocommands)}}list of commands implemented as ADO files (unless {cmd:no}{opt adocommands} is specified){p_end}
{synopt:{cmd:r(functions)}}list of Stata functions (unless {cmd:no}{opt functions} is specified){p_end}
{synopt:{cmd:r(matafunctions)}}list of Mata functions (unless {cmd:no}{opt matafunctions} is specified){p_end}
{synopt:{cmd:r(egenfunctions)}}list of {cmd:egen} functions (unless {cmd:no}{opt egenfunctions} is specified){p_end}
{p2colreset}{...}


{marker alsosee}
{title:Also see}

{psee}
{space 2}Help: {help sysdir}, {help adopath}, {help getcmds} (if installed)
{p_end}
