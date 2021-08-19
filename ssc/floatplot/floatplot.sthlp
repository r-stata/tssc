{smcl}
{* 29may2021/30may2021/31may2021/3jun2021}{...}
{hline}
help for {hi:floatplot}
{hline}

{title:Floating or sliding stacked bar plot for frequencies, proportions, or percents} 

{p 8 12 2} 
{cmd:floatplot} 
{it:numvar}
[{it:weight}]
[{cmd:if} {it:exp}] 
[{cmd:in} {it:range}]{break} 
{cmd:,}
{c -(} 
{opt centre(#)} | 
{opt center(#)} | 
{opt highneg:ative(#)} 
{c )-} 
{break} 
{c -(}
{opt fcolors(colors)} | {opt fcolours(colours)} 
{c )-}{break}  
[
{opt vert:ical}{break}
{opt prop:ortions}
{opt freq:uencies}{break}   
{opt over(overvar)} 
{opt by(byvar, hyopts)}{break}
{opt barw:idth(#)} 
{c -(} {opt lcolors(colors)} | {opt lcolours(colours)} {c )-} 
{opt baropts(rbar_options)}{break} 
{opt format(format)} 
{opt textoffset(#)} 
{opt showval:opts(marker_label_options)}{break} 
{it:twoway_options}  
]

{p 4 4 2}{cmd:fweight}s and {cmd:aweight}s may be specified. 


{title:Description}

{p 4 4 2} 
{cmd:floatplot} produces a floating or sliding stacked bar plot showing
percents (or optionally proportions or frequencies) of categories of a
numeric outcome variable {it:numvar} by zero, one, or two other
categorical variables.  The plot is most helpful if categories of an
outcome variable have a natural or conventional pre-defined order.
Although there is no formal check, the design of the plot tacitly
assumes a modest number of distinct categories, say between 2 and 9. The
command is a wrapper for a call to {help twoway rbar} for showing bars and 
{help twoway scatter} for showing text. 
 
{p 4 4 2} 
The bar plot is horizontal by default but may optionally be vertical.
The choice is a matter of personal taste, although in general horizontal
displays make it easier to show and read values or labels of categories. 

{p 4 4 2}
The most basic option choice concerns which bars are stacked below a
zero axis, which if any bar straddles zero, and which bars are stacked
above a zero axis.  This is best explained by example. Suppose the
outcome of interest is a 5 point scale with 1 = strongly disagree, 2 =
disagree, 3 = neither disagree nor agree, 4 = agree, 5 = strongly agree.
Then a conventional and possibly congenial choice would be that a bar
representing the percent (proportion, frequency) of answer 3 would
straddle zero; bars representing answers 1 and 2 would be stacked
negatively and bars representing 4 and 5 would be stacked positively.
The syntax ensuring this would be {cmd:centre(3)} or {cmd:center(3)}.
Other way round, suppose the scale is a 4 point scale with 1 and 2 to be
plotted as negative categories and 3 and 4 to be plotted as positive
categories. The syntax for ensuring that would be {cmd:highnegative(2)}
indicating the highest value to be plotted as negative. 


{title:Remarks} 

{p 4 4 2}
The history of this plot depends on its definition. For example, bars
floating relative to an axis have long been used to indicate (say) the reigns
of monarchs, the lives of famous people, radio and television schedules, high 
and low prices, or the durations allocated to or consumed by various tasks 
(so-called Gantt charts, for example). 

{p 4 4 2}
A plot does not absolutely need a name if a widely agreed name does not
exist, but a Stata command certainly does.  Brinton (1939) briefly
showed what he called {it:bilateral bar charts} and similar designs appear
under that and other names in many bar charts showing  paired variables
(such as pyramids showing age and sex breakdown of populations).  The
focus here is rather on bar charts in which several ordered categories
are shown at once.  Greater credit must be given to Stouffer et al.
(1949a, 1949b) who showed many examples of such charts, without ever
naming them so far as I can tell. 

{p 4 4 2}
Spear (1952) and Schmid (1954) both used the terms {it:sliding bar} (for
horizontal plots) and {it:floating column} (for vertical plots). The
terminology may well be older or perhaps both authors devised those 
terms independently. Either way, Spear gave no literature references,
while Schmid did give literature references but did not cite Spear.  The
terms are repeated in later works, Spear (1969) on one side and Schmid
and Schmid (1979) and Schmid (1983) on another.  In her later book Spear
did give some literature references but not to any work by Schmid, while
none of the Schmid sequels cite Spear either.  Be that as it may, terms
such as sliding, slide, or floating have been repeated by others, such as
Lockwood (1969) and Robertson (1988).   
 
{p 4 4 2}
In their papers giving a big push to the idea, Robbins and Heiberger
(2011) and Heiberger and Robbins (2014) talk of 
{it:diverging stacked bar charts}, 
a term that is much more informative, but also a little more 
clunky in my view. 

{p 4 4 2}
A problem for me as author is that I wrote a Stata command
{cmd:slideplot} in 2003 as a wrapper for {cmd:graph bar} or 
{cmd:graph hbar}. It should remain accessible, so that name is taken,
and a slightly different name such as {cmd:slidebar} seems likely to be
confusing.  Hence, with some small pleasure in a whimsical name that
should make sense once people see the results, I have called this
command {cmd:floatplot}.

{p 4 4 2}
Although neither option is required, the most interesting and useful
plots show how the distribution of an outcome varies with one or two
predictors, for which {cmd:over()} and {cmd:by()} options are supplied. 

{p 4 4 2} 
Note that {it:numvar} and {it:overvar} if specified are temporarily
mapped to numeric variables that are integers 1 up, regardless of their
existing values.  

{p 4 4 2} 
Categories that do not appear in the data may be considered as shown
with bars of zero length, which should be regarded as defined but
invisible. Text displays of 0 for percents, proportions, or frequencies
are suppressed too.  Note that text labels may overlap whenever adjacent
categories are infrequent. Users finding this puzzling or unclear, for
themselves or their readers, may wish to turn to a different design. In
particular, {help tabplot} from the {it:Stata Journal} makes zeros
discernible as holes in a display and small frequencies discernible as
short bars. 

{p 4 4 2} 
Here even more than usually, the command is offered as
indicative, not definitive. In particular, the design codifies
prejudices in favour of a hybrid graph and table display.  


{title:Options}

{p 0 0 2}{it:How bars should be arranged} 

{p 4 4 2}
{cmd:centre()} or {cmd:center()} specifies a value of {it:numvar} for a
bar to straddle zero. As explained in the Description, an example such
as {cmd:centre(3)} specifies that the bar representing the abundance of
{it:numvar} value 3 should straddle zero, so that bars for lower values
will plot negatively and bars for higher values will plot positively. 

{p 4 4 2}{cmd:highnegative()} specifies the highest value of {it:numvar}
to be plotted negatively. As explained in the Description, an example
such as {cmd:highnegative(2)} specifies that bars representing the
abundance of {it:numvar} value 2 or lower should be plotted negatively
and so also that bars representing higher values should be plotted
positively.

{p 8 8 2}One (and only one) of {cmd:centre()}, {cmd:center()} or
{cmd:highnegative()} must be specified. 

{p 4 4 2}{cmd:vertical} specifies vertical bars (columns). The default
is horizontal. 

{p 0 0 2}{it:What should be plotted} 

{p 4 4 2} 
Options {cmd:proportions} or {cmd:frequencies} specify that proportions
(between 0 and 1) or frequencies should be plotted, rather than the
default percents. The options are exclusive. 

{p 8 8 2}
If analytic weights are specified, the frequencies need not be integers.
An important nuance here is that {cmd:floatplot} calculates percents and
proportions from the data given. If you wish data or summaries available
to you to be echoed exactly, use the {cmd:frequencies} option. For
example, suppose the data available are percents of strongly
agree to strongly disagree with also percents of don't know and/or other
"missing" categories, and you wish to ignore the missings, but to show the
percents as percents of the total number of respondents, not of those
answering with an agreement category. {cmd:frequencies} is the option
you need. 

{p 0 0 2}{it:How bars should be rendered} 

{p 4 4 2}{cmd:fcolours()} or {cmd:fcolors()} is a required option
specifying fill colo[u]rs for each bar. As many colo[u]rs should be
specified as there are distinct categories of the outcome.  

{p 4 4 2}{cmd:lcolours()} or {cmd:lcolors()} optionally specifies 
line colo[u]rs for each bar. The default is to use the choices of 
{cmd:fcolours()} or {cmd:fcolors()}, as explained just above.  

{p 4 4 2}{cmd:barwidth()} specifies the width of all bars. The
default is 0.5. 

{p 4 4 2}{cmd:baropts()} is for specifying other options of 
{help twoway rbar}. 

{p 0 0 2}{it:Other variables} 

{p 4 4 2}{cmd:over()} specifies a categorical variable (numeric or
string) defining different groups of observations to be shown in
parallel within one graph panel. 

{p 4 4 2}{cmd:by()} specifies that bars are to be shown in separate
panels for distinct values of a categorical variable (numeric or
string). The usual suboptions are allowed, as explained in the help for 
{help by_option}.   

{p 0 0 2}{it:Text display of percents, proportions, or frequencies} 

{p 4 4 2}{cmd:format()} specifies a display format for the text display
of percents, proportions, or frequencies. The default format
is %2.0f, except if the option {cmd:proportions} is specified, when it
is %3.2f. See help for {help format} if more detail is needed. 

{p 4 4 2}{cmd:textoffset()} specifies an offset distance relative to the 
midpoint of each bar to be subtracted
for the position of text. The default is 0.35, which with the default of
{cmd:barwidth(0.5)} places text 0.1 below each horizontal bar, or
above it with {cmd:ysc(reverse)}, or 0.1 to the left of each vertical
bar, or to the right with {cmd:xsc(reverse)}. {cmd:textoffset(0)} places
text at the midpoint of each bar, which can work well if colo[u]rs are
subdued. Negative offsets are allowed to flip text above or to the right of 
each bar. 

{p 4 4 2}{cmd:showvalopts()} are other {help marker_label_options},
except that as a special case {cmd:none} suppresses the display of text. 

{p 0 0 2}{it:twoway_options} refers to other options of 
{help graph_twoway:graph twoway}. 


{title:Examples} 

{p 4 8 2}{cmd:. set scheme s1color}{p_end}

{p 4 4 2}A canonical example for Stata users arises with the auto data. 
How does the distribution of grades 1 to 5 for repair record {cmd:rep78} 
vary with whether cars are {cmd:foreign}? 

{p 4 8 2}{cmd:. sysuse auto, clear}{p_end}

{p 4 8 2}{cmd:. floatplot rep78, centre(3) fcolors(red red*0.5 gs12 blue*0.5 blue) over(foreign) note(% centred on record 3) name(float1, replace)}{p_end}

{p 4 8 2}{cmd:. floatplot rep78, centre(3) vertical fcolors(red red*0.5 gs12 blue*0.5 blue) over(foreign) note(% centred on record 3) name(float2, replace)}{p_end}

{p 4 4 2}Fienberg (1980, 54{c -}55) reports data from
Duncan, Schuman and Duncan (1973) from 1959 and 1971 surveys of a large
American city asking "Are the radio and TV networks doing a good job, just a
fair job, or a poor job?".

{p 4 8 2}{cmd:. clear}{p_end}
{p 4 8 2}{cmd:. input float(year freq) long(Opinion race)}{p_end}
{p 4 8 2}{cmd:1959 81 3 2}{p_end}
{p 4 8 2}{cmd:1959 23 2 2}{p_end}
{p 4 8 2}{cmd:1959 4 1 2}{p_end}
{p 4 8 2}{cmd:1959 325 3 1}{p_end}
{p 4 8 2}{cmd:1959 253 2 1}{p_end}
{p 4 8 2}{cmd:1959 54 1 1}{p_end}
{p 4 8 2}{cmd:1971 224 3 2}{p_end}
{p 4 8 2}{cmd:1971 144 2 2}{p_end}
{p 4 8 2}{cmd:1971 24 1 2}{p_end}
{p 4 8 2}{cmd:1971 600 3 1}{p_end}
{p 4 8 2}{cmd:1971 636 2 1}{p_end}
{p 4 8 2}{cmd:1971 158 1 1}{p_end}
{p 4 8 2}{cmd:end}{p_end}
{p 4 8 2}{cmd:. label values Opinion Opinion}{p_end}
{p 4 8 2}{cmd:. label def Opinion 1 "Poor" 2 "Fair" 3 "Good"}{p_end}
{p 4 8 2}{cmd:. label values race race}{p_end}
{p 4 8 2}{cmd:. label def race 1 "White" 2 "Black"}{p_end}

{p 4 8 2}{cmd:. floatplot Opinion [fw=freq] , over(race) by(year, note("") col(1))  centre(2) fcolors(red gs12 blue) subtitle(, pos(9) fcolor(none) nobexpand nobox) ytitle("") name(float3, replace)}{p_end}

{p 4 8 2}{cmd:. floatplot Opinion [fw=freq] , over(year) by(race, note("") row(1) legend(pos(3)))  centre(2) fcolors(red gs12 blue) subtitle(, fcolor(none) nobexpand nobox) xtitle("") vertical name(float4, replace)}{p_end}

{p 4 4 2}Aitkin et al. (1989, 242; 2005, 299; 2009, 311) reported data
from a survey of student opinion on the Vietnam War taken at the University of
North Carolina in Chapel Hill in May 1967. Students were classified by sex,
year of study, and the policy they supported, given choices of 

{p 8 10 2} 
A The US should defeat the power of North Vietnam by widespread bombing 
  of its industries, ports and harbours and by land invasion. 

{p 8 10 2} 
B The US should follow the present policy in Vietnam. 

{p 8 10 2} 
C The US should de-escalate its military activity, stop bombing North 
  Vietnam, and intensify its efforts to begin negotiation. 

{p 8 10 2} 
D The US should withdraw its military forces from Vietnam immediately. 

{p 4 4 2} 
(They also report response rates (1989, 243; 2005, 298; 2009, 310), averaging 26% for males and 17% 
for females.) 

{p 4 8 2}{cmd:. clear}{p_end}
{p 4 8 2}{cmd:. input str1 policy float freq long(female year)}{p_end}
{p 4 8 2}{cmd:"A" 175 0 1}{p_end}
{p 4 8 2}{cmd:"B" 116 0 1}{p_end}
{p 4 8 2}{cmd:"C" 131 0 1}{p_end}
{p 4 8 2}{cmd:"D" 17 0 1}{p_end}
{p 4 8 2}{cmd:"A" 160 0 2}{p_end}
{p 4 8 2}{cmd:"B" 126 0 2}{p_end}
{p 4 8 2}{cmd:"C" 135 0 2}{p_end}
{p 4 8 2}{cmd:"D" 21 0 2}{p_end}
{p 4 8 2}{cmd:"A" 132 0 3}{p_end}
{p 4 8 2}{cmd:"B" 120 0 3}{p_end}
{p 4 8 2}{cmd:"C" 154 0 3}{p_end}
{p 4 8 2}{cmd:"D" 29 0 3}{p_end}
{p 4 8 2}{cmd:"A" 145 0 4}{p_end}
{p 4 8 2}{cmd:"B" 95 0 4}{p_end}
{p 4 8 2}{cmd:"C" 185 0 4}{p_end}
{p 4 8 2}{cmd:"D" 44 0 4}{p_end}
{p 4 8 2}{cmd:"A" 118 0 5}{p_end}
{p 4 8 2}{cmd:"B" 176 0 5}{p_end}
{p 4 8 2}{cmd:"C" 345 0 5}{p_end}
{p 4 8 2}{cmd:"D" 141 0 5}{p_end}
{p 4 8 2}{cmd:"A" 13 1 1}{p_end}
{p 4 8 2}{cmd:"B" 19 1 1}{p_end}
{p 4 8 2}{cmd:"C" 40 1 1}{p_end}
{p 4 8 2}{cmd:"D" 5 1 1}{p_end}
{p 4 8 2}{cmd:"A" 5 1 2}{p_end}
{p 4 8 2}{cmd:"B" 9 1 2}{p_end}
{p 4 8 2}{cmd:"C" 33 1 2}{p_end}
{p 4 8 2}{cmd:"D" 3 1 2}{p_end}
{p 4 8 2}{cmd:"A" 22 1 3}{p_end}
{p 4 8 2}{cmd:"B" 29 1 3}{p_end}
{p 4 8 2}{cmd:"C" 110 1 3}{p_end}
{p 4 8 2}{cmd:"D" 6 1 3}{p_end}
{p 4 8 2}{cmd:"A" 12 1 4}{p_end}
{p 4 8 2}{cmd:"B" 21 1 4}{p_end}
{p 4 8 2}{cmd:"C" 58 1 4}{p_end}
{p 4 8 2}{cmd:"D" 10 1 4}{p_end}
{p 4 8 2}{cmd:"A" 19 1 5}{p_end}
{p 4 8 2}{cmd:"B" 27 1 5}{p_end}
{p 4 8 2}{cmd:"C" 128 1 5}{p_end}
{p 4 8 2}{cmd:"D" 13 1 5}{p_end}
{p 4 8 2}{cmd:end}{p_end}
{p 4 8 2}{cmd:. label values female female}{p_end}
{p 4 8 2}{cmd:. label def female 0 "male" 1 "female"}{p_end}
{p 4 8 2}{cmd:. label values year year}{p_end}
{p 4 8 2}{cmd:. label def year 5 "Graduate"}{p_end}

{p 4 8 2}{cmd:. encode policy, gen(Preference)}{p_end}
   
{p 4 8 2}{cmd:. floatplot Preference [fw=freq], over(year) by(female, note("")) highneg(2) fcolors(red red*0.5 blue*0.5 blue) subtitle(, fcolor(green*0.2)) name(float5, replace) }{p_end}

{p 4 4 2}Box, Hunter and Hunter (1978, 145{c -}149; 2005, 112{c -}116) 
gave data on five hospitals on the degree of restoration (no improvement,
partial functional restoration, complete functional restoration) of certain
joints impaired by disease effected by a certain surgical procedure. (It is
not clear whether these data are real.) Hospital E is a referral hospital.
Box et al. carry out chi-square analyses, focusing on the difference between
Hospital E and the others.

{p 4 8 2}{cmd:. clear}{p_end}
{p 4 8 2}{cmd:. input str1 hospital float freq long restore}{p_end}
{p 4 8 2}{cmd:"A" 13 1}{p_end}
{p 4 8 2}{cmd:"B" 5 1}{p_end}
{p 4 8 2}{cmd:"C" 8 1}{p_end}
{p 4 8 2}{cmd:"D" 21 1}{p_end}
{p 4 8 2}{cmd:"E" 43 1}{p_end}
{p 4 8 2}{cmd:"A" 18 2}{p_end}
{p 4 8 2}{cmd:"B" 10 2}{p_end}
{p 4 8 2}{cmd:"C" 36 2}{p_end}
{p 4 8 2}{cmd:"D" 56 2}{p_end}
{p 4 8 2}{cmd:"E" 29 2}{p_end}
{p 4 8 2}{cmd:"A" 16 3}{p_end}
{p 4 8 2}{cmd:"B" 16 3}{p_end}
{p 4 8 2}{cmd:"C" 35 3}{p_end}
{p 4 8 2}{cmd:"D" 51 3}{p_end}
{p 4 8 2}{cmd:"E" 10 3}{p_end}
{p 4 8 2}{cmd:end}{p_end}
{p 4 8 2}{cmd:. label values restore restore}{p_end}
{p 4 8 2}{cmd:. label def restore 1 "none" 2 "partial" 3 "complete"}{p_end}
{p 4 8 2}{cmd:. label var restore "How far restored?"}{p_end}

{p 4 8 2}{cmd:. floatplot restore [w=freq], over(hospital) centre(2) fcolors(red gs12 blue) ysc(reverse) name(float6, replace)}{p_end}

{p 4 8 2}{cmd:. floatplot restore [fw=freq], over(hospital) centre(2) fcolors(red*0.4 gs12*0.4 blue*0.4) lcolors(red black blue) textoffset(0) showvalopts(mlabsize(medlarge)) subtitle(percents) name(float7, replace)}{p_end}

{p 4 4 2}To compare several variables, {cmd:reshape long} and apply {cmd:floatplot, over()}: 

{p 4 8 2}{cmd:. use http://www.stata-press.com/data/cirtms/anxiety5items, clear}{p_end}
{p 4 8 2}{cmd:. rename (*) (answer=)}{p_end}
{p 4 8 2}{cmd:. gen id = _n}{p_end}
{p 4 8 2}{cmd:. reshape long answer, i(id) j(question) string}{p_end}
{p 4 8 2}{cmd:. egen prneg = mean(answer <= 2), by(question)}{p_end}
{p 4 8 2}{cmd:. myaxis question2=question, sort(mean prneg)}{p_end}
{p 4 8 2}{cmd:. label def question2 1 "at ease", modify}{p_end}
{p 4 8 2}{cmd:. floatplot ans, over(question2) center(3) fcolors(red red*0.5 gs12 blue*0.5 blue) name(float8, replace)}{p_end}


{title:Acknowledgments} 

{p 4 4 2}Eric Melse made several helpful and encouraging comments. 
He suggested the problem of comparing several variables.


{title:Author}

{p 4 4 2}Nicholas J. Cox, University of Durham{break}
n.j.cox@durham.ac.uk


{title:Also see}

{p 4 4 2}Help for{break}  
{help tabplot} ({it:Stata Journal}) (if installed){break}
{help distplot} ({it:Stata Journal}) (if installed){break}
{help qplot} ({it:Stata Journal}) (if installed){break}
{help myaxis} (SSC and {it:Stata Journal} in press 21(3)) (if installed){break}
{help slideplot} (SSC) (if installed){break}
{help catplot} (SSC) (if installed){p_end}


{title:References}

{p 4 8 2}Aitkin, M., D. Anderson, B. Francis, and J. Hinde. 1989. 
{it:Statistical Modelling in GLIM}. Oxford: Oxford University Press. 

{p 4 8 2}Aitkin, M., B. Francis and J. Hinde. 2005. 
{it:Statistical Modelling in GLIM 4.} 
Oxford: Oxford University Press. 

{p 4 8 2}Aitkin, M., B. Francis, J. Hinde and R. Darnell. 2009. 
{it:Statistical Modelling in R.} 
Oxford: Oxford University Press. 

{p 4 8 2}
Bentley, J. L. 1984. 
Programming Pearls: Graphic output. 
{it:Communications, Association for Computing Machinery}  
27: 529{c -}536. 

{p 4 8 2}
Bentley, J. L. 1988. 
{it:More Programming Pearls: Confessions of a Coder.} 
Reading, MA: Addison-Wesley. 

{p 4 8 2}Box, G. E. P., J. S. Hunter and W. G. Hunter. 2005.   
{it:Statistics for Experimenters: Design, Innovation, and Discovery.} 
Hoboken, NJ: John Wiley. 

{p 4 8 2}Box, G. E. P., W. G. Hunter, and J. S. Hunter. 1978. 
{it: Statistics for Experimenters: An Introduction to Design, Data Analysis, and Model Building}.  New York: Wiley. 

{p 4 8 2}
Brinton, W. C. 1939.
{it:Graphic Presentation}.
New York: Brinton Associates.

{p 4 8 2}
Cox, N. J. 2004a. 
Speaking Stata: Graphing distributions. 
{it:Stata Journal} 4: 66{c -}88.

{p 4 8 2}
Cox, N. J. 2004b. 
Speaking Stata: Graphing categorical and compositional data
{it:Stata Journal} 4: 190{c -}215.

{p 4 8 2}
Cox, N. J. 2016.
Speaking Stata: Multiple bar charts in table form
{it:Stata Journal} 16: 491{c -}510.

{p 4 8 2}Duncan, O. D., H. Schuman, and B. Duncan. 1973. 
{it:Social Change in a Metropolitan Community}.
New York: Russell Sage Foundation. 

{p 4 8 2}Fienberg, S. E. 1980. 
{it:The Analysis of Cross-Classified Categorical Data}.
Cambridge, MA: MIT Press. 

{p 4 8 2}
Heiberger, R. M. and N. B. Robbins. 2014.
Design of diverging stacked bar Charts for Likert scales and other applications.
{it:Journal of Statistical Software} 57(5): 1{c -}32. 
doi:10.18637/jss.v057.i05

{p 4 8 2}
Lockwood, A.  1969. 
{it:Diagrams: A Visual Survey of Graphs, Maps, Charts and Diagrams for the Graphic Designer.} 
London: Studio Vista. 

{p 4 8 2}
Robertson, B. 1988. 
{it:Learn to Draw Charts and Diagrams Step by Step.} 
London: Macdonald.

{p 4 8 2}
Robbins, N. B. and R. M. Heiberger. 2011.
Plotting Likert and other rating scales.
{it:JSM Proceedings, Section on Survey Research Methods}, 1058{c -}1066. 
Alexandria, VA: American Statistical Association. 
https://www.amstat.org/membersonly/proceedings/2011/papers/300784_64164.pdf
Google for copies if this official version is inaccessible to you. 
 
{p 4 8 2}
Schmid, C. F. 1954.  
{it:Handbook of Graphic Presentation.} 
New York: Ronald Press. 

{p 4 8 2}
Schmid, C. F. 1983. 
{it:Statistical Graphics: Design Principles and Practices.} 
New York: John Wiley. 

{p 4 8 2}
Schmid, C. F. and S. E. Schmid. 1979. 
{it:Handbook of Graphic Presentation.} 
New York: John Wiley. 

{p 4 8 2}
Spear, M. E. 1952. 
{it:Charting Techniques.} 
New York: McGraw-Hill. 

{p 4 8 2}
Spear, M. E. 1969.
{it:Practical Charting Techniques.} 
New York: McGraw-Hill. 

{p 4 8 2}
Stouffer, S. A., E. A. Suchman, L. C. DeVinney, S. A. Star, and R. M.
Williams, Jr. 1949a.
{it:The American Soldier: Adjustment During Army Life}.
Princeton, NJ: Princeton University Press.

{p 4 8 2}
Stouffer, S. A., A. A. Lumsdaine, M. H. Lumsdaine, R. M. Williams, Jr.,
M. B. Smith, I. L. Janis, S. A. Star, and L. S. Cottrell. 1949b.
{it:The American Soldier: Combat and its Aftermath}.
Princeton, NJ: Princeton University Press.

