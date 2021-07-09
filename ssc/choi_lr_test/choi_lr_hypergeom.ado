program define choi_lr_hypergeom
version 14

*    This program is called by ml and in turn calls hyperg_prob.
*    Its function is to call choi_lr_hyperg_prob using the macros required by ml

*    The ml program is intended to calculate a MLE for models that regress 
*    a dependent variable y against a linear predictor Xb. It requires a 
*    global macro $ML_y1, which equals the dependent variable and a local 
*    macro Xb which equals the linear predictor. In this example there is only 
*    a single record with dependent variable y1. Xb equals the constant term
*    in the linear predictor, which is the log odds ratio psi.

*    $ML_y1 = y1 is the observed number of successes on treatment 1
*    Xb is the log odds ratio psi
*    n1 & n2 are scalars defined in ChoiLRtest that equal the number of 
*        patients on treatments 1 and 2, respectively.
*    y2 is a variable that equals the number of successes on treatment 2
*    lnf is the log of the likelihood function

     args   lnf Xb 
     choi_lr_hyperg_prob n1 n2 $ML_y1 y2 `Xb'
     replace `lnf' = r(lnf) 
     
end
