{smcl}
{* *! version 1.1.0  31dec2020}{...}
{viewerjumpto "Syntax" "xtmipolateu##syntax"}{...}
{viewerjumpto "Description" "xtmipolateu##description"}{...}
{viewerjumpto "Options" "xtmipolateu##options"}{...}
{viewerjumpto "Remarks" "xtmipolateu##remarks"}{...}
{viewerjumpto "Examples" "xtmipolateu##examples"}{...}
{title:Title}

{phang}
{bf:xtmipolateu} {hline 2} Replace missing values in a time series,
two- or multidimensional varlist with interpolated (extrapolated) ones
and prepare a corresponding report document

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:xtmipolateu}
[{varlist}]
{ifin}
[{cmd:,} {it:options}]

{synoptset 35 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Mipolate-related}
{synopt :{opth i:(varlist:varlist)}}use {it:varlist} as dimensions
        (grouped by {cmd:egen group}) (omittable) {p_end}
{synopt :{opth t:(varname:varname_t)}}use {it:varname_t} as the time
        variable{p_end}
{synopt :{helpb mipolate##options:{it:* (mipolate options)}}}none or all options
        from (SSC) {cmd:mipolate}{p_end}

{syntab :Exporting}
{synopt :{helpb export:export(... [using] {it:filename}, ...)}}export
        descriptive statistics to {help filename:{it:filename}}
        (omittable){p_end}

{syntab :Reporting}
{synopt :{opth put:(strings:docx|pdf)}}"docx" or "pdf" (omittable){p_end}
{synopt :{opt pbr:eak}}add a page break between each graph
        and table (omittable){p_end}
{synopt :{opth nfor:mat(%fmt)}}specify numeric {help format:{it:format}}
        for cell text (omittable){p_end}
{synopt :{helpb putdocx begin##saveopts:{ul:sa}ving({it:filename}, ...)}}save
        the report document to {help filename:{it:filename}} (omittable){p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{cmd:by} is not allowed; see {manhelp by D}.{p_end}
{p 4 6 2}
{cmd:weight}s are not allowed; see {help weight}.


{marker description}{...}
{title:Description}

{pstd}
{cmd:xtmipolateu} replaces missing values in a time series, two- or
multidimensional {varlist} with interpolated (extrapolated) ones using
(SSC) {helpb mipolate}, at the same time allowing the user to {helpb export}
related descriptive statistics (mean, sd, min and max) collected with (SSC)
{helpb summarizeby} (an extension of {helpb statsby} for {helpb summarize}
with the same syntax but no ": command") and to write
corresponding {helpb tsline} or {helpb xtline} graphs and
{helpb putdocx table:tables} with these statistics into a new or existing
report document using {helpb putdocx} or {helpb putpdf}, keeping it open or
saving it and finishing work.

{pstd}
The user can change the style of the report document by typing a customized
{helpb putdocx begin} or {helpb putpdf begin} prior to running
{cmd:xtmipolateu} or with {helpb putdocx table} or {helpb putpdf table}
after the command has finished running. The name of each table
in the document is identical to each {varname} in the {varlist}.

{marker options}{...}
{title:Options}

{phang}
{opth "i(varlist:varlist)"} is a {varlist} used as non-time dimension(s)
for panel and multidimensional data. This option should be a) omitted
for time series, b) {varname} for panel data and c) {varlist}
for multidimensional data. Multidimensional data are treated as panel data
with a group variable, generated from {varlist} using
{helpb egen:egen group, missing label}.

{phang}
{opth "t(varname:varname_t)"} is a {varname} used as the time dimension
for a) time series, b) panel and c) multidimensional data, and so
{bf:non-omittable}. The {varname} should have the correct
{help datetime:{it:date and time type}} and {help format:{it:format}}.

{phang}
{helpb mipolate##options:{it:* (mipolate options)}} are none or all options
from (SSC) {helpb mipolate} such as {it:pchip}, {it:groupwise} or
{it:epolate} with the exception of {it:generate()} which is handled internally
and will be ignored (if typed after comma in the command). The user is
expected to having read help on {cmd:mipolate}.

{phang}
{helpb export:export(... [using] {it:filename}, ...)} is an
{help syntax:{it:everything}}-like {it:{help strings:string}} forwarded
to {helpb export}. The descriptive statistics (mean, sd, min and max)
are collected by dimensions specified in {bf:i({varlist})} with (SSC)
{helpb summarizeby} (an extension of {helpb statsby} for {helpb summarize}
with the same syntax but no ": command")
for both interpolated (extrapolated) and original data allowing to compare
and contrast both. The output file can be
{helpb import_delimited##export_delimited_options:CSV},
{helpb import_excel##export_excel_options:Microsoft Excel} or any other
supported file type {bf:{mansection D export}}.

{phang}
{opth put:(strings:docx|pdf)} is {it:{help strings:string}} with two possible
values, "docx" and "pdf". Depending on its value, a report document using
{helpb putdocx} or {helpb putpdf} is either created (if {helpb putdocx begin}
or {helpb putpdf begin} are not specified by user in advance) or appended 
(otherwise).

{phang}
{opt pbr:eak} adds a {helpb putdocx pagebreak:page break} between each graph
and table in the report document, its usage is optional. These page breaks
are not useful except for a big number of groups generated from
{bf:i({varlist})}.

{phang}
{opth nfor:mat(%fmt)} sets the numeric {help format:{it:format}} for cell text
of each table in the report document. The default format is {bf:"%9.2f"}.

{phang}
{helpb putdocx begin##saveopts:{ul:sa}ving({it:filename}, ...)} is an
{help syntax:{it:everything}}-like {it:{help strings:string}} forwarded
to {helpb putdocx_begin##opts_putdocx_save:putdocx save} or
{helpb putpdf_begin##opts_putpdf_save:putdpdf save}. This option should
be omitted if work with the report document is expected to continue, and
the file must be saved manually by the user using the aforementioned
commands.

{marker remarks}{...}
{title:Remarks}

{pstd}
For detailed information on {cmd:mipolate}, see {helpb mipolate}.

{marker examples}{...}
{title:Examples}

        {cmd:. sysuse xtline1.dta, clear}
        {cmd:. replace calories = . if ! mod(_n, 5) | ! mod(_n, 14)}

        * pure mipolate:
        {cmd:. xtmipolateu calories, i(person) t(day) spline }

        * export descriptive statistics to "./stats.csv"
        {cmd:. xtmipolateu calories, i(person) t(day) nearest export(delimited using "./stats.csv", replace)}

        * create a report file "./report.docx"
        {cmd:. xtmipolateu calories, i(person) t(day) spline epolate put("docx") sa("./report.docx", replace)}

        * create a report file "./report.pdf" with a custom style
        {cmd:. set scheme economist}
        {cmd:. putpdf begin, landscape font("Verdana")}
        {cmd:. xtmipolateu calories, i(person) t(day) epolate put("pdf") pbr sa("./report.pdf", replace)}
