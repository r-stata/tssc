.-
help for ^relogit^
.-

Logit with corrected coefficients
---------------------------------

  ^relogit^ depvar [indepvars] [weight] [^if^ exp] [^in^ range] [^, wc(^#^) pc(^#|# #^)^
                  ^nomcn cl^uster^(^varname^) nor^obust ^nocon^stant ^l^evel^(^#^) ]

  ^fweight^s, ^pweight^s, ^aweight^s, and ^pweight^s are allowed.  See help @weight@


Description
-----------

^relogit^ implements the procedures suggested in King and Zeng
(1999a,b) for generating approximately unbiased and lower-variance
estimates of logit coefficients and their variance-covariance matrix
by correcting for small samples and rare events.  This procedure also
allows for selection on the dependent variable as in case-control
studies.  After running ^relogit^, use @setx@ and @relogitq@ to
compute quantities of interest such as absolute risks (probabilities),
relative risks, and attributable risks (first differences).

Options
-------

^pc(^#|# #^)^ corrects for selection on the dependent variable by using the 
   method of prior correction.  This option requires a numeric
   argument, the proportion of 1's in the population, which should be
   between 0 and 1, exclusive.  If the true proportion of 1's is known
   only to fall within some range, the pc option will accept the upper
   and lower bounds of the range.  For instance, pc(.2 .4) indicates
   that the true proporation lies in the interval (.2 .4).  For a
   discussion of how relogit would interpret pc(0), pc(1) or pc(0 1),
   see documentation for the wc() option.

^wc(^#^)^ corrects for selection on the dependent variable
   (case-control designs) by weighting the sample, such that the
   weighted proportion of 1s and 0s in the sample equals the true
   proportion in the population.  The weight-correction option
   requires a numeric argument, the proportion of 1s in the
   population, which should be between 0 and 1 exclusive.  If you type
   wc(0), relogit will presume that you intended a very small positive
   number, since the true proportion of 1's in the population cannot
   be 0.  Likewise, if you type wc(1) the program will presume you
   intended a number just shy of 1.  ^wc()^ and ^pc()^ cannot be
   specified simultaneously.

^nomcn^ suppresses the MCN correction for biases arising from small samples.
   By default ^relogit^ uses a finite sample correction developed by McCullagh
   and Nelder and extended to simultaneous correction for selection on Y by
   King and Zeng.

^cl^uster^(^varname^)^ specifies that the observations are independent across
   groups (clusters) but not necessarily independent within groups. varname
   indicates to which group each observation belongs.  Specifying ^cluster()^
   implies robust.  Thus, the ^cluster()^ option cannot be used in conjunciton
   with the ^norobust^ option.

^nor^obust specifies that the traditional variance calculation be used in
   place of the Huber/White/sandwich estimator.  By default, ^relogit^
   calculates robust variance estimates.  Traditional variance calculations
   do not make sense with ^wc()^ specified.

^nocon^stant suppresses the constant term.  This option cannot be used in
   conjunction with ^pc()^

^l^evel^(^#^)^ specifies the confidence level, in percent, for the confidence
   intervals of the coefficients.  See help @level@.


Examples
--------

To correct for small sample and rare events bias in a logit model
where the dependent variable is y and the explanatory variables are x1
and x2 (and the sampling design is random or conditional on x), type

   . ^relogit y x1 x2^

To correct for small sample and rare events bias, and use the method
of prior correction to correct for a case-control sampling design
assuming that the true proportion of 1's falls in the interval
[.6,.7], type

   . ^relogit y x1 x2, pc(.6 .7)^

To correct for small sample and rare events bias, and use the
weighting procedure to correct for a case-control sampling design, the
population fraction of 1s is 0.2, type

   . ^relogit y x1 x2, wc(.2)^

To run a traditional logit use

   . ^relogit y x1 x2, nomcn norobust^

which is equivalent to Stata's ^logit y x1 x2^ command.


Distribution
------------

    ^relogit^ is (C) Copyright, 1999, Michael Tomz, Gary King and Langche
    Zeng, All Rights Reserved.  You may copy and distribute this program
    provided no charge is made and the copy is identical to the original.
    To request an exception, please contact:

    Michael Tomz <tomz@@fas.harvard.edu>
    Department of Government, Harvard University
    Littauer Center North Yard
    Cambridge, MA 02138

    Please distribute the current version of this program, which is
    available at http://GKing.Harvard.Edu.


References
----------

    Gary King and Langche Zeng. 1999a. "Logistic Regression in Rare
    Events Data," Department of Government, Harvard University,
    available from http://GKing.Harvard.Edu.

    Gary King and Langche Zeng. 1999b. "Estimating Absolute, Relative,
    and Attributable Risks in Case-Control Studies," Department of
    Government, Harvard University, available from
    http://GKing.Harvard.Edu.
