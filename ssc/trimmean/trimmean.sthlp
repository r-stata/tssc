{smcl}
{* 30jan2013/6feb2013/22feb2013/12may2013}{...}
{hline}
help for {hi:trimmean}
{hline}

{title:Trimmed means as descriptive or inferential statistics}

{p 8 17 2}{cmd:trimmean}
{it:varname}
[{cmd:if} {it:exp}]
[{cmd:in} {it:range}] 
{cmd:,}
{c -(} 
{cmdab:p:ercent(}{it:numlist}{cmd:)} {c |} 
{cmdab:n:umber(}{it:numlist}{cmd:)} {c |}
{cmdab:m:etric(}{it:numlist}{cmd:)} 
{c )-} 
[
{cmdab:ceil:ing}
{cmdab:w:eighted} 
{cmdab:f:ormat(}{it:format}{cmd:)}
{cmd:ci} 
{cmdab:l:evel(}{it:#}{cmd:)} 
{cmdab:g:enerate(}{it:newvar}{cmd:)} 
]

{p 4 4 2}{cmd:by ... :} may also be used with {cmd:trimmean}: see help on
{help by}.

 
{title:Description}

{p 4 4 2}{cmd:trimmean} calculates symmetric trimmed means as
descriptive or inferential statistics for {it:varname}. 


{title:Literature} 

{p 4 4 2}The reviews by Dixon and Yuen (1974) and Rosenberger and Gasko
(1983) remain clear and helpful on both specific details and wider
context.  Both have often been overlooked in later surveys, for no
obvious good reason. Kafadar (2003) gives an excellent concise review of
Tukey's work on robustness. Stigler (2010) gives a light and brisk
historical perspective on robust statistics in general.  

{p 4 4 2}Introductory or intermediate texts featuring trimmed means include 
Breiman (1973, p.244), 
Dixon and Massey (1983, pp.380{c -}382), 
Siegel (1988, pp.66{c -}68), 
Helsel and Hirsch (1992, p.7), 
Venables and Ripley (2002, p.122), 
van Belle et al. (2004, pp.276{c -}277),
Rice (2007, p.397),
Sprent and Smeeton (2007, pp.461{c -}465), 
Reimann et al. (2008, p.43)  
and 
Feigelson and Babu (2012, p.110). 
 

{title:Definitions}

{p 4 4 2}The order statistics of a sample of n values of y are defined
by  

	y(1) <= y(2) <= ... <= y(n-1) <= y(n)
	
{p 4 4 2}so that y(1) is the smallest and y(n) is the largest. 

{p 4 4 2}The recipe for trimmed means at its simplest is to set aside
some fraction of the lowest order statistics and the same fraction of
the highest order statistics and then to calculate the mean of what
remains, thus providing some protection against possible stretched tails
or outliers in a sample. For example, suppose n = 100 and we set aside
5% in each tail, namely y(1),...,y(5) and y(96),...,y(100). We can then
take the mean of y(6),...,y(95).  For such a definition, see (for
example)
Tukey and McLaughlin (1963, p.336), 
Bickel (1965, p.848), 
Huber (1981, pp.57{c -}8), 
Lehmann (1983, p.360), 
Rosenberger and Gasko (1983, pp.307{c -}8), 
Hampel et al. (1986, p.178), 
Staudte and Sheather (1990, p.104),  
Barnett and Lewis (1994, p.79), 
Miller (1997, p.29), 
David and Nagaraja (2003, p.213), 
Wilcox (2003, pp.62{c -}63), 
Jureckov{c a'} and Picek (2006, p.67), 
Wilcox (2009, p.26), 
Pearson (2011, pp.228, 267), 
Wilcox (2012a, p.55) or 
Wilcox (2012b, p.25).  

{p 4 4 2}The 0% trimmed mean is just the usual mean.  By courtesy, or as
a limiting case, the 50% trimmed mean is taken to be the median.  The
25% trimmed mean has been called the "midmean" (i.e. the mean of the
middle half of the data) (Tukey 1970a, 1970b, p.168, adopting earlier
scientific usage, on which see Tukey 1981, p.871), the "interquartile
mean" (e.g. Tilanus and Rey 1964; Erickson and Nosanchuk 1977, p.40;
1992, p.44) and the "quartile-discard average" (Daniell 1920). 

{p 4 4 2}A more general rule is that the lowest value included in the
calculation of the p% trimmed mean is y(r), where r = 1 + floor(n *
p/100) and the highest value included is thus y(n - r + 1). The
{cmd:ceiling} option specifies use of {help ceil()} rather than 
{help floor()}. See Cox (2003) for more discussion and further references on
floor and ceiling functions. 

{p 4 4 2}Some authors use a yet more elaborate definition in which some
values may be given fractional weights. This definition may be obtained
with the {cmd:weighted} option. See (for example) 
Andrews et al. (1972, pp.7, 31), 
Stigler (1977, p.1060), 
Kleiner and Graedel (1980, p.706), 
Huber (1981, pp.57{c -}8), 
Rosenberger and Gasko (1983, p.311), 
Barnett and Lewis (1994, p.79) 
Huber and Ronchetti (2009, pp.57{c -}58)
or Wilcox (2012a, p.55). 

{p 4 4 2}The precise rule is usually that floor(n * p/100) values are
removed in each tail, and the smallest and largest remaining values are
assigned weight 1 + floor(n * p/100) - n * p/100. So, for example, given
n = 74 and percent 5/100, their product is 3.7. Rounding down gives 3
and so we work with y(4),...,y(71).  However, y(4) and y(71) are
assigned weight 4 - 3.7 = 0.3 and y(5),...,y(70) weight 1.  Then a
weighted mean is taken. 

{p 4 4 2}The idea underlying this alternative definition appears
twofold: p% should mean precisely that, and also that the result of
trimming should vary as smoothly as possible with p. Rosenberger and
Gasko explain this especially clearly with two helpful diagrams
(pp.310{c -}1). 

{p 4 4 2}The difference is partly a matter of taste. But always using
weights that are 1 or 0 is appealingly simple and appears entirely
adequate for descriptive and exploratory uses. Moreover, any fine
structure that results from the inclusion and exclusion of particular
values as trimming proportion varies is likely to be trivial or part of
what we are watching for, so there is little loss either way.  

{p 4 4 2}In some situations it is more natural to specify trimming in
terms of the number of values trimmed, rather than the percent. For
example, trimming or truncating procedures have been used in combining
the scores of a panel of judges in various sports, as a way of
discouraging or discounting partisan bias for or against competitors.
Here the rules might require, for example, trimming the highest and
lowest values. The {cmd:number()} option is provided for this situation. 

{p 4 4 2}Whatever the precise definition, trimming the same number of
order statistics in each tail is arguably based on a symmetry
assumption, if not that the distribution of interest is approximately
symmetric, then that the chances of contamination are approximately
equal in either tail. The opposite argument is that the estimand is
whatever the estimator points to.  "We must give even more attention to
starting with an estimator and discovering what is a reasonable
estimand, to discovering what is it reasonable to think of the estimator
as estimating" (Tukey 1962, p.60). A similar point of view has been
elaborated more formally in considerable detail and depth by Bickel and
Lehmann (1975). 

{p 4 4 2}Confidence intervals may be produced using the {cmd:ci} option.
The approach follows Tukey and McLaughlin (1963). 
Note also Dixon and Tukey (1968) as the sequel to that paper. 
For a one-sentence summary, see Huber (1972, pp.1053{c -}1054). 
For lucid textbook accounts, see (e.g.)
Staudte and Sheather (1990, p.98),  
Miller (1997, pp.30{c -}31), 
Wilcox (2003, pp.126{c -}132), 
Huber and Ronchetti (2009, pp.147{c -}148),  
Wilcox (2009, pp.98{c -}99, 127{c -}128, 150{c -}151),
Wilcox (2010, pp.153{c -}154), 
Wilcox (2012a, pp.57{c -}61, 111{c -}114) or 
Wilcox (2012b, pp.153{c -}159). 

{p 4 4 2}Suppose we have n values and trim g in each tail and we seek
level% confidence intervals (e.g. level = 95). We need first a
Winsorized standard deviation. Winsorizing is replacing values in each
tail by the next inward value, i.e. y(1) ... y(g) are each replaced by
y(g+1) and y(n-g+1) ... y(n) are each replaced by y(n-g) before
calculation, so long as g >= 1. Let sd_W denote the standard deviation
of the Winsorized values. Then intervals are mean +/- (t-multiplier *
sd_W) / (sqrt(n) * (1 - 2 * g/n)), where the t-multiplier is
{cmd:invttail(n - 2*g - 1, (100 - level)/200)}. 

{p 4 4 2}Note that {cmd:trimmean} uses {help summarize} to calculate the
standard deviation, so that as documented in [R] summarize the divisor
before rooting is (n - 1). The fraction of values used in the trimmed
mean 1 - 2 * g/n is calculated from the number actually used, not from
any percent trimming specified. 

{p 4 4 2}This approach does not in the limit give reasonable confidence
intervals for the median, as the number of degrees of freedom approaches
0. {cmd:trimmean} declines to cite confidence intervals for the median;
otherwise obtaining intervals for large trimming fractions is left to
the judgment of the user. 

{p 4 4 2}As another approach to confidence intervals, bootstrapping is
quite attractive.  Efron and Tibshirani (1993) and Davison and Hinkley
(1997) both discuss bootstrapping trimmed means. Although all results
are returned in a matrix, {cmd:trimmean} also saves each trimmed mean
separately as a convenience. However, bootstrapping necessarily implies
that wild values could be selected repeatedly in a bootstrap sample, so
that some individual trimmed means could be much less resistant than the
mean based on the sample as a whole. The converse is also true. 

{p 4 4 2}As yet another alternative, the {cmd:metric()} option
implements trimmed means that are means of values satisfying some
constraint on |y - median(y)| = d. Thus d = 0 identifies data points
equal to the median, while such a trimmed mean equals the mean so long
as d >= max(median(y) - y(1), y(n) - median(y)).  The name "metric"
echoes Bickel (1965), Kim (1992) and Venables and Ripley (2002, p.122);
none of those cited the earlier work of Short (1763). Metric trimming
can be combined with trimming based on order statistics (e.g. Hampel,
1997, p.150; Olive, 2001), but only the simplest flavour is supported
here.  See also Huber (1964) for a brief mention and Hampel (1985) for
broader discussion. 

{p 4 4 2}Trimmed means may also be based on trimming differently in each
tail, including the case of trimming in one tail only. In their text
Staudte and Sheather (1990), for example, first introduce trimmed means
in terms of trimming only in the right tail when estimating the scale of
an exponential distribution. Such trimming lies beyond the scope of this
command. 


{title:Historical remarks} 

{p 4 4 2}The idea of a trimmed mean is quite old. For some related
history, see Stigler (1973, 1976), Harter (1974a, 1974b), Hampel et al.
(1986, pp.34{c -}36) and Barnett and Lewis (1994, pp.27{c -}31).

{p 4 4 2}James Short (1710{c -}1768) used a relative of what is now
called metric trimming in 1763 for estimating the sun's parallax based
on observations of the transit of Venus across the face of the Sun. His
method took the mean of values closer than some chosen distance from the
mean of all. The parallax here is the angle subtended by the Earth's
radius, as if viewed and measured from the surface of the Sun. The units
are seconds of a degree. Note that repeating his calculations points up
small errors in his arithmetic.  For much more on measuring the transit
of Venus in 1761 (and 1769) as a major research programme in astronomy,
see Woolf (1959) or Wulf (2012).  Woolf (1959, p.147) commented: "One of
the factors that had rendered Short's results so homogeneous had been
the rather judicious series of alterations which he had made in the
original data concerning longitude and time of contact at various
stations". Short's line, however, was that he was fixing the mistakes of
others.  

{p 4 4 2}53 measurements are given on p.310 of Short's paper. These are
datasets (1) to (3) in Stigler (1977, p.1074). He first averages all 53
and gets 8.61; then all 45 within 1 of that mean and gets 8.55; then all
37 within 0.5 of that mean and gets 8.57.  Then he takes the mean of all
3 means and gets 8.58. In effect his final mean is weighted according to
deviations from the initial overall mean.  

{p 4 4 2}Similarly 63 measurements are given on p.316 of his paper.
These are datasets (4) to (6) in Stigler (1977, p.1074). He first
averages all 63 and gets 8.63; then all 49 within 1 of that mean and
gets 8.50; then all 37 within 0.5 and gets 8.535. The mean of all 3
means is 8.55. 

{p 4 4 2}Short's data on p.325 of his paper are datasets (7) and (8) in
Stigler (1977, p.1074). The mean of 21 values in the first set, for the
Cape of Good Hope, is 8.56. All 29 values are within 0.2 of that. The
mean of 21 values in the second set, for Rodrigues, is 8.57; the same
mean is obtained for all 13 within 0.2. 
 
{p 4 4 2}An anonymous writer (identified by Stigler, 1976, as Joseph
Diaz Gergonne, 1771{c -}1859) included an example of trimmed means in a
discussion of how to calculate means (1821, p.189). "For example, there
are certain provinces of France where, to determine the mean yield of a
property of land, there is a custom to observe this yield during twenty
consecutive years, to remove the strongest and the weakest yield and
then to take one eighteenth of the sum of the others" (translation in
Huber, 1972, p.1043).

{p 4 4 2}Mendeleev (1895) (reference in Harter, 1974b) reported his
method "to evaluate the harmony of a series of observations that must
give identical numbers, namely I divide all the numbers into three, if
possible equal, groups (if the number of observations is not divisible
by three, the greatest number is left in the middle group): those of
greatest magnitude, those of medium magnitude, and those of smallest
magnitude; the mean of the middle group is considered the most probable
... and if the mean of the remaining groups is close to it ... the
observations are considered harmonious" (Harter, 1974b, p.241).  

{p 4 4 2}Daniell (1920) gave an elegant and path-breaking general
treatment of statistics that are linear combinations of the order
statistics, including various estimators of location and scale. It was
apparently inspired by a reading of Poincar{c e'}'s 
{it:Calcul des probabilit{c e'}s} (1912). Daniell derived optimal
weighting functions and gave the first mathematical treatment of the
trimmed mean. However, his paper had essentially no impact before its
rediscovery by Stigler (1973). Its placement in a journal rarely read by
statisticians cannot have helped. 

{p 4 4 2}Tukey (1960) surveyed the problem of location estimation when
data are likely to come from distributions heavier-tailed than the
normal (Gaussian) in a path-breaking paper. In particular, he showed
that truncated means calculated after dropping the same percentage of
the lowest and highest values offered considerable protection in the
face of such distributions. 

{p 4 4 2}The term "trimmed mean" was introduced by Tukey (1962).  Names
in earlier use include "truncated mean" (Tukey 1960, as above) and
"discard average" (Daniell, 1920).  Dixon (1960) discussed using means
of a censored sample. Talking of truncation or censoring raises the need
to distinguish carefully between truncation or censoring of the data
before they arrive and such truncation or censoring used deliberately in
data analysis, reason enough for using the term "trimming" instead. 


{title:Other Stata implementations} 

{p 4 4 2}Note that the user-written program {cmd:iqr} by Hamilton (1991)
calculates the 10% trimmed mean (only) as a sideline to other aims. His
definition is the mean of values greater than the 10% percentile and
less than the 90% percentile as calculated by {help summarize}, so
results may often differ at least slightly from those calculated by
{cmd:trimmean}. 

{p 4 4 2}The user-written program {cmd:robmean} by Ender (2009)
calculates trimmed means according to the fraction trimmed (equivalent
to the default here with the {cmd:p()} option), together with some other
quantities.

{p 4 4 2}Stata here lags behind other statistical software: "a trimmed
mean" was added to BMDP in 1977 (Hill and Dixon 1982, p.378).  


{title:Options}

{p 4 8 2}{cmdab:p:ercent(}{it:numlist}{cmd:)} specifies percents of
trimming for one or more trimmed means. Percents must be integers
between 0 and 50, but otherwise can be specified as a {help numlist}.

{p 4 8 2}{cmdab:n:umber(}{it:numlist}{cmd:)} specifies numbers of values
to be trimmed for one or more trimmed means. Numbers must be zero or
positive integers less than half the number of observations available,
but otherwise can be specified as a {help numlist}.

{p 4 8 2}{cmdab:m:etric(}{it:numlist}{cmd:)} specifies trimming such that means
are of values within a specified absolute deviation of the median of a variable
(y, say). Suppose {cmd:metric(0 100 200)} is specified. Then the means are
means of values satisfying |y - med(y)| <= 0, 100, 200.  Deviations must be
zero or positive values, but otherwise can be specified as a {help numlist}.

{p 4 8 2}Precisely one of {cmd:percent()} or {cmd:number()} or
{cmd:metric()} is required. 

{p 4 8 2}{cmdab:ceil:ing} specifies use of {help ceil()} rather than
{help floor()} in the calculation of ranks to be included. It is allowed
with {cmd:number()} or {cmd:metric()}, but ignored as irrelevant. This
variation is occasionally suggested in the literature (e.g. Huber in
Andrews et al., 1972, p.254). 

{p 4 8 2}{cmdab:w:eighted} implements a weighted variant explained in
detail in the {cmd:Definitions}. It is allowed with {cmd:number()} or
{cmd:metric}, but ignored as irrelevant. This option may not be combined
with {cmd:ci}. 

{p 4 8 2}{cmd:ci} specifies production of confidence intervals. This
option may not be combined with {cmd:weighted} or {cmd:metric()}. For
detailed discussion, see {cmd:Definitions} above. 

{p 4 8 2}{cmdab:l:evel(}{it:#}{cmd:)} sets a confidence level for
confidence intervals.  The default is as recorded in {cmd:c(level)}. 

{p 4 8 2}{cmdab:f:ormat(}{it:format}{cmd:)} specifies a numeric format
for displaying trimmed means (and confidence limits when requested). The
default is the display format of {it:varname}. 

{p 4 8 2}{cmdab:g:enerate(}{it:newvar}{cmd:)} specifies that an
indicator (a.k.a. dummy) variable be generated with value 1 if an
observation was included in the last trimmed mean calculated and 0
otherwise. The trimmed mean with highest trimming percent or number or
allowed deviation is always produced last, regardless of user input. 


{title:Examples} 

{p 4 8 2}{cmd:. sysuse auto}{p_end}
{p 4 8 2}{cmd:. trimmean mpg, p(0(5)50)}{p_end}
{p 4 8 2}{cmd:. trimmean mpg if foreign, p(0(5)50)}{p_end}
{p 4 8 2}{cmd:. trimmean price if foreign, p(0(5)50) format(%6.1f)}


{title:Saved results} 

{p 4 18 2}r(results){space 4}Stata matrix with columns percents or numbers,
number averaged and trimmed means (and confidence limits when requested) 

{p 4 18 2}r(tmean#){space 5}each trimmed mean for percent or number # (e.g.
tmean5 for 5%) (with the {cmd:metric()} option, labelling is 1 upwards,
not with deviations specified) 


{title:Author}

{p 4 4 2}Nicholas J. Cox, Durham University, U.K.{break}
n.j.cox@durham.ac.uk


{title:Acknowledgments} 

{p 4 4 2}Rebecca Pope and Ariel Linden both found a typo in the help.
Ariel suggested an option for generating indicator variables.  David
Hoaglin was very helpful in identifying citations in and around Tukey's
work. 


{title:References} 

{p 4 8 2}Aldrich, J. 2007. 
"But you have to remember P. J. Daniell of Sheffield". 
{it:Electronic Journal for History of Probability and Statistics}
3(2): 1{c -}58. 
{browse "http://www.emis.de/journals/JEHPS/Decembre2007/Aldrich.pdf": http://www.emis.de/journals/JEHPS/Decembre2007/Aldrich.pdf}

{p 4 8 2}Andrews, D.F., Bickel, P.J., Hampel, F.R., Huber, P.J., Rogers,
W.H. and Tukey, J.W. 1972. 
{it:Robust estimates of location: Survey and advances.}
Princeton, NJ: Princeton University Press. 

{p 4 8 2}Anonymous. 1821. 
Dissertation sur la recherche du milieu le plus probable, entre les 
r{c e'}sultats de plusieurs observations ou exp{c e'}riences. 
{it:Annales de Math{c e'}matiques Pures et Appliqu{c e'}es}
12: 181{c -}204.
{browse "http://www.numdam.org/item?id=AMPA_1821-1822__12__181_0":http://www.numdam.org/item?id=AMPA_1821-1822__12__181_0} 

{p 4 8 2}Barnett, V. and Lewis, T. 1994. 
{it:Outliers in statistical data.} 
Chichester: John Wiley. 

{p 4 8 2}Bickel, P.J. 1965. 
On some robust estimates of location.
{it:Annals of Mathematical Statistics} 36: 847{c -}858.  

{p 4 8 2}Bickel, P.J. and Lehmann, E.L. 1975. 
Descriptive statistics for nonparametric models. II. Location. 
{it:Annals of Statistics} 3: 1045{c -}1069.

{p 4 8 2}Breiman, L. 1973.
{it:Statistics: With a view toward applications.}
Boston: Houghton Mifflin. 

{p 4 8 2}Cox, N.J. 2003. 
Stata tip 2: Building with floors and ceilings. 
{it:Stata Journal} 3: 446{c -}447. 
{browse "http://www.stata-journal.com/sjpdf.html?articlenum=dm0002":http://www.stata-journal.com/sjpdf.html?articlenum=dm0002}

{p 4 8 2}Daniell, P.J. 1920. 
Observations weighted according to order. 
{it:American Journal of Mathematics} 42: 222{c -}236. 

{p 4 8 2}David, H.A. and Nagaraja, H.N. 2003. 
{it:Order statistics.} 
Hoboken, NJ: John Wiley. 

{p 4 8 2}Davison, A.C. and Hinkley, D.V. 1997. 
{it:Bootstrap methods and their application.} 
Cambridge: Cambridge University Press. 

{p 4 8 2}Dixon, W.J. 1960. 
Simplified estimation from censored normal samples. 
{it:Annals of Mathematical Statistics} 31: 385{c -}391.

{p 4 8 2}Dixon, W.J. and Massey, F.J. 1951, 4th edition 1983. 
{it:Introduction to statistical analysis.} 
New York: McGraw-Hill. 

{p 4 8 2}Dixon, W.J. and Tukey, J.W. 1968. 
Approximate behavior of the distribution of Winsorized t 
(Trimming/Winsorization 2). 
{it:Technometrics} 10: 83{c -}98. 

{p 4 8 2}Dixon, W.J. and Yuen, K.K. 1974. 
Trimming and Winsorization: A review. 
{it:Statistische Hefte}
15: 157{c -}170.

{p 4 8 2}Efron, B. and Tibshirani, R.J. 1993. 
{it:An introduction to the bootstrap.} 
New York: Chapman and Hall. 

{p 4 8 2}Ender, P.B. 2009. 
robmean: Trimmed, Winsorized means & Huber 1-step estimator. 
{browse "http://www.ats.ucla.edu/stat/stata/ado/analysis": http://www.ats.ucla.edu/stat/stata/ado/analysis}
[accessed 3 April 2013]
 
{p 4 8 2}Erickson, B.H. and Nosanchuk, T.A. 1977. 
{it:Understanding data.} 
Toronto: McGraw-Hill Ryerson. 

{p 4 8 2}Erickson, B.H. and Nosanchuk, T.A. 1992. 
{it:Understanding data.} 
Toronto: University of Toronto Press. 

{p 4 8 2}Feigelson, E.D. and Babu, G.J. 2012. 
{it:Modern statistical methods for astronomy with R applications.} 
Cambridge: Cambridge University Press. 

{p 4 8 2}Flournoy, N. 1993.  
A conversation with Wilfrid J. Dixon. 
{it:Statistical Science} 8: 458{c -}477. 

{p 4 8 2}Flournoy, N. 2010. 
Wilfrid Joseph Dixon, 1915{c -}2008. 
{it:Journal of the Royal Statistical Society, Series A}
173: 455{c -}457. 

{p 4 8 2}Gordin, M.D. 2004. 
{it:A well-ordered thing: Dmitrii Mendeleev and the shadow of the periodic table.} 
New York: Basic Books. 

{p 4 8 2}Hamilton, L.C. 1991. 
Resistant normality check and outlier identification. 
{it:Stata Technical Bulletin} 3: 15{c -}18. 
{browse "http://www.stata.com/products/stb/journals/stb3.pdf":http://www.stata.com/products/stb/journals/stb3.pdf}

{p 4 8 2}Hampel, F.R. 1985. 
The breakdown points of the mean combined with some rejection rules. 
{it:Technometrics} 27: 95{c -}107.

{p 4 8 2}Hampel, F.R. 1997. 
Some additional notes on the "Princeton robustness year". 
In Brillinger, D.R., Fernholz, L.T. and Morgenthaler, S. (eds) 
{it:The practice of data analysis: Essays in honor of John W. Tukey.}
Princeton, NJ: Princeton University Press, 133{c -}153. 

{p 4 8 2}Hampel, F.R., Ronchetti, E.M., Rousseeuw, P.J. and Stahel, W.A. 1986. 
{it:Robust statistics: The approach based on influence functions.} 
New York: John Wiley. 

{p 4 8 2}Harter, H.L. 1974a. 
The method of least squares and some alternatives: Part I. 
{it:International Statistical Review}
42: 147{c -}174.

{p 4 8 2}Harter, H.L. 1974b. 
The method of least squares and some alternatives: Part II. 
{it:International Statistical Review}
42: 235{c -}264 and 282.

{p 4 8 2}Helsel, D.R. and Hirsch, R.M. 1992.
{it:Statistical methods in water resources.} 
Amsterdam: Elsevier.  

{p 4 8 2}Hill, M. and Dixon, W.J. 1982. 
Robustness in real life: a study of clinical laboratory data.
{it:Biometrics} 38: 377{c -}396.

{p 4 8 2}Huber, P.J. 1964. 
Robust estimation of a location parameter. 
{it:Annals of Mathematical Statistics} 35: 73{c -}101. 

{p 4 8 2}Huber, P.J. 1972. 
Robust statistics: A review.
{it:Annals of Mathematical Statistics} 43: 1041{c -}1067. 

{p 4 8 2}Huber, P.J. 1981. 
{it:Robust statistics.} 
New York: John Wiley. 

{p 4 8 2}Huber, P.J. and Ronchetti, E.M. 2009. 
{it:Robust statistics.} 
Hoboken, NJ: John Wiley. 

{p 4 8 2}Jennrich, R.I. 2007. 
BMDP and some statistical computing history.
{it:Statistical Computing and Graphics} 18(1): 17{c -}23. 
{browse "http://stat-computing.org/newsletter/issues/scgn-18-1.pdf":http://stat-computing.org/newsletter/issues/scgn-18-1.pdf}

{p 4 8 2}Jureckov{c a'}, J. and Picek, J. 2006.
{it:Robust statistical methods with R.} 
Boca Raton, FL: Chapman and Hall/CRC. [caron on "c" of Jureckov{c a'}] 

{p 4 8 2}Kafadar, K. 2003.
John Tukey and robustness. 
{it:Statistical Science} 18: 319{c -}331. 

{p 4 8 2}Kim, S.-J. 1992.
The metrically trimmed mean as a robust estimator of location. 
{it:Annals of Statistics} 20: 1534{c -}1547.

{p 4 8 2}Kleiner, B. and Graedel, T.E. 1980. 
Exploratory data analysis in the geophysical sciences. 
{it:Reviews of Geophysics and Space Physics} 
18: 699{c -}717.              

{p 4 8 2}Lehmann, E.L. 1983. 
{it:Theory of point estimation.}
New York: John Wiley.

{p 4 8 2}Miller, R.G. 1986. 
{it:Beyond ANOVA: Basics of applied statistics.} 
New York: John Wiley. Reissued 1997. London: Chapman and Hall.

{p 4 8 2}Olive, D.J. 2001. 
High breakdown analogs of the trimmed mean.
{it:Statistics and Probability Letters}
51: 87{c -}92.

{p 4 8 2}Pearson, R.K. 2011. 
{it:Exploring data in engineering, the sciences, and medicine.} 
New York: Oxford University Press. 

{p 4 8 2}Poincar{c e'}, H. 1912. 
{it:Calcul des probabilit{c e'}s.} 
Paris: Gauthier-Villars. 
{browse "http://archive.org/details/calculdeprobabil00poinrich":http://archive.org/details/calculdeprobabil00poinrich} 

{p 4 8 2}Reimann, C., Filzmoser, P., Garrett, R. and Dutter, R. 2008.  
{it:Statistical data analysis explained.}
Chichester: John Wiley. 

{p 4 8 2}Rice, J.A. 2007. 
{it:Mathematical statistics and data analysis.}
Belmont, CA: Duxbury.

{p 4 8 2}Rosenberger, J.L. and Gasko, M. 1983. 
Comparing location estimators: trimmed means, medians, and trimean. 
In Hoaglin, D.C., Mosteller, F. and Tukey, J.W. (Eds)
{it:Understanding robust and exploratory data analysis.}
New York: John Wiley, 297{c -}338. 

{p 4 8 2}Short, J. 1763. 
Second paper concerning the parallax of the sun determined from the 
observations of the late transit of Venus, in which this subject is 
treated of more at length, and the quantity of the parallax more 
fully ascertained. 
{it:Philosophical Transactions of the Royal Society of London}
53: 300{c -}345. 
{browse "http://www.jstor.org/stable/105736":http://www.jstor.org/stable/105736}

{p 4 8 2}Siegel, A.F. 1988.                        
{it:Statistics and data analysis: an introduction.} 
New York: John Wiley. 

{p 4 8 2}Sprent, P. and Smeeton, N.C. 2007. 
{it:Applied nonparametric statistical methods.}
Boca Raton, FL: CRC Press. 

{p 4 8 2}Staudte, R.G. and Sheather, S.J. 1990.
{it:Robust estimation and testing.} 
New York: John Wiley. 

{p 4 8 2}Stewart, C.A. 1947. 
P.J. Daniell. 
{it:Journal of the London Mathematical Society}
22: 75{c -}80.

{p 4 8 2}Stigler, S.M. 1973. 
Simon Newcomb, Percy Daniell, and the history of robust estimation 
1885{c -}1920. 
{it:Journal of the American Statistical Association}
68: 872{c -}879. 

{p 4 8 2}Stigler, S.M. 1976. 
The anonymous Professor Gergonne. 
{it:Historia Mathematica}
3: 71{c -}74. 

{p 4 8 2}Stigler, S.M. 1977. 
Do robust estimators work with real data?
{it:Annals of Statistics}
5: 1055{c -}1098.

{p 4 8 2}Stigler, S.M. 2010. 
The changing history of robustness. 
{it:American Statistician} 
64: 277{c -}281. 

{p 4 8 2}Tilanus, C.B. and Rey, G. 1964. 
Input-output volume and value predictions for the Netherlands, 1948{c -}1958. 
{it:International Economic Review} 5: 34{c -}45.

{p 4 8 2}Tukey, J.W. 1960. 
A survey of sampling from contaminated distributions. 
In Olkin, I., Ghurye, S.G., Hoeffding, W., Madow, W.G. and Mann, H.B. (Eds) 
{it:Contributions to probability and statistics: Essays in honor of Harold Hotelling.} 
Stanford, CA: Stanford University Press, 448{c -}485. 

{p 4 8 2}Tukey, J.W. 1962. 
The future of data analysis. 
{it:Annals of Mathematical Statistics} 33: 1{c -}67.

{p 4 8 2}Tukey, J.W. 1970a. 
{it:Exploratory data analysis.} Limited preliminary edition, 3 volumes. 
Reading, MA: Addison-Wesley. 

{p 4 8 2}Tukey, J.W. 1970b. 
Some further inputs. 
In Merriam, D.F. (Ed.)
{it:Geostatistics: a colloquium.}
New York: Plenum, 163{c -}174.

{p 4 8 2}Tukey, J.W. 1981. 
Choosing techniques for the analysis of data.
Reprinted in Jones, L.V. (ed.) 1988. 
{it:The collected works of John W. Tukey. Volume IV Philosophy and principles of data analysis: 1965-1986.}
Monterey, CA: Wadsworth and Brooks/Cole, 869{c -}874. 

{p 4 8 2}Tukey, J.W. and McLaughlin, D.H. 1963. 
Less vulnerable confidence and significance procedures for location based on 
a single sample: Trimming/Winsorization 1. 
{it:Sankhya, Series A} 25: 331{c -}352.
[macron on last "a" of Sankhya] 

{p 4 8 2}Turner, G.L'E. 1969. 
James Short, F.R.S., and his contribution to the construction of reflecting telescopes. 
{it:Notes and Records of the Royal Society of London}
24: 91{c -}108. 

{p 4 8 2}van Belle, G., Fisher, L.D., Heagerty, P.J. and Lumley, T. 2004.
{it:Biostatistics: A methodology for the health sciences.} 
Hoboken, N.J.: John Wiley. 

{p 4 8 2}Venables, W.N. and Ripley, B.D. 2002. 
{it:Modern applied statistics with S.} 
New York: Springer. 

{p 4 8 2}Wilcox, R.R. 2003. 
{it:Applying contemporary statistical techniques.} 
San Diego, CA: Academic Press. 

{p 4 8 2}Wilcox, R.R. 2009. 
{it:Basic statistics: Understanding conventional methods and modern insights.} 
New York: Oxford University Press. 

{p 4 8 2}Wilcox, R.R. 2010. 
{it:Fundamentals of modern statistical methods: Substantially improving power and accuracy.} 
New York: Springer. 

{p 4 8 2}Wilcox, R.R. 2012a. 
{it:Introduction to robust estimation and hypothesis testing.} 
Waltham, MA: Academic Press. 

{p 4 8 2}Wilcox, R.R. 2012b. 
{it:Modern statistics for the social and behavioral sciences: A practical introduction.} 
Boca Raton, FL: CRC Press. 

{p 4 8 2}Woolf, H. 1959. 
{it:The transits of Venus: A study of eighteenth-century science.} 
Princeton, NJ: Princeton University Press. 

{p 4 8 2}Wulf, A. 2012. 
{it:Chasing Venus: The race to measure the heavens.} 
London: William Heinemann. 


{title:Vignettes}

{p 4 4 2}Percy John Daniell (1889{c -}1946) was born to British parents
in Valparaiso, Chile. He was the last publicly declared Senior Wrangler
in Mathematics (top student in his year) at Cambridge in 1909. After
brief periods in Liverpool and G{c o:}ttingen, he taught and researched
at the Rice Institute at Houston (1912{c -}1924) before returning to
Britain as Professor of Mathematics at Sheffield. Daniell's
contributions span a wide range from pure mathematics to applied
mathematics and statistics; they were surveyed briefly by Stewart (1947)
and Stigler (1973) and in much more detail by Aldrich (2007). 

{p 4 4 2} 
Wilfrid Joseph Dixon (1915{c -}2008) was born in Portland, Oregon. He
received degrees in mathematics and statistics from Oregon State
College, the University of Wisconsin and Princeton. He was on the
faculty at the University of Oklahoma, the University of Oregon and
UCLA, where he was a leader in biostatistics and biomathematics. Dixon's
statistical interests were wide-ranging, including robust estimation in
the presence of outliers, and he collaborated on many projects with
medical scientists. With Frank Jones Massey, Jr. (1919{c -}1995) he
wrote a major statistics text for non-mathematicians, which was unusual
in including material on trimming and Winsorizing in its 3rd and 4th
editions (1969, 1983). From 1961 he led the development of the package
which has morphed over its history from BIMED to BIMD to BMD to BMDP.
See Flournoy (1993, 2010) and Jennrich (2007) for more details. 

{p 4 4 2}Donald Hatch McLaughlin (1941{c -}) earned degrees in
mathematics and psychology from Princeton, the University of
Pennsylvania, and Carnegie-Mellon and taught psychology at Berkeley for
six years. From 1973 he worked for the American Institutes for Research
in Palo Alto and independently as a senior researcher and consultant on
many applied projects in education and several other areas. 

{p 4 4 2}Dmitrii Ivanovich Mendeleev (1835{c -}1907) was born near
Tobolsk in Siberia. He studied and researched in chemistry in St
Petersburg and Heidelberg, quickly rising to professorial rank and
establishing St Petersburg as a major centre in chemical research.
Mendeleev is best known for his work developing a periodic table of the
elements, distinguished not only for providing a classification but also
for allowing the prediction of other elements and correcting errors in
the measurement of atomic weights. He was, however, much more than an
outstanding chemist: "The same individual who composed the periodic
system also helped design the highly protectionist Russian tariff of
1891, battled local Spiritualists, created a smokeless gunpowder,
attempted Arctic exploration, consulted on oil development in Baku,
investigated iron and coal deposits, published art criticism, flew in
balloons, introduced the metric system, and much more" (Gordin, 2004,
p.xviii).  Numerous different transliterations of his name exist. 

{p 4 4 2}James Short (1710{c -}1768) was born in Edinburgh and first
educated to become a minister, but with inspiration and support from
Colin MacLaurin he became more interested in mathematics and optics, and
specifically the construction of telescopes.  He used metallic specula
and succeeded in giving them true parabolic and elliptic shapes. Short
adopted telescope-making as his profession, practising with great
success in Edinburgh and then London.  He was elected Fellow of the
Royal Society and published many of his observations, including his
calculation of solar parallax from the 1761 transit of Venus.  See also
Turner (1969).  Note that Short was Scottish, not English as stated by
Stigler (1973, p.873).

{p 4 4 2}John Wilder Tukey (1915--2000) was born in New Bedford,
Massachusetts.  He studied chemistry at Brown and mathematics at
Princeton and afterward worked at both Princeton and Bell Labs, as well
as being involved in a great many government projects, consultancies,
and committees. He made outstanding contributions to several areas of
statistics, including time series, multiple comparisons, robust
statistics, and exploratory data analysis. Tukey was extraordinarily
energetic and inventive, not least in his use of terminology: he has
been credited with inventing the term bit, in addition to
ANOVA, boxplot, data analysis, hat matrix, jackknife, stem-and-leaf
plot, trimming, and Winsorizing, among many others. He was awarded the
U.S. National Medal of Science in 1973.  Tukey’s direct and indirect
impacts mark him as one of the greatest statisticians of all time.  

{p 4 4 2}Charles P. Winsor (1895{c -}1951) was educated at Harvard as an
engineer and then worked for the New England Telephone and Telegraph
Company, but his interests shifted to biological research and
biostatistics. After further study at Johns Hopkins and Harvard, he held
posts at Iowa State College and Johns Hopkins; in between, in the Second
World War, he did government work at Princeton. The term "Winsorize" has
been attributed to J.W. Tukey, but was first used in publications by 
Dixon (1960). 


{title:Also see}

{p 4 13 2}
Online:  
{help summarize}, 
{help means}, 
{help trimplot} (if installed), 
{help hsmode} (if installed), 
{help shorth} (if installed), 
{help iqr} (if installed), 
{help robmean} (if installed)


