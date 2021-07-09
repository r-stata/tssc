.-
help for ^predcalc^                                      (JMGarrett 12/06/99)
.-

Predicted Values  
----------------

   ^predcalc^ yvar [^if^ exp], ^x^var^(^xlist^)^  [^m^odel ^lin^ear ^l^evel^(^#^)^
                                          ^cl^uster^(^cluster_var^)^]

   ^predcalc^ calculates predicted values and confidence intervals from
      linear or logistic regression model estimates for user specified values
      for the X variables.
 

Variables and options required
------------------------------

    yvar -- dependent variable

      If yvar is continuous, defaults to linear regression
      If yvar is binary (0,1), defaults to logistic regression

    ^xvar(^x1=# x2=# ...^)^ -- list of X variables and value each is assigned.
                           For example: xvar(age=50 gender=1 sbp=160)

      
Options allowed 
---------------

    ^model^ -- displays regression table

    ^linear^ -- requests linear regression when yvar is binary (0,1); if not 
               specified, logistic regression is assumed

    ^level(^#^)^ -- specifies the confidence level, in percent, for calculation
                    of confidence intervals of predicted values (default=95%)

    ^cluster(^cluster_var^)^ -- cluster variable; adjusts standard errors for
                              intraclass correlation


Examples
--------

 . ^predcalc chol, xvar(age=35 gender=1 sys=120)^

        Uses linear regression to calculate the predicted cholesterol value for
        a 35 year old male with systolic blood pressure of 120 

 . ^predcalc htn, xvar(age=65 gender=0 smoker=1) model^

        Uses a logistic regression model to calculate the predicted probability
        of being hypertensive for a 65 year old women who smokes; the logistic
        regression table is printed.

