{smcl}
{cmd:help overdisp}
{hline}

{title:Title}
{phang}
{bf:overdisp -- A direct command to detect overdispersion in count-data models}

{title:Syntax}
{p 8 17 12}
{cmd:overdisp} {it:depvar indepvars} {cmd:,} {cmdab:level}{cmd:(}{it:#}{cmd:)}

{title:Description}

{pstd}
{cmd:overdisp} provides a direct alternative to identify overdispersion in Stata, being a faster and an easier way to choose between Poisson and binomial negative estimations in the presence of count-data. Thus, overdisp can be implementd without the necessity of previously estimating Poisson or binomial negative models.


{title:Options}

{phang}
{cmd:level(}{it:#}{cmd:)} specifies confidence level, and the default is level(95). H0 indicates equidispersion.


{title: Examples}

{phang}
{cmd: . overdisp docvis private medicaid age age2 educyr actlim totchr}

{phang}
{cmd: . overdisp docvis private medicaid age age2 educyr actlim totchr, level(90)}


{title: References}

{pstd}
Cameron, A. C., and P. K. Trivedi. 2010. Microeconometrics using Stata. Revised ed. College Station, TX: Stata Press.

{pstd}
Cameron, A. C., and P. K. Trivedi. 2013. Regression Analysis of Count Data. 2nd ed. Cambridge: Cambridge University Press.

{pstd}
Fávero, L. P., and P. Belfiore. 2017. Manual de Análise de Dados: Estatística e Modelagem Multivariada. Rio de Janeiro: Elsevier.

{pstd}
Fávero, L. P., and P. Belfiore. 2018. Data Science for Business and Decision Making. San Diego: Academic Press Elsevier.


{title: Acknowledgment}

{pstd}
We are especially grateful to Enrique Pinzon (StataCorp) for providing us with helpful suggestions and support.

