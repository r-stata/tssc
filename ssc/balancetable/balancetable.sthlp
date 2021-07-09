{smcl}
{* *! version 5.0 Mattia Chiapello 19nov2018}

{title:Title}

{phang}{bf:balancetable} {hline 2} Build a balance table (showing means and difference in means) and print it in a LaTeX file or an Excel file


{title:Table of contents}

{phang}{help balancetable##syntax:Syntax}{p_end}
{phang}{help balancetable##descr:Description}{p_end}
{phang}{help balancetable##options:Options}{p_end}
{phang}{help balancetable##remarks:Remarks}{p_end}
{phang}{help balancetable##examples:Examples}{p_end}


{marker syntax}{...}
{title:Syntax}

{phang}Basic syntax{p_end}

{p 8 16 2}{cmd:balancetable} {varname} {depvarlist} {cmd:using} {it:{help filename}} {ifin} {weight} [{cmd:,} {it:options}]

{pmore}where {varname} must be a variable taking values 0 and 1 only.{p_end}


{phang}Long syntax{p_end}

{p 8 16 2}{cmd:balancetable} {cmd:(}{it:column1}{cmd:)} [{cmd:(}{it:column2}{cmd:)} {it:...}] {depvarlist} {cmd:using} {it:{help filename}} {ifin} {weight} [{cmd:,} {it:options}]

{pmore}where {cmd:(}{it:column#}{cmd:)} can take either of these two forms:{p_end}
{pmore2}a. {cmd:(mean} [{it:{help if}}]{cmd:)}, or{p_end}
{pmore2}b. {cmd:(diff} {varname} [{it:{help if}}]{cmd:)}, where {varname} must be a variable taking values 0 and 1 only.{p_end}

{pmore}The long syntax can be used to show the means over several subsamples and/or when there is more than one treatment arm (see {help balancetable##remarks_long:remarks} below).{p_end}


{pmore}For both syntaxes, {it:{help filename}} must be a LaTeX file (.tex) or an Excel file (.xls or .xlsx), and it can be preceded by the file path.{p_end}


{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:{help balancetable##content:Content}}
{synopt: {opt pval:ues}} print p-values instead of standard errors for the difference in means{p_end}
{synopt: {opth vce(vcetype)}} specify the type of standard errors reported{p_end}
{synopt: {opth fe(varname)}} add fixed effects when computing the difference in means{p_end}
{synopt: {opth cov:ariates(varlist)}} add control variables when computing the difference in means{p_end}
{synopt: {opt stddiff}} compute standardized differences {it:[basic syntax only]}{p_end}
{synopt: {opt observationscolumn}} add an additional column with the sample size for each variable in {it:depvarlist} {it:[basic syntax only]}{p_end}

{syntab:{help balancetable##formatting:Table formatting and labels}}
{synopt: {opt wide}[{cmd:(}{it:statlist}[{cmd:,} {it:subopt}]{cmd:)}]} make table wide, with statistics side by side{p_end}
{synopt: {opt onel:ine}[{cmd:(}{it:stat}[{cmd:,} {it:subopt}]{cmd:)}]} print only one row per variable{p_end}
{synopt: {opt cti:tles(strlist)}} insert column titles (in quotes){p_end}
{synopt: {opt leftcti:tle(string)}} change the title in the leftmost column of the title row{p_end}
{synopt: {opt leftcobs:ervations(string)}} change the text in the leftmost column of the footer{p_end}
{synopt: {opt varna:mes}} use variable names in the balance table{p_end}
{synopt: {opt varla:bels}} use variable labels in the balance table{p_end}
{synopt: {opt wrap}[{cmd:(}{it:opt}{cmd:)}]} wrap variable label if it is too long{p_end}
{synopt: {space 2}{it:#}} number of characters before wrapping{p_end}
{synopt: {space 2}{opt indent}} indent the second line{p_end}
{synopt: {opt nonum:bers}} do not print column numbers in the header{p_end}
{synopt: {opt noobs:ervations}} do not print the number of observations for each subsample in the footer{p_end}
{synopt: {opt noli:nes}} do not print horizontal lines{p_end}
{synopt: {opt groups}{cmd:(}{it:strlist}[{cmd:,} {it:subopt}{cmd:)}]} define and label groups of columns{p_end}
{synopt: {space 2}{opt pattern(numlist)}} define how to group columns{p_end}
{synopt: {space 2}{opt leftc(string)}} insert text in the leftmost column of the group row{p_end}
{synopt: {space 2}{opt prefix(string)}} define prefix to be added before each group label{p_end}
{synopt: {space 2}{opt suffix(string)}} define suffix to be added after each group label{p_end}
{synopt: {space 2}{opt begin(string)}} define common text to be added at the beginning of the group row {it:[LaTeX only]}{p_end}
{synopt: {space 2}{opt end(string)}} define common text to be added at the end of the group row {it:[LaTeX only]}{p_end}
{synopt: {space 2}{opt nomerge}} do not merge cells containing group labels {it:[Excel only]}{p_end}
{synopt: {opt nohead}} omit entire table header{p_end}
{synopt: {opt nofoot}} omit entire table footer{p_end}

{syntab:{help balancetable##cell:Cell formatting}}
{synopt: {opth format(fmt)}} format numbers inside the table{p_end}
{synopt: {opt displayf:ormat}} use display format in the table{p_end}
{synopt: {opt nopar}} do not print parentheses around standard deviation and standard errors (or p-values){p_end}
{synopt: {opt par(l r)}} redefine the parentheses to be used{p_end}
{synopt: {it:statistic}{cmd:(}{it:opt}{cmd:)}} apply formatting to each type of statistic{p_end}
{synopt: {space 2}{opth fmt(fmt)}} format numbers for specified statistic{p_end}
{synopt: {space 2}{opt nopar}} do not print parentheses around specified statistic{p_end}
{synopt: {space 2}{opt par(l r)}} redefine parentheses around specified statistic{p_end}

{syntab:{help balancetable##stars:Significance stars}}
{synopt: {opt nostars}} do not add significance stars{p_end}
{synopt: {opt starl:evels(levelslist)}} specify significance levels and symbols{p_end}
{synopt: {opt staraux}} attach significance stars to standard errors (or p-values) instead of coefficients{p_end}

{syntab:{help balancetable##latex:LaTeX-specific}}
{synopt: {opt tabulary}[{opt (width)}]} use the {cmd:tabulary} environment in LaTeX{p_end}
{synopt: {opt long:table}} use the {cmd:longtable} environment in LaTeX{p_end}
{synopt: {opt bookt:abs}} use the {cmd:booktabs} package in LaTeX{p_end}
{synopt: {opt prehead(strlist)}} add text before the table header{p_end}
{synopt: {opt posthead(strlist)}} add text after the table header{p_end}
{synopt: {opt prefoot(strlist)}} add text before the table footer{p_end}
{synopt: {opt postfoot(strlist)}} add text after the table footer{p_end}
{synopt: {opt varwidth(#)}} set maximum length of variable label{p_end}

{syntab:{help balancetable##output:Output}}
{synopt: {opt replace}} overwrite existing file{p_end}
{synopt: {opt append}} append to existing file {it:[LaTeX only]}{p_end}
{synopt: {opt modify}} modify existing file {it:[Excel only]}{p_end}
{synopt: {opt sheet(sheetname)}} write to worksheet {it:sheetname} {it:[Excel only]}{p_end}
{synopt: {opt cell(cellreference)}} start printing table from {it:cellreference} {it:[Excel only]}{p_end}
{synopt: {opt nomata}} do not use Mata in managing the output file {it:[Excel only]}{p_end}
{synoptline}
{pstd}{cmd:aweight}s, {cmd:fweight}s and {cmd:iweight}s are allowed; see {help weight}.{p_end}


{marker descr}{...}
{title:Description}

{pstd}
This command builds a balance table, comparing two or more subsamples according to a set of characteristics, with the goal of checking whether the differences are statistically significant. The
characteristics to be compared are listed in {depvarlist}, while {varname} is the dummy identifying the two subsamples.{p_end}

{pstd}
The basic syntax can be used to illustrate the functioning of this command. For
each variable in {depvarlist}, {cmd: balancetable} does the following:{p_end}
{p 6 9 2}1. compute the mean and the standard deviation of the variable when {varname} is equal to 0, placing them in column (1);{p_end}
{p 6 9 2}2. compute the mean and the standard deviation of the variable when {varname} is equal to 1, placing them in column (2);{p_end}
{p 6 9 2}3. regress the variable in {depvarlist} on {varname} to compute the difference and the associated standard error (or p-value, if the appropriate option is specified), placing them in column (3).{p_end}
{pstd}
The same procedure is applied to all the variables in {depvarlist}, to produce the complete balance table.{p_end}
{pstd}
In step 3, it is possible to use different types of standard errors, add fixed effects or other control variables. In
addition, with {cmd:balancetable} it is possible to change the level of significance, set the numeric format and customize the table in many other ways.{p_end}

{pstd}
The long syntax allows more control over the content of each column. In
particular, the user can add as many columns as desired, and these can be of two types:{p_end}
{p 6 9 2}a. type {cmd:(mean)}, containing the mean and the standard deviation of each variable in {depvarlist}, as in columns (1) and (2) with the basic syntax;{p_end}
{p 6 9 2}b. type {cmd:(diff)}, containing the difference between the subsamples indicated by {varname}, as well as the associated standard error (or p-value), as in column (3) with the basic syntax.{p_end}


{marker options}{...}
{title:Options}

{phang}Contents{p_end}
{phang2}{help balancetable##content:Content}{p_end}
{phang2}{help balancetable##formatting:Table formatting and labels}{p_end}
{phang2}{help balancetable##cell:Cell formatting}{p_end}
{phang2}{help balancetable##stars:Significance stars}{p_end}
{phang2}{help balancetable##latex:LaTeX-specific}{p_end}
{phang2}{help balancetable##output:Output}{p_end}

{marker content}{...}
{dlgtab:Content}

{phang}{opt pvalues} instructs {cmd: balancetable} to print p-values instead of standard errors in column (3) for the basic syntax or in {cmd:diff} type columns for the complex syntax.

{phang}{opth vce(vcetype)} specifies the type of standard errors to be used. It
accepts all the standard errors used accepted by {help regress}, but they must be specified inside the parentheses of {opt vce()}. For
instance, one could use {cmd: vce(robust)} or {cmd: vce(cluster} {it:clustvar}{cmd:)}. This
option can be used in conjunction with {opt pvalues}: reported p-values are the correct ones.{p_end}

{phang}{opth fe(varname)} includes fixed effects for {varname} when computing the coefficient in column (3). Of
course, if the {opt fe()} option is specified, the number in column (3) will no longer be the difference between column (1) and column (2).{p_end}
{pmore}The {opt fe()} option is outdated: it accepts only one variable; to add more fixed effects use the {opt covariates()} option.{p_end}

{phang}{opth covariates(varlist)} includes covariates in {varlist} when computing the coefficient in column (3). Of
course, if the {opt covariates()} option is specified, the number in column (3) will no longer be the difference between column (1) and column (2).{p_end}
{pmore}The option {opt covariates()} accepts time-series operators and factor variables. Therefore,
it can be used to add fixed effects instead of using the {opt fe()} option (e.g. by typing {cmd:cov(i.strata)}).{p_end}

{phang}{opt stddiff} computes the standardized differences in means and adds them in a column next to column (3). The
standardized difference is computed as {cmd:[mean(t)-mean(c)]/[sqrt(var(t)+var(c))]},
where {cmd:mean(t)} and {cmd:mean(c)} are the mean of the variable of interest in the treatment group and control group respectively, while {cmd:var(t)} and {cmd:var(c)} are the variances in those two groups.{p_end}

{phang}{opt observationscolumn} adds one more column, containing the sample size for each regression computed in column (3). This
number may vary across variables in {depvarlist}, depending on the number of missing values for each variable.{p_end}

{marker formatting}{...}
{dlgtab:Table formatting and labels}

{phang}{opt wide} changes the table layout, so that statistics are shown side by side, taking one row in the table instead of two.{p_end}
{pmore}In addition, {opt wide} allows the user to optionally specify which statistics should be included in the table (the default is to include all). The
possible arguments of {it:statlist} are:{p_end}
{pmore}- {opt mean}: mean, first line of columns (1) and (2) (basic syntax) or {cmd:mean} type columns (complex syntax){p_end}
{pmore}- {opt sd}: standard deviation, second line of columns (1) and (2) (basic syntax) or {cmd:mean} type columns (complex syntax){p_end}
{pmore}- {opt diff}: difference in means, first line of column (3) (basic syntax) or {cmd:diff} type columns (complex syntax){p_end}
{pmore}- {opt se}: standard error of the difference in means, second line of column (3) (basic syntax) or {cmd:diff} type columns (complex syntax){p_end}
{pmore}- {opt pval}: p-value of the difference in means, second line of column (3) (basic syntax) or {cmd:diff} type columns (complex syntax){p_end}
{pmore}Statistics specified in {it:statlist} by the user will be printed, regardless of the column where they are. For
instance, typing {cmd:wide(mean diff se)} will not print standard deviations and place mean of control group in the first column, mean of treatment group in the second,
difference in means in the third and standard error in the fourth.{p_end}

{phang3}{opt wrapok} makes {opt wide} compatible with the {opt wrap} option. By
default, these two options cannot be used together, because the second line of the variable label would be lost. By
specifying {opt wrapok} the user explicitly declares that it is ok to truncate long variable labels with the {opt wrap} option.{p_end}

{pmore}See {help balancetable##remarks_wide:remarks} for more details on wide tables.{p_end}

{phang}{opt oneline} drops the second line of the table for each variable (i.e. it only prints means and difference in means, and not standard deviations and standard errors/p-values).{p_end}
{pmore}It is possible to specify a {it:stat}, which can be either {opt se} or {opt pval}, to substitute the difference in means with standard errors or p-values respectively. Typing
{cmd:oneline(se)} -or {cmd:oneline(pval)}- ensures that column (3) (with the basic syntax) or the {cmd:diff} type columns (with the complex syntax) show the standard errors
-or the p-values- instead of showing the difference in means.{p_end}

{phang3}{opt wrapok} makes {opt oneline} compatible with the {opt wrap} option. The
rationale is the same as with the {opt wide} option.{p_end}

{pmore}See {help balancetable##remarks_wide:remarks} for more details on one-line (wide) tables.{p_end}

{phang}{opt ctitles(strlist)} is used to insert the titles of columns (1), (2), etc. Each
column title must be enclosed in quotes if it contains more than one word. The
titles will appear in the same order as they are written; to skip the title for one column, it is sufficient to open and close the quotes without any text in between ({cmd:""}) and then continue with the subsequent column title.{p_end}

{phang}{opt leftctitle(string)} changes the title of the leftmost column, the one containing the variable names or labels (the default column name is "Variable"). The syntax to use to leave it empty is {cmd:leftctitle(none)}. This
option is effective only if the option {opt ctitles} has been specified.{p_end}

{phang}{opt leftcobservations(string)} changes the text of the leftmost column in the observations row (the default is "Observations"). This
option is effective only if {opt noobservations} has {it:not} been specified.{p_end}

{phang}{opt varnames} includes variable names in the balance table (this is the default).{p_end}

{phang}{opt varlabels} includes variable labels in the balance table, instead of variable names.{p_end}

{phang}{opt wrap} split labels in two lines when they are too long. The
default is to wrap after 32 characters (unless a number is specified in the suboption), but words are not broken. Even
with the option {opt wrap}, labels can never take more than two lines.{p_end}

{phang3}{it:#} sets the number of characters after which the label is wrapped (the default is 32 characters).{p_end}

{phang3}{opt indent} ensures that the second line is indented, to ease readability.{p_end}

{phang}{opt nonumbers} removes column numbers, i.e. (1), (2), etc. (included by default as the first row in the header).{p_end}

{phang}{opt noobservations} removes the row with the number of observations for each subsample (added by default at the bottom of the table).{p_end}

{phang}{opt nolines} removes the horizontal lines separating the header and the footer.{p_end}

{phang}{opt groups(strlist)} defines and labels groups of columns, according to the scheme specified in {opt pattern()}. The
argument {it:strlist} is the list of labels in the order they should appear in the table. When
a label includes two or more words, it should be enclosed in quotes. If
the user specifies less labels than the number of models, the last labels will be assumed to be empty. If
there are more labels than groups, the extra labels are ignored.{p_end}

{phang3}{opt pattern(numlist)} defines how columns are allocated to groups. {it:numlist}
should be a list of 1s and 0s, where 1s indicate where groups start. For
instance, {cmd:pattern(1 0 1)} would indicate to group the first and the second column, while leaving the third column in a separate group. If
{it:numlist} has less elements than the number of columns, the last ones are assumed to be 0s. If
{it:numlist} has more elements than the number of columns, the extra ones are ignored. If
a pattern is not specified at all, {cmd:balancetable} assumes that {it:all} the columns belong to one big group, basically adding one extra title row in the header.{p_end}

{phang3}{opt leftc(string)} allows adding a text in the leftmost column (above the "Variable" title).{p_end}

{phang3}{opt prefix(string)} adds a prefix that is inserted before the label of each group.{p_end}

{phang3}{opt suffix(string)} adds a suffix that is inserted after the label of each group.{p_end}

{phang3}{opt begin(string)} adds a common beginning that is added before the entire group row. This
suboption is allowed only for LaTeX output files.{p_end}

{phang3}{opt end(string)} adds a common ending that is added after the entire group row. This
suboption is allowed only for LaTeX output files.{p_end}

{phang3}{opt nomerge} prevents {cmd:balancetable} from merging the cells forming each group, in Excel files (while with LaTeX files this option is not allowed). With
{opt nomerge}, group labels will still appear centered, but they will be stored in the first cell of the group, because the underlying cells have not been merged.{p_end}
{pmore3}To merge cells, {cmd:balancetable} needs to use Mata. For
this reason, the option {opt nomata} (see below) automatically triggers the {opt groups()} suboption {opt nomerge}.{p_end}

{pmore}There are placehoders that can be used anywhere in the {opt group()} option (including in the label itself). Each
placeholder will be substituted with the appropriate number (see {help balancetable##remarks_placeholders:remarks} below).{p_end}
{pmore}By default, when the output is a LaTeX file, {opt prefix()} will be "\multicolumn{@span}{c}{" and {opt suffix()} "}",
so that the group labels are automatically placed in a centered multicolumn. Specifying
{opt prefix()} or {opt suffix()} will overwrite these.{p_end}

{phang}{opt nohead} removes the table header. A
similar result would be achieved by specifying neither {opt ctitles()} nor {opt group()}, and using the options {opt nonumbers} and {opt nolines}. In
addition, for LaTeX output {opt nohead} also removes the initial "\begin{tabular}...", as if the user specified {cmd:prehead("")}. Even
with {opt nohead}, the LaTeX-specific options {opt prehead()} and {opt posthead()} will still be usable.{p_end}

{phang}{opt nofoot} removes the table footer. A
similar result would be achieved by using the options {opt noobservations} and {opt nolines}. In
addition, for LaTeX output {opt nofoot} also removes the final "\end{tabular}", as if the user specified {cmd:postfoot("")}. Even
with {opt nofoot}, the LaTeX-specific options {opt prefoot()} and {opt postfoot()} will still be usable.{p_end}

{marker cell}{...}
{dlgtab:Cell formatting}

{pstd}These options allow controlling the format of the numbers used in the table and the parentheses used.{p_end}
{pstd}The statistic-specific options (indicated as {it:statistic}{cmd:(}{it:opt}{cmd:)} in the table above) override the generic options, both for numeric formats and for parentheses. For
numeric formats, {opt displayformat} overrides {opt format()}.{p_end}

{phang}{opth format(fmt)} allows formatting numbers inside the table according to conventional Stata formatting (e.g. %#.#g, %#.#fc, etc.).{p_end}

{phang}{opt displayformat} uses the display format of each variable, instead of using a common format. This
may be useful when the balance table contains variables with very different magnitude. For
instance, the user may want to display large monetary amounts with commas and no decimal digits and dummy variables with 3 decimal digits. This
can be achieved by setting the appropriate format with the {help format} command before creating the balance table and then using {opt displayformat} (see {help balancetable##example_displayformat:example} below).{p_end}
{pmore}This option overrides {opt format()}. However,
it does not affect p-values, whose format can still be controlled with the generic {opt format()} option or with {cmd:pval(fmt())}.{p_end}

{phang}{opt nopar} avoids printing parentheses around standard deviations and standard errors (or p-values).{p_end}

{phang}{opt par(l r)} overrides the standard parentheses that are used in the table, which are {cmd:(} and {cmd:)} by default. For
instance, specifying {cmd:par([ ])} inserts square brackets instead of parentheses.{p_end}
{pmore}Normally, {opt par()} requires two arguments. If,
for any reason, the user wants one-sided parentheses, this can be achieved by typing {cmd:par(( "")} or {cmd:par("" ])}.{p_end}

{phang}{opt mean}, {opt sd}, {opt diff}, {opt se}, {opt pval}, {opt stddiff}, {opt obs} allow setting numeric format and parentheses for each type of statistic. They
actually are 7 separate options which follow the same syntax, but can be used independently to control each statistic. The
statistics are:{p_end}
{pmore}- {opt mean}: mean, first line of columns (1) and (2) (basic syntax) or {cmd:mean} type columns (complex syntax){p_end}
{pmore}- {opt sd}: standard deviation, second line of columns (1) and (2) (basic syntax) or {cmd:mean} type columns (complex syntax){p_end}
{pmore}- {opt diff}: difference in means, first line of column (3) (basic syntax) or {cmd:diff} type columns (complex syntax){p_end}
{pmore}- {opt se}: standard error of the difference in means, second line of column (3) (basic syntax) or {cmd:diff} type columns (complex syntax){p_end}
{pmore}- {opt pval}: p-value of the difference in means, second line of column (3) (basic syntax) or {cmd:diff} type columns (complex syntax) if {opt pvalues} is specified{p_end}
{pmore}- {opt stddiff}: standardized difference in means, first line of column (4) (basic syntax) if {opt stddiff} is specified{p_end}
{pmore}- {opt obs}: number of observations, last table row if {opt noobservations} is not specified and rightmost column if {opt observationscolumn} is specified (both controlled at the same time){p_end}

{phang3}{opth fmt(fmt)} allows formatting numbers for the specified statistic according to conventional Stata formatting (e.g. %#.#g, %#.#fc, etc.).{p_end}

{phang3}{opt nopar} avoids printing parentheses around the specified statistic.{p_end}

{phang3}{opt par(l r)} specifies which parentheses to use for the specified statistic. It
follows the same rules as the generic {opt par()} option.{p_end}

{pmore}As mentioned above, each statistic has can be controlled independently. For
instance, {cmd:... , sd(nopar) se(par([ ]))} will remove parentheses around the standard deviations and use square brackets around standard errors.{p_end}
{pmore}The option {opt obs} is somewhat different, as it controls two separate "areas" of the table. An
observation count is displayed at the bottom of the table, but also in the last column, with the {opt observationscolumn} option. Specifying
something like {cmd:obs(fmt(%9.0f))} will affect {it:both}, it is not possible to control these two areas independently.{p_end}

{pmore}Statistic-specific options override generic options set for the whole table. For
instance, writing {cmd:pvalues format(%12.0fc) pval(fmt(%5.3f))} will make sure that every number in the table is rounded to the nearest integer, except for p-values, which are shown with 3 decimal digits.{p_end}

{marker stars}{...}
{dlgtab:Significance stars}

{phang}{opt nostars} drops the significance stars from the table. By
default, significance stars are added to column (3) with the basic syntax and to the {cmd:diff} type columns with the complex syntax.{p_end}

{phang}{opt starlevels(levelslist)} allows defining the thresholds for significance and the corresponding symbols. Significance
levels can take values in the interval (0,1] and they must be written in descreasing order, followed by their symbol. That
is, {it:levelslist} should be something like {cmd:++ 0.01 +++ 0.005}. The
default levels are * for {it:p} < 0.10, ** for {it:p} < 0.05 and *** for {it:p} < 0.01.{p_end}

{phang}{opt staraux} shifts stars to the second line of the table (or to the next column for the wide table), so that they are attached to the standard errors (or p-values) instead of the coefficient.

{marker latex}{...}
{dlgtab:LaTeX-specific}

{pstd}These options apply only if the output is a LaTeX file, that is the {it:{help filename}} specified by the user has the .tex extension.{p_end}
{pstd}Options {opt prehead()}, {opt posthead()}, {opt prefoot()} and {opt postfoot()} should be compatible with the tabular environment, so the text must be chosen accordingly, i.e. using the correct number of "&" symbols and/or multicolumns, as well as "\\" at the end of each row. Also,
the total number of columns may increase to 5 or 6 when the options {opt stddiff} and/or {opt observationscolumn} are specified with the basic syntax,
while with the complex syntax the total number of columns depends on the number of parentheses.{p_end}

{phang}{opt tabulary} prints the table using the {cmd:tabulary} environment in LaTeX (instead of the default {cmd:tabular}). This
allows for better spacing and text wrapping and it is particularly useful when column titles are rather long. It
is also possible to specify the width of the table. If
{it:width} is not entered by the user, it defaults to "\textwidth".{p_end}
{pmore}This option requires using the {cmd:tabulary} package in the .tex file and it cannot be used with {opt longtable}.{p_end}

{phang}{opt longtable} allows building tables that span more than one page, with the {cmd:longtable} environment in LaTeX (instead of the default {cmd:tabular}). It
is useful if the balance table contains a large number of variables and therefore does not fit in one page.{p_end}
{pmore}This option requires using the {cmd:longtable} package in the .tex file and it cannot be used with {opt tabulary}.{p_end}

{phang}{opt booktabs} uses the horizontal lines provided with the {cmd:booktabs} package, which allows for enhanced quality of tables. By
default, {cmd:balancetable} uses the standard "\hline" command in LaTeX.{p_end}
{pmore}This option requires using the {cmd:booktabs} package in the .tex file.{p_end}

{phang}{opt prehead(strlist)} insert strings of text before the table header. The
text must be enclosed in quotes, and multiple quotes may be used to add several lines to the table. This
option allows the use of placeholders (see {help balancetable##remarks_placeholders:remarks} below). By
default, {opt prehead()} contains the "\begin{tabular}..." code and the top horizontal line of the table. Specifying
{opt prehead()} will overwrite it.{p_end}

{phang}{opt posthead(strlist)} insert strings of text after the table header. The
text must be enclosed in quotes, and multiple quotes may be used to add several lines to the table. This
option allows the use of placeholders (see {help balancetable##remarks_placeholders:remarks} below). By
default, {opt posthead()} contains the horizontal line separating the header from the main body of the table. Specifying
{opt posthead()} will overwrite it.{p_end}

{phang}{opt prefoot(strlist)} insert strings of text before the table footer. The
text must be enclosed in quotes, and multiple quotes may be used to add several lines to the table. This
option allows the use of placeholders (see {help balancetable##remarks_placeholders:remarks} below). By
default, {opt prefoot()} contains the horizontal line separating the main body of the table from the footer. Specifying
{opt prefoot()} will overwrite it.{p_end}

{phang}{opt postfoot(strlist)} insert strings of text after the table footer. The
text must be enclosed in quotes, and multiple quotes may be used to add several lines to the table. This
option allows the use of placeholders (see {help balancetable##remarks_placeholders:remarks} below). By
default, {opt postfoot()} contains the bottom horizontal line of the table and the "\end{tabular}" code. Specifying
{opt postfoot()} will overwrite it.{p_end}

{phang}{opt varwidth(#)} sets the length of the leftmost column of the table (the one with variable names or labels). This
width can be seen as expressed in number of characters, but in reality it is expressed in {cmd:ex} units, whose length depends on the font used. Basically,
{opt varwidth} creates a filler in each cell of the variable name/label column, stretching it to the desired width.{p_end}
{pmore}It would be safer not to use this option, it is provided mainly for backward compatibility. When
there is the need to set a specific width for the leftmost column, a better approach is to use a {cmd:p} column, replacing the head with a the {opt prehead()} option. For
instance, typing {cmd:prehead("\begin{tabular}{p{5cm}*{@col}c}" "\toprule")} would set the leftmost column to 5cm.{p_end}

{marker output}{...}
{dlgtab:Output}

{phang}{opt replace} allows overwriting {it:{help filename}} if it already exists.{p_end}

{phang}{opt append} makes sure that the newly created balance table is appended to the specified file if it already exists. This
option is valid only for LaTeX output files.{p_end}

{phang}{opt modify} allows modifying an Excel file if it already exists. This
option is valid only for Excel output files.{p_end}

{phang}{opt sheet(sheetname)} specifies that the table should be written in worksheet {it:sheetname}. If
this option is not specified, the balance table is placed in the first worksheet of the destination file. This
option is valid only for Excel output files.{p_end}

{phang}{opt cell(cellreference)} specifies that the table should be printed using {it:cellreference} as the upper-left corner. If
this option is not specified, the balance table will start from the first cell of the worksheet (cell A1). This
option is valid only for Excel output files.{p_end}

{phang}{opt nomata} prevents {cmd:balancetable} from using Mata to manage the output file. Mata
is used when merging cells for the {opt groups()} option and when processing the {opt cell()} option. Should
these steps cause any problems, {opt nomata} offers a workaround; however, this should be avoided, if possible. This
option is valid only for Excel output files.{p_end}


{marker remarks}{...}
{title:Remarks}

{phang}Contents{p_end}
{phang2}{help balancetable##remarks_long:Long syntax}{p_end}
{phang2}{help balancetable##remarks_wide:Wide table}{p_end}
{phang2}{help balancetable##remarks_placeholders:Placeholders}{p_end}
{phang2}{help balancetable##remarks_quotes:Quotes}{p_end}

{marker remarks_long}{...}
{dlgtab:Long syntax}

{pstd}
The long syntax allows a more refined control over the table layout, by letting the user specify the content of each column inside the parentheses. The
long syntax supports two types of columns ({cmd:mean} and {cmd:diff}), mimicking those used in the basic syntax.{p_end}

{pstd}
The {cmd:mean} column takes the form{p_end}

{phang2}{cmd:(mean} [{it:{help if}}]{cmd:)}{p_end}

{pstd}allowing the use of an optional {help if:if expression} to identify the subsample over which to calculate the mean and the standard deviations.{p_end}

{pstd}
The {cmd:diff} column takes the form

{phang2}{cmd:(diff} {varname} [{it:{help if}}]{cmd:)}{p_end}

{pstd}meaning that it requires specifying a {varname} (which must be binary) to identify the two subsamples to calculate the difference and the standard errors (and it also supports optional {help if:if expressions}).{p_end}

{pstd}Therefore, the short syntax{p_end}

{phang2}{cmd:. balancetable treatvar depvar_1 depvar_2 depvar_3 using "myfile.tex"}{p_end}

{pstd}is completely equivalent to{p_end}

{phang2}{cmd:. balancetable (mean if treatvar==0) (mean if treatvar==1) (diff treatvar) depvar_1 depvar_2 depvar_3 using "myfile.tex"}{p_end}

{pstd}
The long syntax is especially useful in case of multiple treatments. For
instance, suppose we have an experiment with two treatment arms (A and B) and a control group, and we want to check the balance of each treatment arm versus the control group and the balance between treatment arms.{p_end}
{pstd}We could write

{phang2}{cmd:. balancetable (mean if treatment==0) (mean if treatment==1) (mean if treatment==2) (diff treatment_A if treatment!=2) (diff treatment_B if treatment!=1) (diff treatment_A if treatment!=0) $depvarlist using "myfile.xls"}{p_end}

{pstd}where {cmd:treatment} is a variable that takes value 0 for the control group, value 1 for treatment A and value 2 for treatment B, while {cmd:treatment_A} and {cmd:treatment_B} are two dummy variables for treatment arms.

{pstd}
As mentioned above, {cmd:(diff)} type columns require the use of a binary (dummy) variable, and the command {cmd:balancetable} does not create them. In
the previous example, {cmd:treatment_A} and {cmd:treatment_B} must be created by the user, for instance in the following way:{p_end}

{phang2}{cmd:. generate treatment_A = (treatment==1)}{p_end}
{phang2}{cmd:. generate treatment_B = (treatment==2)}{p_end}

{pstd}
One final remark: {help if:if expressions} placed inside the parentheses are complementary to the {ifin} conditions specified in the main argument of {cmd:balancetable},
that is {it:both} are applied to the relevant columns (see {help balancetable##example_ifexp:example} below).{p_end}

{marker remarks_wide}{...}
{dlgtab:Wide table}

{pstd}
Usually, {cmd:balancetable} would produce a table with twice as many rows as variables in the {depvarlist}. For
each variable, the first row contains means and difference in means, while the second row contains standars deviations and standard errors (or p-values).{p_end}
{pstd}
With the {opt wide} option, however, the table is reshaped so that the statistics that would normally be on the second row are placed next to the ones of the first row. Therefore,
the number of columns of the table doubles, while the rows are as many as the variables in the {depvarlist}.{p_end}
{pstd}
The {opt oneline} option follows a similar procedure, producing a table with one row per variable, but without doubling the number of columns.{p_end}

{pstd}
Since the wide table only has one line per variable, it is incompatible with the {opt wrap} option. An
exception is made if the user specifies the {opt wrapok} suboption, accepting that variable labels are truncated according to the parameters of the {opt wrap} options,
with the consequent loss of the second part of the label.{p_end}
{pstd}
Also {opt oneline} accepts the {opt wrapok} suboption, even when there is no main option. The
syntax in this case is simply {cmd:oneline(, wrapok)}.{p_end}

{pstd}
By default, {opt wide} includes all the statistics in the table. However,
it is possible to control which statistics to include by adding an optional {it:statlist}. If
{it:statlist} is specified, only the columns with the selected statistics will be included in the table.{p_end}
{pstd}
The statistics that can be included in {it:statlist} are the following:{p_end}
{pmore}- {opt mean}: mean, first line of columns (1) and (2) (basic syntax) or {cmd:mean} type columns (complex syntax){p_end}
{pmore}- {opt sd}: standard deviation, second line of columns (1) and (2) (basic syntax) or {cmd:mean} type columns (complex syntax){p_end}
{pmore}- {opt diff}: difference in means, first line of column (3) (basic syntax) or {cmd:diff} type columns (complex syntax){p_end}
{pmore}- {opt se}: standard error of the difference in means, second line of column (3) (basic syntax) or {cmd:diff} type columns (complex syntax){p_end}
{pmore}- {opt pval}: p-value of the difference in means, second line of column (3) (basic syntax) or {cmd:diff} type columns (complex syntax){p_end}
{pstd}
With the basic syntax, two more statistics can be displayed: the standardized difference and the number of observations used in the regression. These
are always included when {opt wide} is specified, if they have been computed. If
they are not meant to be in the table, they should not be added in the first place, by not using the {opt stddiff} or {opt observationscolumn} options.{p_end}
{pstd}
The order in which statistics appear in {it:statlist} does not matter, it will not change the order in the final table.{p_end}

{pstd}
By default, if one of the above is specified, {it:all} the statistics of that type will be included in the table. For
instance, if you specify {cmd:wide(mean sd diff)}, the table will not contain the standard errors, but it will include all means, all standars deviations and all differences in means.{p_end}
{pstd}
Actually, {it:statlist} allows an even more granular control of the columns to include in the table. The
user can specify exactly the column from which each statistic must be printed, by adding the column number. For
instance, typing {cmd:wide(mean1 sd1 sd2 diff)} will drop the column containing the mean of the second subsample (corresponding to {cmd:mean2}),
in addition to dropping the standard errors.{p_end}
{pstd}
The number to be added to the statistic is the column where the statistic would have been if the table had not been wide. That
is, it is the number of the parenthesis in the complex syntax. As
a result, the following three syntaxes are perfectly equivalent:{p_end}

{phang2}{cmd:. balancetable} ... {cmd:, wide}{p_end}
{phang2}{cmd:. balancetable} ... {cmd:, wide(mean sd diff se)}{p_end}
{phang2}{cmd:. balancetable} ... {cmd:, wide(mean1 sd1 mean2 sd2 mean3 sd3 diff4 se4)}{p_end}

{pstd}
The option {opt oneline} drops the second row for each variable of {depvarlist}, keeping only means and differences in means. Basically,
specifying {cmd:oneline} is exactly the same as writing {cmd:wide(mean diff)}.{p_end}
{pstd}
There is also the possibility of replacing the differences in means with the standard errors or the p-values, using the alternative options {opt se} or {opt pval}. In
this case, {cmd:oneline(se)} is the same as {cmd:wide(mean se)}.{p_end}

{pstd}
A short remark on wide/one-line tables: to specify {cmd:wide(pval)} or {cmd:oneline(pval)}, they must be combined with the {opt pvalues} option of the {cmd:balancetable} command.{p_end}

{pstd}
The option {opt wide} can be used to create very non-standard balance tables. For
instance, consider a table created with {cmd:oneline(se)}, showing means in columns (1) and (2), and standard errors in column (3). If,
for any reason, someone wanted to show standard deviations instead of means, this could be achieved by typing{p_end}

{phang2}{cmd:. balancetable} ... {cmd:, wide(sd se)}{p_end}

{marker remarks_placeholders}{...}
{dlgtab:Placeholders}

{pstd}
There are placehoders that can be used with the options {opt groups()} (in the label itself or in its suboptions), {opt prehead()}, {opt posthead()}, {opt prefoot()} and {opt postfoot()}. These
placeholders will be substituted with the appropriate numbers before printing the table.{p_end}

{pstd}
The available placeholders are the following:{p_end}
{pmore}- {cmd:@span}: number of columns spanned by the current group (available only for the {opt groups()} option){p_end}
{pmore}- {cmd:@col}: number of columns in with a statistic in the table (e.g. 3 with the basic syntax, or 6 with the basic syntax and the {opt wide} option){p_end}
{pmore}- {cmd:@tot}: total number of columns, including the leftmost column with variable names/labels (that is, @tot=@col+1){p_end}

{pstd}
As an example, a placeholder could be used in the {opt prehead()} to change the tabular environment and align to the right the columns of the main body of the table (while keeping the column with variable names aligned to the left). The
syntax would be the following:{p_end}

{phang2}{cmd:. balancetable treatment depvar_1 depvar_2 using "file.tex", prehead("\begin{tabular}{l*{@col}r}" "\hline")}

{pstd}
Or a placeholder could be used with the {opt groups()} option to create horizontal lines spanning columns (1)-(4), with a code like this:{p_end}

{phang2}{cmd:. balancetable treatment depvar_1 depvar_2 using "file.tex", observationscolumn groups("Title", end("\cmidrule{2-@tot}"))}

{pstd}This way, the table will correctly contain "\cmidrule{2-5}" (the option {opt observationscolumn} adds one column, so the table has 5 columns in total).{p_end}

{marker remarks_quotes}{...}
{dlgtab:Quotes}

{pstd}
It is almost always possible to use quotation marks inside titles and labels, if using the correct syntax.{p_end}

{pstd}
As a general rule, whenever an option in the table above mentions {it:string} as an argument, it is expected to receive only one string. For
this reason, any outer quotes are stripped away (that is, writing {cmd:leftc("text")} or {cmd:leftc(text)} is perfectly equivalent). In
order to add quotation marks to the text, it is necessary to use Stata's compound double quotes.{p_end}
{pstd}
Options behaving in this way are {opt leftctitle()}, {opt leftcobservations()}, {opt tabulary()} and all the suboptions of {opt groups()}
(specifically, {opt left()}, {opt prefix()}, {opt suffix()}, {opt begin()} and {opt end()}). Also
{opt cell()} and {opt sheet()} can be written with or without quotes, but {opt sheet()} does not accept compound double quotes.{p_end}

{pstd}
On the other hand, options that take {it:strlist} as an argument expect a list of strings. Each
one of these strings must be contained in quotes (unless it is a one-word string, making quotes unnecessary). Also
in this case it is possible to print text with quotation marks, by enclosing the corresponding string in compound double quotes.{p_end}
{pstd}
The main examples are {opt ctitles()} and the main argument of {opt groups()}. List of strings are accepted also by {opt prehead()},
{opt posthead()}, {opt prefoot()} and {opt postfoot()}; with these options, each string will be printed in a separate line of the .tex file.{p_end}

{pstd}
Check the {help balancetable##example_quotes:example} below to see how quotes can be used.{p_end}


{marker examples}{...}
{title:Examples}

{pstd}
These examples are not meant to show correct practices to build a balance table or the specifications to use. They
are just meant to show how the options of {cmd:balancetables} can be used and combined.{p_end}

{pstd}Basic syntax with column titles{p_end}
{phang2}{cmd:. balancetable subsample_dummy age sex income using "myfile.tex", ctitles("Control group" "Treatment group" "Difference")}{p_end}

{pstd}Basic syntax computing robust standard errors and showing the corresponding p-values, in a tabulary environment{p_end}
{phang2}{cmd:. balancetable choice_dummy var1 var2 var3 var4 using "path/myfile.tex", vce(robust) pval ctitles("First group" "Second group" "Difference") tabulary}{p_end}

{pstd}Subsample and weights, with prefoot{p_end}
{phang2}{cmd:. balancetable dummy var1 var2 var3 var4 using "myfile.tex" if baseline==1 [iweight=myweightvar], prefoot(" & This goes in column (1) & & This goes in column (3) \\")}{p_end}

{pstd}Standardized differences column and postfoot to add table notes{p_end}
{phang2}{cmd:. balancetable dummy var1 var2 var3 var4 using "My file.tex", stddiff ///}{p_end}
{pmore2}{cmd:postfoot("\hline" "\multicolumn{5}{l}{postfoot can be used to add table notes} \\" `"\multicolumn{5}{l}{"notes" may have quotes, requiring compound quotes in postfoot} \\"'' "\end{tabular}")}{p_end}

{pstd}Use of variable labels and label wrapping{p_end}
{phang2}{cmd:. balancetable treatment covariate1 covariate2 covariate3 using "filename.tex", varlabels wrap(15 indent)}{p_end}

{pstd}File path including directory and replace option{p_end}
{phang2}{cmd:. balancetable treatment_dummy age sex income using "mydirectory/somefile.xlsx", replace}{p_end}

{pstd}Complex syntax with 2 treatment arms and 1 control group{p_end}
{phang2}{cmd:. generate treat_A = (treat==1)}{p_end}
{phang2}{cmd:. generate treat_B = (treat==2)}{p_end}
{phang2}{cmd:. balancetable (mean if treat==0) (mean if treat==1) (mean if treat==2) (diff treat_A if treat!=2) (diff treat_B if treat!=1) (diff treat_A if treat!=0) $depvarlist using "myfile.xlsx", ///}{p_end}
{pmore2}{cmd:ctitles("Mean Control" "Mean treat. A" "Mean treat. B" "Treat. A vs Control" "Treat. B vs Control" "Treat. A vs Treat. B")}{p_end}
{phang2}{cmd:. drop treat_A treat_B}{p_end}

{marker example_ifexp}{...}
{pstd}Complex syntax (mimicking basic syntax) restricting to a subsample (if condition), without numbers row and with booktabs style{p_end}
{phang2}{cmd:. balancetable (mean if treat==0) (mean if treat==1) (diff treat) age sex income hh_members using "balance.tex" if followup1==1, nonumbers booktabs}{p_end}

{pstd}Clustered standard errors and factor variables as covariates (fixed effects){p_end}
{phang2}{cmd:. balancetable treatment age sex income years_education using "bt.xls", vce(cluster village) covariates(i.survey_wave i.village)}{p_end}

{pstd}One-line table, without parentheses, showing p-values and with custom confidence levels{p_end}
{phang2}{cmd:. balancetable treatment age sex income years_education using "bt.tex", pvalues oneline(pval) nopar starlevels(+ 0.1 ++ 0.05)}{p_end}

{pstd}Wide table without difference in means and with (starred) p-values{p_end}
{phang2}{cmd:. balancetable treat $depvarlist using "file.xlsx", wide(mean sd pval) pvalues staraux ///}{p_end}
{pmore2}{cmd:ctitles("Mean control" "SD control" "Mean treat" "SD treat" "P-val. control vs treat")}{p_end}

{pstd}Wide table showing differences and standard errors and then subsample means (not showing standard deviations), format with one decimal digit{p_end}
{phang2}{cmd:. balancetable (diff treat) (mean if treat==0) (mean if treat==1) $depvars using "Output file.tex"}, wide(mean diff se) format(%9.1f){p_end}

{pstd}Column groups with booktabs style and lines under group labels{p_end}
{phang2}{cmd:. balancetable dummy $depvarlist using "file.tex", booktabs ctitles("Control" "Treatment" "Control vs Treatment") ///}{p_end}
{pmore2}{cmd:groups("Means" "Difference", pattern(1 0 1) end("\cmidrule(lr){2-3} \cmidrule(lr){4-4}"))}{p_end}

{pstd}Table with statistics for full sample, subsample A, subsample B and difference, and with column groups{p_end}
{phang2}{cmd:. balancetable (mean) (mean if dummy==1) (mean if dummy==0) (diff dummy) dep1 dep2 dep3 dep4 using "bt.tex", ///}{p_end}
{pmore2}{cmd:groups("Means" "Difference", pattern(1 0 0 1) leftc("Stat.")) ///}{p_end}
{pmore2}{cmd:ctit("Full sample" "Subsample A" "Subsample B" "A vs B") lefctit("Sample")}{p_end}

{pstd}Minimally formatted table (no header, no footer, etc.){p_end}
{phang2}{cmd:. balancetable treat $variables using "myfile.xlsx", nohead nofoot nopar nostars noobs varnames}{p_end}

{marker example_displayformat}{...}
{pstd}Format changing by variables (comma and no decimal digits for monetary amounts and 2 decimal digits for dummy variables) and show p-values with 3 decimal digits{p_end}
{phang2}{cmd:. format $monetary_vars %10.0fc}{p_end}
{phang2}{cmd:. format $dummy_vars %4.2f}{p_end}
{phang2}{cmd:. balancetable treatment $monetary_var $dummy_vars using "anyfile.xlsx", displayformat format(%4.3f) pvalues}{p_end}

{pstd}Two separate tables comparing control vs treatment 1 and control vs treatment 2, one per worksheet, starting from cell B2{p_end}
{phang2}{cmd:. gen t1 = treat==1}{p_end}
{phang2}{cmd:. gen t2 = treat==2}{p_end}
{phang2}{cmd:. balancetable (mean if treat==0) (mean if treat==1) (diff t1 if treat!=2) $depvars using "Excel file.xlsx", replace sheet(First sheet) cell(B2) ///}{p_end}
{pmore2}{cmd:ctitles("Mean control" "Mean treatment 1" "Diff. control vs treat. 1")}{p_end}
{phang2}{cmd:. balancetable (mean if treat==0) (mean if treat==2) (diff t2 if treat!=1) $depvars using "Excel file.xlsx", modify sheet(Second sheet) cell(B2) ///}{p_end}
{pmore2}{cmd:ctitles("Mean control" "Mean treatment 2" "Diff. control vs treat. 2")}{p_end}

{marker example_quotes}{...}
{pstd}Compound double quotes{p_end}
{phang2}{cmd:. balancetable dummy $depvarlist using "file.xls", replace wide sheet("Sheet name") cell(B2) ///}{p_end}
{pmore2}{cmd:ctitles(First "Second column" `"Third "column" with quotes"' Fourth "Fifth column" "6th") leftctitle(No need for quotes here) ///}{p_end}
{pmore2}{cmd:groups("First group" `"Second "group""' Third, pattern(1 0 1 0 1 0) leftc("These quotes here are unnecessary"))}{p_end}


{title:Author}

{pstd}
Mattia Chiapello, chiapello.ma@gmail.com{p_end}

{pstd}
If you have been patient enough to read until here, congratulations!{p_end}
{pstd}
Hopefully, the explanations and examples in this help file were useful. Should
this not be the case, feel free to send me an email and I will try to help.{p_end}
{pstd}
You can also contact me if you find any errors or if there are any features that you would like to be added to {cmd:balancetable}: any feedback is more than welcome.{p_end}







