{smcl}
{* *! version 1.1.1}{...}
{title:Title}

{phang}
{bf:dkdensity} {hline 2} Executes deconvolution kernel density estimation and a construction of its uniform confidence band.


{marker syntax}{...}
{title:Syntax}

{p 4 17 2}
{cmd:dkdensity}
{it:x1}
{it:x2}
{ifin}
[{cmd:,} {bf:numx}({it:real}) {bf:domain}({it:real}) {bf:cover}({it:real}) {bf:tp}({it:real})]


{marker description}{...}
{title:Description}

{phang}
{cmd:dkdensity} executes deconvolution kernel density estimation and a construction of its uniform confidence band based on 
{browse "https://www.sciencedirect.com/science/article/abs/pii/S0304407618301301":Kato and Sasaki (2018)}. 
The command requires as input two measurements, {bf:x1} and {bf:x2}, of the unobserved latent variable {bf:x} with classical measurement errors, {bf:e1} = {bf:x1} - {bf:x} and {bf:e2} = {bf:x2} - {bf:x}, respectively. The output consists of a deconvolution kernel density estimate of {it:f}({bf:x}) and their uniform confidence band over a domain of {bf:x}.

{marker options}{...}
{title:Options}

{phang}

{phang}
{bf:numx({it:real})} sets the number of grid points of {bf:x} for deconvolution kernel density estimation and its uniform confidence band. The default value is {bf: numx(20)}.

{phang}
{bf:domain({it:real})} sets the domain of deconvolution kernel density estimation and its uniform confidence band. The default value {bf:domain(2)} defines the domain as +/- 2 standard deviations of {bf:x}.

{phang}
{bf:cover({it:real})} sets the nominal uniform coverage probability for the uniform confidence band. The default value {bf: cover(0.95)} constructs a 95% uniform confidence band.

{phang}
{bf:tp({it:real})} sets the scale-normalized tuning parameter. The default value is {bf: tp(0.2)}.

{marker examples}{...}
{title:Examples}

{phang}
({bf:x1} first measurement of {bf:x}, {bf:x2} second measurement of {bf:x}){p_end}

{phang}Construction of a 95% uniform confidence band:

{phang}{cmd:. dkdensity x1 x2}{p_end}

{phang}Construction of a 90% uniform confidence band:

{phang}{cmd:. dkdensity x1 x2, cover(0.90)}{p_end}

{phang}Constructing a uniform confidence band on a grid points of 100 points in the domain corresponding to +/- 3 standard deviations of {bf:x}:

{phang}{cmd:. dkdensity x1 x2, numx(100) domain(3)}{p_end}

{title:Reference}

{p 4 8}Kato, K. and Y. Sasaki. 2018. Uniform Confidence Bands in Deconvolution with Unknown Error Distribution. {it:Journal of Econometrics}, 207 (1), pp. 129-161. 
{browse "https://www.sciencedirect.com/science/article/abs/pii/S0304407618301301":Link to Paper}.
{p_end}

{title:Authors}

{p 4 8}Kengo Kato, Cornell University, Ithaca, NY.{p_end}

{p 4 8}Yuya Sasaki, Vanderbilt University, Nashville, TN.{p_end}



