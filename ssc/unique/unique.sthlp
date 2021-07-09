{smcl}
{* *! version 1.2.0  June 27, 2017 @ 22:35:09}{...}
{cmd:help unique}
{hline}

{title:Title}

{phang}
{bf:unique} {hline 2} Unique values of a variable or group of variables


{title:Syntax}

{p 8 17 2}
{cmd:unique} {varlist}
{ifin}
[{cmd:,}
{opth by(varname)}
{opth gen:erate(newvar)}
{opt d:etail}]


{title:Description}

{p 4 4 2}
{cmd:unique} reports the number of unique values for the {it:varlist}. With a {bf:by} it does the same, but also creates a new variable ({bf:_Unique} by default but can be named in the {bf:generate} option). This new variable contains the number of unique values of the {it:varlist} for each level of the {bf:by} variable. The new variable is coded missing except for the first record in each group defined by the levels of the {bf:by} variable.

{p 4 4 2}
The command is useful for exploring data where the records refer to
more than one level, for example longitudinal data where each record
refers to a visit by a subject.

{title:Options}

{phang}
{opth by(varname)} counts unique values within levels of {it:varname} and stores them in a new variable named {bf:_Unique}.

{phang}
{opth generate(varname)} supplies an alternative name for the new variable created by {bf:by}.

{phang}
{opt detail} request summary statistics on the number of records which are
present for unique values of the varlist. If you have longitudinal data
for instance, this option reports the mean, median, minimum and maximum number of visits per subject.

{title:Examples}

{p 4 4 2}
Consider a longitudinal data set in which each record corresponds to a
visit by a subject. The subject identity is in the variable {it:id}, and
the visit is identified by the variable {it:visit}, within {it:id}. Then

{p 4 8 2}{cmd:. unique id}

{p 4 4 2}
reports the number of subjects

{p 4 8 2}{cmd:. unique id visit}

{p 4 4 2}
reports a number which will be the same as the number of records unless
there are duplicate records with the same id and visit number.

{p 4 8 2}{cmd:. unique visit, by(id) gen(num_visits)}

{p 4 4 2}
creates a new variable {it:num_visits} at the subject level which contains the number of visits for that subject. Alternatively

{p 4 8 2}{cmd:. unique id, detail}

{p 4 4 2}
reports summary statistics for the number of visits per subject.


{title:Authors}

{p 4 4 2}
Michael Hills, retired{break}
Tony Brady, Sealed Envelope Ltd, UK (tony@sealedenvelope.com)

{title:Also see}

{p 4 17 2}On-line:  help for {help count}, {help egen (tag)}
