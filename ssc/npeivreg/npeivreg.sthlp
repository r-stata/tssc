{smcl}
{* *! version 1.1.1}{...}
{title:Title}

{phang}
{bf:npeivreg} {hline 2} Executes estimation of nonparametric errors-in-variables (EIV) regression and construction of its uniform confidence band.


{marker syntax}{...}
{title:Syntax}

{p 4 17 2}
{cmd:npeivreg}
{it:y}
{it:x1}
{it:x2}
{ifin}
[{cmd:,} {bf:numx}({it:real}) {bf:domain}({it:real}) {bf:cover}({it:real}) {bf:tp}({it:real})]


{marker description}{...}
{title:Description}

{phang}
{cmd:npeivreg} executes estimation of nonparametric errors-in-variables (EIV) regression and construction of its uniform confidence band based on 
{browse "https://www.sciencedirect.com/science/article/abs/pii/S0304407619301605":Kato and Sasaki (2019)}. 
In addition to the dependent variable {bf:y}, the command requires as input two measurements, {bf:x1} and {bf:x2}, of the unobserved independent variable {bf:x} with classical measurement errors, 
{bf:e1} = {bf:x1} - {bf:x} 
and 
{bf:e2} = {bf:x2} - {bf:x}, 
respectively. The output consists of a deconvolution estimate of the nonparametric EIV regression {it:g}({bf:x}) of {bf:y} on {bf:x}, and its uniform confidence band over a domain of {bf:x}.

{marker options}{...}
{title:Options}

{phang}

{phang}
{bf:numx({it:real})} sets the number of grid points of {bf:x} for estimation of the nonparametric EIV regression {it:g}({bf:x}) and its uniform confidence band. The default value is {bf: numx(20)}.

{phang}
{bf:domain({it:real})} sets the domain of estimation of the nonparametric EIV regression {it:g}({bf:x}) and its uniform confidence band. The default value {bf:domain(2)} defines the domain as +/- 2 standard deviations of {bf:x}.

{phang}
{bf:cover({it:real})} sets the nominal uniform coverage probability for the uniform confidence band of the nonparametric EIV regression {it:g}({bf:x}). The default value {bf: cover(0.95)} constructs a 95% uniform confidence band.

{phang}
{bf:tp({it:real})} sets the scale-normalized tuning parameter. The default value is {bf: tp(0.2)}.

{marker examples}{...}
{title:Examples}

{phang}
({bf:y} dependent variable, {bf:x1} 1st measurement of unobserved independent variable {bf:x}, {bf:x2} 2nd measurement of unobserved independent variable {bf:x}){p_end}

{phang}Construction of a 95% uniform confidence band:

{phang}{cmd:. npeivreg y x1 x2}{p_end}

{phang}Construction of a 90% uniform confidence band:

{phang}{cmd:. npeivreg y x1 x2, cover(0.90)}{p_end}

{phang}Constructing a uniform confidence band on a grid points of 100 points in the domain corresponding to +/- 3 standard deviations of {bf:x}:

{phang}{cmd:. npeivreg y x1 x2, numx(100) domain(3)}{p_end}

{phang}
({bf:huq050} number of doctor visits, {bf:bmi_exam} clinically measured BMI, {bf:bmi_self} self reported BMI){p_end}

{phang}Nonparametric EIV regression of the number of doctor visits on BMI, accounting for measurement errors in clinically measured BMI and/or self reported BMI:

{phang}{cmd:. use "doctor_visit_male50.dta"}{p_end}
{phang}{cmd:. npeivreg huq050 bmi_exam bmi_self, domain(1.5)}{p_end}

{title:Reference}

{p 4 8}Kato, K. and Y. Sasaki. 2019. Uniform Confidence Bands for Nonparametric Errors-in-Variables Regression. {it:Journal of Econometrics}, 213 (2), pp. 516-555. 
{browse "https://www.sciencedirect.com/science/article/abs/pii/S0304407619301605":Link to Paper}.
{p_end}

{title:Authors}

{p 4 8}Kengo Kato, Cornell University, Ithaca, NY.{p_end}

{p 4 8}Yuya Sasaki, Vanderbilt University, Nashville, TN.{p_end}



