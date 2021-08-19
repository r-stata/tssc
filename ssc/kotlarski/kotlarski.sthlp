{smcl}
{* *! version 1.1.1}{...}
{title:Title}

{phang}
{bf:kotlarski} {hline 2} Executes deconvolution kernel density estimation and a robust construction of its uniform confidence band.


{marker syntax}{...}
{title:Syntax}

{p 4 17 2}
{cmd:kotlarski}
{it:x1}
{it:x2}
{ifin}
[{cmd:,} {bf:numx}({it:real}) {bf:domain}({it:real}) {bf:cover}({it:real}) {bf:tp}({it:real}) {bf:order}({it:real}) {bf:grid}({it:real})]


{marker description}{...}
{title:Description}

{phang}
{cmd:kotlarski} executes deconvolution kernel density estimation and a robust construction of its uniform confidence band based on 
{browse "https://qeconomics.org/ojs/index.php/qe/article/view/1560":Kato, Sasaki, and Ura (2021)}. 
The command requires as input two measurements, {bf:x1} and {bf:x2}, of the unobserved latent variable {bf:x} with classical measurement errors, {bf:e1} = {bf:x1} - {bf:x} and {bf:e2} = {bf:x2} - {bf:x}, respectively. The output consists of a deconvolution kernel density estimate of {it:f}({bf:x}) and their uniform confidence band over a domain of {bf:x}.

{phang}
FAQ: Why do {bf:kotlarski x1 x2} and {bf:kotlarski x2 x1} produce different results?
Answer: This is because Kotlarski's identity treats {bf:x1} and {bf:x2} separately in that {bf:x1} is assumed to have the zero mean of its measurement error, while {bf:x2} is not.
See Assumption 1 in 
{browse "https://qeconomics.org/ojs/index.php/qe/article/view/1560":Kato, Sasaki, and Ura (2021)}.

{marker options}{...}
{title:Options}

{phang}
{bf:numx({it:real})} sets the number of grid points of {bf:x} for deconvolution kernel density estimation and its uniform confidence band. The default value is {bf: numx(20)}.

{phang}
{bf:domain({it:real})} sets the domain of deconvolution kernel density estimation and its uniform confidence band. The default value {bf:domain(2)} defines the domain as +/- 2 standard deviations of {bf:x}.

{phang}
{bf:cover({it:real})} sets the nominal uniform coverage probability for the uniform confidence band. The default value {bf: cover(0.95)} constructs a 95% uniform confidence band.

{phang}
{bf:tp({it:real})} sets the scale-normalized tuning parameter. Not invoking this option will entail an optimal choice of the tuning parameter.

{phang}
{bf:order({it:real})} sets the order {bf: q} of the Hermite polynomial basis. The default value is {bf: order(2)}.

{phang}
{bf:grid({it:real})} sets the size {bf: L} of grid in the frequency domain. The default value is {bf: grid(50)}.


{marker examples}{...}
{title:Examples}

{phang}
({bf:x1982} first measurement of {bf:x}, {bf:x1983} second measurement of {bf:x}){p_end}

{phang}Constructing a uniform confidence band in the domain corresponding to +/- 4 standard deviations of {bf:x}:

{phang}{cmd:. use "example_1982_1983.dta"}{p_end}
{phang}{cmd:. kotlarski x1982 x1983, domain(4)}{p_end}

{phang}Construction of a 90% uniform confidence band:

{phang}{cmd:. use "example_1982_1983.dta"}{p_end}
{phang}{cmd:. kotlarski x1982 x1983, domain(4) cover(0.90)}{p_end}


{title:Reference}

{p 4 8}Kato, K., Y. Sasaki., and T. Ura 2021. Robust Inference in Deconvolution. {it:Quantitative Economics}, 12 (1), pp. 109-142. 
{browse "https://qeconomics.org/ojs/index.php/qe/article/view/1560":Link to Paper}.
{p_end}


{title:Authors}

{p 4 8}Kengo Kato, Cornell University, Ithaca, NY.{p_end}

{p 4 8}Yuya Sasaki, Vanderbilt University, Nashville, TN.{p_end}

{p 4 8}Takuya Ura, University of California, Davis, CA.{p_end}



