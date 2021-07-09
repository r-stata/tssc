{smcl}
{* *! version 1.1 04apr2017}{...}
{title:Title}

{p2colset 5 20 22 2}{...}
{p2col :{hi:texresults} {hline 2}}Create external file of LaTeX macros with results{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{cmd:texresults} {cmd:using} {help filename:{it:filename}}{cmd:,}
[{help texresults##options:{it:options}}]
{p_end}

{marker opt_summary}{...}
{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:{help texresults##opt_result:Result}^}
{synopt: {opt r:esult(real)}}specify any result to be stored in {it:macroname}; see {help texresults##opt_result:Result} below{p_end}
{synopt: {opth c:oef(varname)}}coefficient to be stored in {it:macroname}{p_end}
{synopt: {opth se(varname)}}standard error to be stored in {it:macroname}{p_end}
{synopt: {opth t:stat(varname)}}{it:t}-stat to be stored in {it:macroname}{p_end}
{synopt: {opth p:value(varname)}}{it:p}-value to be stored in {it:macroname}{p_end}

{syntab:{help texresults##opt_file:File}}
{p2coldent:* {opt tex:macro(macroname)}}name of new LaTeX macro (without backslash){p_end}
{synopt: {opt replace}}replace {help filename:{it:filename}}{p_end}
{synopt: {opt a:ppend}}append new result to {help filename:{it:filename}}{p_end}

{syntab:{help texresults##opt_format:Formatting}}
{synopt:{opt ro:und(real)}}round {it:result} in units of {it:real}; see {help round:round()}{p_end}
{synopt:{opt unit:zero}}add a zero to the units digit if abs({it:result})<1 (e.g. -0.6 instead of -.6){p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}* {opt texmacro(macroname)} is required.{p_end}
{p 4 6 2}^ options in this category are mutually exclusive.{p_end}
{p 4 6 2}{it:varname} may contain factor variables; see {help fvvarlist}.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:texresults} is a convenience command to easily store any computed result to a LaTeX macro.
After running an estimation command in Stata, {cmd:texresults} can be used to create a new LaTeX macro, which is stored in an external text file.
This file may be called from a LaTeX document in order to use those results.

{pstd}
One of the main advantages of a Stata/LaTeX workflow is the automatic updating of tables and figures.
For instance, if we add a new control variable to a regression, we can correct the do-file that produces a table of coefficients and compile the LaTeX document again to see the updated table.
However, that advantage doesn't extend to in-text mentions of coefficients (or other results).
This leads to documents that contain inconsistent results, which have to be manually checked every time a preliminary result changes. 

{pstd}
This sitation can be remedied by creating an external file with LaTeX macros that store all cited results of an analysis.
Using these macros instead of manually copying results in the text is much less error prone, and we can be certain that results are consistent throughout the document.

{marker options}{...}
{title:Options}

{marker opt_result}{...}
{dlgtab:Result}
{* Any numeric result can be stored as a LaTeX macro with texresults, including stored estimates, scalars, numeric locals or real numbers.}
{pstd}
The most general option for storing results is by using {opt result(real)}, which allows for any numeric input.
Alternatively, {cmd:coef}, {cmd:se}, {cmd:tstat} and {cmd:pvalue} are convenience options that may be used to directly access (or compute) estimated coefficients, standard errors, {it:t}-stats or {it:p}-values respectively.

{pstd}
Options in this category are mutually exclusive (only one must be specified):

{phang}
{opt re:sult(real)}
adds any {it:real} number to {it:macroname}, including scalars, locals or matrix elements.
It can be used in post estimation.
For instance, consider the following setup:

{phang2}{cmd:. sysuse auto}{p_end}
{phang2}{cmd:. regress mpg trunk weight foreign}{p_end}

{pmore}
We can use {cmd:result(e(r2))} to add the computed R-squared and {cmd:result(_b[foreign])} to add the estimated coefficient for {cmd:foreign}.
However, for adding coefficients it may be easier to use {opt coef(varname)} (see below).

{phang}
{opth c:oef(varname)}
includes {it:varname}'s coefficient in the LaTeX macro.
For example, considering the same setup as in {opt result(real)}, we can use {cmd:coef(foreign)} to add the coefficient of {cmd:foreign}.

{phang}
{opth se(varname)}
includes {it:varname}'s standard error in the LaTeX macro.
For example, considering the same setup as in {opt result(real)}, we can use {cmd:se(foreign)} to add the standard error of {cmd:foreign}.

{phang}
{opth t:stat(varname)}
includes {it:varname}'s {it:t}-stat in the LaTeX macro.
For example, considering the same setup as in {opt result(real)}, we can use {cmd:tstat(foreign)} to add the {it:t}-stat of {cmd:foreign}.

{phang}
{opth p:value(varname)}
includes {it:varname}'s {it:p}-value in the LaTeX macro.
For example, considering the same setup as in {opt result(real)}, we can use {cmd:pvalue(foreign)} to add the {it:p}-value of {cmd:foreign}.

{marker opt_file}{...}
{dlgtab:File}

{phang}
{opt tex:macro(macroname)} will save the specified result in a LaTeX macro with name {it:macroname}, automatically appending an initial backslash.
For example, the option {opt macroname(weirdresult)} will create the LaTeX macro {cmd:\weirdresult}, which will print the specified result when used in a LaTeX document.

{pmore}
{cmd:texresults} will issue a warning if {it:macroname} is not a valid LaTeX macro, that is, if it doesn't contain only uppercase and lowercase alphabetical characters (assuming new macros don't consist of a single non-alphabetical character).

{phang}
{opt replace} will replace all contents in {it:filename} with a new LaTeX macro; see {help file:[P] file}.

{phang}
{opt a:ppend} will append the new LaTeX macro to the end of {it:filename}; see {help file:[P] file}.

{marker opt_format}{...}
{dlgtab:Formatting}

{phang}
{opt ro:und(real)} will round the result in units of {it:real}; see {help round:round()}. By default all results will be rounded to 2 decimal digits, that is, {cmd:round(0.01)}.
So if the specified result is 1.082598, it will be displayed as 1.08.

{pmore}
If you don't want to apply any rounding, use {cmd:round(0)}.

{phang}
{opt unit:zero} will add a zero to the units digit if abs({help texresults##opt_result:{it:result}})<1, which is usually preferred in text.
For example, a coefficient whose value is -.6 will be stored as -0.6.
{p_end}


{marker examples}{...}
{title:Examples}

{pstd}Stata setup{p_end}
{phang2}{cmd:. sysuse auto}{p_end}
{phang2}{cmd:. regress mpg trunk weight foreign}{p_end}

{pstd}Store root MSE of model in "results.txt", rounded by default to 2 decimal digits (default), with macro name "\rmse":{p_end}
{phang2}{cmd:. texresults using results.txt, texmacro(rmse) result(e(rmse))}{p_end}

{pstd}Append {cmd:foreign} coefficient macro to "results.txt", rounded to 1 decimal digit. The created macro is "\mainresult":{p_end}
{phang2}{cmd:. texresults using results.txt, texmacro(mainresult) coef(foreign) append}{p_end}

{pstd}Append {cmd:trunk} standard error with macro name "\trunkSE", adding a zero to unit digit:{p_end}
{phang2}{cmd:. texresults using results.txt, texmacro(trunkSE) se(trunk) unitzero append}{p_end}

{pstd}LaTeX document:{p_end}
{phang2}{cmd:\documentclass{article}}{p_end}
{phang2}{cmd:\input{results.txt}}{p_end}
{phang2}{cmd:\begin{document}}{p_end}
{phang2}{cmd:The model's root MSE is \rmse, }{p_end}
{phang2}{cmd:foreign coefficient is \mainresult, and}{p_end}
{phang2}{cmd:trunk standard error is \trunkSE.}{p_end}
{phang2}{cmd:\end{document}}{p_end}

{marker author}{...}
{title:Author}

{pstd}Alvaro Carril{break}
Research Analyst at J-PAL LAC{break}
acarril.github.io{break}
acarril@fen.uchile.cl

{marker acknowledgements}{...}
{title:Acknowledgements}

{pstd}
The creation of this program arose out of necessity, as me and a team of other RAs needed a way to streamline the inclusion of results in paper drafts.
This team includes Andre Cazor, Raul Duarte, Maximiliano Garcia, João Marcos Garcia, Shanon Hsu, Jemimah Muraya, Nikolai Schaffner and Jose Vila-Belda.
I thank them all for their valuable feedback and continuous (long distance) support.
{p_end}