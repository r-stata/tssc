.-
help for ^setx^                                                Version 2.1                                        
.-

Sets values of explanatory variables (x's)
------------------------------------------

        ^setx^

        ^setx^ function [weight] [^if^ exp] [^in^ range] [^, noinh^er ^nocw^del]

        ^setx^ varname1 function1 varname2 function2 ...
             [weight] [^if^ exp] [^in^ range] [^, noi^nher ^nocw^del]

        ^setx^ (varname1 varname2) function1 (varname3 varname4) function2 ...
             [weight] [^if^ exp] [^in^ range] [^, noi^nher ^nocw^del]

        where

             function = mean|median|min|max|p#|math|#|^`^macro^'^|varname^[^#^]^

Description
-----------

After estimating parameters with @estsimp@ or @relogit@, use ^setx^ to set values
for the explanatory variables (the X's), change values that have already been
set, or list the values that have been chosen.  The main value-types are

        ^mean^      arithmetic mean
        ^median^    median
        ^min^       minimum
        ^max^       maximum
        ^p^#        #th percentile
        math      a mathematical expression, such as 5*5 or sqrt(23)
        #         a numeric value, such as 5
        ^`^macro^'^   the contents of a local macro
        ^[^#^]^       the value in the #th observation of the dataset

Setx will not accept spaces in mathematical expressions unless you enclose the
expression in parentheses.  For instance, ^setx x4 ln(20)^ and ^setx x4 (ln( 20 ))^
are equivalent valid commands, but ^setx x4 ln( 20 )^ is a syntax error.

If you used multiply imputed datasets at the estimation stage, ^setx^ will use
those same imputed datasets to calculate values for the explanatory variables.
For instance, ^estsimp x1 mean^ would calculate the mean of x1 across all the
imputed datasets.

When using ^setx^ or any other Stata command to calculate summary statistics such
as means, medians, minimums, maximums, and percentiles, it is important to
define the sample.  At the estimation stage, Stata automatically disregards
observations that do not satisfy the "if", "in", and "weight" conditions
specified by the user.  It also ignores observations with missing values on
one or more variables.  Before setting a particular variable equal to its mean
or any other summary statistic, users must decide whether to calculate the
statistic based only on observations that were used during the estimation
stage, or to include other observations in the calculation.

By default, ^setx^ inherits the if-in-weight conditions from @estsimp@ and
disregards (casewise-deletes) any observation with missing values on the
dependent or explanatory variables.  You can specify different if-in-weight
conditions by including them in the ^setx^ command line, and you can disregard
all inherited conditions by using the ^noinh^er and ^nocw^del options described
below.

The ^setx^ command is used by both -clarify- and -relogit-, two programs that
are available from http://gking.harvard.edu.  If you ran -relogit- with 
the wc() or pc() options, indicating that the data were selected on the 
dependent variable, ^setx^ will correct the selection bias when calculating 
summary statistics.  For this reason, means and percentiles produced by ^setx^ 
may differ from means and percentiles of the (biased) sample.  When the 
proportion of 1's in the population is known only to fall within a range, such 
as pc(.2 .3), ^setx^ will calculate bounds on the values of the explanatory 
variables.  The result will two X-vectors, the first assuming that the true 
proportion of 1's is at its lower bound, and the second conditional on the 
true proportion being at its upper bound.  The program will pass these vectors 
to ^relogitq^ and use them to calculate bounds on quantities of interest.  
To set each explanatory variable at a single value that falls midway between 
its upper and lower bounds, use the ^nob^ound option that is described below.

^setx^ relies upon three globals: the matrix mrt_xc and the macros mrt_vt
and mrt_seto.  If you change the values of these globals, the program may
not work properly.

^setx^ accepts aweights and fweights.  It also accepts the special options
listed below.


Options
-------

^noinh^er causes setx to ignore all if-in-weight conditions that are inherited
   from estsimp.  The user can specify new if-in-weight conditions by typing
   them as part of the setx command.

^nocw^del forces setx to calculate summary statistics based on all valid
   observations for a given variable, even if the observations contain missing
   values for the other variables.  If ^nocw^del is not specified, setx will
   casewise-delete observations with missing values.

^nob^ound.  This option is available only after -relogit-, and only when the
   true proportion of 1's is assumed to fall within a specified range.  Suppose
   the user typed ^pc(.2 .4)^ with relogit and then entered ^setx x1 mean^.
   By default, setx would set the variable x1 equal to two values: the mean
   of x1, assuming that the true proportion of ones is only 0.2, and the mean
   of x1, allowing that the true proportion is as high as 0.4.  Both values for
   x1 will be passed to relogitq and used to calculate bounds on quantities of
   interest.  The ^nob^ound option overrides this procedure by setting each x
   to a single value: the midpoint of its upper and lower bound.  Thus, the
   command ^setx x1 mean, nob^ound would set x1 equal to the following 
   expression: [(mean(x1)|tau=0.2) + (mean(x1)|tau=0.4)]/2, where tau 
   represents the presumed proportion of 1's in the population.

^keepmrt^ is a programmer's option that instructs ^setx^ to return the matrix
   r(mrt_xc) without changing the globals mrt_xc, mrt_vt, and mrt_seto.


Examples
--------

To list values that have already been set:

   . ^setx^

To set each explanatory variable at its mean:

   . ^setx mean^

To set each explanatory variable at its median, based on a sample in which
x3>12, all inherited conditions are ignored, and casewise deletion is
suppressed:

   . ^setx median if x3>12, noinh nocw^

To set each explanatory variable to the value contained in the 15th
observation of the dataset

   . ^setx [15]^

The command can also set each variable separately.  For instance, to set x1
at its mean, x2 at its median, x3 at its minimum, x4 at its maximum,
x5 at its 25th percentile, x6 at ln(20), x7 at 2.5, and x8 equal to a local
macro called myval, type:

   . ^setx x1 mean x2 median x3 min x4 max x5 p25 x6 ln(20) x7 2.5 x8 `myval'^

^setx^ can also set values for groups of variables.  To set x1 and x2 to
their means, x3 to its median, and x4 and x5 to their 25th percentiles, type:

   . ^setx (x1 x2) mean x3 median (x4 x5) p25^

To change the value of x3 from its peviously chosen value to 5*5

   . ^setx x3 5*5^

To set all variables except x10 at their means, and fix x10 at its 25th
percentile, call setx twice: once to set all variables at their means, and
a second time to change the value of x10 to its 25th percentile.

   . ^setx mean^
   . ^setx x10 p25^


Distribution
------------

    ^setx^ is part of CLARIFY, a suite of Stata programs for interpreting
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


References
----------

    Gary King, Michael Tomz, and Jason Wittenberg.  2000.  "Making
    the Most of Statistical Analyses: Improving Interpretation and
    Presentation."  American Journal of Political Science 44, no. 2
    (April): 347-61.

    Gary King and Langche Zeng.  2001.  "Logistic Regression in Rare 
    Events Data," Political Analysis 9, no. 2 (Spring): 137-63.

    Gary King and Langche Zeng.  2002. "Estimating Risk and Rate
    Levels, Ratios and Differences in Case-Control Studies." 
    Statistics in Medicine 21: 1409-27.
