{smcl}
{* 14oct2014}{...}
{cmd:help randinf}{right:Version 0.1.7}
{hline}

{title:Title}

{pstd}
{hi:randinf} {hline 2} Calculates the treatment effect and p-value using Fisher's Randomization Test for stratified randomized controlled experiments (see Imbens & Rubin, 2015). 
{p_end}

{marker syntax}{title:Syntax}

{pstd} 
{cmd:randinf} [if] [in] {cmd:, }
{opt tr:eat(treatvar)}
{opt out:come(dependentvar)}
{opt str:ata(stratavar)}
[{opt iter:(num)}
{opt gran:ularity(num)}
{opt mi:ss}
{opt cov:ars(covars)}
{opt di:splayprogress}
{opt one:sided}
{opt resid:(residvar)}
{opt nof:igure}]


{marker desc}{title:Description}

{pstd} {cmd:randinf} is a method for calculating the treatment effect and p-value of a stratified randomized controlled experiment using Fisher's Randomization Test under the sharp null hypothesis (see Imbens & Rubin, 2015). 
This function uses rank-sum test statistics to evaluate if the difference between any two experimental conditions is significant, first using a sharp null hypothesis of no effect and then iterating through 
null hypotheses of various constant treatment effects. Namely, the function will test a wide range of constant treatment effects. The constant treatment effect with the highest probability 
in a randomly permuted null distribution will be outputted as the final treatment effect. This command generates a figure showing the probabilities of each treatment effect and highlighting the final treatment effect. {p_end}

{marker opt}{title:Options}

{pstd} {opt treat:(treatvar)} name of the treatment variable; must be binary {p_end} 
{pstd} {opt outcome:(dependentvar)} name of the outcome or dependent variable {p_end} 
{pstd} {opt strata:(stratavar)} name of the strata variable {p_end} 
{pstd} {opt iter:(num)} number of iterations used to construct null distribution; default is 1000 {p_end} 
{pstd} {opt granularity(num)} the precision on the treatment effect; default is .05. This setting also specifies 
the step size of each successive constant treatment effect tested. Lower numbers yield greater precision but take longer to calculate. {p_end} 
{pstd} {opt miss} do not omit strata with missing values {p_end} 
{pstd} {opt covars:(covars)} optional covariate adjustment used to calculate residuals. NOTE: You must specify whether each variable is categorical or continuous using 
the i. (categorical) and c. (continuous) prefixes. If left unspecified, the strata variable is used to calculate residuals as a set of dummy variables.  {p_end} 
{pstd} {opt displayprogress} show covariate regression and iteration through possible treatment effects  {p_end} 
{pstd} {opt onesided} one-sided significance test (default is two-sided){p_end} 
{pstd} {opt resid:(residvar)} specify custom residuals {p_end} 
{pstd} {opt nofigure} suppresses the figure {p_end} 


{marker ex}{title:Examples}

{pstd} {inp:. randinf, treat(treat) dv(voted) strata(congressionaldistrict)}{p_end}
{pstd} {inp:. randinf, treat(treat) dv(voted) strata(congressionaldistrict) covars(i.voted08 c.age)}{p_end}


{marker res}{title:Saved Results}
{pstd}
{cmd:randinf} saves the following in {cmd:e()}:

{synoptset 25 tabbed}{...}
{p2col 5 25 29 2: Scalars}{p_end}
{synopt:{cmd:e(tau)}}treatment effect{p_end}
{synopt:{cmd:e(pvalue)}}p-value{p_end}

{title:Notes}
{pstd}This package requires the package {cmd:shufflevar}. If {cmd:shufflevar} is missing from your installation of Stata, {cmd:randinf} installs {cmd:shufflevar} from SSC.{p_end}

{pstd}This package does not set the seed or the sortseed, so when you require replicability, please set both the seed and the sortseed.{p_end}


{title:References}
{pstd}Imbens, G. W., & Rubin, D. B. (2015). Causal Inference in Statistics, Social, and Biomedical Sciences. Cambridge University Press. Chapter 5.{p_end}

{title:Authors}
{pstd}John Ternovski{p_end}
{pstd} Harvard University{p_end}
{pstd} {browse "mailto:johnt1@gmail.com":johnt1@gmail.com}{p_end}

{title:Thanks}
{pstd}Special thanks to Avi Feller (University of California, Berkeley) for his guidance on the statistical side of things. 
Additionally, I am grateful to Chris Kennedy (University of California, Berkeley) and Josh Kalla (University of California, Berkeley) for their feedback and comments. 


