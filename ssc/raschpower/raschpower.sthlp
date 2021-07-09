{smcl}
{* 6february2012}{...}
{hline}
help for {hi:raschpower}{right:Jean-Benoit Hardouin, Myriam Blanchin}
{hline}

{title:Estimation of the power of the Wald test in order to compare the means of the latent trait in two groups of individuals}

{p 8 14 2}{cmd:raschpower} [{cmd:,} {cmdab:n0}({it:#}) {cmdab:n1}({it:#})
{cmdab:gamma}({it:#}) {cmdab:var}({it:#}) {cmdab:d}({it:matrix}) {cmdab:method}({it:method})]


{title:Description}

{p 4 8 2}{cmd:raschpower} allows estimating the power of the Wald test comparing the means of two groups of patients in the context of the Rasch model or the partial-credit model. The estimation is based
 on the estimation of the variance of the difference of the means based on the Cramer-Rao bound.

{title:Options}

{p 4 8 2}{cmd:n0} and {cmd:n1} indicates the numbers of individuals in the two groups [100 by default].

{p 4 8 2}{cmd:gamma} indicates the group effect (difference between the two means) [0.5 by default].

{p 4 8 2}{cmd:var} indicates the value of the variance of the latent trait [1 by default].

{p 4 8 2}{cmd:d} is a matrix containing the item parameters [one row per item, one column per positive modality - (-1.151, -0.987\-0.615, -0.325\-0.184, -0.043\0.246, 0.554\0.782, 1.724) by default].

{p 4 8 2}{cmd:method}({it:method}) indicates the method for constructing data. ({it:method}) may be GH, MEAN, MEAN+GH or POPULATION+GH [default is method(GH) if number of patterns<500, method(MEAN+GH) if 500<=number of patterns<10000, 
method(MEAN) if 10000<=number of patterns<1000000, method(POPULATION+GH) otherwise].

{p 8 14 2} {bf:GH}: The probability of all possible response patterns is estimated by Gauss-Hermite quadratures.

{p 8 14 2} {bf:MEAN}: The mean of the latent trait for each group is used instead of Gauss-Hermite quadratures.

{p 8 14 2} {bf:MEAN+GH}: In a first step, the MEAN method is used to determine the most probable patterns. In a second step, the probability of response patterns is estimated by Gauss-Hermite quadratures on the most probable patterns.

{p 8 14 2} {bf:POPULATION+GH}: The most frequent response patterns are selected from a simulated population of 1,000,000 of individuals. The probability of the selected response patterns is estimated by Gauss-Hermite quadratures.

{title:Example}

	{p 4 8 2}{cmd:. raschpower}

	{p 4 8 2}{cmd:. raschpower, n0(200) n1(200) gamma(0.4) var(1.3)}

	{p 4 8 2}{cmd:. matrix diff=(-1.47\-0.97\-.23\-0.12\0.02\0.1)}{p_end}
	{p 4 8 2}{cmd:. raschpower, n0(127) n1(134) gamma(0.23) d(diff) var(2.58)}{p_end}

{title:References}

	{p 4 8 2}Hardouin J.B., Amri S., Feddag M., Sébille V. (2012) Towards Power And Sample Size Calculations For The Comparison Of Two Groups Of Patients With Item Response Theory Models. Statistics in Medicine, 31(11): 1277-1290. 

	
{title:Author}

{p 4 8 2}Jean-Benoit Hardouin, PhD, assistant professor{p_end}
{p 4 8 2}Myriam Blanchin, PhD, research assistant{p_end}
{p 4 8 2}EA4275 "Biostatistics, Pharmacoepidemiology and Subjective Measures in Health Sciences"{p_end}
{p 4 8 2}University of Nantes - Faculty of Pharmaceutical Sciences{p_end}
{p 4 8 2}1, rue Gaston Veil - BP 53508{p_end}
{p 4 8 2}44035 Nantes Cedex 1 - FRANCE{p_end}
{p 4 8 2}Emails:
{browse "mailto:jean-benoit.hardouin@univ-nantes.fr":jean-benoit.hardouin@univ-nantes.fr}{p_end}
{p 13 8 2}{browse "mailto:myriam.blanchin@univ-nantes.fr":myriam.blanchin@univ-nantes.fr}{p_end}
{p 4 8 2}Websites {browse "http://www.anaqol.org":AnaQol}
and {browse "http://www.freeirt.org":FreeIRT}
