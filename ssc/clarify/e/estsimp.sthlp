.-
help for ^estsimp^                                             Version 2.1
.-

Estimates model and simulates parameters
----------------------------------------

  ^estsimp^ modelname depvar [indepvars] [weight] [^if^ exp] [^in^ range]
         [^, sims(^m^)^ ^genname(^newvar^)^ ^anti^sim ^mi(^filelist^)^ ^iout^ ^dropsims^]
     

Description
-----------

^estsimp^ estimates a variety of statistical models and generates M simulations
of each parameter.  Currently supported models include @regress@, @logit@, @probit@,
@ologit@, @oprobit@, @mlogit@, @poisson@, @nbreg@, @sureg@, and @weibull@.  The simulations 
are stored in new variables bearing the names newvar1, newvar2, ... ,newvark, 
where k is the number of unique parameters.  Each variable has M observations 
corresponding to the M simulations.  ^estsimp^ labels the simulated variables 
and lists their names on the screen, so you can verify what was simulated.

The ^estsimp^ command accepts nearly all options that are typically available
for the supported models.  It also accepts several special options that are
described below.


Options
-------

^sims(^M^)^ specifies the number of simulations, M, which must be a positive
   integer.  The default is 1000 simulations.  If you choose a large number of
   simulations, you may need to allocate more memory to Stata by typing "clear"
   and then "set memory #m".  See [R] memory in the reference manual for more
   details about memory allocation.

^genname(^newvar^)^ specifies a stub-name for the newly generated variables.
    If no stub is given, Stata will generate the variables b1, b2, ... , bk,
    otherwise it will generate newvar1, newvar2, ... , newvark, provided that
    the variables do not exist in memory already.

^anti^sim instructs ^estsimp^ to use antithetical simulations, in which numbers
    are drawn in pairs from the uniform[0,1] distribution, with the second draw
    being the complement of the first.  This procedure ensures that the mean of
    the simulations for a particular parameter is equal to the point estimate
    of that parameter.

^mi(^filelist^)^ allows ^estsimp^ to analyze multiply-imputed datasets: files in
    which missing values have been multiply imputed.  Enter the name for each
    imputed dataset you want to use, such as ^mi(file1 file2 file3)^.
    Alternatively, you can enter a common stub name for all imputed datasets,
    such as ^mi(file)^.  In this case, estsimp assumes that you want to use all
    files in the working directory that are part of the uninterrupted sequence
    file1, file2, file3...   ^estsimp^ will estimate the parameters for each
    dataset and use the estimates to generate simulations, which will reflect
    not only estimation uncertainty but also the uncertainty arising from the
    imputation process.  Note: if the data in memory have been changed, you
    cannot specify the ^mi()^ option until you clear the memory or save the
    altered dataset.

^iout^ instructs ^estsimp^ to print intermediate output (a table of parameter
    estimates) for each imputed dataset that it analyzes.  By default, ^estsimp^
    suppresses the intermediate output and displays only the final estimates
    produced by combining the results from each imputed dataset.

^dropsims^ drops the variables containing the simulated parameters from the last
    estimation.  This option exists for the convenience of users who call
    estsimp repeatedly and would prefer not to delete b1, b2, b3 ... bk by hand.


Examples
--------

To estimate a linear regression of y on x1, x2, x3, and a constant term;
simulate 1000 sets of parameter estimates; and then save the simulations as
b1, b2, ..., bk, type:

   . ^estsimp regress y x1 x2 x3^

In this example, Stata will create five new variables.  The variables b1,
b2 and b3 will contain simulated coefficients for x1, x2 and x3; b4 will hold
simulations of the constant term; and b5 will contain simulated values for
sigma squared, the mean squared error of the regression.

To simulate 500 sets of parameters from a logit regression and save the
results as variables beginning with the letter "s", type:

   . ^estsimp logit y x1 x2 x3, sims(500) genname(s)^

Since the logit model contains no ancillary parameters, this command will
generate four new variables: s1, s2, s3, and s4.  Variables s1, s2, and s3 are
simulated coefficients for x1, x2 and x3, and the final variable, s4, is the
simulated constant term.

To simulate 1000 sets of parameters from an ordered probit regression in
which the dependent variable can assume three values (low, medium, and high),
type:

   . ^estsimp oprobit y x1 x2 x3^

The ordered probit model does not contain a constant term, but it does have
ancillary parameters called cut-points.  Thus, the ^estsimp^ command listed
above will generate five new variables.  The variables b1, b2 and b3 will
hold simulated coefficients for x1 x2 and x3.  Variables b4 and b5 will
contain simulations for the two cutpoints (cut1 and cut2).

To obtain antithetical variates, simply use the ^anti^sim option, as in

   . ^estsimp oprobit y x1 x2 x3, antisim^

Suppose that we have three imputed datasets, called imp1.dta, imp2.dta, and
imp3.dta.  We could analyze all three datasets and combine the results by
issuing the following command:

   . ^estsimp oprobit y x1 x2 x3, mi(imp1 imp2 imp3)^

The resulting simulations of the main and ancillary parameters would reflect
both estimation uncertainty and the variability associated with the multiple
imputations.

To view the intermediate output from each ordered probit estimation, add the
^iout^ option to the previous command, as in

   . ^estsimp oprobit y x1 x2 x3, mi(imp1 imp2 imp3) iout^


Distribution
------------

    ^estsimp^ is part of CLARIFY, a suite of Stata programs for interpreting
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
