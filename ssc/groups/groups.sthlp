{smcl}
{* 28jul2003/5apr2007/11apr2007/20jan2010/21jan2010/24jan2011/31jan2012/19jun2015/29apr2016/30jun2017/20jul2017}{...}
{hline}
help for {hi:groups}
{hline}

{title:List group frequencies and percents}

{p 8 17 2}
{cmd:groups}
{it:varlist}
[{it:weight}]
[{cmd:if} {it:exp}]
[{cmd:in} {it:range}]
[{cmd:,}

{p 15 15 2}{it:specification_options} 

{p 15 15 2}{it:presentation_options}

{p 15 15 2}{it:saving_option} 

{p 15 15 2}]


{p 4 4 2}
{cmd:by} {it:...}{cmd::} may be used with {cmd:groups}; see help 
{help by}.  Note in particular that this is one key to controlling how
percents are calculated; that is, under {cmd:by:} percents sum to 100
within distinct categories defined by its {it:varlist}. 

{p 4 4 2}
{cmd:fweight}s and {cmd:aweight}s are allowed; see help {help weights}.


{title:Description}

{p 4 4 2}
{cmd:groups} lists the distinct groups of {it:varlist} occurring in the
dataset and their frequencies and/or percents. 
{cmd:groups} is perhaps most useful with
categorical variables, but has other uses. Groups are by default
presented in the sort order of {it:varlist}. Note that there is no limit
on the number of variables in {it:varlist}. 

{p 4 4 2}
Frequencies are counts or other measures of abundance. 

{p 4 4 2}
Percents are percents of each total frequency.  

{p 4 4 2} 
Cumulative frequencies and percents are cumulated in the order of groups
and show frequency (percent) in each group and all earlier groups in the
listing, unless the {cmd:lt} option is specified. 

{p 4 4 2}
Reverse cumulative frequencies and percents show frequency (percent) in
all later groups in the listing, unless the {cmd:ge} option is
specified.  

{p 4 4 2} 
"Valid" percents are calculated relative to all pertinent
non-missing values. 


{title:Options}

{title:{it:specification}} 

{col 5}{cmdab:fill:in}{col 35}show cross-combinations with zero values 

{col 5}{cmd:ge}{col 35}reverse frequencies, 
{col 35}percents for current and later groups 

{col 5}{cmd:lt}{col 35}cumulatives for previous groups  

{col 5}{cmdab:miss:ing}{col 35}show missing values              

{col 5}{cmdab:sel:ect(}{c -(}{it:condition}{c |}{it:#}{c )-}{cmd:)}{col 35}selecting results
 
{col 5}{cmdab:sh:ow(}{it:what_to_show}{cmd:)}{col 35}specify frequencies, percents, etc.

{col 5}{cmd:percent(}{it:varlist}{cmd:)}{col 35}variables defining which percents calculated

{p 4 8 2}
{cmd:fillin} specifies that groups (i.e. cross-combinations) of
{it:varlist} which do not occur in the data are shown explicitly as
having zero frequency.  This has no effect with a single variable. Note
that this option can bite hard as the number of cross-combinations can
explode combinatorially. 

{p 4 8 2}
{cmd:ge} (think {cmd:g}reater than or {cmd:e}qual to) 
specifies that reverse frequencies and percents are to be
calculated for the current and all later groups, that is, they are for
values greater than or equal to each value. 

{p 4 8 2}
{cmd:lt} (think {cmd:l}ess {cmd:t}han) 
specifies that cumulative frequencies and percents are to be
calculated for only the previous groups, that is, they are for values
less than each value. 

{p 4 8 2}
{cmd:missing} specifies that observations with missing values on any of
the variables in {it:varlist} are to be included in the listing.  By
default they are omitted.  Note that "valid" percents will be the same
as other percents unless the {cmd:missing} option is specified. 

{p 4 8 2}
{cmd:select()} specifies that only selected groups are to be listed.
There are two syntaxes. 

{p 8 8 2}
In the first syntax, selection is according to a condition imposed on
the frequencies, or on the percents, or on the cumulative frequencies,
or on the cumulative percents, or on the reverse cumulatives. The syntax
is exemplified by 

{p 8 8 2}{cmd:select(freq == 1)}{p_end}
{p 8 8 2}{cmd:select(percent > 5)}{p_end}
{p 8 8 2}{cmd:select(Percent < 50)}

{p 8 8 2}
The elements {cmd:freq}, {cmd:percent}, {cmd:Freq},  {cmd:Percent},
{cmd:RFreq}, {cmd:RPercent}, {cmd:vpercent}, {cmd:Vpercent} or
{cmd:rvpercent} may be abbreviated down to unambiguous abbreviations.
Note that case matters in distinguishing {cmd:freq} and {cmd:Freq},
{cmd:percent} and {cmd:Percent}, and {cmd:vpercent} and {cmd:Vpercent}.
What follows must complete a simple true-or-false condition in Stata
syntax, typically an inequality or equality.

{p 8 8 2}
In the second syntax, a positive or negative integer is specified.  A
positive integer specifies that only the {it:first #} groups are to be
shown. A negative integer specifies that only the {it:last} 
{c |}{it:#}{c |} groups are to be shown. 

{p 8 8 2}
First and last are determined with
respect to the listing which would otherwise have been given. 

{p 8 8 2}
Thus with {cmd:order(h)},  {cmd:select(5)} shows the 5 groups with the 5
highest frequencies, while {cmd:select(-5)} shows the 5 groups with the
5 lowest frequencies, ties being broken according to the sort order of
{it:varlist}. 

{p 8 8 2}
Similarly,  with {cmd:order(l)} the opposite is true.  Without
{cmd:order()}, {cmd:select(5)} shows the first 5 groups of {it:varlist}
and {cmd:select(-5)} shows the last 5 groups of {it:varlist}. The most
obviously useful example is when {it:varlist} consists of a single
variable, so that the listing is of the 5 lowest (highest) groups of
values of that variable.

{p 4 8 2}
{cmd:show()} specifies which frequencies should be shown.  By default,
frequencies, percents and cumulative percents are shown with one
variable, and frequencies and percents are shown with two or more
variables, in that order.  {cmd:show()} may be used to specify one or
two or three of those, and/or cumulative frequencies, and/or reverse
cumulative frequencies or reverse cumulative percents, and/or equivalent
percents for "valid" values, or to change the order of presentation.
The elements {cmd:freq}, {cmd:percent}, {cmd:Freq}, {cmd:Percent},
{cmd:RFreq}, {cmd:vpercent}, {cmd:Vpercent} and
{cmd:rvpercent} may be abbreviated, down to unambiguous abbreviations.
Note that case matters in distinguishing {cmd:freq} and {cmd:Freq}, 
{cmd:percent} and {cmd:Percent}, or
{cmd:vpercent} and {cmd:Vpercent}.  

{p 8 8 2}
Exceptionally, {cmd:show(none)} may be used to specify that none of these
should be shown.  For example, with {cmd:select(f == 1)} the frequencies
would all be 1, and thus their display may seem unnecessary, while the 
percents and cumulative percents may not be of interest, 
so {cmd:show(none)} may be desired.

{p 4 8 2} 
{cmd:percent()} specifies that percents and cumulatives are calculated
with respect to the combinations of the variables specified. The results
shown will resemble those with {cmd:by:}, except that the variables
named are displayed within each body of results. The default is that
percents and cumulatives are calculated with respect to all observations
selected. 

{p 8 8 2}For example, the same numerical results will appear for

{p 8 8 2}{cmd:. bysort foreign: groups rep78} 

{p 8 8 2}and for 

{p 8 8 2}{cmd:. groups foreign rep78, percent(foreign)} 

{p 8 8 2}so that in either case percents are calculated for groups defined
by distinct categories of {cmd:foreign}. 


{title:{it:presentation}} 

{col 5}{cmdab:form:at(}{it:format}{cmd:)}{col 35}display format for percents

{col 5}{it:list_options}{col 35}options of {help list} 

{col 5}{cmdab:ord:er(}{c -(}{cmdab:h:igh}{c |}{cmdab:l:ow}{c )-}{cmd:)}{col 35}order by frequency 

{col 5}{cmdab:rev:erse}{col 35}reverse display from default 

{col 5}{cmd:showhead(}{it:text}{cmd:)}{col 35}header text for frequencies

{col 5}{cmd:colorder(}{it:integers}{cmd:)}{col 35}reorder or repeat columns of table   

{p 4 8 2}
{cmd:format()} specifies a numeric format for percent and cumulative
percent frequencies. The default is %6.2f. 

{p 4 8 2}
{it:list_options} are options of {help list}. These offer several ways
of changing the appearance of the listing. Note that {cmd:sum} by itself
produces sums only of frequencies and percents, where shown.
{cmd:sepby()} and {cmd:sep()} are often especially helpful. 

{p 4 8 2}
{cmd:order()} specifies that groups should be listed in order of their
frequencies.  Ordering may be {cmd:high} (highest frequencies first) or
{cmd:low} (lowest frequencies first). {cmd:high} and {cmd:low} may be
abbreviated, down to as little as {cmd:h} or {cmd:l} respectively. 

{p 4 8 2}
{cmd:reverse} reverses what would otherwise be displayed, last values first. 

{p 4 8 2}
{cmd:showhead()} specifies alternative text for the header explaining
frequency variables. There should be as many elements as the number of
frequency, percent, cumulative frequency, cumulative percent, reverse
cumulative frequency, reverse cumulative percent and valid percent
variables listed and they should occur in the same order as those
variables are listed. Text containing spaces should be bound in {cmd:" "}. 
Thus with {cmd:show(f RF)}, {cmd:showhead(# "# bigger")} specifies
that {cmd:f}requencies are indicated by {cmd:"#"} and the {cmd:r}everse
cumulative {cmd:f}requencies are indicated by {cmd:"# bigger"}. 

{p 4 8 2}
{cmd:colorder()} specifies a reordering of what would otherwise be shown
as the columns of the listing. You may specify one or more positive
integers. Suppose {cmd:groups} would show 4 columns, but you want the
third and fourth columns to be shown first (i.e. as the leftmost
columns) and then the first and second columns. {cmd:colorder(3 4 1 2)}
or just {cmd:colorder(3 4)} would specify that. (It follows that this
option will not omit columns, although it may be used to repeat columns.) 
Typically therefore this option is used on a second or later pass of 
{cmd:groups}. 


{title:{it:saving results}} 

{col 5}{cmd:saving(}{it:filename} [{cmd:,} {it:save_options}]{cmd:)} {col 35}save results to dataset 

{p 4 8 2}
{cmd:saving()} specifies that the results listed will be saved to a
named Stata .dta file using {help save}. That does not include any sums,
means or similar summaries. Options of {cmd:save} may be specified in
the usual way. This option may not be combined with {cmd:by:}. 


{title:Examples}

{p 4 8 2}{cmd:. sysuse auto, clear}

{p 4 8 2}{cmd:. groups foreign}{p_end}
{p 4 8 2}{cmd:. tabulate foreign}{p_end}
{p 4 8 2}{cmd:. groups foreign rep78}{p_end}
{p 4 8 2}{cmd:. tabulate foreign rep78}

{p 4 8 2}{cmd:. groups foreign rep78, fillin}{p_end}
{p 4 8 2}{cmd:. groups foreign rep78, fillin saving(mytable, replace)}

{p 4 8 2}{cmd:. bysort foreign: groups rep78}{p_end}
{p 4 8 2}{cmd:. groups foreign rep78, percent(foreign)}{p_end}
{p 4 8 2}{cmd:. groups foreign rep78, percent(foreign) show(f p P)}

{p 4 8 2}{cmd:. groups mpg, select(f == 1) show(none)}{p_end}
{p 4 8 2}{cmd:. groups mpg, select(5)}{p_end}
{p 4 8 2}{cmd:. groups mpg, select(-5)}{p_end}
{p 4 8 2}{cmd:. groups mpg, select(5) order(h)}

{p 4 8 2}{cmd:. groups foreign rep78, fill select(f == 0) show(none)} 

{p 4 8 2}{cmd:. groups foreign rep78, sepby(foreign)}{p_end}
{p 4 8 2}{cmd:. groups foreign rep78, sepby(foreign) showhead(# %)} 

{p 4 8 2}{cmd:. groups rep78, missing show(freq percent vpercent) sep(0)}{p_end}
{p 4 8 2}{cmd:. groups rep78, show(freq rfreq Rpercent) ge}{p_end}
{p 4 8 2}{cmd:. groups rep78, show(F f Rf) lt showhead(< = >)}

{p 4 8 2}{cmd:. groups mpg, reverse}{p_end}
{p 4 8 2}{cmd:. groups mpg, reverse show(f p RP) ge}

{p 4 8 2}{cmd:. webuse nlswork}{p_end}
{p 4 8 2}{cmd:. groups collgrad not_smsa c_city south, order(high) sep(0)}{p_end}
{p 4 8 2}{cmd:. groups collgrad not_smsa c_city south, order(high) sep(0) colorder(5 6)}


{title:Author}

{p 4 4 2}
Nicholas J. Cox, Durham University, U.K.{break}
n.j.cox@durham.ac.uk 


{title:Acknowledgments}

{p 4 4 2}
Fred Wolfe made very helpful comments. He, Roger Harbord and Eric Zbinden
all found a bug. A question from Stefan Gawrich led to the {cmd:ge} option.
A question from James Keeler led to the {cmd:reverse} option. 
A question from William Parry led to the {cmd:saving()} option. 


{title:Also see}

{p 4 13 2}
Online:  help for 
{help tabulate}, 
{help table}, 
{help list}; 
{help duplicates}, 
{help contract}, 
{help modes} (if installed), 
{help fre} (Ben Jann; if installed), 
{help qplot} (if installed), 
{help distplot} (if installed)   

