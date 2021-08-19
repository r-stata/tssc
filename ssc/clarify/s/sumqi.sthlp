.-
help for ^sumqi^                                               Version 2.1
.-

Summarizes quantities of interest
---------------------------------

   ^sumqi^ varname1 [varname2 varname3...] [^if^ exp] [^in^ range], ^l^evel^(^#^)^

     
Description
-----------

^sumqi^ summarizes quantities of interest that have been stored as variables
in memory.  The command reports the mean, standard deviation, and a confidence
interval for the simulated quantities of interest.


Options
-------

^l^evel^(^#^)^ specifies the confidence level, in percent, for confidence
   intervals.  The default is ^level(95)^ or the value set by ^set l^evel.  For
   more information on ^set l^evel, see the on-line help for @level@.


Example
-------

To obtain the mean, standard deviation, and a 90% confidence interval for
a variable called myvar, type

   . ^sumqi myvar, level(90)^

To get 80% confidence intervals for myvar1, myvar2, and myvar3, type

   . ^sumqi myvar1 myvar2 myvar3, level(80)^


Distribution
------------

    ^sumqi^ is part of CLARIFY, a suite of Stata programs for interpreting
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
