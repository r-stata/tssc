{smcl}
{* *! version 1.3.74  29Apr2018}{...}
{cmd:help wgtcellcollapse} {right: ({browse "http://staskolenikov.net/stata/":Stas Kolenikov's webpage})}
{hline}

{title:Title}

{p2colset 5 12 14 2}{...}
{p2col :{hi:wgtcellcollapse} {hline 2}}Collapsing weighting cells{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 11 2}
{cmd:wgtcellcollapse} {it:task}
{ifin}
[{cmd:,} {it:options}]

{pstd}where {it:task} is one of:{p_end}

{phang2}
{help wgtcellcollapse##define:define} define collapsing rules explicitly

{phang2}
{help wgtcellcollapse##sequence:sequence} create collapsing rules for a sequence of categories

{phang2}
{help wgtcellcollapse##report:report} list the currently defined collapsing rules

{phang2}
{help wgtcellcollapse##candidate:candidate} find rules applicable to a given category

{phang2}
{help wgtcellcollapse##collapse:collapse} perform cell collapsing

{phang2}
{help wgtcellcollapse##label:label} label collapsed cells using the original labels after {cmd:wgtcellcollapse collapse}


{title:Description}

{pstd}{cmd:wgtcellcollapse} collapses cells defined by categorical variable(s),
i.e., performs a series of {help recode} operations combining cells with small counts
to ensure that a minimal cell size is achieved in every resulting cell.
Typically, the need for this task arises with nonreponse or calibration adjustments
to produce {help survey} {help weight:weights}.

{pstd}As the syntax of the individual subcommands varies wildly, the individual syntax and options
are spelled out under the corresponding tasks, and mini-examples of the code are provided, as well.


{marker define}{title:Syntax of {cmd:wgtcellcollapse define}}

{p 8 11 2}
{cmd:wgtcellcollapse define, }{cmdab:var:iables(}{help varlist}{cmd:)} [{it:options}]
{p_end}

{pstd}
{cmd:wgtcellcollapse define} defines individual collapsing rules. It is typically used
to handle edge cases that automated rules
(defined by {help wgtcellcollapse##sequence:wgtcellcollapse sequence})
have difficulties identifying.

{dlgtab:define task options}

{phang}{cmdab:var:iables(}{help varlist}{cmd:)} (required) specifies the list of variables for which the collapsing rule can be used{p_end}

{phang}{cmd:from({help numlist})} specifies the list of source categories that can be collapsed according to this rule{p_end}

{phang}{cmd:to(#)} specifies the numeric value of the new, collapsed category{p_end}

{phang}{cmd:label({it:text})} provides the {help label:value label} to be attached to the new, collapsed category{p_end}

{phang}{cmd:max(#)} overrides the automatically determined max value of the collapsed variable{p_end}

{phang}{cmd:clear} clears all the rules currently defined{p_end}


{pstd}Individual collapsing rules can be defined as follows.

{phang2}{cmd:. clear}{p_end}
{phang2}{cmd:. set obs 4}{p_end}
{phang2}{cmd:. gen byte x = _n}{p_end}
{phang2}{cmd:. label define x_lbl 1 "One" 2 "Two" 3 "Three" 4 "Four"}{p_end}
{phang2}{cmd:. label values x x_lbl}{p_end}
{phang2}{cmd:. wgtcellcollapse define, var(x) from(1 2 3) to(123)}{p_end}
{phang2}{cmd:. wgtcellcollapse report, var(x)}{p_end}

{pmore2}{txt}Rule ({res}1{txt}): collapse together{p_end}
{pmore2}{res}  x{txt} == {res}1{txt} ({res}One{txt}){p_end}
{pmore2}{res}  x{txt} == {res}2{txt} ({res}Two{txt}){p_end}
{pmore2}{res}  x{txt} == {res}3{txt} ({res}Three{txt}){p_end}
{pmore2}{txt}  into {res}x{txt} == {res}123{txt} ({res}123{txt}){p_end}
{pmore2}{err}  WARNING: unlabeled value x == 123{txt}{p_end}

{pstd}The user would need to develop convenient mnemonic rules for the numeric values
of the collapsed categories that make it easy to understand what the underlying
source cells are. In the example above, the value of the collapsed cell, 123,
reads like "1, 2 and 3", making it easier to identify that the applicable rule
had to do with collapsing cells 1, 2 and 3. Some other mnemonic, like 10203,
padding the individual categories with zeroes, or 10003, indicating a stretch
of all categories between 1 and 3, might also have made sense.
If the underlying collapsing rules are more complex, and/or the source categories
have more digits, the mnemonic values of the collapsed categories may have to
be simplified. See below how {help wgtcellcollapse##sequence:wgtcellcollapse sequence}
deals with the issue.


{marker sequence}{title:Syntax of {cmd:wgtcellcollapse sequence}}

{p 8 11 2}
{cmd:wgtcellcollapse sequence,} {cmdab:var:iables(}{help varlist}{cmd:) from(}{it:numlist}{cmd:) depth(#)}
{p_end}

{pstd}{cmd:wgtcellcollapse sequence} automatically creates rules that allow collapsing subsets
of a series of categories of the source variable(s).

{dlgtab:sequence task options}

{phang}{cmdab:var:iables(}{help varlist}{cmd:)} specifies the list of variables for which the collapsing rule can be used{p_end}

{phang}{cmd:from({it:numlist})} specifies the sequence of values from which the plausible subsequences can be constructed{p_end}

{phang}{cmd:depth(#)} specifies the maximum number of the source categories that can be collapsed (length of subsequence to be collapsed){p_end}


{pstd}All three options are required.

{pstd}Moderate length sequences of collapsing categories can be defined as follows.{p_end}

{phang2}{cmd:. clear}{p_end}
{phang2}{cmd:. set obs 4}{p_end}
{phang2}{cmd:. gen byte x = _n}{p_end}
{phang2}{cmd:. label define x_lbl 1 "One" 2 "Two" 3 "Three" 4 "Four"}{p_end}
{phang2}{cmd:. label values x x_lbl}{p_end}
{phang2}{cmd:. wgtcellcollapse sequence, var(x) from(1 2 3 4) depth(3)}{p_end}
{phang2}{cmd:. wgtcellcollapse report, var(x)}{p_end}

{pmore2}{txt}Rule ({res}1{txt}): collapse together{p_end}
{pmore2}{res}{bind:  }x{txt} == {res}1{txt} ({res}One{txt}){p_end}
{pmore2}{res}{bind:  }x{txt} == {res}2{txt} ({res}Two{txt}){p_end}
{pmore2}into {res}x{txt} == {res}212{txt} ({res}One to Two{txt}){p_end}
{pmore2}{txt}Rule ({res}2{txt}): collapse together{p_end}
{pmore2}{res}{bind:  }x{txt} == {res}2{txt} ({res}Two{txt}){p_end}
{pmore2}{res}{bind:  }x{txt} == {res}3{txt} ({res}Three{txt}){p_end}
{pmore2}{txt}{bind:  }into {res}x{txt} == {res}223{txt} ({res}Two to Three{txt}){p_end}
{pmore2}{txt}...{p_end}
{pmore2}{txt}Rule ({res}8{txt}): collapse together{p_end}
{pmore2}{res}{bind:  }x{txt} == {res}2{txt} ({res}Two{txt}){p_end}
{pmore2}{res}{bind:  }x{txt} == {res}234{txt} ({res}Three to Four{txt}){p_end}
{pmore2}{txt}{bind:  }into {res}x{txt} == {res}324{txt} ({res}Two to Four{txt}){p_end}
{pmore2}{txt}Rule ({res}9{txt}): collapse together{p_end}
{pmore2}{res}{bind:  }x{txt} == {res}4{txt} ({res}Four{txt}){p_end}
{pmore2}{res}{bind:  }x{txt} == {res}223{txt} ({res}Two to Three{txt}){p_end}
{pmore2}{txt}{bind:  }into {res}x{txt} == {res}324{txt} ({res}Two to Four{txt}){p_end}

{pstd}
When creating sequential collapses, {cmd:wgtcellcollapse sequence} uses the following mnemonics
in defining the new categories:

{phang}* The first digit or two contain the length of the collapsed subsequence (up to {cmd:depth(#)}).{p_end}
{phang}* Then comes the starting value of the category in the subsequence (padded by zeroes as needed).{p_end}
{phang}* Then comes the ending value of the category in the subsequence (padded by zeroes as needed).{p_end}

{pstd}In the example above, rules 7 through 9 lead to collapsing into the new category 324. This
should be interpreted as ``{it:the subsequence of length 3 that starts with category 2 and ends with category 4}''.
A numeric value of the collapsed category that reads like 50412 means
``{it:the subsequence of length 5 that starts with category 4 and ends with category 12}'',
where {cmd:wgtcellcollapse sequence} padded the value of 4 with an additional zero,
so that the length of resulting collapsed category value is always (# of digits of the sequence length) +
twice (# of digits of the greatest source category).

{pstd}Note that {cmd:wgtcellcollapse sequence} automatically created labels for the collapsed cells.

{pstd}
The order of the categories in the {cmd:from()} option matters: {cmd:wgtcellcollapse sequence} respects
that order, and does not sort the values. If the categories are supplied
in the order 2, 4, 1 and 3, then {cmd:wgtcellcollapse sequence} would collapse 2 with 4, 4 with 1,
and 1 with 3:

{phang2}{cmd:. wgtcellcollapse define, var(x) clear}{p_end}
{phang2}{cmd:. wgtcellcollapse sequence, var(x) from(2 4 1 3) depth(2)}{p_end}
{phang2}{cmd:. wgtcellcollapse report, var(x)}{p_end}

{pmore2}{txt}Rule ({res}1{txt}): collapse together{p_end}
{pmore2}{bind:  }{res}x{txt} == {res}2{txt} ({res}Two{txt}){p_end}
{pmore2}{res}{bind:  }x{txt} == {res}4{txt} ({res}Four{txt}){p_end}
{pmore2}{txt}{bind:  }into {res}x{txt} == {res}224{txt} ({res}Two to Four{txt}){p_end}
{pmore2}{txt}Rule ({res}2{txt}): collapse together{p_end}
{pmore2}{res}{bind:  }x{txt} == {res}4{txt} ({res}Four{txt}){p_end}
{pmore2}{res}{bind:  }x{txt} == {res}1{txt} ({res}One{txt}){p_end}
{pmore2}{txt}{bind:  }into {res}x{txt} == {res}241{txt} ({res}Four to One{txt}){p_end}
{pmore2}{txt}Rule ({res}3{txt}): collapse together{p_end}
{pmore2}{res}{bind:  }x{txt} == {res}1{txt} ({res}One{txt}){p_end}
{pmore2}{res}{bind:  }x{txt} == {res}3{txt} ({res}Three{txt}){p_end}
{pmore2}{txt}{bind:  }into {res}x{txt} == {res}213{txt} ({res}One to Three{txt}){p_end}


{marker report}{title:Syntax of {cmd:wgtcellcollapse report}}

{p 8 11 2}
{cmd:wgtcellcollapse report,} {cmdab:var:iables(#)} [ {cmd:break} ]

{pstd}
{cmd:wgtcellcollapse report} reports the existing rules, if any are defined for the variable(s) of interest.

{dlgtab:report task options}

{phang}{cmdab:var:iables(}{help varlist}{cmd:)} (required) specifies the list of variables for which the collapsing rules are to be reported{p_end}

{phang}{cmd:break} makes {cmd:wgtcellcollapse} exit with error when technical inconsistencies are encountered{p_end}


{pstd}
The intent of the {cmd:break} option of {cmd:wgtcellcollapse report} is to act as a quality control
measure and abort the execution
when technical deficiencies in the rules or in the data are encountered:

{phang2}{cmd:. clear}{p_end}
{phang2}{cmd:. set obs 4}{p_end}
{phang2}{cmd:. gen byte x = _n}{p_end}
{phang2}{cmd:. label define x_lbl 1 "One" 2 "Two" 3 "Three" 4 "Four"}{p_end}
{phang2}{cmd:. label values x x_lbl}{p_end}
{phang2}{cmd:. wgtcellcollapse define, var(x) from(1 2 3) to(123)}{p_end}
{phang2}{cmd:. wgtcellcollapse report, var(x) break}{p_end}

{pmore2}{txt}Rule ({res}1{txt}): collapse together{p_end}
{pmore2}{res}{bind:  }x{txt} == {res}1{txt} ({res}One{txt}){p_end}
{pmore2}{res}{bind:  }x{txt} == {res}2{txt} ({res}Two{txt}){p_end}
{pmore2}{res}{bind:  }x{txt} == {res}3{txt} ({res}Three{txt}){p_end}
{pmore2}{txt}{bind:  }into {res}x{txt} == {res}123{txt} ({res}123{txt}){p_end}
{pmore2}{err}{bind:  }ERROR: unlabeled value x == 123{p_end}
{pmore2}{err}{bind:  }assertion is false{p_end}
{pmore2}{err}{bind:  }r(9);{txt}{p_end}

{pstd}In this case,
the label of the new category 123 was not defined, and this is considered a serious
enough deficiency to stop.


{marker candidate}{title:Syntax of {cmd:wgtcellcollapse candidate}}

{p 8 11 2}{cmd: wgtcellcollapse candidate, }{cmdab:var:iable(}{it:varname}{cmd:)} {cmdab:cat:egory(#)} [{cmdab:max:category(#)}]

{pstd}
{cmd: wgtcellcollapse candidate} finds the rules that can be used
to collapse a given category of the source variable.

{dlgtab:candidate task options}

{phang}{cmdab:var:iable(}{it:varname}{cmd:)} (required) the variable to be collapsed{p_end}

{phang}{cmdab:cat:egory(#)} (required) the category to be collapsed{p_end}

{phang}{cmdab:max:category(#)} the maximum value of the categories in the candidate rules to be returned{p_end}


{pstd}
The rules found are quietly returned through the mechanism of {cmd:sreturn},
see {help return}, as they are intended to stay in memory sufficiently long for
{cmd:wgtcellcollapse collapse} to evaluate each rule.

{phang2}{cmd: . wgtcellcollapse candidate, var(x) cat(2)}{p_end}
{phang2}{cmd: . sreturn list}{p_end}
{phang2}{txt}{bind:     }s(goodrule) : "{res}1 2 4 7 8{txt}"{p_end}
{phang2}{txt}{bind:        }s(rule8) : "{res}2:234=324{txt}"{p_end}
{phang2}{txt}{bind:        }s(rule7) : "{res}2:3:4=324{txt}"{p_end}
{phang2}{txt}{bind:        }s(rule4) : "{res}1:2:3=313{txt}"{p_end}
{phang2}{txt}{bind:        }s(rule2) : "{res}2:3=223{txt}"{p_end}
{phang2}{txt}{bind:        }s(rule1) : "{res}1:2=212{txt}"{p_end}
{phang2}{txt}{bind:          }s(cat) : "{res}2{txt}"{p_end}
{phang2}{txt}{bind:            }s(x) : "{res}x{txt}"{p_end}

{pstd}If we don't want to use the cells that have already been collapsed,
like {res}234{txt} in the example above, the collapsing rules can be restricted
with {cmd:max(#)} option (assuming that mnemonics for collapsed cells provide
longer labels for collapsed cells, as is done by {cmd:wgtcellcollapse sequence}):

{phang2}{cmd: . wgtcellcollapse candidate, var(x) cat(2) max(9)}{p_end}
{phang2}{cmd: . sreturn list}{p_end}
{phang2}{txt}{bind:     }s(goodrule) : "{res}1 2 4 7{txt}"{p_end}
{phang2}{txt}{bind:        }s(rule7) : "{res}2:3:4=324{txt}"{p_end}
{phang2}{txt}{bind:        }s(rule4) : "{res}1:2:3=313{txt}"{p_end}
{phang2}{txt}{bind:        }s(rule2) : "{res}2:3=223{txt}"{p_end}
{phang2}{txt}{bind:        }s(rule1) : "{res}1:2=212{txt}"{p_end}
{phang2}{txt}{bind:          }s(cat) : "{res}2{txt}"{p_end}
{phang2}{txt}{bind:            }s(x) : "{res}x{txt}"{p_end}

{pstd}
Requests for nonexisting categories are not considered errors, but simply produce empty lists
of ``good rules''.

{phang2}{cmd: . . wgtcellcollapse candidate, var(x) cat(55)}{p_end}
{phang2}{cmd: . sreturn list}{p_end}
{phang2}{txt}{bind:          }s(cat) : "{res}55{txt}"{p_end}
{phang2}{txt}{bind:            }s(x) : "{res}x{txt}"{p_end}


{marker collapse}{title:Syntax of {cmd:wgtcellcollapse collapse}}

{p 8 11 2}{cmd:wgtcellcollapse collapse} {ifin}{cmd:,}
{cmdab:var:iables(}{help varlist}{cmd:)}
{cmdab:min:cellsize(#)}
{cmdab:sav:ing(}{it:dofile_name}{cmd:)}
[ {it:options} ]{p_end}

{pstd}{cmd:wgtcellcollapse collapse} provides the central target functionality of the program,
i.e., processing the sample data to collapse weighting cells.

{dlgtab:Required collapse task options}

{phang}
{cmdab:var:iables(}{help varlist}{cmd:)} provides the list of variables whose cells are to be collapsed.
When more than one variable is specified, {cmd:wgtcellcollapse collapse} proceeds from right to left,
i.e., first attempts to collapse the rightmost variable.

{phang}
{cmdab:min:cellsize(#)} specifies the minimum cell size for the collapsed cells. For most weighting
purposes, values of 30 to 50 can be recommended.

{phang}
{cmdab:sav:ing(}{it:dofile_name}{cmd:)} specifies the name of the do-file that will contain the cell collapsing code.

{dlgtab:do-file management collapse task options}

{phang}
{cmd:replace} overwrites the do-file if one exists.

{phang}
{cmd:append} appends the code to the existing do-file.

{phang}
{cmd:run} specifies that the do-file created is run upon completion. This option is typically specified with most runs.

{dlgtab:Other collapse task options}

{phang}
{cmdab:gen:erate(}{help varlist:varname}{cmd:)} specifies the name of the collapsed variable to be created.

{phang}
{cmd:feed(}{help varlist:varname}{cmd:)} provides the name of an already existing collapsed variable.

{phang}
{cmd:strict} modifies the behavior of {cmd:wgtcellcollapse collapse} so that only
collapsing rules for which all participating categories have nonzero counts are utilized.

{phang}
{cmd:sort({help varlist})} sorts the data set before proceeding to collapse the cell.
The default sort order is in terms of the values of the collapsed variable.
A different sort order may produce a different set of collapsed cell when
cells are tied on size.

{phang}
{cmd:maxpass(#)} specifies the maximum number of passes through the data set. The default value is 10000.

{phang}
{cmdab:maxcat:egory(#)} is the maximum category value of the variable being collapsed.
It is passed to internal calls to {cmd:wgtcellcollapse candidate, ... maxcategory()}, see
{help wgtcellcollapse##candidate:wgtcellcollapse candidate}.

{phang}
{cmdab:zer:oes(}{it:numlist}{cmd:)} provides a list of the categories of the collapsed
variable that may have zero counts in the data.

{phang}
{cmd:greedy} modifies the behavior {cmd:wgtcellcollapse collapse} to prefer the rules
that collapse the maximum number of categories.


{pstd}
The primary intent of {cmd:wgtcellcollapse collapse} is to create the code that can be
utilized for {it:both} the survey data file and the population targets data file, provided that
the variables have identical names and categories in these two files.
Thus it does not only manipulate the data in the memory
and collapses the cells, but also produces the do-file code that can be recycled.
To that effect, when a do-file is created with the {cmd:replace} and {cmd:saving()} options,
the user needs to specify {cmd:generate()} option to provide the name of the collapsed variable;
and when the said do-file is appended with the the {cmd:append} and {cmd:saving()} options,
the name of that variable is provided with the {cmd:feed()} option.{p_end}

{pstd}
The algorithm {cmd:wgtcellcollapse collapse} uses to identify the cells to be collapsed is
a variation of greedy search.
It first identifies the cells with the lowest (positive) counts; finds the candidate rules
for the variable(s) to be collapsed; evaluates the counts of the collapsed cells across all
these candidate rules; and uses the rule that produces the smallest size of the
collapsed cell across all applicable rules. So when it finds several rules that are applicable
to the cell being currently processed that has a size of 5, and the candidate rules produce cells
of sizes 7, 10 and 15, {cmd:wgtcellcollapse collapse} will use the rule that produces the cell
of size 7. The algorithm runs until all cells have sizes of at least
{cmd:mincellsize(#)} or until {cmd:maxpass(#)} passes through the data are executed.
It is a pretty dumb algorithm, actually, and it fails quite often.
For that reason, a number of hooks are provided to modify its behavior.
Section \ref{subsec:example} will demonstrate the typical failures, and the ways to overcome them.

{pstd}
{it:Hint 1}. Since {cmd:wgtcellcollapse collapse} works with the sample data,
it will not be able to identify categories that are not observed in the sample (e.g., rare categories),
but may be present in the population. This will lead to errors at the raking stage,
when the control total matrices have more categories than the data, forcing {help ipfraking} to stop
with errors.
To help with that, the option {cmd:zeroes()} allows the user to pass the categories
of the variables that are known to exist in the population but not in the sample. That
way, {cmd:wgtcellcollapse collapse} can produce the collapsing code for those categories;
it has zero effect in the sample, but touches upon these categories in the population.

{pstd}
{it:Hint 2}. The behavior of {cmd:wgtcellcollapse collapse, zeroes()} may still not be
satisfactory. As it evaluates the sample sizes of the collapsed cells across a number
of candidate rules that involve zero cells, it may pick up a rule with the fewest categories involved,
and that rule may as well leave some other candidate rules with zero cells untouched.
This may create problems when {cmd:wgtcellcollapse collapse} returns to those untouched cells,
and looks for the existing cells to collapse them with, creating collapsing rules with breaks
in the sequences. To improve upon that behavior, option {cmd:greedy} makes
{cmd:wgtcellcollapse collapse} look for a rule that has the {it:greatest} number of elements, thus collapsing
as many categories with zero counts in one swipe as it can.

{pstd}
{it:Hint 3}. Other than for dealing with zero cells, the option {cmd:strict} should be specified
most of the times. It makes sure that the each element in the candidate rules correspond to the actual data
and has a current non-zero count in the sample.

{pstd}
{it:Hint 4}. Sometimes, you see some combinations in the data that seem like a nobrainer
to collapse. Well, they are nobrainers to you, but {cmd:wgtcellcollapse collapse} is not that smart.
If you want to guarantee some specific combination of cells to be collapsed by {cmd:wgtcellcollapse collapse},
your best bet may be to explicitly identify them with the {cmd:if} conditions, and specify some
ridiculously large cell size like {cmd:mincellsize(10000)} so that {cmd:wgtcellcollapse collapse} makes every possible
effort to collapse those cells. It will exit with a complaint that this size could not be achieved,
but hopefully the cells will be collapsed as needed.

{pstd}
{it:Hint 5}. The standard use case of {cmd:wgtcellcollapse} involves using several variables
and creating interactions of two or more categorical variables, where one of the variables is highly detailed
(say dozens of categories in population) while the other is less detailed (say a handful of categories in the population).
If only one variable needs to be collapsed, you would need to provide an extra dummy variable to
{cmd:wgtcellcollapse collapse} as a placeholder.


{pstd}Continuing with the example with four categories, this minimal example collapses
two smallest cells:

{phang2}{cmd: . expand x}{p_end}
{phang2}{cmd: . gen byte _one = 1}{p_end}
{phang2}{cmd: . label variable _one "Dummy"}{p_end}
{phang2}{cmd: . wgtcellcollapse define, var(_one) from(1 2) to(12) label("One, two")}{p_end}
{phang2}{cmd: . wgtcellcollapse collapse, var(_one x) min(3) gen(cx) saving(collapse_x.do) replace run}{p_end}

{phang2}{txt}Pass {res}0{txt} through the data...{p_end}
{phang2}{bind:  }smallest count = {res}1{txt} in the cell         {res}1001{p_end}
{phang2}{bind:  }Invoking rule {res}1:2=212{p_end}
{phang2}{bind:  }{res}replace cx = 1212 if inlist(cx, 1001, 1002){p_end}
{phang2}{txt}Pass {res}1{txt} through the data...{p_end}
{phang2}{bind:  }smallest count = {res}3{txt} in the cell         {res}1003{p_end}
{phang2}{bind:  }Done collapsing! Exiting...

{phang2}{cmd:. *** Automatically created on 13 Dec 2017 at 22:45:37}{p_end}
{phang2}{cmd:. * Source syntax: wgtcellcollapse collapse , var(_one x) min(3) gen(cx) saving(collapse_x.do) replace}{p_end}
{phang2}{cmd:. generate long cx = (_one)*1000 + x}{p_end}
{phang2}{cmd:. label variable cx "Long ID of the interaction"}{p_end}
{phang2}{cmd:. format cx %12.0f}{p_end}
{phang2}{cmd:. char cx[sources] _one x}{p_end}
{phang2}{cmd:. char cx[max] 12324}{p_end}
{phang2}{cmd:. replace cx = 1212 if inlist(cx, 1001, 1002)}{p_end}
{phang2}{res}(3 real changes made){txt}{p_end}
{phang2}{cmd:. char cx[rule1] 1001:1002=1212}{p_end}
{phang2}{cmd:. char cx[nrules] 1}{p_end}
{phang2}{cmd:.}{p_end}
{phang2}{res}end of do-file{txt}{p_end}


{pstd}Here, {cmd:wgtcellcollapse collapse}:{p_end}
{phang2}1. figured out that the greatest value of {res}x{txt} it can reasonably expect, based on all of the collapsing
rules that {res}x{txt} is endowed with, is {res}324{txt}, so the interaction in question should leave space for three decimal
places for the collapsed values of {res}x{txt};{p_end}
{phang2}2. created an interaction of the source variable {res}x{txt} with the dummy variable {res}_one{txt};{p_end}
{phang2}3. provided some relevant metadata for the interaction variable {res}cx{txt};{p_end}
{phang2}4. identified the cell with the smallest size, {res}cx == 1001{txt};{p_end}
{phang2}5. (no output) looked at all the available rules to collapse {res}x==1{txt};{p_end}
{phang2}6. among these rules, found the one with the smallest resulting count (collapse {res}x==1{txt} with {res}x==2{txt});{p_end}
{phang2}7. recalibrated the intermediate category counts;{p_end}
{phang2}8. compared the recalibrated counts with the target given by {cmd:min(3)} option;{p_end}
{phang2}9. concluded that no further collapsing is necessary; and{p_end}
{phang2}10. ran the resulting do-file that was produced.{p_end}


{marker label}{title:Syntax of {cmd:wgtcellcollapse label}}

{p 8 11 2}
{cmd:wgtcellcollapse label, }{cmdab:var:iable(}{help varlist:varname}{cmd:)},
[ {cmd:verbose force} ]
{p_end}

{cmd:wgtcellcollapse label} generates labels for the collapsed data.

{dlgtab:label task options}

{phang}
{cmdab:var:iable(}{help varlist:varname}{cmd:)} (required) is the collapsed variable to be labeled.

{phang}
{cmd:verbose} outputs the labeling results. There may be a lot of output.

{phang}
{cmd:force} instructs {cmd:wgtcellcollapse label} to only use categories present in the data.


{pstd}
Utilizing the multiple language functionality of {help label_language},
{cmd:wgtcellcollapse label} automatically creates labels based on the collapsed categories.



{phang2}{cmd:. wgtcellcollapse label, var(cx)}{p_end}
{phang2}{err}WARNING: source variable _one is not labeled{txt}{p_end}
{phang2}{txt}(language {res}default{txt} renamed {res}unlabeled_ccells{txt}){p_end}
{phang2}{txt}(language {res}numbered_ccells{txt} now current language){p_end}
{phang2}{txt}(language {res}texted_ccells{txt} now current language){p_end}

{phang2}{txt}To attach the numeric labels (of the kind "{res}cx==1003{txt}"), type:{p_end}
{phang2}{bind:  }label language numbered_ccells{p_end}
{phang2}{txt}To attach the text labels (of the kind "{res}cx==1; Three{txt}"), type:{p_end}
{phang2}{bind:  }label language texted_ccells{p_end}
{phang2}{txt}The original state, which is also the current state, is:{p_end}
{phang2}{bind:  }label language unlabeled_ccells{p_end}

{phang2}{cmd:. label language numbered_ccells}{p_end}

{phang2}{cmd:. tab cx}{p_end}

{phang2}{res}Interactions of {c |}{p_end}
{phang2}{res}{bind:   }_one x, with {c |}{p_end}
{phang2}{res}some collapsing {c |}{bind:      }Freq.{bind:     }Percent{bind:        }Cum.{p_end}
{phang2}{dup 16:{c -}}{c +}{dup 35:{c -}}{p_end}
{phang2}{res}{bind:  }_one==1, x==3 {c |}{bind:          }3{bind:       }30.00{bind:       }30.00{p_end}
{phang2}{res}{bind:  }_one==1, x==4 {c |}{bind:          }4{bind:       }40.00{bind:       }70.00{p_end}
{phang2}{res}_one==1, x==212 {c |}{bind:          }3{bind:       }30.00{bind:      }100.00{p_end}
{phang2}{dup 16:{c -}}{c +}{dup 35:{c -}}{p_end}
{phang2}{res}{bind:          }Total {c |}{bind:         }10{bind:      }100.00{p_end}

{phang2}{cmd:. label language texted_ccells}{p_end}

{phang2}{cmd:. tab cx}{p_end}

{phang2}{res}Interactions of {c |}{p_end}
{phang2}{res}{bind:   }_one x, with {c |}{p_end}
{phang2}{res}some collapsing {c |}{bind:      }Freq.{bind:     }Percent{bind:        }Cum.{p_end}
{phang2}{dup 16:{c -}}{c +}{dup 35:{c -}}{p_end}
{phang2}{res}{bind:       }1; Three {c |}{bind:          }3{bind:       }30.00{bind:       }30.00{p_end}
{phang2}{res}{bind:        }1; Four {c |}{bind:          }4{bind:       }40.00{bind:       }70.00{p_end}
{phang2}{res}{bind:  }1; One to Two {c |}{bind:          }3{bind:       }30.00{bind:      }100.00{p_end}
{phang2}{dup 16:{c -}}{c +}{dup 35:{c -}}{p_end}
{phang2}{res}{bind:          }Total {c |}{bind:         }10{bind:      }100.00{p_end}

{phang2}{cmd:. label language unlabeled_ccells}{p_end}

{phang2}{cmd:. tab cx}{p_end}

{phang2}{res}Interactions of {c |}{p_end}
{phang2}{res}{bind:   }_one x, with {c |}{p_end}
{phang2}{res}some collapsing {c |}{bind:      }Freq.{bind:     }Percent{bind:        }Cum.{p_end}
{phang2}{dup 16:{c -}}{c +}{dup 35:{c -}}{p_end}
{phang2}{res}{bind:           }1003 {c |}{bind:          }3{bind:       }30.00{bind:       }30.00{p_end}
{phang2}{res}{bind:           }1004 {c |}{bind:          }4{bind:       }40.00{bind:       }70.00{p_end}
{phang2}{res}{bind:           }1212 {c |}{bind:          }3{bind:       }30.00{bind:      }100.00{p_end}
{phang2}{dup 16:{c -}}{c +}{dup 35:{c -}}{p_end}
{phang2}{res}{bind:          }Total {c |}{bind:         }10{bind:      }100.00{p_end}


{title:References}

{phang}Kolenikov, S. (2014). Calibrating survey data using iterative proportional fitting.
{it:The Stata Journal}, {bf:14} (1), pp. 22--59.
{browse "https://ideas.repec.org/a/tsj/stataj/v14y2014i1p22-59.html":Stata Journal website}

{phang}Kolenikov, S. (2018). Updates to the ipfraking ecosystem.
{browse "http://staskolenikov.net/stata/ipfraking-v66.pdf":Author's website}


{title:Author}

{pstd}Stanislav Kolenikov{p_end}
{pstd}Senior Scientist{p_end}
{pstd}Abt Associates{p_end}
{pstd}skolenik at gmail dot com{p_end}


{title:Also see}

{psee}{help ipfraking} -- weight calibration using iterative proportional fitting
