{marker validvalid}
{title:Valid Validation Rules}

{pstd}
There are 4 ways to create valid validation rules: give a bound, give a range or set
of allowable values (the {cmd:in} syntax), give the name of another
variable which is checked in the same way (the {cmd:like} syntax), or
to use a series of Stata commands (the {cmd:complex rule}
syntax). These are explained below.
{p_end}


{marker boundSyntax}{...}
{title:The {cmd:bound} syntax}

{p 8 16 2}
  {c -(}{opt >=} | {opt >} | {opt ==} | {opt <} | {opt <=}{c )-} {it:number}
{p_end}

{phang}
For variables which should be either larger or smaller than a number, one of the above
will suffice. Only one such bound can be given.
{p_end}

{marker boundExamples}{...}
{title:Examples of bounds}

{phang}
{cmd:>0}
{p_end}
{pmore2}
checks to see if the values are all positive.
{p_end}

{phang}
{cmd:<= 100}
{p_end}
{pmore2}
checks to see if the values are less than or equal to 100. It does not check anything else,
such as whether the values are also non-negative.
{p_end}

{phang}
{cmd:>= 0 & <= 100}
{p_end}
{pmore2}
results in an error. Only one bounding criterion can be specified.
If the numbers are restricted to a range, use the {cmd:in} syntax below.
{p_end}

{marker inSyntax}{...}
{title:The {cmd:in} syntax}

{p 8 16 2}
   {cmd:in} {c -(}{it:Stata numlist} | {it:set notation}{c )-}
{p_end}

{phang}{it:Stata numlist} is any type of list of numbers which Stata
can understand. See {help numlist} for the available syntaxes.
{p_end}

{phang}{it:set notation} allows using set notation to specify the
list. To specify a set of discrete numbers, enclose them in curly
braces ({cmd:{c -(}} and {cmd:{c )-}} and separate them with
commas. To specify ranges of numbers, use square braces {cmd:[} and
{cmd:]} to include the endpoints and and round braces {cmd:(} and
{cmd:)} to exclude endpoints. The missing value symbol {cmd:.} is used
for infinity.

{marker inExamples}
{title:Examples of {cmd:in}}

{phang}{cmd: in {c -(}3,4,5,6{c )-}}{p_end}
{pmore2}checks to see if the values are in given values. Note that
this would be identical any of the following Stata numlists{break}
{cmd:3 4 5 6}{break}
{cmd:3(1)6}{break}
{cmd:3 4 to 6}
{p_end}	

{phang}{cmd: in [1,5]}{p_end}
{pmore2}checks to see if the values are between 1 and 5 inclusive.{p_end}

{phang}{cmd: in [1,5)}{p_end}
{pmore2}checks to see if the values are from >=1 and <5.{p_end}

{phang}{cmd: in [0,.)}{p_end}
{pmore2}checks to see if the values are non-negative (i.e. 0 is a
valid value). This is the same as {cmd:>=0}, but looks more impressive.
{p_end}
	
{phang}{cmd: in (-.,0)}{p_end}
{pmore2}checks to see if the values are negative (i.e. 0 is not a valid value).
This is the same as {cmd:<0}.	
{p_end}

{marker likeSyntax}
{title:The {cmd:like} syntax}

{p 8 16 2}
{cmd:like} {varname}
{p_end}

{phang}{opt like} simply says that the rule given for {varname} should
be used for this variable, also. This allows having just one copy of a
rule for a series of similar variables, such as in a wide dataset,
making the checking more reliable and easier to alter.
{p_end}

{title:Example of {cmd:like}}

{phang}{cmd:like wow} will use the same validation rule as is used for
the variable {cmd:wow}.

{marker complexSyntax}
{title:The {cmd:complex} syntax}

{pstd}There really is no syntax for this, since there could be a
possible series of commands which are being run. It is best to edit
these commands by using the {help ckvaredit} dialog box and pushing
the {bf:Edit Complex Command} button. This will invoke the
{help docharedit} command, allowing the use of Stata's {help doedit}
do file editor. There are a couple of things to keep in mind when writing
a complex rule:
{p_end}

{pin}The variable for which the rule is being written is refered to as
{cmd:`self'} (note the open and close quotes!). This will ensure that
the rule works properly when called using a {cmd:like} syntax or if
the variable itself is renamed.
{p_end}

{pin}If the rule is being used as a validation rule, so that valid
values will generate non-zero results and invalid values will generate
zeros, the variable holding the results is called {cmd:`valid'} (note
the quotes, again!). If the rule will flag errors, so that non-zero
results are errors, and zeros correspond to valid values, use the
variable name {cmd:`error'} (quotes required!). Finally, if the routine is a scoring
routine, then the new variable must be called {cmd:`score'} (quotes!).

{marker complexExamples}
{title:Examples using the {cmd:complex} syntax}

{phang}{cmd: gen byte `valid' = `self'>=0}{p_end}
{pmore2}could be used to check if the values are non-negative (i.e. >= 0).
{p_end}

{phang}{cmd: gen byte `error' = `self'<0}{p_end}
{pmore2}could also be used to check if the values are non-negative (i.e. >= 0).
{p_end}

{phang}{cmd: gen byte `valid' = `self' >= someOtherVar}{p_end}
{pmore2}could be used to check if the values of the checked variable
are at least as big as that of another variable. Note that if the
second variable is renamed, the validation rule will break.
{p_end}

{phang}{cmd: gen byte `score' = `self'=="a" + .5*(`self'=="b")}{p_end}
{pmore2}would give 1 full point (mark) for the answer "a", and 1/2
point (mark) for the answer "b" when grading questionnaire or multiple-choice
exam.
{p_end}
