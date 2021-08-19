.-
help for ^simqi^                                               Version 2.1
.-

Simulates quantities of interest
--------------------------------

      ^simqi^ [^, pv genpv(^newvar1 newvar2...^)^
               ^ev^ ^genev(^newvar1 newvar2...^)^
               ^pr^ ^prval(^value1 value2...^)^ ^genpr(^newvar1 newvar2...^)^
               ^fd(^existing option^)^ ^changex(^var1 val1 val2 [^&^ var2 val1 val2] ^)^
               ^msims(^#^)^ ^tfunc(^function^)^ ^l^evel^(^#^)^ ^listx^ ]

Description
-----------

After simulating parameters from the last estimation (see help @estsimp@) and
setting values for the explanatory variables (see help @setx@), use ^simqi^ to
simulate various quantities of interest, including predicted values, expected
values, and first-differences.

Predicted values contain two forms of uncertainty: "fundamental" uncertainty
arising from sheer randomness in the world, and "estimation" uncertainty
caused by not having an infinite number of observations.  More technically,
predicted values are random draws of the dependent variable from the
stochastic component of the statistical model, given a random draw from the
posterior distribution of the unknown parameters.

If there were no estimation uncertainty, the expected value would be a
single number representing the mean of the distribution of predicted values.
But estimates are never certain, so the the expected value must be a
distribution rather than a point.   To obtain this distribution, we
average-away the fundamental variability, leaving only estimation uncertainty.
For this reason, expected values have a smaller variance than predicted
values, even though the point estimate should be roughly the same in both
cases.  ^simqi^ calculates two kinds of expected values: the expected value
of Y and the probability that Y takes on a particular value.  For models
in which these two quantities are equal, ^simqi^ avoids redundancy by
reporting only the probabilities.

Note: simulated expected values are equivalent to simulated probabilities for
all the discrete choice models that ^simqi^ supports (logit, probit, ologit,
oprobit, mlogit).  In these models, the expected value of Y is a vector, with
each element indicating the probability that Y=j.  Consider an ordered probit
with outcomes 1, 2, 3.  The expected value is [Pr(Y=1), Pr(Y=2), Pr(Y=3)],
the mean of a multinomial distribution that generates the dependent variable.

A first difference is the difference between two expected values.  To
simulate first differences use the fd "wrapper", which is described below.

It is possible to compute many other quantities of interest based on the
output from ^simqi^.  For examples of such quantities, see the paper by
King, Tomz and Wittenberg (2000) cited at the end of this help file.


Default Output
--------------

^simqi^ can generate predicted values, expected values and first differences
for all the models that it supports.  By default, however, it will only
report the quantities of interest that appear in the table below.  To view
other quantities of interest or save the simulated quantities as new
variables that can be analyzed and graphed, use one of ^simqi^'s options.

           Statistical             Quantities displayed
              Model                     by default
           -----------          --------------------------
             regress                       E(Y)
             logit                        Pr(Y=1)
             probit                       Pr(Y=1)
             ologit             Pr(Y=j) for all outcomes j
             oprobit            Pr(Y=j) for all outcomes j
             mlogit             Pr(Y=j) for all outcomes j
             poisson                       E(Y)
             nbreg                         E(Y)
             sureg              E(Y_j) for all equations j
             weibull                       E(Y)


Options
-------

^pv^ displays a summary of the predicted values that ^simqi^ generated via
   simulation

^genpv(^newvar1 newvar2...^)^ saves the predicted values as new variables in
   the current dataset.  For single-equation models, you may specify only one
   new variable; each "observation" of that new variable will contain one
   simulated predicted value.  For multiple-equation models such as @sureg@,
   you may specify as many new variables as there are outcome variables in
   the model.

^pr^ displays a summary of the probabilities that ^simqi^ generated via
   simulation

^prval(^value1 value2 ...^)^ instructs ^simqi^ to evaluate the probability
   that the dependent variable takes-on each of the listed values.  The
   values must appear in ascending order without any duplicates.

^genpr(^newvar1 newvar2 ...^)^ saves the simulated probabilities as new
   variables in the current dataset.  Each new "observation" represents
   one simulated probability.  If both the ^prval()^ option and the ^genpr()^
   option are used, ^simqi^ will save Pr(Y==value1) in newvar1, Pr(Y==value2)
   in newvar2, etc.  If the ^prval()^ option is not specified, ^genpr()^ will
   save the probabilities in the same ascending order as the outcome
   values of the dependent variable.

^ev^ displays a summary of expected values that ^simqi^ generated via
   simulation.  This option is not available for discrete choice models,
   where it is redundant with ^pr^

^genev(^newvar1 newvar2 ... ^)^ saves the expected values in new variables.
   For single equation models you may specify only one new variable.  Each
   observation of newvar will contain one simulated expected value of the
   dependent variable.  For multiple-equation models such as @sureg@,
   you may specify as many new variables as there are outcome variables in
   the model.  The ^genev()^ option is not available for discrete choice
   models, where it is redundant with ^genpr()^

^fd(^existing option^)^ is a "wrapper" that makes it easy to simulate first
   differences.  Simply wrap the fd() wrapper around an existing option and
   specify the changex() option.

^changex(^var1 val1 val2^)^ specifies how the explanatory variables (the x's)
   should change when evaluating a first difference.  ^changex^ uses the
   same basic syntax as @setx@, except that each explanatory variable has
   two values: a starting value and an ending value.  For instance, ^fd(ev)^
   ^changex(x1 .2 .8)^ instructs ^simqi^ to simulate a change in the expected
   value of Y caused by increasing x1 from its starting value, 0.2, to its
   ending value, to 0.8.

^msims(^#^)^ sets the number of simulations to be used when calculating
   expected values.  The number must be a positive integer.  By default,
   the value of msims is set at 1000.  ^simqi^ disregards the msims option
   whenever the expected value is parametrically defined.

^tfunc(^function^)^ allows the user to specify a transformation function for
   transforming the dependent variable.  This option is only available for
   @regress@ and @sureg@.  The currently supported functions are

            Function             Transformation (for all variables j)
           -----------           ------------------------------------
            squared                   y_j ----> y_j * y_j
            sqrt                      y_j ----> sqrt(y_j)
            exp                       y_j ----> exp(y_j)
            ln                        y_j ----> ln(y_j)
            logiti                    y_j ----> inverselogit(y_j)

   The inverse logit function is exp(y_j)/(1+SUM[exp(y_j)]) where the summation
   is done over all the j's.

^l^evel^(^#^)^ specifies the confidence level, in percent, for confidence
   intervals.  The default is ^level(95)^ or the value set by ^set l^evel.  For
   more information on ^set l^evel, see the on-line help for @level@.

^listx^ instructs ^simqi^ to list the x-values that were used to produce
   the quantities of interest.  These values were set using the @setx@ command.


Basic Examples
--------------

To display the default quantities of interest for the last estimated model,
type:

   . ^simqi^

For a summary of the simulated expected values, type:

   . ^simqi, ev^

For a summary of the simulated probabilties, Pr(Y=j), for all j categories
of the dependent variable, type:

   . ^simqi, pr^

To display only a summary of Pr(Y=1), the probability that the dependent
variable takes on a value of 1, type:

   . ^simqi, prval(1)^

To generate first differences, use the fd() wrapper and the changex() option.
For instance, the following command will simulate the change in the expected
value of Y caused by increasing x4 from 3 to 7, while holding other
explanatory variables at their means

   . ^setx mean^                   
   . ^simqi, fd(ev) changex(x4 3 7)^

To simulate the change in the simulated probabilities, Pr(Y=j), for all j
categories of the dependent variable, given an increase in x4 from its
minimum to its mean, type:

   . ^setx mean^                   
   . ^simqi, fd(pr) changex(x4 min mean)^

If you are only interested in the change in Pr(Y=1) caused by raising
x4 from its 20th to its 80th percentile when other variables are held at
their mean, type:

   . ^setx mean^
   . ^simqi, fd(prval(1)) changex(x4 p20 p80)^


More Intricate Examples
-----------------------

To display not only the simulated expected values but also the x-values used
to produce them, we would type:

   . ^simqi, ev listx^

-simqi- displays 95% confidence intervals by default, but we could modify
the previous example to give a 90% confidence interval for the expected
value:

   . ^simqi, ev listx level(90)^

To save the simulated expected values in a new variable called predval, type:

   . ^simqi, genev(predval)^

To simulate Pr(Y=0), Pr(Y=3), and Pr(Y=4), and then save the simulated
probabilities as variables called simpr0, simpr3 and simpr4, type:

   . ^simqi, prval(0 3 4) genpr(simpr0 simpr3 simpr4)^

The changex option can be arbitrarily complicated.  Suppose that we want
to simulate the change in Pr(Y=1) caused by simultaneously increasing x1
from .2 to .8 and x2 from ln(7) to ln(10).  The following lines will
produce the quantities we seek

   . ^setx mean^
   . ^simqi, fd(prval(1)) changex(x1 .2 .8 x2 ln(7) ln(10))^

We could augment the previous example by requesting a second first difference,
caused by increasing x3 from its median to its 90th percentile.  Simply
separate the two changex requests with an ampersand.

   . ^setx mean^
   . ^simqi, fd(prval(1)) changex(x1 .2 .8 x2 ln(7) ln(10) & x3 median p90)^

Likewise, the fd() option can be as intricate as we would like.  For
instance, suppose that we have run a poisson regression.  We want to see what
happens to Pr(Y=2), Pr(Y=3), and the expected count when we increase x1 from
its minimum to its maximum.  To obtain our quantities of interest, we would
type:

   . ^setx mean^
   . ^simqi, fd(prval(2 3)) fd(ev) changex(x1 min max)^

-simqi- allows us to save any simulated variable for subsequent analysis.
To find the mean, standard deviation, and a confidence interval around any
quantity of interest that has been saved in memory, use the @sumqi@ command.
To graph the simulations, use @graph@ or @kdensity@.


Distribution
------------

    ^simqi^ is part of CLARIFY, a suite of Stata programs for interpreting
    statistical results, and is (C) Copyright, 1999-2003, Michael Tomz, Jason
    Wittenberg and Gary King, All Rights Reserved.  You may copy and
    distribute this program provided no charge is made and the copy is
    identical to the original. To request an exception, please contact:

    Michael Tomz <tomz@@stanford.edu>
    Department of Political Science
    Encina Hall, Stanford University
    Stanford, CA 94305-6044

    We recommend that you distribute the current version of this program,
    which is available from http://GKing.Harvard.Edu.


Reference
---------

If you use this program, please cite:

    Michael Tomz, Jason Wittenberg, and Gary King.  2003.  CLARIFY: 
    Software for Interpreting and Presenting Statistical Results.  
    Version 2.1.  Stanford University, University of Wisconsin, 
    and Harvard University.  January 5.  Available at 
    http://gking.harvard.edu/

and

    Gary King, Michael Tomz, and Jason Wittenberg.  2000.  "Making
    the Most of Statistical Analyses: Improving Interpretation and
    Presentation."  American Journal of Political Science 44, no. 2
    (April): 347-61.
