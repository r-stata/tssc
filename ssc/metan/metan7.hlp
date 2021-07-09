.-
help for ^metan7^, ^labbe^, ^funnel^                                    
.-

Fixed and random effects meta-analysis
--------------------------------------


 ^metan7^  varlist [^if^ exp] [^in^ range]
              [, ^rr or rd  cohen hedges glass nosta^ndard
              ^fixed random fixedi randomi peto wgt(^weightvar^) nooverall^ 
              ^cornfield chi2 breslow log eform noint^eger^ cc(^#^)^
              ^by(^byvar^) nosubgroup sgweight ilevel(^#^) olevel(^#^)^ 
              ^label(namevar=^name^, yearvar=^year^) legend(^text^)^
              ^sortby(^sort_vars^) nokeep notable nograph^ 
              ^xt^ick^(^#,..,#^) xla^bel^(^#,..,#^) force^
              ^t1title(^#,..,#^) t2title(^#,..,#^) b1title(^#,..,#^) b2title(^#,..,#^)^
              ^boxsha(^#^) boxsca(^#^) nobox texts(^#^) nowt nostats counts^
              ^group1(^text^) group2(^text^) effect(^text^) saving(^filename^)^ ]


 ^labbe^  varlist [^if^ exp] [^in^ range] [^weight^] 
              [ , ^nowt per^cent ^or(^#^) rr(^#^) rd(^#^) rrn(^#^) null logit^
                  graph_options ]
 
 ^funnel^ [varlist] [^if^ exp] [^in^ range] [^weight^] 
              [, ^ysq^rt ^sa^mple ^ov^erall(#) graph_options ]

Description
-----------

These routines provide methods for the meta-analysis of aggregate level 
data. Either binary (event) or continuous data from two groups may be 
combined using the ^metan7^ command. Additionally, pre-calculated effect 
sizes may be pooled. Several meta-analytic methods are available, and 
the results may be displayed graphically in a Forest plot. A test for 
the statistical significance of the overall effect size is also provided, 
along with a test for excess between-trial variation (heterogeneity) 
and the I-squared measure which is an alternative summary of this 
(Higgins & Thompson 2002). Note that this command has been updated-
see ^metan^

^labbe^ draws a L'Abbe plot for event data (proportion of successes in the 
two groups). This is an alternative to the graph produced by ^metan7^

^funnel^ may be used for producing a "funnel plot", a graph of either the
study sample size, standard error or precision (inverse of s.e.) against 
the effect size.


Options for ^metan7^
-----------------

The main meta-analysis routine ^metan7^ requires either two, three, four 
or six variables to be declared. 

When four variables are specified, analysis of binary data is performed 
on the 2x2 table with cell counts denoted by the variable list. 

With six variables, the data are assumed continuous and to be the sample 
size, mean and standard deviation of the experimental group followed by 
those of the control group. 

For two or three variables, a variance-weighted analysis is performed in 
a similar fashion to the @meta@ command; 
 the two variable syntax is <theta> and <SE(theta)>.
 the 3 variable syntax is <theta>, <lower ci (theta)>, <upper ci (theta)>
Note that in this situation "theta" is taken to be the logarithm of the 
effect size if the odds ratio or risk ratio is used. ^This differs from^
^the equivalent in the meta command^. This program does not assume the 
three variables need log transformation: if odds ratios or risk ratios 
are combines, it is up to the user to log-transform them first. The 
^eform^ option can be used to change back to the original scale if needed.
By default the confidence intervals are assumed symmetric, and the studies 
are pooled by taking the variance to be equal to (CI width)/2z. 


  Specifying the measure and model with which to pool the data
  ------------------------------------------------------------


Options for binary data (4 variables)

^rr^   pools risk ratios [default]
^or^   pools odds ratios
^rd^   pools risk differences


^fixed^   specifies a fixed effect model using the method of 
  Mantel and Haenszel [default]
^fixedi^  specifies a fixed effect model using the inverse variance method 
^peto^    specifies that Peto's method is used to pool odds ratios 
^random^  specifies a random effects model using the method of 
  DerSimonian & Laird, with the estimate of heterogeneity being taken 
  from the Mantel-Haenszel model
^randomi^ specifies a random effects model using the method of 
  DerSimonian & Laird, with the estimate of heterogeneity being taken 
  from the inverse variance fixed effect model

^cornfield^   computes confidence intervals for odds ratios by method of 
  Cornfield, rather than the (default) Woolf method
^chi2^        displays chi-squared statistic (instead of z) for the test 
  of significance of the pooled effect size. This is available only for 
  odds ratios pooled using Peto or Mantel-Haenszel methods
^breslow^     produces Breslow-Day test for homogeneity of ORs

^cc(^#^)^   defines a fixed continuity correction to add in the case where 
  a study contains a zero cell. By default, metan7 adds 0.5 to each cell of
  a trial where a zero is encountered when using Inverse-Variance, 
  Der-Simonian & Laird or Mantel-Haenszel weighting to enable finite 
  variance estimators to be derived. However, the cc option allows the use 
  of other constants (including none). See also the ^nointeger^ option below.

^nointeger^    allows the cell counts to be non-integers. This may be useful
  when a variable continuity correction is sought for studies containing 
  zero cells, but also may be used in other circumstances, such as where a 
  cluster-randomised trial is to be incorporated and the "effective sample 
  size" is less than the total number of observations.


Options for continuous data

^cohen^      pools standardised mean differences by the method of Cohen 
  [default] 
^hedges^     pools standardised mean differences by the method of Hedges 
^glass^      pools standardised mean differences by the method of Glass 
^nostandard^ pools unstandardised mean differences 

^fixed^   specifies a fixed effect model using the inverse variance method
  [default]
^random^  specifies a random effects model using the DerSimonian & Laird 
  method

^nointeger^   denotes that the number of observations in each arm does not 
 need to be an integer. By default, the first and fourth variables specified 
(containing N_intervention and N_control respectively) may occasionally be 
non-integer (see above entry under binary data)



Alternative weighting (for all data types) 
 
^wgt(^wgtvar^)^ denotes that the effect size is to be computed by assigning 
  a weight of wgtvar to the studies. When RRs or ORs are declared, their 
  logarithms are weighted. You should only use this option if you are
  satisfied that the weights are meaningful. 


   Output
   ------

General 

^by^         specifies that the meta-analysis is to be stratified
  according to the variable declared. 

^sgweight^   specifies that the display is to present the percentage
  weights within each subgroup separately. By default metan7 presents
  weights as a percentage of the overall total.
^nosubgroup^ indicates that no within-group results are to be 
  presented.  By default metan7 pools trials both within and across 
  all studies

^log^         reports the results on the log scale 
  (valid for OR and RR analyses only)
^eform^       exponentiates all effect sizes and confidence intervals  
  (valid only for analyses of odds ratios or risk ratios)
^ilevel()^    specifies the significance level (eg 90,95,99) for the 
  individual trial confidence intervals
^olevel()^    specifies the significance level (eg 90,95,99) for the 
  overall (pooled) confidence intervals
^ilevel^ and ^olevel^ need not be the same, and by default are equal 
  to the significance level specified using the ^set level^ command

^sortby(^varlist^)^    sorts by one or more variables ^varlist^
^label(^ [^namevar^=namevar] [^,yearvar^=yearvar] ^)^
  labels the data by its name, year or both. Either or both option/s 
  may be left blank. For the table display the overall length of the
  label is restricted to 20 characters
^nokeep^      prevents the retention of study parameters in permanent 
  variables (see saved results below)
^notable^     prevents display of table of results
^nograph^     prevents display of graph



Graph display options for forest plot

^legend()^    specifies a label to be used for the study identifiers at 
  the top of the graph. This is a rename of the ^stext()^ option that 
  appeared in some previous versions of metan7.
^effect()^    may be used when the effect size and its standard error 
  are declared. This allows the graph to name the summary statistic used

^nooverall^   prevents display of overall effect size on graph 
  (automatically enforces the ^nowt^ option)
^nowt^        prevents display of study weight on graph
^nostats^     prevents display of study statistics on graph
^counts^      displays data counts (n/N) for each group when using
  binary data

^group1()^, ^group2()^  can be used with the counts option: the text should 
  contain the names of the two groups.

^xlabel()^    defines x-axis labels
^xtick()^     adds tick marks to the x-axis 

^force()^     forces the x-axis scale to be in the range specified
  by ^xlabel()^

^t1title(..)^, ^t2title(..)^, ^b1title(..)^, ^b2title(..)^ 
  adds titles to graph in the usual manner, but ^b1title(..)^ has an added
  feature. If the text starts with "*I:" and contains an asterisk, metan7 
  interprets this as meaning the label declares something about the effect 
  sizes. For example,

   . ^metan7^ [varlist] ^, b1title(*I:^Favours treatment ^*^ Favours control^)^ 

  displays a legend under the graph denoting that studies with effect sizes 
  to the left of the graph (eg below odds ratios of less than 1) denote a 
  beneficial treatment, whilst those finding effects to the right indicate
  a negative treatment effect.

^boxsha()^    controls box shading intensity, between 0 and 4. The default 
  is 4, which produces a filled box
^boxsca()^    controls box scaling, which by default is 1
^nobox^       prevents a "weighted box" being drawn for each study, instead
            displaying effect sizes as identically sized circles
^texts()^     specifies font size for text display on graph.  The default 
  size is 1

^saving(^filename^)^  saves the forest plot to the specified file

Note that for graphs on the log scale (that is, ORs or RRs), values
outside the range [10e-8,10e8] are not displayed.  A confidence interval 
which extends beyond this will have an arrow added at the end of the range;
should the effect size and confidence interval be completely off this 
scale, they will be represented as a single (triangle-shaped) arrow.

By default, ^metan7^ adds the following new variables to the data set:

      ^_ES^        Effect size (ES)
      ^_seES^      Standard error of ES 
        or, when OR or RR are specfied: 
      ^_selogES^   the standard error of its logarithm 
      ^_LCI^       Lower confidence limit for ES
      ^_UCI^       Upper confidence limit for ES
      ^_WT^        Study percentage weight
      ^_SS^        Study sample size


Options for ^funnel^
------------------

If the ^funnel^ command is invoked following ^metan7^ with no parameters
specified it will produce a standard funnel plot of precision (1/SE)
against treatment effect. Addition of the ^noinvert^ option will produce
a plot of standard error against treatment effect. The alternative 
sample size version of the funnel plot can be obtained by using the 
^sample^ option (this automatically selects the ^noinvert^ option).
Alternative plots can be created by specifying ^precision_var^ and
^effect_size^. If the effect size is a relative risk or odds ratio,
the ^xlog^ option should be used to create a symmetrical plot.

                                        
All options for graph are valid.  Additionally,

^sample^    denotes that the y-axis is the sample size and not a 
  standard error
^noinvert^  prevents the values of the precision variable from being
  inverted
^ysqrt^     represent y-axis on square root scale
^overall(^x^)^ draws a dashed vertical line at overall effect size given by x


Options for ^labbe^
-----------------

By default the size of the plotting symbol is proportional to the sample 
size of the study. If weight is specified the plotting size will be 
proportional to the weight variable. 
All options for graph are valid. Additionally, the following options may 
be used

^nowt^    declares that the plotted data points are to be the same size
^percent^ display the event rates as percentages rather than proportions

^null^     draws a line corresponding to a null effect (ie p1=p2)
^or(^x1^)^   draws a line corresponding to a fixed odds ratio of x1
^rd(^x2^)^   draws a line corresponding to a fixed risk difference of x2
^rr(^x3^)^   draws a line corresponding to a fixed risk ratio 
  (for the event) of x3
^rrn(^x4^)^  draws a line corresponding to a fixed risk ratio 
  (for the non-event) of x4

The latter two may require explanation: whereas the OR and RD are 
invariant to the definition of which of the binary outcomes is the "event" 
and which is the "non-event", the RR is not.  That is, whilst the command 
^metan7 a b c d , or^ gives the same result as ^metan7 b a d c , or^ 
(with direction changed), an RR analysis does not.  The L'Abbe plot allows
the display of either or both be superimposed

^logit^    is for use when the ^or()^ option has been used; it displays the
  probabilities on the logit scale ie log(p/1-p). On the logit scale the  
  odds ratio is a linear effect, and so this makes it easier to assess the 
  "fit" of the line. 

One note of caution: depending on the size of the studies, you may need to 
rescale the graph (by means of the ^psize()^ option)

Examples
--------

  . ^metan7 tdeath tnodeath cdeath cnodeath, or chi2 label(namevar=trialid)^
  . ^metan7 tdeath tnodeath cdeath cnodeath, rd random^ 
  . ^metan7 tdeath tnodeath cdeath cnodeath, olevel(99) ilevel(95)^ /*
   /* ^sortby(year) label(namevar=trialid, yearid=year) nostats nowt^

  . ^metan7 n1 mean1 sd1 n2 mean2 sd2, by(trialtype)^  /* 
  */ ^b1(*I:Treatment reduces blood pressure * Treatment increases blood pressure)^

  . ^gen logor = (a*d)/(b*c)^
  . ^gen selogor = sqrt( (1/a) + (1/b) + (1/c) + (1/d) )^
  . ^metan7 logor selogor , eform effect(Odds ratio) ^

  . ^metan7 percentlowerci upperci , wgt(n_positives) b1(Sensitivity)^ /*
  */ ^xlabel(0,20,40,60,80,100) nooverall^


  . ^local ovratio=r(ES)^
  . ^funnel , sample ysqrt xlabel(0.1,0.5,1,5,10) ylabel(0,500,1000)^  /*
  */  ^overall(`ovratio')^
  . ^funnel or selogor, xlabel(0.1,0.5,1,5,10) ylabel(0,0.05,0.1) xlog^

  . ^labbe tdeath tnodeath cdeath cnodeath, xlabel(0,0.25,0.5,0.75,1)^ /*
  */  ^ylabel(0,0.25,0.5,0.75,1) rr(0.91) rd(-0.021) ^ 

  . ^metan7 n1 m1 sd1 n2 m2 sd2, nostandard^
  . ^metan7 n1 m1 sd1 n2 m2 sd2, random xla(-2,-1,0,1,2) force saving(metagrph)^




Authors
-------

    Michael J Bradburn, Jonathan J Deeks, Douglas G Altman.
    Centre for Statistics in Medicine, University of Oxford, 
    Old Road Campus, Headington, Oxford OX3 7LF, UK. 

    email mike.bradburn@@cancer.org.uk


References
----------

Higgins JPT, Thompson SG (2002) Quantifying heterogeneity in a meta-analysis. 
Statistics in Medicine 21:1539-1558


Also see
--------

    STB: STB-44 sbe24
On-line: help for @meta@ (if installed), @metacum@ (if installed),
         @metareg@ (if installed), @metabias@ (if installed), 
         @metatrim@ (if installed), @metainf@ (if installed), 
         @galbr@ (if installed)

