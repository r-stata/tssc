{smcl}
{* *! version 1.0 12Dec2014}
{cmd:help logtest}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col :{hi:logtest }{hline 2}}tests significance of a predictor in logistic models{p_end}
{p2colreset}{...}



{title:Description}

There exist a few ways (e.g. Wald test) of testing the statistical 
significance of a predictor in logistic models. The likelihood ratio 
(LR) test used for comparing two models is considered as a better 
approach (Menard 2002). It is about comparing two logistic 
regression models, one with the predictor (unrestricted) and one 
without the predictor (restricted) being tested.

If the LR-difference is significant, this means that the unrestricted
model is making a significant improvement as compared to the
restricted model. Thus, we can conclude that the predictor being
tested is statistically significant.



KW: logistic regression
KW: likelihood ratio
KW: model comparison



{title:Examples}

{phang}{stata "sysuse auto, clear": . sysuse auto, clear}{p_end}
{phang}{stata "recode price 0/5000=0 5001/15906=1": . recode price 0/5000=0 5001/15906=1} {p_end}

{phang}{stata "logtest, m1(price foreign) m2(price foreign turn)": . logtest, m1(price foreign) m2(price foreign turn)} {p_end}

{phang}{stata "logtest, m1(price headroom) m2(price foreign headroom)": . logtest, m1(price headroom) m2(price foreign headroom)} {p_end}


{title:Author}
Mehmet Mehmetoglu
Department of Psychology
Norwegian University of Science and Technology
mehmetm@svt.ntnu.no


Reference
Menard, S. (2002). Applied logistic regression analysis (Vol. 106). 
Thousand Oaks, Calif.: Sage.
