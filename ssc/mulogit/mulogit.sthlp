.-
help for ^mulogit^              Version 4/2/08
.-

Multivariate and univariate odd ratios (logistic regression)
-------------------------------------------------------------

 ^mulogit^ depvar indepvar1 indepvar2 ... indepvarp [^if^ exp] 

Generates multivariate and univariate odds ratios (ORs) and 95%
confidence intervals (CIs) for variables in ^varlist^.  The
resulting univariate and multivariate ORs are appended to the
rightside of the data editor, so that they can be cut and pasted
into other graphics packages or publication tables.

The purpose of ^mulogit^ is to write the ORs and 95% CIs
limits as new variable values in the data editor, and then generate
plots of the ORs and CIs using the new variables.  

The twoway rcap graph of Version 10 is first used to generate
a separate plot for multivariate ORs and CIs, then a separate
plot for univariate ORs and CIs.  The variable names (value labels)
in the plots are appended with one of the three labels
designating the significance level for each variable:

* - p<0.05
** - p<0.01
*** - p<0.001

The following plots are saved to disk:

^multuniv.gph^ - a twoway rcap plot of both the multivariate
and univariate ORS and CIs   

^mult.gph^ - a twoway rcap plot of multivariate ORs and CIs

^univ.gph^ - a twoway rcap plot of univariate ORs and CIs  

Finally, the ^combine^ graphics command is used to combine
the separate multivariate and univariate plots into a single
graph.  The ^ycommon^ option for ^combine^ is also employed
to display the same scale (ranges) of multivariate and
univariate ORs and CIs.
        
 ^Examples:^
 ^---------^

. mulogit low age lwt smoke ptl ht ui ftv
. mulogit low age lwt smoke ptl ht ui ftv if race==1

^Author:^
^-------^ 
  Leif E. Peterson
  Center for Biostatistics
  The Methodist Hospital Research Institute (TMHRI)
  Houston, Texas  77030  USA
  Tel: +001 (713) 441-6121
  e-mail: lepeterson@tmhs.org












