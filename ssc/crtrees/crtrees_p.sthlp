{smcl}
{* *! version 1.0  10Dec2018}{...}
{cmd:help crtrees_p} 
{hline}

{title:Syntax for predict after Random Forests using crtrees}

{p 8 16 2}
{opt predict} {dtype} {newvar} {dtype} {newvar:2} {ifin} [{cmd:,} opentrees({it:filename})]

{title:Syntax for predict after Regression and Classification Trees using crtrees}

{p 8 16 2}
{opt predict} {dtype} {newvar} {ifin}

{phang}
{it:newvar} is the name for the new variable containing the model predictions.
For Random Forest (Regression), {it:newvar2} is the name for the new variable containing the bootstrap standard error of the model prediction.
For Random Forest (Classification), {it:newvar2} is the name for the new variable containing the bootstrap misclassification cost (by default, the probability of misclassification).{p_end}

{synoptset 20 tabbed}{...}

{synopthdr}
{synoptline}

{syntab: Random Forests}
{synopt: {opt opentrees(string)}} name of file with mata matrices of bootstrapped trees, their node criteria and coefficients{p_end}

{hline}

{title:Description}

{pstd}
{cmd:predict} after {cmd:crtrees} creates a variable containing the predictions of the last estimated model.
If option {opt rforests} was used with {cmd:crtrees}, then it creates two variables. 
The  first one contains the predictions.
The second one contains either the boootstrap standard error of the predictions (under Regression) or the bootstrap misclassification cost of the classifier (under Classification).

{title:Options}

{dlgtab:Random Forests}

{phang}
{opt opentrees}{cmd:(}{it:string}{cmd:)} string containing the name of the file where to find mata matrices of bootstrapped trees and coefficients in terminal nodes for each tree.
The file must exist and the directory must be readable.
When option {opt opentrees} is not specified, {cmd:predict} attemps first to load mata matrices from file {it: e(matatree)}.
If unsuccessful, then it attempts to load mata matrices from file {it: matatree} in the current working directory.

{title:Remarks}

{pstd}
The model predictions are computed using the honest tree under CART, the average prediction of all bootstrapped trees under Random Forest (Regression), or the most popular vote from all bootstrapped trees under Random Forest (Classification).

{pstd}
Under Random Forest, standard errors/misclassification costs are computed using all bootstrapped trees saved after command {cmd:crtrees}. 

{title:Examples}

{p 4 8 2}
{stata "sysuse auto, clear"}

{p 4 8 2} 
Regression Trees with partition, learning sample size 0.5, and 0 SE rule.
The model predicts within-node constant expectations:{p_end}
{p 8 16 2}{cmd:. crtrees price trunk weight length, seed(12345)}{p_end}
{p 8 16 2}{cmd:. predict price_hat}{p_end}

{p 4 8 2}
Under Random Forest, {cmd:crtrees} creates mata matrix file where all trees in the forest are stored.
{cmd:predict} uses by default, if it still exists, the file last saved with {cmd:crtrees}:{p_end} 
{p 8 16 2}{cmd:. crtrees price trunk weight length, rforests generate(p_hat) bootstraps(2500) savetrees("mymatafile1")}{p_end}
{p 8 16 2}{cmd:. predict price_hat price_stdp}{p_end}

{p 4 8 2}And we get the same result using {opt opentrees}{p_end}
{p 8 16 2}{cmd:. predict price_hat price_stdp, opentrees("mymatafile1")}{p_end}


{title:Author}

{pstd}
{browse "http://www.eco.uc3m.es/%7Ericmora/":Ricardo Mora} {break}
{browse "mailto:ricmora@eco.uc3m.es":email:ricmora@eco.uc3m.es} {break}
Departament of Economics, Universidad Carlos III Madrid{break}
Madrid, Spain{break}


{title:References}

{phang}
Breiman, Leo ; Friedman, Jerome H ; Olshen, Richard A ; Stone, Charles J (1984).
{it: Classification and Regression Trees}.  
Monterey, CA : Wadsworth & Brooks/Cole Advanced Books & Software.

{phang}
Breiman, Leo (2001).
Random Forests, {it: Machine Learning}, Vol. 45, 5-32.

{phang}
Sexton, Joseph; Laake, Peter (2009).
Standard errors for bagged and random forest estimators, {it:Computational Statistics and Data Analysis}, Vol. 53, 801-811.

{phang}
Efron, Bradley (2014)
Estimation and accuracy after model selection, {it:Journal of the American Statistical Association}, 109:507, 991-1007.

{phang}
Scornet, Erwan; Biau, Gérard; Vert, Jean-Philippe (2015).
Consistency of random forests, {it:The Annals of Statistics}, Vol. 43, No. 4, 1710-1741.

{phang}Update: February - 2019{p_end}



