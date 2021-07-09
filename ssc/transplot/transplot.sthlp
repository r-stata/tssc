{smcl}
{* 1 July 2020}{...}
{hline}
help for {hi:transplot}
{hline}

{title:Plots for trying out transformations}

{p 8 17 2} 
One-way mode: 

{p 8 17 2}
{cmd:transplot} 
{it:cmd} 
{it:varlist} 
[{cmd:if} {it:exp}] 
[{cmd:in} {it:range}] 
{cmd:,}
{cmdab:tr:ansform(}{it:trans_spec}{cmd:)}
[
{it:cmd_options} 
{cmdab:combine:opts(}{it:combine_opts}{cmd:)} 
]  


{p 8 17 2}
Two-way mode: 

{p 8 17 2}
{cmd:transplot} 
{it:cmd} 
{cmd:(} {it:yvarlist} {cmd:)}  
{cmd:(} {it:xvarlist} {cmd:)}  
[{cmd:if} {it:exp}] 
[{cmd:in} {it:range}] 
{cmd:,}
{cmdab:ytr:ansform(}{it:trans_spec}{cmd:)}
{cmdab:xtr:ansform(}{it:trans_spec}{cmd:)}
[
{it:cmd_options} 
{cmdab:combine:opts(}{it:combine_opts}{cmd:)} 
]  

 
{title:Description}

{p 4 4 2}
{cmd:transplot} draws plots using one or more transformed versions of
supplied numeric variables. One-way and two-way modes are supported. 

{p 4 8 2}For the one-way mode, the syntax starts {cmd:transplot} {it:cmd}
{it:varlist}, where 

{p 8 8 2}{it:cmd} is any graph command for one variable

{p 8 8 2}{it:varlist} specifies one or more numeric variables 

{p 8 8 2}and {cmd:transform()} is a required option. 

{p 4 4 2}With one-way mode a separate plot appears for each variable and
each transformation specified.  

{p 4 8 2}For the two-way mode, the declared syntax starts 
{cmd:transplot} {it:cmd}
{cmd:(} {it:yvarlist} {cmd:)} 
{cmd:(} {it:xvarlist} {cmd:)} where 

{p 8 8 2}{it:cmd} is any graph command for two variables, noting that
commands such as {cmd:twoway connected} are included 

{p 8 8 2}{cmd:(} {it:yvarlist} {cmd:)} specifies one or more numeric variables
to be plotted on the vertical axis (in practice, parentheses {cmd:()}
may be omitted for a single {it:y} variable) 

{p 8 8 2}{cmd:(} {it:xvarlist} {cmd:)} specifies one or more numeric variables
to be plotted on the horizontal axis (in practice, parentheses {cmd:()}
may be omitted; all variables named after the first token are treated as
{it:x} variables)  

{p 8 8 2}and at least one of {cmd:ytransform()} and {cmd:xtransform()}
is a required option.  

{p 4 4 2}With two-way mode a plot is drawn for each combination of
{it:y} variable, {it:x} variable and transformation. 

{p 4 4 2}Some broad advice: {cmd:transplot} allows you to draw many
graphs, but comparison may be difficult with more than a chosen few.  
{cmd:transplot} does not try to be smart about axis labels for 
transformed scales.
{cmd:transplot} is for exploratory analysis, not modelling. 


{title:Options}

{p 4 8 2}{cmd:transform()} is a required option for one-way mode. The
rules are (1) {cmd:@} means the variable itself; (2) a bare Stata
function name such as {cmd:log10} is applied to the variable; (3) an
expression such as {cmd:sqrt(@) - sqrt(1 - @)} is evaluated substituting
the variable name for {cmd:@}. 

{p 4 8 2}{cmd:ytransform()} is a required option for two-way mode if the
{it:y} axis variable is to be transformed. If omitted, the variable is
plotted as it arrives. Otherwise the rules are (1) (2) (3) as above. 

{p 4 8 2}{cmd:xtransform()} is a required option for two-way mode if the
{it:x} axis variable is to be transformed. If omitted, the variable is
plotted as it arrives. Otherwise the rules are (1) (2) (3) as above. 

{p 8 8 2}Transformation expressions containing spaces should be protected by
double quotation marks {cmd:""}. 

{p 4 8 2}{it:cmd_options} are options of {it:cmd}. 

{p 4 8 2}{cmd:combineopts()} are options of {help graph combine}. Note
that this includes {cmd:name()} or {cmd:saving()} should you wish to
name or save the resulting graph. 


{title:Examples}

{p 4 4 2}For most of the graphs here see Cox (2019a). 

{p 4 4 2}Spiegelhalter (2019) includes an example with guesses on how
many jelly beans are in a jar.  The data tell you more about guessing
than about jelly beans, but that is fine. 

{p 4 8 2}{cmd:. use beans, clear}{p_end}
{p 4 8 2}{cmd:. transplot qnorm beans, trans(@ log10) ms(Oh)}{p_end}
{p 4 8 2}{cmd:. transplot kdensity beans, trans(@ log10) combine(col(1))}{p_end}

{p 4 8 2}{cmd:. webuse grunfeld, clear}{p_end}
{p 4 8 2}{cmd:. transplot qnorm invest mvalue kstock, trans(@ log10) ms(Oh)}{p_end}
{p 4 8 2}{cmd:. transplot qnorm invest mvalue kstock, trans(@ log10) ms(Oh) combine(colfirst)}{p_end}
{p 4 8 2}{cmd:. transplot qnorm invest mvalue kstock, trans(@ log10) combine(colfirst) recast(line) lw(medthick)}{p_end}

{p 4 4 2}Note: Although {cmd:qnorm} works fine here, the
community-contributed {cmd:qplot} (Cox 1999, 2005, 2019b) is more
flexible.
 
{p 4 8 2}{cmd:. sysuse auto, clear}{p_end}
{p 4 8 2}{cmd:. transplot scatter mpg weight, ytrans(@ log10 100/@) ms(Oh)}{p_end}
{p 4 8 2}{cmd:. transplot scatter mpg weight, ytrans(@ log10 100/@) xtrans(@ log10) ms(Oh) combine(colfirst)}{p_end}

{p 4 8 2}{cmd:. sysuse census, clear}{p_end}
{p 4 8 2}{cmd:. transplot scatter (marriage divorce) (pop) , ytr(log10) xtr(log10)}{p_end}


{title:Remarks}

{title:{it:Transformations in general}} 

{p 4 4 2}Transformation can mean (for example) using a
transformed scale on a graph axis; transforming variables for later
analysis; using a particular link function in a model. 

{p 4 4 2}Researchers and students alike often have problems deciding
whether and how to choose transformed scales. Teachers often have
problems trying to teach that topic. Whatever makes thinking about 
transformations easier is welcome. The best arguments are often graphical, 
whenever you can see that a transformation works {c -} or is useless. 

{p 4 4 2}What makes use of a transformed scale {c -} or choice of a
transformed scale {c -} easier to think about? 

{p 4 4 2}Without attempting here even a brief history, I note that
Galileo Galilei in 1627 recommended using the geometric mean of bids to
decide on a fair price, in effect recommending thinking on a logarithmic
scale. 

{p 8 8 2}  
In 1627 Galileo "was presented with an amiable dispute between a
Florentine gentleman and a parish priest over the proper method to price
a horse .... one bidder{c -}undoubtedly the priest{c -}had offered ten crowns
and the other one thousand. In arriving at the proper value, the
equestrians asked Galileo to be their arbiter. Was it better to employ
an arithmetic or a geometric proportion in arriving at a fair price
between divergent estimates? A geometric proportion was Galileo's
answer. The real value of the horse was one hundred." 

{p 4 4 2} 
Reston, James. 1994. {it:Galileo: A Life.} New York: HarperCollins, p.218

{p 4 4 2}The toolkit includes (Tukey 1957, 1977; Box and Cox 1964; 
Mosteller and Tukey 1977; Atkinson 1985; Keene 1995)

{p 4 4 2}for variables {it:y}

	logarithms and powers 
	neglog: sign({it:y}) log(1 +|{it:y}|) and its siblings 
	inverse hyperbolic sine asinh()

{p 4 4 2}for proportions {it:p} 

	logit: log [{it:p} / (1 - {it:p})] = log {it:p} - log (1 - {it:p}) 
	folded roots: sqrt({it:p}) - sqrt(1 - {it:p}) and its siblings
	loglog(), cloglog() 

{p 4 4 2}for correlations and similar measures {it:r}

	Fisher's {it:z}: atanh({it:r}) = (1/2) logit((1 + {it:r})/2) 

{p 4 4 2} 
Some goals (or Grails) of transformations are 

	linear relationships 
	additive effects 
	equal variability 
	symmetric distribution (even normal distribution)

{p 4 4 2}The last goal is not the most important, as many researchers
seem to think....

{p 4 4 2}Objections {c -} not always from those new to or naive about
statistics {c -} include

{p 8 8 2}{it:Transformation is troubling.} Using an unfamiliar function
just makes the analysis harder to think about. 

{p 8 8 2}{it:Transformation is tricky.} How do we choose a
transformation without seeming arbitrary or {it:ad hoc}? 

{p 8 8 2}{it:Transformation is treasonous.}  You are proposing changing
the data. How is that allowed or even honest? 

{title:{it:Transformed scales in graphics}}

{p 4 4 2}As people are always coming new to Stata, so a brisk survey of
using transformed scales in graphics comes first.  Graph commands in
most cases allow {cmd:yscale(log)} and {cmd:xscale(log)} as option
choices. 

{p 4 4 2}Limitation: This does not always give what you really want. For
example, with histograms and box plots, working on logarithmic scale
requires a fresh calculation. 

{p 4 4 2}Limitation: {cmd:graph} does not typically make good default
choices of axis labels with a logarithmic scale.  Doing better was
discussed in Cox (2018). The {cmd:niceloglabels} command discussed there
depends on the user specifying a style.  {cmd:style(1)} means labels
like 1 10 100.  {cmd:style(13)} means labels like 1 3 10 30 100.
{cmd:style(125)} means labels like  1 2 5 10 20 50 100. 

{p 4 4 2}Using other transformed scales (e.g. root, logit) divides into
(1) which numbers to use on the transformed scale?  (2) which axis labels to
show values on the original scale?  For more technique, see Cox (2008) and
{cmd:mylabels} (SSC). 

{title:{it:The ladder commands in official Stata}}

{p 4 4 2}{cmd:ladder}, {cmd:gladder} and {cmd:qladder} are official
commands of some vintage.  {cmd:ladder} and {cmd:gladder} were added to
Stata in 1992.  {cmd:qladder} was added to Stata in 2000. A sample
script follows. 

{p 4 8 2}{cmd:. sysuse citytemp, clear}{p_end}
{p 4 8 2}{cmd:. set scheme s1color}{p_end}
{p 4 8 2}{cmd:. ladder tempjuly}{p_end}
{p 4 8 2}{cmd:. gladder tempjuly, l1title("") ylabel(none) xlabel(none) name(gladder)}{p_end}
{p 4 8 2}{cmd:. qladder tempjuly, ylabel(none) xlabel(none) name(qladder)}{p_end}

{p 4 4 2}{cmd:ladder} bins transformed data and does a chi-square test
for normality.  If you want such a test, other tests are surely better,
say Shapiro-Wilk or Doornik-Hansen. Such a test often answers the wrong
question.  For moderate or large sample sizes, it may merely detect
trivial departures from normality.  For small sample sizes, it may
indicate that you do not have enough data. 

{p 4 4 2}{cmd:gladder} transforms data and shows histograms with
comparable normal distributions superimposed. 

{p 4 4 2}{cmd:qladder} transforms data and shows normal quantile plots
with comparable normal distributions as reference lines.  Such plots are
also known as normal probability plots, normal scores plots, or probit
plots.

{p 4 4 2}What is wrong with these commands?

{p 4 4 2}{it:These commands offer too many transformations.} It should
never be true that all the transformations from cube to reciprocal cube
are serious candidates. 

{p 4 4 2}{it:These commands offer too few transformations.} No support
is offered for cube root, neglog, asinh, logit, folded roots or anything
not on the menu. 

{p 4 4 2}{it:Histograms are poor for choosing a transformation.} 
Histograms depend too much on arbitrary choices of bin width and origin. 
Important details are often difficult to spot.  

{p 4 4 2}{it:The official examples are poor.} Fahrenheit temperatures are
interval scale variables. 

{p 4 4 2}{it:One variable at a time.} Often you want to compare two or
more variables. 

{p 4 4 2}{it:No support for group comparisons.} Often you want to
compare two or more groups.

{p 4 4 2}To be fair: The ladder idea is powerful (power full!) and
persuasive.  Many transformations lie on a ladder (as emphasised by 
J.W. Tukey and others):  hence
choose that best suited to the data (possibly the identity
transformation?).  

{p 4 4 2}What is right: These commands are based on the idea of looping
over candidate transformations, generating temporary variables with
transforms and then drawing a graph for each candidate. Finally, combine
graphs and so show a portfolio.

{title:{it:Rumination}}

{p 4 4 2}Command design means thinking through the design carefully
before you write any code. That can be hard....  Commands can suffer
from option creep and other conditions of complexity. The syntax becomes
Baroque if not rococo, and at most only the programmer understands the
command. What the programmer thinks of as a handy Swiss army knife might
be just a Heath Robinson machine (William Heath Robinson, 1872{c -}1944)
or a Rube Goldberg machine (Reuben Garrett Lucius Goldberg, 
1883{c -}1970). 


{title:References}

{p 4 8 2}Atkinson, A.C. 1985. 
{it:Plots, Transformations, and Regression: An Introduction to Graphical Methods of Diagnostic Regression Analysis.} 
Oxford: Oxford University Press. 

{p 4 8 2}Box, G.E.P. and D.R. Cox. 1964.
An analysis of transformations. 
{it:Journal of the Royal Statistical Society, Series B} 26: 211{c -}252.  
https://www.jstor.org/stable/2984418

{p 4 8 2}Cox, N.J. 1999.  
Quantile plots, generalized. 
{it:Stata Technical Bulletin} 51: 16{c -}18. 

{p 4 8 2}Cox, N.J. 2005. 
The protean quantile plot.  
{it:Stata Journal} 5: 442{c -}460. 

{p 4 8 2}Cox, N.J. 2008. 
Plotting on any transformed scale. 
{it:Stata Journal} 8: 142{c -}145.  

{p 4 8 2}Cox, N.J. 2018.  Logarithmic binning and labelling. 
{it:Stata Journal} 18: 262{c -}286. 

{p 4 8 2}Cox, N.J. 2019a. Needing a different space? 
Transformed scales in Stata.
Presentation at  London Stata Conference, 5-6 September 2019, Cass Business School. 
https://www.stata.com/meeting/uk19/slides/uk19_cox.pptx

{p 4 8 2}Cox, N.J. 2019b. Software Update: Quantile plots, generalized. 
{it:Stata Journal} 19: 748. 

{p 4 8 2}Keene, O.N. 1995. The log transformation is special. 
{it:Statistics in Medicine} 14: 811{c -}819.

{p 4 8 2}Mosteller, F. and J.W. Tukey. 1977. 
{it:Data Analysis and Regression: A Second Course in Statistics.} 
Reading, MA: Addison-Wesley. 

{p 4 8 2}Spiegelhalter, D. 2019. 
{it:The Art of Statistics: Learning from Data.} 
London: Penguin. 
 
{p 4 8 2}Tukey, J.W. 1957.
On the comparative anatomy of transformations.
{it:Annals of Mathematical Statistics} 28: 602{c -}632.
https://www.jstor.org/stable/2237224 

{p 4 8 2}Tukey, J.W. 1977. 
{it:Exploratory Data Analysis.} 
Reading, MA: Addison-Wesley. 


{title:Author} 

{p 4 4 2}Nicholas J. Cox, University of Durham, U.K.{break} 
        n.j.cox@durham.ac.uk
		

{title:Also see}

{p 4 13 2}On-line:  help for {help ladder}, {help gladder}, 
{help qladder}, {help qplot} (if installed), {help niceloglabels} (if
installed), {help mylabels} (if installed), {help crossplot} (if
installed) 


