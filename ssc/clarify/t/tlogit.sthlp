.-
help for ^tlogit^                                                     Version 2.0
.-

Apply the logistic tranformation to a set of variables
------------------------------------------------------

        ^tlogit v1old v1new^ [v2old v2new ...]^, base(^basevar^) p^ercent


Description
-----------

If v1old and basevar are existing variables, ^tlogit^ will generate a new 
variable,

                        v1new = ln(v1old/basevar)

the log-ratio of v1old with respect to the basevar.  If additional variables
are specified on the left-hand side of the command, ^tlogit^ will generate
additional log-ratios with respect to the basevar.


Options
-------

^base(^basevar^)^ is required.  It specifies the base variable for all the log-
   ratios.

^p^ercent indicates that the original variables (v1old, v2old...) are percentages
   rather than proportions.  By default, tlogit assumes that the original
   variables are proportions, such that the values of each old variable fall
   between 0 and 1 inclusive and the sum of basevar and the old variables is 1.


Examples
--------

Suppose we have three variables -- Tory, Labour, and Ally -- which report the
proportion of votes received by the Conservative party, the Labour party, and
the Alliance in a particular electoral district.  To create log-ratios for
Tory and Labour with respect to Ally, type:

   . ^tlogit Tory lrTory Labour lrLabour, base(Ally)^

This command will generate two new variables, lrTory and lrLabour, the log-
ratios for each party with respect to the alliance.

If the original values were expressed as percentages (rather than proportions)
of the total vote, we would add the ^percent^ option to create the log-ratios:

   . ^tlogit Tory lrTory Labour lrLabour, base(Ally) percent^


Distribution
------------

    ^tlogit^ is part of CLARIFY, a suite of Stata programs for interpreting
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

    Gary King, Michael Tomz, and Jason Wittenberg (2000).  "Making
    the Most of Statistical Analyses: Improving Interpretation and
    Presentation."  American Journal of Political Science 44, no. 2
    (April 2000): 347-61.

    Michael Tomz, Joshua A. Tucker, and Jason Wittenberg.  2002.  
    "An Easy and Accurate Regression Model for Multiparty Electoral 
    Data."  Political Analysis 10, no. 1 (Winter): 66-83.
