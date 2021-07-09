{smcl}
{* 7may2003/29sept2003/11mar2004/16may2004/14apr2005/17aug2005/18dec2009/29mar2010/15sep2017}{...}
{hline}
help for {hi:distplot}{right:(SJ17-4: gr41_5; SJ10-1: gr41_4; SJ5-3: gr41_3;}
{right:SJ3-4: gr41_2; SJ3-2: gr41_1; STB-51: gr41)}
{hline}

{title:Distribution function plots} 

{p 8 17 2} 
{cmd:distplot}
{it:varname}
{ifin}
{weight}
[{cmd:,}
{cmd:over(}{it:varname}{cmd:)}
{cmd:by(}{it:varname}[{cmd:,} {it:sub_options}]{cmd:)}
{c -(} {cmdab:freq:uency} 
{c |} 
{cmdab:mid:point} 
{c )-} 
{cmdab:miss:ing}
{cmdab:rev:erse}[{cmd:(ge)}] 
{cmdab:trsc:ale(}{it:transformation_syntax}{cmd:)} 
{it:graph_options}
]

{p 8 17 2}
{cmd:distplot} 
{it:varlist}
{ifin}
{weight}
[{cmd:,}
{cmd:by(}{it:varname}[{cmd:,} {it:sub_options}]{cmd:)}
{c -(} 
{cmdab:freq:uency} 
{c |} 
{cmdab:mid:point} 
{c )-} 
{cmdab:rev:erse}[{cmd:(ge)}] 
{cmdab:trsc:ale(}{it:transformation_syntax}{cmd:)} 
{it:graph_options}
]

{p 4 4 2}{cmd:fweight}s and {cmd:aweight}s may be specified. 


{title:Description}

{p 4 4 2}{cmd:distplot} produces a plot of the cumulative distribution
function(s) for the variables in {it:varlist}. By default this shows the
proportion (or if desired the frequency) of values less than or equal to
each value.

{p 4 4 2}With the {cmd:reverse} option, {cmd:distplot} produces a plot
of the reverse cumulative probabilities (or frequencies), a.k.a., or a
multiple of, the converse or complementary distribution, reliability,
survival or survivor function.  This shows the proportion (or if desired
the frequency) of values greater than each value, or (if
{cmd:reverse(ge)} is specified) of values greater than or equal to each
value. 

{p 4 4 2}The plot is by default a line plot. Note the possibility of
using {helpb advanced_options:recast()} to recast the plot as another
{helpb graph_twoway:twoway} type, such as {cmd:connected}, {cmd:dot},
{cmd:dropline}, {cmd:scatter}, or {cmd:spike}.


{title:Remarks} 

{p 4 4 2}
In principle the cumulative distribution function has values ranging
between 0 and 1. Hence people are sometimes puzzled by graphs from
finite data, which do not stretch over that entire range. The puzzle is
easily explained.  To make discussion simple and concrete, forget about
possible ties and weights, and imagine a simple set of data values 1 2 3
4 5. 

{p 4 4 2}
By default {cmd:distplot} shows probabilities of being less than or
equal to any value, so the cumulative probabilities shown for the
example data run 1/5 ... 5/5 or 0.2 0.4 0.6 0.8 1 and 0 is never
plotted. With the {cmd:reverse} option the cumulative probabilities are
the complements (subtracted from 1) and run 0.8 0.6 0.4 0.2 0.  With the
{cmd:reverse(ge)} option they run 1 0.8 0.6 0.4 0.2, which has a
particular advantage that all can be shown on a logarithmic scale. So,
with {cmd:reverse} 1 is never plotted and with {cmd:reverse(ge)} 0 is
never plotted. 

{p 4 4 2}
Logically there seems scope to plot probability of being less, which
would mean plotting 0 0.2 0.4 0.6 0.8, but that does not seem
conventional and is not currently supported by {cmd:distplot}. 

{p 4 4 2}
The {cmd:midpoint} option splits probabilities upwards and downwards.
Consider Tukey's (1977, 496) apt summary: "It is a long-used statistical
practice to treat any observed value exactly equal to a cutting value as
if it were half below and half above." The principle goes back at least
to Galton. This option thus yields cumulative probabilities of 0.1 0.3
0.5 0.7 0.9 or their complements in 1, and so treats tails
symmetrically. 

{p 4 4 2}
The midpoint convention is helpful for showing distribution functions
for which cumulative probabilities are on various transformed scales.
The convention is crucial for quantile plotting in which one axis is
expected quantiles calculated by feeding cumulative probabilities to a
quantile function (inverse cumulative distribution function, if you
insist). Results of quantile functions are often undefined for arguments
of 0 or 1. The normal quantile function is the first example of this
kind met in most people's statistical education. A twist now, which
takes us beyond the scope of {cmd:distplot}, is that there can be
grounds in quantile plotting for preferring variations on (rank - 0.5) /
#values, which is the implied rule here. 

{p 4 4 2}
For any sufficiently large sample, cumulative probabilities approach 0
and 1 so closely that these nuances are not discernible on graphs, but
the principle is the same. 

{p 4 4 2}
For other information on what to calculate as cumulative probabilities
{c -} in other contexts often called plotting positions or percentile
ranks {c -} see Cox (2014a) and its references. 


{title:Options}

{p 4 8 2} {cmd:by(}{varname}[{cmd:,}{it:sub_options}]{cmd:)} specifies
that calculations be carried out separately for each distinct value of a
specified single variable. Results will be shown separately in distinct
panels. See {it:{help by_option}}. 

{p 8 8 2}Note that although the {cmd:total} 
suboption of {cmd:by()} is not prohibited, it does not implement calculation 
of the distribution function of all values. A work-around to do that is 
outlined in the Examples. See also Cox (2014b). 

{p 4 8 2} {cmd:over(}{it:varname}{cmd:)} specifies that calculations be
carried out separately for each distinct value of a specified single
variable.  Curves will be shown together within the same panel.
{cmd:over()} is only allowed with a single {it:varname}.

{p 4 8 2}{cmd:frequency} specifies calculation of cumulative frequency
rather than cumulative probability.

{p 4 8 2}{cmd:midpoint} specifies the use of midpoints of cumulative
probability for each distinct value. This is especially appropriate for
showing distributions of graded (ordinal) data with a relatively small
number of categories. For more explanation and examples, see the
Appendix below. 

{p 4 8 2}{cmd:frequency} and {cmd:midpoint} may not be combined. 

{p 4 8 2}{cmd:missing}, used only with {cmd:over()}, permits the use of
nonmissing values of {it:varname} corresponding to missing values for
the variable named by {cmd:over()}. The default is to ignore such
values.
 
{p 4 8 2}{cmd:reverse} or {cmd:reverse(ge)} specifies plotting of the
reverse distribution function.  Note an important detail (setting on one
side the effects of {cmd:midpoint}): With {cmd:reverse} the highest
observed value is plotted as probability or frequency 0, as no values
are greater than that. That prohibits plotting probability or frequency
on a logarithmic scale.  With {cmd:reverse(ge)} the highest observed
value is plotted as a positive probability or frequency, as at least one
value is greater than or equal to that. That allows plotting of
probability or frequency on a logarithmic scale. 

{p 4 8 2}{cmd:trscale()} specifies the use of an alternative transformed scale
for cumulative probabilities (or frequencies) on the graph. Stata syntax should
be used with {cmd:@} as placeholder for untransformed values. To show
probabilities as percents, specify {cmd:trscale(100 * @)}. To show probabilities
on an inverse normal scale, specify {cmd:trscale(invnorm(@))}; on a logit scale,
specify {cmd:trscale(logit(@))}; on a folded root scale, specify
{cmd:trscale(sqrt(@) - sqrt(1 - @))}; on a loglog scale, specify
{cmd:trscale(-log(-log(@)))}; on a cloglog scale, specify 
{cmd:trscale(cloglog(@))}. Tools to make associated labels and ticks
easier are available on SSC: see {stata ssc desc mylabels:ssc desc mylabels}. 

{p 4 8 2}{it:graph_options} refers to any options allowed by 
{helpb graph}. 
In particular, note that the default y axis title is always
simple, such as "Cumulative probability". If you wish to show more
algebra and use Stata 11 up, know that the {help text} option supports
"less than or equal to" and "greater than or equal to" symbols 
through {cmd:{&le}} and {cmd:{&ge}}. 


{title:Examples}

{p 4 8 2}{cmd:. sysuse citytemp, clear}{p_end}
{p 4 8 2}{cmd:* degrees as below need Stata 11 up}{p_end} 
{p 4 8 2}{cmd:. label var tempjan "Mean January temperature ({&degree}F)"}{p_end} 
{p 4 8 2}{cmd:. distplot tempjan, over(region)}{p_end}
{p 4 8 2}{cmd:. distplot tempjan, by(region)}{p_end}
{p 4 8 2}{cmd:. distplot tempjan, by(region) reverse}{p_end}
{p 4 8 2}{cmd:. distplot tempjan, by(region) reverse(ge)}{p_end}
{p 4 8 2}{cmd:. distplot tempjan tempjul, by(region) legend(order(1 "January" 2 "July")) xtitle("Mean temperature ({&degree}F)")}

{p 4 8 2}{cmd:. count}{p_end}
{p 4 8 2}{cmd:. local np1 = r(N) + 1}{p_end}
{p 4 8 2}{cmd:. expand 2}{p_end}
{p 4 8 2}{cmd:. replace region = 5 in `np1'/L}{p_end}
{p 4 8 2}{cmd:. label def region 5 "Total", add}{p_end}
{p 4 8 2}{cmd:. distplot tempjan, by(region)}


{title:Author}

{p 4 4 2}Nicholas J. Cox, Durham University{break}
	 n.j.cox@durham.ac.uk
	 

{title:Acknowledgments} 

{p 4 4 2}Elizabeth Allred, Ron{c a'}n Conroy and Roger Harbord made 
helpful comments during development of earlier versions of this 
or related programs. L{c a'}szl{c o'} Kardos found a bug and raised
the detail of {cmd:by(, total)}. A question from Maria Sundaram on 
Statalist prompted fuller explanation of exactly what is plotted. 


{title:Also see}

{p 4 13 2}Manual: {hi:[R] cumul}, {hi:[R] diagnostic plots}

{p 4 13 2}Online: help for {helpb graph}, {helpb cumul}, {helpb quantile},
{helpb qplot} (if installed), {helpb mylabels} (if installed), {helpb stripplot} (if installed) 


{title:Appendix: the midpoint option and graded data} 

{p 4 4 2}The focus of this Appendix is conveyed by its title, but the 
examples illustrate a variety of additional points of technique. 

{p 4 4 2}The cumulative probability {it:P} is defined under the {cmd:midpoint} 
option as 

	SUM counts in categories below + (1/2) count in this category
	{hline 61}.
                       SUM counts in all categories
		   
{p 4 4 2}With terminology from Tukey (1977, 496-497), this could be
called a `split fraction below'. It is also a `ridit' as defined by
Bross (1958): see also Fleiss et al. (2003, 198-205)  or Flora (1988).
Yet again, it is also the mid-distribution function of Parzen (1993,
3295) and the grade function of Haberman (1996, 240-241). The numerator
is a `split count'. Using this numerator, rather than 

	SUM counts in categories below 

{p 4 4 2}or 

	SUM counts in categories below + count in this category, 
	
{p 4 4 2}means that more use is made of the information in the data. Either 
alternative would always mean that some probabilities are identically 0 
or 1, which tells us nothing about the data. In addition, there are 
fewer problems in showing the cumulative distribution on any 
transformed scale (e.g., logit) for which the transform of 0 or 1 is 
not plottable. Using this approach for graded data was suggested by 
Cox (2001, 2004). 

{p 4 4 2}A plot of the complement of this cumulative probability, 1 - {it:P}, 
may be obtained through the {cmd:reverse} option. 

{p 4 4 2}Further information on working with counted fractions and folded 
transformations for probability scales is available in Tukey (1960, 
1961, 1977), Atkinson (1985), Cox and Snell (1989) and Emerson (1991).
Some of the possible transformations appear as link functions in 
the literature on generalized linear models (e.g., McCullagh and Nelder 
1989; Aitkin et al. 1989).

{p 4 4 2}{bf:Example 1}{space 4}Aitkin et al. (1989, 242) reported data
from a survey of student opinion on the Vietnam War taken at the University of
North Carolina in Chapel Hill in May 1967. Students were classified by sex,
year of study and the policy they supported, given choices of 

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
(They also report response rates (page 243), averaging 26% for males and 17% 
for females.) 

{p 4 4 2}
Here are the data as code: 

{p 4 8 2}{cmd:. input str1 policy float freq long(female year)}{p_end}
{p 4 8 2}{cmd:. "A" 175 0 1}{p_end}
{p 4 8 2}{cmd:. "B" 116 0 1}{p_end}
{p 4 8 2}{cmd:. "C" 131 0 1}{p_end}
{p 4 8 2}{cmd:. "D"  17 0 1}{p_end}
{p 4 8 2}{cmd:. "A" 160 0 2}{p_end}
{p 4 8 2}{cmd:. "B" 126 0 2}{p_end}
{p 4 8 2}{cmd:. "C" 135 0 2}{p_end}
{p 4 8 2}{cmd:. "D"  21 0 2}{p_end}
{p 4 8 2}{cmd:. "A" 132 0 3}{p_end}
{p 4 8 2}{cmd:. "B" 120 0 3}{p_end}
{p 4 8 2}{cmd:. "C" 154 0 3}{p_end}
{p 4 8 2}{cmd:. "D"  29 0 3}{p_end}
{p 4 8 2}{cmd:. "A" 145 0 4}{p_end}
{p 4 8 2}{cmd:. "B"  95 0 4}{p_end}
{p 4 8 2}{cmd:. "C" 185 0 4}{p_end}
{p 4 8 2}{cmd:. "D"  44 0 4}{p_end}
{p 4 8 2}{cmd:. "A" 118 0 5}{p_end}
{p 4 8 2}{cmd:. "B" 176 0 5}{p_end}
{p 4 8 2}{cmd:. "C" 345 0 5}{p_end}
{p 4 8 2}{cmd:. "D" 141 0 5}{p_end}
{p 4 8 2}{cmd:. "A"  13 1 1}{p_end}
{p 4 8 2}{cmd:. "B"  19 1 1}{p_end}
{p 4 8 2}{cmd:. "C"  40 1 1}{p_end}
{p 4 8 2}{cmd:. "D"   5 1 1}{p_end}
{p 4 8 2}{cmd:. "A"   5 1 2}{p_end}
{p 4 8 2}{cmd:. "B"   9 1 2}{p_end}
{p 4 8 2}{cmd:. "C"  33 1 2}{p_end}
{p 4 8 2}{cmd:. "D"   3 1 2}{p_end}
{p 4 8 2}{cmd:. "A"  22 1 3}{p_end}
{p 4 8 2}{cmd:. "B"  29 1 3}{p_end}
{p 4 8 2}{cmd:. "C" 110 1 3}{p_end}
{p 4 8 2}{cmd:. "D"   6 1 3}{p_end}
{p 4 8 2}{cmd:. "A"  12 1 4}{p_end}
{p 4 8 2}{cmd:. "B"  21 1 4}{p_end}
{p 4 8 2}{cmd:. "C"  58 1 4}{p_end}
{p 4 8 2}{cmd:. "D"  10 1 4}{p_end}
{p 4 8 2}{cmd:. "A"  19 1 5}{p_end}
{p 4 8 2}{cmd:. "B"  27 1 5}{p_end}
{p 4 8 2}{cmd:. "C" 128 1 5}{p_end}
{p 4 8 2}{cmd:. "D"  13 1 5}{p_end}
{p 4 8 2}{cmd:. end}{p_end}
{p 4 8 2}{cmd:. label values female female}{p_end}
{p 4 8 2}{cmd:. label def female 0 "male" 1 "female"}{p_end}
{p 4 8 2}{cmd:. label values year year}{p_end}
{p 4 8 2}{cmd:. label def year 5 "Graduate"}{p_end}

{p 4 4 2}{cmd:distplot} needs a numeric outcome variable. Here are some sample plots. 

{p 4 8 2}{cmd:. encode policy, gen(Preference)}{p_end}
{p 4 8 2}{cmd:. local opts recast(connected) mid over(year) xla(, valuelabel)}{p_end}
{p 4 8 2}{cmd:. distplot Pref [w=freq] if !female, `opts' }{p_end}
{p 4 8 2}{cmd:. distplot Pref [w=freq] if female, `opts'}{p_end}
{p 4 8 2}{cmd:. distplot Pref [w=freq], `opts' by(female, note(""))}{p_end}


{p 4 4 2}{bf:Example 2}{space 4}Fienberg (1980, 54-55) reports data from
Duncan, Schuman and Duncan (1973) from 1959 and 1971 surveys of a large
American city asking "Are the radio and TV networks doing a good job, just a
fair job, or a poor job?". Here are the data as code: 

{p 4 8 2}{cmd:. clear}{p_end}
{p 4 8 2}{cmd:. input float(year freq) long(Opinion race)}{p_end}
{p 4 8 2}{cmd:. 1959  81 3 2}{p_end}
{p 4 8 2}{cmd:. 1959  23 2 2}{p_end}
{p 4 8 2}{cmd:. 1959   4 1 2}{p_end}
{p 4 8 2}{cmd:. 1959 325 3 1}{p_end}
{p 4 8 2}{cmd:. 1959 253 2 1}{p_end}
{p 4 8 2}{cmd:. 1959  54 1 1}{p_end}
{p 4 8 2}{cmd:. 1971 224 3 2}{p_end}
{p 4 8 2}{cmd:. 1971 144 2 2}{p_end}
{p 4 8 2}{cmd:. 1971  24 1 2}{p_end}
{p 4 8 2}{cmd:. 1971 600 3 1}{p_end}
{p 4 8 2}{cmd:. 1971 636 2 1}{p_end}
{p 4 8 2}{cmd:. 1971 158 1 1}{p_end}
{p 4 8 2}{cmd:. end}{p_end}
{p 4 8 2}{cmd:. label values Opinion Opinion}{p_end}
{p 4 8 2}{cmd:. label def Opinion 1 "Poor" 2 "Fair" 3 "Good"}{p_end}
{p 4 8 2}{cmd:. label values race race}{p_end}
{p 4 8 2}{cmd:. label def race 1 "White" 2 "Black"}{p_end}

{p 4 8 2}* for groups, see Cox (2017){p_end}
{p 4 8 2}{cmd:. groups race year Opinion [w=freq] , percent(race year) sepby(race year)}{p_end}
{p 4 8 2}{cmd:. mylabels 2 5 10(10)80, myscale(logit(@/100)) local(myla)}{p_end}
{p 4 8 2}{cmd:. distplot Opinion [w=freq], recast(connected) mid over(year) by(race, note("")) trscale(logit(@)) xla(1/3, valuelabel) yla(`myla', ang(h)) ytitle(Percent) xsc(r(0.8 3.2))}{p_end}
	   
{p 4 4 2}This shows a clear shift of opinion towards Poor from 1959 to 1971,
and a narrowing gap between Black and White.

{p 4 4 2}{bf:Example 3}{space 4}Clogg and Shihadeh (1994, 156) give data from
the 1988 General Social Survey on answers to the question "When a marriage is
troubled and unhappy, do you think it is generally better for the children if
the couple stays together or gets divorced?". Responses were "much better to
divorce", "better to divorce", "don't know", "worse to divorce" and "much worse
to divorce". Here are the data as code, with "don't know" treated as in the middle of the scale: 

{p 4 8 2}{cmd:. clear}{p_end}
{p 4 8 2}{cmd:. input float freq long(female Opinion)}{p_end}
{p 4 8 2}{cmd:.  84 0 5}{p_end}
{p 4 8 2}{cmd:. 205 0 4}{p_end}
{p 4 8 2}{cmd:. 135 0 3}{p_end}
{p 4 8 2}{cmd:. 121 0 2}{p_end}
{p 4 8 2}{cmd:.  56 0 1}{p_end}
{p 4 8 2}{cmd:. 154 1 5}{p_end}
{p 4 8 2}{cmd:. 330 1 4}{p_end}
{p 4 8 2}{cmd:. 178 1 3}{p_end}
{p 4 8 2}{cmd:.  72 1 2}{p_end}
{p 4 8 2}{cmd:.  49 1 1}{p_end}
{p 4 8 2}{cmd:. end}{p_end}
{p 4 8 2}{cmd:. label values female female}{p_end}
{p 4 8 2}{cmd:. label def female 0 "male" 1 "female"}{p_end}
{p 4 8 2}{cmd:. label values Opinion Opinion}{p_end}
{p 4 8 2}{cmd:. label def Opinion 1 "much worse" 2 "worse" 3 "don't know" 4 "better" 5 "much better"}{p_end}
                 
{p 4 4 2}However, it is not clear that the "don't know"s do 
belong in the middle of the 
scale. The point can be explored by graphs with and without those 
values. Either way, there is a distinct separation between males and females, 
and a logit scale gives a more nearly linear pattern. 

{p 4 8 2}{cmd:. local opts recast(connected) mid over(female) xla(, valuelabel) }{p_end}
{p 4 8 2}{cmd:. local opts `opts' legend(col(1) pos(5) ring(0))}{p_end}

{p 4 8 2}{cmd:. distplot Opinion [w=freq], `opts' xsc(r(0.7,5.3) titlegap(*5))}{p_end}
{p 4 8 2}{cmd:. mylabels 2 5 10(10)90 95 98, myscale(logit(@/100)) local(myla)}{p_end}
{p 4 8 2}{cmd:. distplot Opinion [w=freq], `opts' xsc(r(0.7,5.3)) trscale(logit(@)) yla(`myla', ang(h)) ytitle(Percent)}{p_end}
{p 4 8 2}{cmd:. egen Opinion2 = group(Opinion) if Opinion != 3, label}{p_end}
{p 4 8 2}{cmd:. label var Opinion2 "Opinion"}{p_end}
{p 4 8 2}{cmd:. distplot Opinion2 [w=freq], `opts' xsc(r(0.7, 4.3)) trscale(logit(@)) yla(`myla', ang(h)) ytitle(Percent)}{p_end}
                
{p 4 4 2}{bf:Example 4}{space 4}Knoke and Burke (1980, 68) gave data from the 
1972 General Social Survey on church attendance. Here are the data as code:  

{p 4 8 2}{cmd:. clear}{p_end}
{p 4 8 2}{cmd:. input float freq long(group Attendance)}{p_end}
{p 4 8 2}{cmd:. 322 1 1}{p_end}
{p 4 8 2}{cmd:. 122 1 2}{p_end}
{p 4 8 2}{cmd:. 141 1 3}{p_end}
{p 4 8 2}{cmd:. 250 2 1}{p_end}
{p 4 8 2}{cmd:. 152 2 2}{p_end}
{p 4 8 2}{cmd:. 194 2 3}{p_end}
{p 4 8 2}{cmd:.  88 3 1}{p_end}
{p 4 8 2}{cmd:.  45 3 2}{p_end}
{p 4 8 2}{cmd:. 106 3 3}{p_end}
{p 4 8 2}{cmd:.  28 4 1}{p_end}
{p 4 8 2}{cmd:.  24 4 2}{p_end}
{p 4 8 2}{cmd:. 119 4 3}{p_end}
{p 4 8 2}{cmd:. end}{p_end}
{p 4 8 2}{cmd:. label values group group}{p_end}
{p 4 8 2}{cmd:. label def group 1 "young non-Catholic" 2 "old non-Catholic"}{p_end}
{p 4 8 2}{cmd:. label def group 3 "young Catholic" 4 "old Catholic", modify}{p_end}
{p 4 8 2}{cmd:. label values Attendance Attend}{p_end}
{p 4 8 2}{cmd:. label def Attend 1 "low" 2 "medium" 3 "high"}{p_end}

{p 4 4 2}The {cmd:reverse} option ensures that higher attendance groups plot
higher on the graph. There are clear age and denomination effects and an
indication of an interaction between the two. 

{p 4 8 2}{cmd:. mylabels 0.05 0.1(0.2)0.9 0.95, myscale(logit(@)) local(myla)}{p_end}
{p 4 8 2}{cmd:. distplot Attend [w=freq], recast(connected) mid over(group) trscale(logit(@)) reverse xla(1/3, valuelabel) xsc(titlegap(*5)) yla(`myla', ang(h))}

{p 4 4 2}{bf:Example 5}{space 4}Box, Hunter and Hunter (1978, 145-149) 
gave data on five hospitals on the degree of restoration (no improvement,
partial functional restoration, complete functional restoration) of certain
joints impaired by disease effected by a certain surgical procedure. (It is
not clear whether these data are real.) Hospital E is a referral hospital.
Box et al. carry out chi-square analyses, focusing on the difference between
Hospital E and the others. Here are the data as code: 

{p 4 8 2}{cmd:. clear}{p_end}
{p 4 8 2}{cmd:. input str1 hospital float freq long restore}{p_end}
{p 4 8 2}{cmd:. "A" 13 1}{p_end}
{p 4 8 2}{cmd:. "B"  5 1}{p_end}
{p 4 8 2}{cmd:. "C"  8 1}{p_end}
{p 4 8 2}{cmd:. "D" 21 1}{p_end}
{p 4 8 2}{cmd:. "E" 43 1}{p_end}
{p 4 8 2}{cmd:. "A" 18 2}{p_end}
{p 4 8 2}{cmd:. "B" 10 2}{p_end}
{p 4 8 2}{cmd:. "C" 36 2}{p_end}
{p 4 8 2}{cmd:. "D" 56 2}{p_end}
{p 4 8 2}{cmd:. "E" 29 2}{p_end}
{p 4 8 2}{cmd:. "A" 16 3}{p_end}
{p 4 8 2}{cmd:. "B" 16 3}{p_end}
{p 4 8 2}{cmd:. "C" 35 3}{p_end}
{p 4 8 2}{cmd:. "D" 51 3}{p_end}
{p 4 8 2}{cmd:. "E" 10 3}{p_end}
{p 4 8 2}{cmd:. end}{p_end}
{p 4 8 2}{cmd:. label values restore restore}{p_end}
{p 4 8 2}{cmd:. label def restore 1 "none" 2 "partial" 3 "complete"}{p_end}
{p 4 8 2}{cmd:. label var restore "How far restored?" }{p_end}

{p 4 8 2}{cmd:. mylabels 5 10(20)90 5, myscale(logit(@/100)) local(myla)}{p_end}
{p 4 8 2}{cmd:. distplot restore [w=freq], recast(connected) mid over(hospital) trsc(logit(@)) xla(1/3, valuelabel) xsc(r(0.9,3.1) titlegap(*5)) yla(`myla', ang(h)) ytitle(Percent)}


{title:References}

{p 4 4 2}Aitkin, M., D. Anderson, B. Francis, and J. Hinde. 1989. 
{it:Statistical Modelling in GLIM}. Oxford: Oxford University Press. 

{p 4 4 2}Atkinson, A. C. 1985. {it:Plots, Transformations, and Regression}.
Oxford: Oxford University Press. 

{p 4 4 2}Box, G. E. P., W. G. Hunter, and J. S. Hunter. 1978. 
{it: Statistics for Experimenters: An Introduction to Design, Data Analysis, and Model Building}.  New York: Wiley. 

{p 4 4 2}Bross, I. D. J. 1958. How to use ridit analysis. {it:Biometrics}
14: 38-58.

{p 4 4 2}Clogg, C. C. and E. Shihadeh. 1994.
{it:Statistical Models for Ordinal Variables}.
Thousand Oaks, CA: Sage. 

{p 4 4 2}Cox, D. R. and E. J. Snell. 1989. {it:Analysis of Binary Data}.
London: Chapman & Hall.

{p 4 4 2}Cox, N. J. 2001. Plotting graded data: a Tukey-ish approach. 
Presentation to UK Stata users meeting, Royal Statistical Society, 
London, 14-15 May. 
{browse "http://www.stata.com/support/meeting/7uk/cox1.pdf":http://www.stata.com/support/meeting/7uk/cox1.pdf}

{p 4 4 2}Cox, N. J. 2004. Speaking Stata: Graphing categorical and
compositional data. {it:Stata Journal} 4(2): 190{c -}215. 

{p 4 4 2}Cox, N. J. 2014a. 
How can I calculate percentile ranks? How can I calculate plotting positions?
{browse "https://www.stata.com/support/faqs/statistics/percentile-ranks-and-plotting-positions":/https://www.stata.com/support/faqs/statistics/percentile-ranks-and-plotting-positions/} 

{p 4 4 2}Cox, N. J. 2014b. 
Stata tip 119: Expanding datasets for graphical ends.
{it:Stata Journal} 14: 230{c -}235.

{p 4 4 2}Cox, N. J. 2017. Speaking Stata: Tables as lists: The groups
command. {it:Stata Journal} 17(3): !!!{c -}!!!.

{p 4 4 2}Duncan, O. D., H. Schuman, and B. Duncan. 1973. 
{it:Social Change in a Metropolitan Community}.
New York: Russell Sage Foundation. 

{p 4 4 2}Emerson, J. D. 1991. Introduction to transformation.
In {it:Fundamentals of Exploratory Analysis of Variance},
ed. D. C. Hoaglin, F. Mosteller, and J. W. Tukey, 365{c -}400.
New York: Wiley.

{p 4 4 2}Fienberg, S. E. 1980. 
{it:The Analysis of Cross-Classified Categorical Data}.
Cambridge, MA: MIT Press. 

{p 4 4 2}Fleiss, J. L., B. Levin, and M. C. Paik. 2003. 
{it:Statistical Methods for Rates and Proportions}.
Hoboken, NJ: Wiley. 

{p 4 4 2}Flora, J. D. 1988. Ridit analysis. In 
{it:Encyclopedia of Statistical Sciences},
ed. S. Kotz and N. L. Johnson, (8) 136{c -}139.
New York: Wiley. 

{p 4 4 2}Haberman, S. J. 1996. 
{it:Advanced Statistics Volume I: Description of Populations}.
New York: Springer. 

{p 4 4 2}Knoke, D. and P. J. Burke. 1980. {it:Log-linear Models}.
Beverly Hills, CA: Sage. 

{p 4 4 2}McCullagh, P. and J. A. Nelder. 1989. {it:Generalized Linear Models}.
London: Chapman & Hall.

{p 4 4 2}Parzen, E. 1993. Change {it:PP} plot and continuous sample quantile 
function. {it:Communications in Statistics {c -}Theory and Methods} 
22: 3287{c -}3304.

{p 4 4 2}Tukey, J. W. 1960. The practical relationship between the common 
transformations of percentages or fractions and of amounts. Reprinted in 
Mallows, C.L. (ed.) 1990. 
{it:The Collected Works of John W. Tukey. Volume VI: More Mathematical.}
Pacific Grove, CA: Wadsworth & Brooks-Cole, 211{c -}219.

{p 4 4 2}Tukey, J.W. 1961. Data analysis and behavioral science or learning to
bear the quantitative man's burden by shunning badmandments. Reprinted in
Jones, L.V. (ed.) 1986.  {it:The Collected Works of John W. Tukey. Volume III: Philosophy and Principles of Data Analysis: 1949-1964.} Monterey, CA:
Wadsworth & Brooks-Cole, 187{c -}389. 

{p 4 4 2}Tukey, J. W. 1977. {it:Exploratory Data Analysis}.
Reading, MA: Addison-Wesley. 
