.-
help for ^metannt^
.-

Estimates of absolute benefit or risk from meta-analysis 
--------------------------------------------------------


 ^metannt , measure(^or|rr|rd^) size(^#^) confint(^#,#^) baseline(^#[,#...#]^)^ 


Description
-----------

This program is intended to aid interpretation of meta-analyses of binary 
data by presenting the effect sizes in absolute terms. Both the number 
needed to treat (NNT) and the number of events avoided (or added) per 
1000 are presented. 

The ^Number Needed to Treat (NNT)^ is the number of individuals required 
to experience the intervention in order to expect there to be one 
additional event to be observed. Assuming the event is undesireable, this 
is termed the "number needed to treat to benefit" (NNTB). If the 
intervention arm experiences more events, this is commonly refered to as 
the "number needed to treat to harm" (NNTH). 

^metannt^ calculates this by deriving an effect size (e.g. a risk ratio), 
applying it to a population with a given event prevalance, and from this 
deriving a projected event rate if the population were to receive the 
intervention. The NNT is equal to 
1/(control group event rate - treatment group event rate).

The ^number of avoided or excess events (respectively) per 1000 population^ 
is the difference between the two event rates multiplied by 1000. The 
intervention group event rate is calculated in the same manner as with 
the NNT. Optionally a confidence interval is also presented, using the 
confidence limits of the effect size applied to the control group event 
rate.

Options for ^metannt^
-------------------

^baseline()^ specifies the baseline (ie. control group) event rates, from 
which the NNT and number of events avoided are computed from. More than 
one baseline event rate may be specified.

^measure(^rr|or|rd^)^ specifies whether the estimated effect size pooled is
a risk ratio, odds ratio or (absolute) risk difference.

^size(^#^)^ denotes the size of the effect

^confint(^#,#^)^ denotes the confidence interval around the effect size. 

By default the saved results from the r() macros within @metan@ are used to
derive the control group event rate, the effect measure, the effect size and 
its confidence interval. However, unless a recent version of metan (1.71 
onwards) was used immediately beforehand, the first three options must be 
specified. The confidence interval is optional.


Examples
--------

  . ^metannt , measure(rr) size(0.2) baseline(0.1,0.2,0.3)^ 

  . ^metan tdeath tnodeath cdeath cnodeath, or^
  . ^metannt , baseline(0.15)^ 




Authors
-------

    Michael J Bradburn, Jonathan J Deeks, Douglas G Altman.
    Centre for Statistics in Medicine, Institute of Health Sciences, 
    Old Road, Headington, Oxford OX3 7LF, UK. 

    email mike.bradburn@@cancer.org.uk

Also see
--------

On-line: help for @metan@ (if installed), @meta@ (if installed)


