{smcl}
{* *! NJC 10aug2016/25aug2016}{...}
{cmd:help lvalues}
{hline}

{title:Title}

{p 8 8 2}Letter value calculation

{title:Syntax}

{p 8 12 2}
{cmd:lvalues} 
{varlist} 
{ifin} 
[
{cmd:,} 
{opt a(#)} 
{opt by(byvarlist)} 
{c -(} 
{opt gen:erate(newvarlist)} 
{c |}
{opt display:only} 
{c )-} 
{opt l:ist}
{it:list_options} 
]


{title:Description}

{pstd}
{cmd:lvalues} calculates letter values as defined by Tukey (1977)
and Hoaglin (1983) for each variable in {varlist}. By default 
letter values are stored in new variables. Optionally, letter values 
may be displayed only, without generation of new variables. 


{title:Remarks} 

{pstd}
Consider a set of {it:n} values ordered, smallest first, 
so that they have ranks 1 to {it:n}.
The ordered values are often called {it:order statistics} or
(particularly in statistical graphics) the (sample) {it:quantiles}. In
ranking, tied values are here assigned distinct (unique) ranks, so each
integer from 1 to {it:n} is used just once as a rank. 

{pstd} 
The {it:depth} associated with rank {it:i} is the smaller of {it:i} and
{it:n} - {it:i} + 1. Hence the extremes (minimum and maximum) with ranks
1 and {it:n} both have depth 1, the second smallest and second largest
values both have depth 2, and so on. Think of depth as giving the number
of values counted inwards from the extremes. 

{pstd} 
The conventional rule for calculating a median can be stated in terms of
a depth (1 + {it:n})/2. If {it:n} is odd, then the result is an integer;
and if {it:n} is even, then the result is a half-integer. So if {it:n} =
75, the depth is 38, which means that the median is the single value
which has rank 38; if {it:n} = 74, the depth is 37.5, which is
interpreted as the mean of, or midpoint between, the values with ranks
37 and 38.  The median may be tagged with the letter M. The median
is a {it:letter value}, in Tukey's terminology. 

{pstd} 
Further letter values are calculated by extending this idea to mark
successively smaller tail fractions of a sample. Fourths (approximate
quartiles) (tagged F, say) both have a depth which is (1 + floor(depth
of median))/2; eighths (approximate octiles) (tagged E, say) have depth
(1 + floor(depth of fourths))/2; and so on. See Hoaglin (1983) for a
systematic account. In each case integer and half-integer depths imply
selecting single values and averaging adjacent ordered values
respectively. 

{pstd} 
Note that Tukey (1970) discussed medians M, hinges H, eighths E and in
passing sixteenths defined in this way. Tukey (1977) used further letter
values D (for sixteenths), C, B, A, Z, Y, X, and so on, as needed,
stopping when the extremes are reached at depth 1 (each is tagged 1).
These letter tags are used in the output of the {help lv} command.  The
labels M, F, E are pleasantly mnemonic and those and other tags help to
simplify tabular displays.  However, memorising the meanings of other
tags is harder work. Knowing or using the tags is less important than
keeping an eye on the depths, ranks and plotting positions associated
with each letter value. 

{pstd}
The term {it:letter values} historically was closely tied to particular
letter value displays, which could be produced with relatively little
effort from small datasets using only sorting, averaging pairs of
numbers, and subtraction (e.g. Tukey 1977; Mosteller and Tukey 1977;
Velleman and Hoaglin 1981).  {help lv} is the standard Stata
implementation.  Despite the advent of larger datasets and ubiquitous
computing facilities, interest in letter values continues (e.g. Hofmann
{it:et al.} 2011).  In essence, the letter values are interesting and
useful as a parsimonious but informative reduction of a sample
distribution based on order statistics (quantiles), with detail in the
tails. Hence they are pertinent to data screening and exploratory data
analysis, including determination of distribution location, scale and
shape; identification of problematic data points; and consideration of
transformations. 

{pstd}
By default, {cmd:lvalues} calculates new variables as follows. For every
variable in {varlist} there is a new variable containing its
letter values for the observations included in the calculation. In
addition, variables give ranks, depths and plotting positions
{bind:({it:i} - {it:a})/({it:n} - 2{it:a} + 1)} for some
{it:a}. The default variable names for {it:k} variables in {varlist} are
{cmd:_lv1} to {cmd:_lv}{it:k} and {cmd:_rank}, {cmd:_depth} and
{cmd:_ppos}. If any of those names is in use, and alternatives not in
use are not suggested through the {cmd:generate()} option, then the
command will fail. Unlike {help lv}, {cmd:lvalues} will not overwrite
existing variables. 

{pstd}
As no letter value necessarily corresponds uniquely to any single data
value, and as many letter values are means of (midpoints between) data
values, the values of any new variables are (contrary to usual Stata
practice) not to be considered as aligned with values of other variables
in the same observations.  However, if the {cmd:by()} option is used,
values of any new variables will be placed in observations with
corresponding values of the {it:byvarlist} specified. Positively, it is
always true that letter value results are aligned with depths, ranks and
plotting positions. 

{pstd}
The number of letter values for {it:n} values is 
{bind:1 + 2 * ceil(log_2 {it:n})}. 
For {it:n} = 1, that is 1, so the single letter value (median) is just
the single data value.  For {it:n} = 2, 3, 4, 5, 6, 7 the number of
letter values is 3, 5, 5, 7, 7, 7, i.e. in some cases there are more
letter values than data values. For {it:n} <= 7, {cmd:lvalues} just
returns the ordered values.  With that small a sample size, looking at
all the values is both feasible and sensible. 

{pstd} 
Here is a handle on the number of letter values: for {it:n} = 1000, 1
million, 1 billion, there are 21, 41, 61 letter values. Note that {help lv}
will not display or save more than 21 letter values. 

{pstd} 
See also Tukey (1977) and Hoaglin (1985) for more on using letter values
in study of distributions. See Cox (2004) for discussion of related
skewness plots. 


{title:Options}

{phang}
{opt a()} specifies the constant {it:a} in calculating plotting
positions. The default is 1/3, as suggested by Hoaglin (1983) in a
detailed discussion of letter values and plotting positions.  A
particular advantage of this choice is that it corresponds closely to
the position of the median of the sampling distribution of each order
statistic. See also Cox (2014) on plotting positions in a Stata context. 

{phang} 
{opt by()} specifies one or more variables defining distinct groups for
which letter values are to be calculated separately. 

{phang}
{opt generate()} specifies new variable names as alternatives to the
default, up to as many as the number of variables plus 3. If fewer variable
names are suggested, as many of {cmd:_lv1} up, {cmd:_rank}, {cmd:_depth}
and {cmd:_ppos} are used as needed, but those default names used must
still be new in the dataset. 

{phang}
{opt displayonly} specifies display of the letter values only, with no
generation of new variables. Here "display" implies {cmd:list}, as just
below. 

{phang}
{opt list} specifies that the letter values be listed. {cmd:list}
may be specified by itself or together with options of {help list}. The 
default options include {cmd:sep(0) noobs} or (with the {cmd:by()} option)
{cmd:sepby(}{it:byvar}{cmd:) noobs}. Plotting positions are shown 
to 3 decimal places (but stored as {cmd:double} variables). 


{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. sysuse auto}

{pstd}Calculate letter values for {cmd:mpg}{p_end}
{pstd}(default variable names {cmd:_lv1}, {cmd:_rank}, {cmd:_depth},
{cmd:_ppos}):{p_end}
{phang2}{cmd:. lvalues mpg}

{pstd}Calculate letter values for {cmd:mpg} with new names:{p_end}
{phang2}{cmd:. lvalues mpg, generate(lv_mpg rank depth ppos)}

{pstd}Calculate letter values for {cmd:mpg} with new names, separately
by groups of {cmd:foreign}:{p_end}
{phang2}{cmd:. lvalues mpg, generate(lv_mpgf rankf depthf pposf) by(foreign)}

{pstd}Different variables and different groups at once; other options:{p_end}
{phang2}{cmd:. sysuse auto, clear}{p_end}
{phang2}{cmd:. lvalues mpg weight, gen(lv_mpg lv_weight rank depth ppos) by(foreign) list a(0.5)}

{pstd}Display only:{p_end}
{phang2}{cmd:. lvalues headroom trunk weight length displacement, displayonly}


{title:Author}

{pstd}Nicholas J. Cox, Durham University{break}
n.j.cox@durham.ac.uk


{title:Acknowledgment}

{pstd}David Hoaglin rekindled my interest in letter values by a comment
at the Chicago Stata Conference in 2016 and provided helpful encouragement
thereafter. 


{title:References}

{phang}
Cox, N. J. 2004. Graphing distributions. 
{it:Stata Journal} 4: 66{c -}88.          
{browse "http://www.stata-journal.com/sjpdf.html?articlenum=gr0003":http://www.stata-journal.com/sjpdf.html?articlenum=gr0003}

{phang} 
Cox, N. J. 2014. Calculating percentile ranks or plotting positions. 
{browse "http://www.stata.com/support/faqs/statistics/percentile-ranks-and-plotting-positions/":http://www.stata.com/support/faqs/statistics/percentile-ranks-and-plotting-positions/} 

{phang}
Hoaglin, D. C. 1983.
Letter values:  A set of selected order statistics.  In
{it:Understanding Robust and Exploratory Data Analysis},
ed. D. C. Hoaglin, F. Mosteller, and J. W. Tukey, 33{c -}57.
New York: John Wiley.

{phang}
Hoaglin, D. C. 1985. 
Using quantiles to study shape. In 
{it:Exploring Data Tables, Trends, and Shapes},
ed. D. C. Hoaglin, F. Mosteller, and J. W. Tukey, 417{c -}460. 
New York: John Wiley.

{phang} 
Hofmann, H., K. Kafadar, and H. Wickham. 2011. 
Letter-value plots: Boxplots for large data. 
{browse "http://vita.had.co.nz/papers/letter-value-plot.pdf":http://vita.had.co.nz/papers/letter-value-plot.pdf}

{phang} 
Mosteller, F. and J. W. Tukey. 1977. 
{it:Data Analysis and Regression}.
Reading, MA: Addison-Wesley.

{phang}Tukey, J. W. 1970. 
{it:Exploratory data analysis. Limited Preliminary Edition. Volume I.}
Reading, MA: Addison-Wesley. 

{phang}
Tukey, J. W. 1977.
{it:Exploratory Data Analysis}.
Reading, MA: Addison-Wesley.

{phang}
Velleman, P. F. and D. C. Hoaglin. 1981. 
{it:Applications, Basics, and Computing of Exploratory Data Analysis.} 
Boston: Duxbury. 
{browse "https://ecommons.cornell.edu/retrieve/91/A-B-C_of_EDA_040127.pdf":https://ecommons.cornell.edu/retrieve/91/A-B-C_of_EDA_040127.pdf}


{title:Also see}

{psee}
Manual:  {manlink R lv}

{psee}
{space 2}Help:  {manhelp diagnostic_plots R:diagnostic plots},
{manhelp stem R},
{manhelp summarize R}, 
{help qplot} (if installed),
{help skewplot} (if installed), 
{help stripplot} (if installed) 
{p_end}
