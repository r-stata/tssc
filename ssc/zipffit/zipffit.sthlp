{smcl}

{hline}
help for {hi:zipffit}{right:Alexander Koplenig (July 2014)}
{hline}

{title:Fitting a Zipf or a Zipf-Mandelbrot distribution by ML}

{p 8 17 2}{cmd:zipffit} {it:var} [{cmd:if}]
        [{cmd:,}
        {cmdab:zm:andelbrot} 
        {cmdab:r:ank(#)} 
        {cmdab:log} {it:maximize_options}]
 
{p 4 4 2}{cmd:by} is allowed {p_end}

{title:Options}

{p 4 8 2}{cmdab:zm:and} specifies to fit the two parameters of the Zipf-Mandelbrot distribution. 
				By default, the parameter of the Zipf distribution is fitted.{p_end}

{p 4 8 2}{cmdab:r:ank(}{it:#}{cmdab:)} requests to fit the distribution only for the first {it:#} ranks.

{p 4 8 2}{cmd:log} displays the iteration log. Suppressed by default.

{p 4 8 2}All standard {it:maximize_options} are available ({help maximize}). Using {cmd:difficult} or {cmd:technique} can sometimes help to achieve convergence, 
when the message "not concave" appears repeatedly.


{title:Description}

{p 4 4 2}
{cmd: zipffit} fits a Zipf distribution or a Zipf-Mandelbrot distribution by ML using a right truncated zeta distribution. 
If one {cmd: -gsorts} a list of observations by the frequency of {it: var}
and assign rank 1 to the most frequent observation, 
rank 2 to the second most frequent observation, and so on, 
then many empirical phenomena (e.g. word frequency distributions, city sizes, income distributions, relative species abundance) 
tend to be Zipf distributed (Zipf, 1935), that is, they (roughly) obey the following relation
between the rank r of an observation and its frequency f_r:

{p 8 4 2}f_r~r^(-a)

{p 4 4 2}where {it: a} is a parameter that has to be determined empirically. 
[NB.: if two observations have the same {it: var} frequency, then individual ranks are assigned randomly, that is, 
ties are broken arbitrarily.]
 
{p 4 4 2}Mathematically, Zipf’s law can be modeled as a right-truncated 
zeta distribution (Baixeries et al. , 2013), 
where the probability p of a word with rank r is given by

{p 8 4 2}p_r=(1/H(N,a))*r^(-a)

{p 4 8 2}where H(N,a) is defined as

{p 8 4 2}H(N,a) = SUM(1/r^(a))
 
{p 4 4 2}Here, the SUM is the sum starting from rank one to the maximum rank N, which is the observed number of observations (e.g. different word types)

{p 4 4 2}Correspondingly, the Zipf-Mandelbrot law (Mandelbrot, 1953) can be modeled as 

{p 8 4 2}p_r=(1/H(N,a,ß))*(r+ß)^(-a)

{p 4 4 2}with

{p 8 4 2}H(N,a,ß) = SUM(1/(r+ß)^(a))

{p 4 4 2}Since Zipf's law is just a special case of the Zipf-Mandelbrot law 
with the second parameter ß set to 0, the following description focusses on the maximum likelihood fit of the ZM law.

{p 4 4 2}In what follows, observations are assumed to be conditionally independent. 
Thus, the log-likelihood satisfies the linear form restriction and the {cmd:ml model lf} can be used to maximize. 

{p 4 4 2}Following Baixeries et al. (2013), the likelihood function for one single observation with rank r and the corresponding frequency f_r can be defined as:

{p 8 4 2}l_r=p_r^(f_r) 		

{p 4 4 2}Taking logs on both sides and using the definitions presented above, 
this yields the log likelihood function:

{p 8 4 2}ll_r=-a*f_r*log(r+ß)-f_r*log(H(N,a,ß)). 		

{title:Saved results}


{p 4 4 2} 
All results saved after {cmd:ml}, additionally {cmd:zipffit} saves the parameter of the Zipf distribution ({cmd:e(zalpha)}) 
or the parameters of the Zipf-Mandelbrot distribution ({cmd:e(zmalpha)},{cmd:e(zmbeta)}). In both cases, the number of different observations
({cmd:e(types)}) and the sum of the {it: var} frequencies ({cmd:e(tokens)}) are saved.
 
        
{title:Examples:}

{p 4 8 2}Generate test data (taken from Izsák, 2006).

{p 4 8 2}{cmd:. clear}

{p 4 8 2}{cmd:. set obs 18}

{p 4 8 2}{cmd:. gen test=1}

{p 4 8 2}{cmd:. replace test=145 in 1}

{p 4 8 2}{cmd:. replace test=96 in 2}

{p 4 8 2}{cmd:. replace test=35 in 3}

{p 4 8 2}{cmd:. replace test=29 in 4}

{p 4 8 2}{cmd:. replace test=20 in 5}

{p 4 8 2}{cmd:. replace test=11 in 6}

{p 4 8 2}{cmd:. replace test=4 in 7/9}

{p 4 8 2}{cmd:. replace test=3 in 10/11}

{p 4 8 2}{cmd:. replace test=2 in 12/13}

{p 4 8 2}ML fit of the Zipf distribution.

{p 4 8 2}{cmd:. zipffit test}

{p 4 8 2}ML fit of the Zipf-Mandelbrot distribution with {it:maximize_options.}

{p 4 8 2}{cmd:. zipffit test, zmand iterate(100) difficult}

{p 4 8 2}ML fit of the Zipf-Mandelbrot distribution with the iteration log displayed.

{p 4 8 2}{cmd:. zipffit test, zmand log difficult}

{p 4 8 2}ML fit of the Zipf-Mandelbrot distribution for the first 10 ranks.

{p 4 8 2}{cmd:. zipffit test, zmand rank(10)}



{title:Author}

{p 4 4 2}Alexander Koplenig <koplenig@ids-mannheim.de>, Institute for the
German Language (IDS), Mannheim, Germany.


{title:References}

{p 4 8 2}For this help file and for some code lines in the 
actual ado file, the paretofit.ado written by 
Stephen P. Jenkins & Philippe Van Kerm was used as a blueprint (cf. {help paretofit}).

{p 4 8 2}Baixeries, J., Elvevåg, B., & Ferrer-i-Cancho, R. (2013). 
				The Evolution of the Exponent of Zipf’s Law in Language Ontogeny. 
				PLoS ONE, 8(3), e53227. doi:10.1371/journal.pone.0053227

{p 4 8 2}Izsák, F. (2006). Maximum likelihood estimation for constrained parameters of multinomial distributions—Application 
				to Zipf–Mandelbrot models. Computational Statistics & Data Analysis, 51(3), 1575–1583. 
			
{p 4 8 2}Mandelbrot, B. (1953). An informational theory of the statistical structure of language. 
				In W. Jackson (Ed.), Communication Theory (pp. 468–502) 
				London: Butterworths Scientific Publications.

{p 4 8 2}Zipf, G. K. (1935). The psycho-biology of language?; 
				an introduction to dynamic philology. 
				Boston: Houghton Mifflin company.




