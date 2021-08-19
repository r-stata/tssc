{smcl}
{* *! version 1.1.0  31dec2020}{...}
{viewerjumpto "Syntax" "xtimportu##syntax"}{...}
{viewerjumpto "Description" "xtimportu##description"}{...}
{viewerjumpto "Options" "xtimportu##options"}{...}
{viewerjumpto "Remarks" "xtimportu##remarks"}{...}
{viewerjumpto "Examples" "xtimportu##examples"}{...}
{title:Title}

{phang}
{bf:xtimportu} {hline 2} Import monthly, quarterly, half-yearly or yearly time
series and panel data as {it:panelvar} {it:timevar} {it:valuevar} from a
supported file format to memory or a file

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:xtimportu}
{it:import syntax}
[{cmd:,} {it:options}]

{synoptset 35 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Import data}
{synopt :{helpb import:{it:* (import options)}}}none or all options from
        {cmd:import}{p_end}

{syntab:Preformat}
{synopt :{opth pre:format(strings:string)}}any inbuilt and/or user-defined
        command with standard Stata syntax, prefix included (omittable){p_end}

{syntab:Process}
{synopt :{opth panel:var(varname:panelvar)}}unit variable (omittable){p_end}
{synopt :{opth re:gex(strings:string)}}regular expressions, separated by "|"
        for multiple matches
        (omittable){p_end}
{synopt :{opth en:code(strings:string)}}replacement {help strings:{it:strings}}
        for each match in {it:regex()}, separated by "|" (omittable){p_end}
{synopt :{opth time:var(varname:timevar)}}time variable
        for long data, omitted for wide{p_end}
{synopt :{opth tfor:mat(strings:string)}}{help strings:{it:s2}} in -ly()
        {help datetime functions:{it:datetime functions}},
        for example "M[##]Y" or "[##]YQ" (omittable){p_end}
{synopt :{opth tfreq:uency(strings:Y|H|Q|M)}}time frequency
        (yearly, half-yearly, quarterly or monthly){p_end}
{synopt :{opt drop}}drop yearly sums for half-years,
        quarters, and months{p_end}
{synopt :{opt tde:string}}return {help varname:{it:timevar}}
        in a {help format:{it:%t format}} instead of
        a {help strings:{it:string}} "####[-T#]" {p_end}

{syntab:Finalize}
{synopt :{opth g:enerate(strings:string)}}specify the new name
        for the returned {help varname:{it:valuevar}} (omittable){p_end}
{synopt :{helpb destring:{it:* (destring options)}}}none or all options
        from {cmd:destring}{p_end}
{synopt :{opt to:string}}return {help varname:{it:valuevar}}
        as a {help strings:{it:string}}, incompatible with
        {help destring##destring_options:{it:destring options}}{p_end}

{syntab :Save output}
{p2coldent :* {opt clear}}replace data in memory{p_end}
{p2coldent :* {helpb export:export(... [using] {it:filename}, ...)}}export
        data to {help filename:{it:filename}}, forwarded
        to {cmd:export}{p_end}
{p2coldent :* {helpb save:{ul:sa}ving([{it:filename}] [, ...])}}save
        data to {help filename:{it:filename}}, forwarded
        to {cmd:save} (no {cmd:saveold}){p_end}
{synoptline}
{p2colreset}{...}
{pstd}* One or more of {opt clear}, {opt export(string asis)}
or {opt saving(string asis)} is/are required.
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd:xtimportu} imports long or wide (pivoted) monthly, quarterly half-yearly
or yearly time series and panel data from a supported file type using
standard Stata {helpb import} syntax, filtering cross-sectional units with
{help f_ustrregexm:{it:regular expressions}} ({ul:case-sensitive!}) and
{help f_ustrregexm:{it:encoding}} the matches (each match to a string,
{ul:spaces are replaced with underscores} "_") (if required), and returns
long data as {help varname:{it:panelvar}} {help varname:{it:timevar}}
{help varname:{it:valuevar}} to memory and/or to a file using standard Stata
{helpb export} and/or {helpb save}
syntax. {ul:Imported data are assumed to be wide if}
{ul:{help varname:{it:timevar}}} {ul:is omitted}.

{pstd}
{cmd:xtimportu} uses (SSC) {helpb sxpose2} in combination with {helpb destring}
and {helpb reshape} to process wide (pivoted) data and accepts all
{help destring##destring_options:{it:destring options}}.

{pstd}
For wide (pivoted) data {ul:the first imported row} ({help _variables:{it:_n}}
== 1) must include future {help varname:{it:timevar}} values (at least
the years with possible breaks in place of higher frequency) which can be
achieved with the help of {helpb import:import} and {cmd:xtimportu} subcommand
options such as
{help import_excel##import_excel_options:{it:cellrange([start][:end])}}
or {help xtimportu##options:{it:preformat(string)}}.

{pstd}
Unicode strings are supported in both
{help xtimportu##options:{it:regex(string)}}
and {help xtimportu##options:{it:encode(string)}}.

{marker options}{...}
{title:Options}

{phang}
{helpb import:{it:* (import options)}} are none or all options from
{helpb import} such as
{help import_delimited##import_delimited_options:{it:import delimited's}}
{it:delimiters()}, {it:*range()}, {it:as*}, {it:*quotes()}, {it:*rows()}
{it:*separator()} and {it:parselocale()} or
{help import_excel##import_excel_options:{it:import excel's}} {it:sheet()},
{it:cellrange()}, {it:firstrow}, {it:allstring()} and {it:locale()}
with the exception of {it:varnames()}, {it:firstrow}, {it:case()} and
{it:clear} which are handled internally and will be ignored (if typed after
comma in the command).

{phang}
{opth pre:format(strings:string)} is an inbuilt command (including {helpb do}
and {helpb run}) and/or a user-defined {helpb program} with standard Stata
syntax (prefix included). Multiple commands (even those containing
{helpb m3 mata:mata}) can be wrapped into a {mansection P program:[P] program}
or a DO-file {findalias frdofiles} and passed to {cmd:xtimportu} as one
command, for example, {cmd:..., preformat({it:myprogram [args], [options]})}
or {cmd:..., preformat(do {it:filename [args]})}.

{phang}
{opth panel:var(varname:panelvar)} is the {varname} of the cross-sectional
unit(s) (one or multiple) or {ul:the first variable (column)} (if omitted)
in the imported data. If the data lack {help varname:{it:panelvar}}, either
a) the use of {helpb import} instead of {cmd:xtimportu} should be considered
or b) {help varname:{it:panelvar}} should be pre-generated, for example,
with the help of {help xtimportu##options:{it:preformat(string)}}. 
{break}{bf:NB} The returned {help varname:{it:panelvar}} has the name
{bf:"unit"}.

{phang}
{opth re:gex(strings:string)} is/are regular expression(s), separated by "|"
for multiple matches, and equal(s) "^.*$" if omitted. The user should note
that {ul:matching is case-sensitive}!

{phang}
{opth en:code(strings:string)} is/are {help strings:{it:string}}
replacement(s) for {help xtimportu##options:{it:regex(string)}}, separated
by "|". The user should note that
{ul:spaces in {help strings:{it:string}} will be replaced with underscores}
"_" (see the example below).

{phang}
{opth time:var(varname:timevar)} is the {varname} of the date for the imported
long data. {ul:The data are assumed to be wide if}
{ul:{help xtimportu##options:{it:timevar(string)}}} {ul:is omitted}.
{break}{bf:NB} The returned {help varname:{it:timevar}} has the full name
of {help xtimportu##options:{it:tfrequency(string)}}: {bf:"year"},
{bf:"halfyear"}, {bf:"quarter"} or {bf:"month"}.

{phang}
{opth tfor:mat(strings:string)} is the {help strings:{it:s2}} in
{it:yearly(s1,s2[,Y])}, {it:halfyearly(s1,s2[,Y])},
{it:quarterly(s1,s2[,Y])} or {it:monthly(s1,s2[,Y])}
{help datetime functions:{it:datetime functions}}, for example, "M[##]Y" or
"[##]YQ". If omitted, {cmd:xtimportu} will (re)construct the
{help varname:{it:timevar}} automatically,
{ul:starting with "####" or "####-T1"} (always with the first half-year,
quarter or month in the first year for time frequency higher than yearly) and
{ul:dropping yearly sums} (for half-years, quarters, and months if such sums
are present in the data and {help xtimportu##options:{it:drop}} is specified).
{break}{bf:NB} The user should omit this option for unsupported time formats
such as "IV/2020" or "2020年11月"!

{phang}
{opth tfreq:uency(strings:M|Q|H|Y)} is {bf:non-omittable} and is required
to pass time frequency (yearly, half-yearly, quarterly or monthly) to the
command.

{phang}
{opt drop} is required to drop yearly sums for half-years, quarters, and months
(if such sums are present in the data).

{phang}
{opt tde:string} is required to return {help varname:{it:timevar}}
in a {help format:{it:%t format}}, the default {help format:{it:format}}
is a {help strings:{it:string}} "####", "####-H#", "####-Q#" or "####-M#".

{phang}
{opth g:enerate(strings:string)} is required to replace the name of
{help varname:{it:valuevar}}.
{break}{bf:NB} The returned {help varname:{it:valuevar}} has the default name
{bf:"value"}.

{phang}
{helpb destring##options:{it:* (destring options)}} are none or all options
from {helpb destring} such as {it:ignore()}, {it:float}, {it:percent} or
{it:dpcomma} with the exception of {it:{ul:g}enerate()}, {it:replace} and
{it:force} which are handled internally and will be ignored (if typed after
comma in the command).

{phang}
{opt to:string} is required to ignore the default {helpb destring} and
is incompatible with any
{help destring##destring_options:{it:destring options}}
(if typed after comma in the command).

{phang}
{opt clear} is required to replace the data in memory,
even though the current data have not been saved to disk, otherwise
{helpb preserve} and {helpb restore} are used.

{phang}
{helpb export:export(... [using] {it:filename}, ...)} is an
{help syntax:{it:everything}}-like {it:{help strings:string}} forwarded
to {cmd:export}. The output file can be
{helpb import_delimited##export_delimited_options:CSV},
{helpb import_excel##export_excel_options:Microsoft Excel} or any other
supported file type {bf:{mansection D export}}.

{phang}
{helpb save:{ul:sa}ving([{it:filename}] [, ...])} is an
{help syntax:{it:everything}}-like {it:{help strings:string}} forwarded
to {cmd:save} ({helpb saveold} is not supported, the user should use
{help xtimportu##options:{it:clear}} with {cmd:xtimportu} and a separate
{helpb saveold} command!).

{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:xtimportu} is not a replacement tool for {helpb import} and was designed
to help automate data collection! {cmd:xtimportu} is preferable to {cmd:import}
if the data require filtering and/or they are wide (pivoted).

{pstd}
To build a dataset from several hundred CSV, Microsoft Excel or other supported
file types, the user may want to code a loop using {cmd:xtimportu},
{helpb append}, {helpb merge} or {helpb frlink} - {helpb frget}. Input files
can be pre-processed with a user-defined program passed to {cmd:xtimportu}
in {help xtimportu##options:{it:preformat(string)}} to ensure same
{help import_excel##import_excel_options:{it:cellrange([start][:end])}} or
{help xtimportu##options:{it:other options}} for each file.

{pstd}
For detailed information on {cmd:sxpose2}, see {helpb sxpose2}.

{marker examples}{...}
{title:Examples}

        ****
        * Example 1. Population time series for the Czech Republic (a country in Central Europe, EU member since 2004)
        ****

        * RegEx for the indicator, case sensitive!
        * unoptimized, illustration only
        {cmd:. local regex "Počet"}

        * ČSÚ's (Czech Statistical Office) file URL for Population
        {cmd:. local url "https://www.czso.cz/documents/10180/123502877/32018120_0101.xlsx/d60b89c8-980c-4f3a-bc0c-46f38b0b8681?version=1.0"}

        * import the time series data to memory, unit: thousand
        {cmd:. xtimportu excel "`url'", cellrange(A3) regex(`regex') encode("Czech Republic") tfreq(Y) tde clear}

        * revert underscores to spaces in the unit
        {cmd:. replace unit = ustrregexra(unit, "_", " ")}

        * tsset data
        {cmd:. tsset year}

        ****
        * Example 2. FDI matrix from UNCTAD's Bilateral FDI statistics (historical data, 2000–2014)
        ****

        * RegEx for the EU-28, case sensitive! "{c -(}0,{c )-}$" (0 or more non-word characters) excludes Netherlands Antilles
        * unoptimized, illustration only
        {cmd:. local regex "`regex'Austria|Belgium|Bulgaria|Croatia|Cyprus|Czech Republic|Denmark|Estonia|"}
        {cmd:. local regex "`regex'Finland|France|Germany|Greece|Hungary|Ireland|Italy|Latvia|Lithuania|"}
        {cmd:. local regex "`regex'Luxembourg|Malta|Netherlands\W{c -(}0,{c )-}$|Poland|Portugal|Romania|"}
        {cmd:. local regex "`regex'Slovakia|Slovenia|Spain|Sweden|United Kingdom"}

        * UNCTAD's (United Nations Conference on Trade and Development) file URL for the U.S.
        {cmd:. local url "https://unctad.org/system/files/non-official-document/webdiaeia2014d3_USA.xls"}

        * import the panel data to memory, export a copy as a CSV file
        {cmd:. xtimportu excel "`url'", sheet("inflows") cellrange(E5) regex(`regex') tfreq(Y) clear tde export(delimited "./usa_fdi_matrix.csv", replace)}

        * rename variables to form the 28x1 aka the EU-28 x U.S. FDI matrix, unit: million USD
        {cmd:. rename unit from}
        {cmd:. rename value to_USA}

        * xtset data
        {cmd:. encode from, gen(id)}
        {cmd:. xtset id year}
