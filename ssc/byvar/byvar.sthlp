{smcl}
{* *! version 2.0.3 27oct2014}{...}
{cmd:help byvar}
{hline}


{title:Title}

{p2colset 5 14 16 2}{...}
{p2col :{hi:byvar} {hline 2}}Repeat command by variable(s){p_end}
{p2colreset}{...}


{title:Syntax}

{phang2}
{cmd:byvar} {it:varlist} {ifin} 
[ {cmd:,} {it:options} ]
{cmd:: }{it:stata_cmd} [ @{it:stata_cmd} ... ]


{synoptset 28}{...}
{synopthdr :options}
{synoptline}

{synopt :{opt b(coeflist)}}store regression coefficients for variables named in {it:coeflist}{p_end}
{synopt :{opt e(elist)}}save E-class estimates {cmd:e()} named in {it:elist}{p_end}
{synopt :{opt ge:nerate}}create new variable(s) corresponding to the quantities
named in the {opt e()}, {opt r()}, {opt b()} and {opt se()} options{p_end}
{synopt :{opt m:issing}}cause {it:stata_cmd}(s) to be executed even when a combination
of values of variables in {it:varlist} includes a missing value{p_end}
{synopt :{opt nol:abel}}suppress display of score labels for categoric variables{p_end}
{synopt :{opt p:ause}}pause output after each execution of {it:stata_cmd}{p_end}
{synopt :{opt r(rlist)}}save R-class results {cmd:r()} named in {it:rlist}{p_end}
{synopt :{opt re:turn}}return quantities named in the
{opt e()}, {opt r()}, {opt b()} and {opt se()} options in functions{p_end}
{synopt :{opt se(selist)}}store standard errors of regression coefficients for
variables named in {it:selist}{p_end}
{synopt :{opt t:abulate}}display results in tabular form{p_end}
{synopt :{opt u:nique}}store results for each unique combination of values in
{it:varlist} only in first position of the new variable(s){p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
{cmd:byvar} repeats {it:stata_cmd} (and additional {it:stata_cmd}s following
each {cmd:@}, if present) for each distinct combination of values in {it:varlist}.
The latter may contain string variables.

{pstd}
For details of storage of results, see the {opt generate} and {opt return} options.


{title:Options}

{phang}
{opt b(coeflist)} stores the regression coefficients for variables
named in {it:coeflist}. Individual items may be labelled as with the
{opt e()} option.

{phang}
{opt e(elist)} saves the E-class estimates {cmd:e()} named in
{it:elist} which arise from the final {it:stata_cmd} in
{it:stata_cmd}[@{it:stata_cmd} ...]. The E-class estimates must evaluate to
numbers; strings are not allowed. The estimate names must be separated by
space(s). You may append a label, preceded by an {cmd:=} sign, to each
estimate name; this is used to label the corresponding column of
output (if the {cmd:tabulate} option is used) or variable (if the
{cmd:generate} option is used). The label is truncated to 14 characters
if it is longer than 14. If spaces are to be included, the label must be
enclosed within quotes ({cmd:""}). Commas, colons or equals signs are not
allowed anywhere within in the label. Example of {opt e()} option with
such labelling: {cmd:e(rmse="RMS error" F="F statistic" N)}.

{phang}
{opt generate} creates new variable(s) corresponding to the quantities
named in the {cmd:e()}, {cmd:r()}, {cmd:b()} and {cmd:se()} options. The names
of the new variables begin with letter {cmd:E}, {cmd:R}, {cmd:B} and {cmd:S},
respectively, followed by up to six characters which represent the {cmd:e()},
{cmd:r()}, {cmd:b()} and {cmd:se()} quantity or variable name.
The final character is {cmd:_} (or sometimes, to avoid overwriting, a letter).
For example, {cmd:e(rmse N) generate} would create variables called {cmd:Ermse_}
and {cmd:EN_}, containing the values of {cmd:e(rmse)} and {cmd:e(N)},
respectively, as left behind by each execution of the final {it:stata_cmd} in
{it:stata_cmd}[@{it:stata_cmd} ...]. Results are stored according to the
combinations of values of the by-variables in {it:varlist}.

{phang}
{opt missing} causes {it:stata_cmd}(s) to be executed even when a combination
of values of any of the variables in {it:varlist} involves a missing value.
The idea is the same as for the {cmd:missing} option in Stata's 
{help tabulate} command.

{phang}
{opt nolabel} suppresses display of score labels for categoric variables for which
score labels are defined. Numeric values are used instead.

{phang}
{opt pause} pauses output after each execution of {it:stata_cmd}. Useful for graphs.

{phang}
{opt r(rlist)} saves the R-class results {cmd:r()} named in
{it:rlist} which arise from the final {it:stata_cmd} in
{it:stata_cmd}[@{it:stata_cmd} ...]. The estimates must evaluate to numbers;
strings are not allowed. Individual items may be labelled as with the
{cmd:e()} option. Example: {cmd:r(W="W statistic" p=P-value)}.

{phang}
{opt return} returns the quantities named in the {cmd:e()}, {cmd:r()},
{cmd:b()} and {cmd:se()} options in functions of the form
{cmd:r(E}|{cmd:R}|{cmd:B}|{cmd:S}{it:#1}{cmd:gp}#2{cmd:)}. Here, {it:#1}
indexes the items in the {cmd:e()}, {cmd:r()}, {cmd:b()} and {cmd:se()}
options; {cmd:gp}{it:#2} indexes the subgroups defined by the combinations of
values in {it:varlist}. For example, {cmd:e(rmse N) return} would
return {cmd:r(E1gp1)}, {cmd:r(E1gp2)}, ... containing {cmd:e(rmse)} for subgroups 1, 2, ...
and {cmd:r(E2gp1)}, {cmd:r(E2gp2)}, ... containing {cmd:e(N)} for subgroups 1, 2, ... .

{phang}
{opt se(selist)} stores the standard errors of regression coefficients for
variables named in {it:selist}. Individual items may be labelled as with
the {cmd:e()} option.

{phang}
{opt tabulate} displays the results in tabular form, suppressing the
output (if any) from the final {it:stata_cmd}.

{phang}
{opt unique} is relevant only with {cmd:generate}. It specifies that results
for each unique combination of values defined by varlist are stored only in the
first position in the new variable(s). Values in other positions are
set to missing.

{phang}
{it:stata_cmd} is any Stata command and its options.


{title:Remarks}

{pstd}
Note that {cmd:byvar} acts conservatively when creating new variables with the
{cmd:generate} option. It won't wipe out existing variables. You may therefore find
your workspace becomes cluttered by variables beginning with the letters {cmd:E},
{cmd:R}, {cmd:B} or {cmd:S}. With caution, you can type, for example,
{cmd:drop E* R*} to eliminate them in one action.

{pstd}
Note that {cmd:byvar} has {cmd:sortpreserve}, meaning that {cmd:byvar}
changes the sort order of the data and that Stata restores the original
sort order at the program's conclusion. See {help program}.
 

{title:Examples}

{pstd}
To produce a Normal Q-Q plot of {cmd:weight} for each non-missing value of {cmd:rep78}:

{phang}{cmd:. sysuse auto}{p_end}
{phang}{cmd:. byvar rep78, pause: qnorm weight}{p_end}

{pstd}
To carry out Shapiro-Wilk tests on {cmd:mpg} for each of the 6 values
of {cmd:rep78} including missing, store the W-statistics ({cmd:r(W)})
in functions {cmd:r(R1gp1)},..., {cmd:r(R1gp6)} and their P-values
({cmd:r(p)}) in functions {cmd:r(R2gp1)}, ..., {cmd:r(R2gp6)},
and display the results in tabular form, with columns headed {cmd:W statistic}
and {cmd:P-value}:

{phang}{cmd:. byvar rep78, r(W="W statistic" p=P-value) return tabulate missing: swilk mpg}{p_end}

{pstd}
To create two new variables: {cmd:Ermse_} containing {cmd:e(rmse)}, i.e. the regression
mean square error, for each of the two values of {cmd:foreign}, and {cmd:Bweight_}
containing the estimated regression coefficients for regressing {cmd:mpg} on {cmd:weight}:

{phang}{cmd:. byvar foreign, e(rmse) b(weight) generate: regress mpg weight}{p_end}

{pstd}
To run a logistic regression of {cmd:foreign} on {cmd:mpg} for levels 3, 4 and 5
of {cmd:rep78}, and calculate and report a Hosmer-Lemeshow chi-square statistic
based on 5 groups:

{phang}{cmd:. byar rep78 if rep78>=3, tabulate r(chi2):}
{cmd:logit foreign mpg @ estat gof, groups(5)}{p_end}

{pstd}
To do the same, but save the chi-square values to a new variable called {cmd:Rchi2_},
storing only the unique result for each value of {cmd:rep78}:

{phang}{cmd:. byar rep78 if rep78>=3, generate r(chi2) unique:}
{cmd:logit foreign mpg @ estat gof, groups(5)}{p_end}


{title:Author}

{pstd}
Patrick Royston{break}
MRC Clinical Trials Unit at UCL, London WC2B 6NH, UK.

{pstd}Email: {browse "mailto:j.royston@ucl.ac.uk":Patrick Royston}


{title:Also see}

{psee}Manual:  [D] by{break}{p_end}
{psee}Online:  help for {help collapse}{p_end}
