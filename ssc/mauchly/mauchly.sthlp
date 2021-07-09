*Version Jan 22, 2017
------------
Syntax:
Mauchly varlist, [m(repeated measure)]

Description:
Mauchly performs sphericity test for repeated measures ANOVA and reports Mauchly (1940) W statistic, Greenhouse_Geiser(1958) and Huynh Feldt (1976) epsilons. Module supports both wide and long format datasets.

Mauchly tests sphericity assumption under null hypothesis that variances across levels of repeated measures are equal. A significant Chi2 value rejects null hypothesis and indicates that sphericity assumption has been violated

Option:
-----------
m: Repeated measures id for panel data

Example:
----------
clear
use http://www.stata-press.com/data/r12/t43, clear
tsset person drug
mauchly score, m(drug)

*Wide format
qui separate score, by(drug)
collapse (sum) score1- score4, by(person)
mauchly score1 score2 score3 score4
 
Author						
Muhammad Rashid Ansari						
INSEAD Business School						
1 Ayer Rajah Avenue, Singapore 138676						
rashid.ansari@insead.edu

References: 
Significance Test for Sphericity of a Normal n-Variate Distribution. John W. Mauchly, The Annals of Mathematical Statistics Vol. 11, No. 2 (Jun., 1940), pp. 204-209 
http://www.jstor.org/stable/2235878

Geisser, S., and S. W. Greenhouse. 1958. An extension of Box's results on the use of the F distribution in multivariate analysis. Annals of Mathematical Statistics 29: 885-891
http://www.jstor.org/stable/2237272

Huynh, H., and L. S. Feldt. 1976. Estimation of the Box correction for degrees of freedom from sample data in randomized block and split-plot designs. Journal of Educational Statistics 1(1): 69-82 
https://www.jstor.org/stable/1164736
