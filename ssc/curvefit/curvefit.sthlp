{smcl}
{* 10Apr2013}{* 09Apr2013}{* 30Mar2013}{* 13Mar2013}{* 15Mar2010}{* 1Oct2010}{...}
{hline}
help for {hi:curvefit}{right: version 4.0}
{right:{stata ssc install curvefit, replace: get the newest version}}
{hline}


{title:Curve Estimation}


{title:Description}


{pstd}
{opt curvefit} procedure produces curve estimation regression statistics and related plots {cmd:between two variables} for 35 different 
curve estimation regression models. {opt curvefit} based on the Stata command {help nl} which fits an arbitrary nonlinear regression function by least squares.


{title:Syntax}


{p 5 4 2}
{cmd:curvefit}
{it:{help depvar}} {it:{help indepvars:indepvar}} [{it:{help if}}] [{it:{help in}}] [{it:{help weight}}]
{cmd:,} {cmdab:f:unction(}{it:string}{cmd:)} [{cmdab:n:ograph} {cmdab:i:nitial(}{it:string}{cmd:)} {cmdab:c:ount(}{it:integer}{cmd:)}
 {help nl##vcetype:vce{cmd:(}}{it:string}{cmd:)} {it:{help scheme}(string)} {help saving_option:saving}{cmd:(}{it:filename} [{cmd:,} {it:suboptions}]{cmd:)}]{break}

{synoptset 20 tabbed}{...}
{marker options}{...}
{synopthdr}
{synoptline}
{p2coldent :* {cmdab:f:unction(}{it:string}{cmd:)}}The following are alternative Models correspond with the values of the {it:sting}: {p_end}
{p2coldent :. {it:string} = 1}{cmd:Linear: }Y = b0 + (b1 * X){p_end}
{p2coldent :. {it:string} = 2}{cmd:Logarithmic: }Y = b0 + (b1 * ln(X)){p_end}
{p2coldent :. {it:string} = 3}{cmd:Inverse: }Y = b0 + (b1 / X){p_end}
{p2coldent :. {it:string} = 4}{cmd:Quadratic: }Y = b0 + (b1 * X) + (b2 * X^2){p_end}
{p2coldent :. {it:string} = 5}{cmd:Cubic: }Y = b0 + (b1 * X) + (b2 * X^2) + (b3 * X^3){p_end}
{p2coldent :. {it:string} = 6}{cmd:Power: }Y = b0 * (X^b1) {cmd:OR} ln(Y) = ln(b0) + (b1 * ln(X)){p_end}
{p2coldent :. {it:string} = 7}{cmd:Compound: }Y = b0 * (b1^X) {cmd:OR} ln(Y) = ln(b0) + (ln(b1) * X){p_end}
{p2coldent :. {it:string} = 8}{cmd:S-curve: }Y = e^(b0 + (b1/X)) {cmd:OR} ln(Y) = b0 + (b1/X){p_end}
{p2coldent :. {it:string} = 9}{cmd:Logistic: }Y = b0 / (1 + b1 * e^(-b2 * X)){p_end}
{p2coldent :. {it:string} = 0}{cmd:Growth: }Y = e^(b0 + (b1 * X)) {cmd:OR} ln(Y) = b0 + (b1 * X){p_end}
{p2coldent :. {it:string} = a}{cmd:Exponential: }Y = b0 * (e^(b1 * X)) {cmd:OR} ln(Y) = ln(b0) + (b1 * X){p_end}
{p2coldent :. {it:string} = b}{cmd:Vapor Pressure: }Y = e^(b0 + b1/X + b2 * ln(X)){p_end}
{p2coldent :. {it:string} = c}{cmd:Reciprocal Logarithmic: }Y = 1 / (b0 + (b1 * ln(X))){p_end}
{p2coldent :. {it:string} = d}{cmd:Modified Power: }Y = b0 * b1^(X){p_end}
{p2coldent :. {it:string} = e}{cmd:Shifted Power: }Y = b0 * (X - b1)^b2{p_end}
{p2coldent :. {it:string} = f}{cmd:Geometric: }Y = b0 * X^(b1 * X){p_end}
{p2coldent :. {it:string} = g}{cmd:Modified Geometric: }Y = b0 * X^(b1/X){p_end}
{p2coldent :. {it:string} = h}{cmd:nth order Polynomial: }Y = b0 + b1*X + b2*X^2 + b3*X^3 + b4*X^4 + b5*X^5 ...{p_end}
{p2coldent :. {it:string} = i}{cmd:Hoerl: }Y = b0 * (b1^X) * (X^b2){p_end}
{p2coldent :. {it:string} = j}{cmd:Modified Hoerl: }Y = b0 * b1^(1/X) * (X^b2){p_end}
{p2coldent :. {it:string} = k}{cmd:Reciprocal: }Y = 1 / (b0 + b1 * X){p_end}
{p2coldent :. {it:string} = l}{cmd:Reciprocal Quadratic: }Y = 1 / (b0 + b1 * X + b2 * X^2){p_end}
{p2coldent :. {it:string} = m}{cmd:Bleasdale: }Y = (b0 + b1 * X)^(-1 / b2){p_end}
{p2coldent :. {it:string} = n}{cmd:Harris: }Y = 1 / (b0 + b1 * X^b2){p_end}
{p2coldent :. {it:string} = o}{cmd:Exponential Association: }Y = b0 * (1 - e^(-b1 * X)){p_end}
{p2coldent :. {it:string} = p}{cmd:Three-Parameter Exponential Association: }Y = b0 * (b1 - e^(-b2 * X)){p_end}
{p2coldent :. {it:string} = q}{cmd:Saturation-Growth Rate: }Y = b0 * X/(b1 + X){p_end}
{p2coldent :. {it:string} = r}{cmd:Gompertz Relation: }Y = b0 * e^(-e^(b1 - b2 * X)){p_end}
{p2coldent :. {it:string} = s}{cmd:Richards: }Y = b0 / (1 + e^(b1 - b2 * X))^(1/b3){p_end}
{p2coldent :. {it:string} = t}{cmd:MMF: }Y = (b0 * b1+b2 * X^b3)/(b1 + X^b3){p_end}
{p2coldent :. {it:string} = u}{cmd:Weibull: }Y = b0 - b1*e^(-b2 * X^b3){p_end}
{p2coldent :. {it:string} = v}{cmd:Sinusoidal: }Y = b0+b1 * b2 * cos(b2 * X + b3){p_end}
{p2coldent :. {it:string} = w}{cmd:Gaussian: }Y = b0 * e^((-(b1 - X)^2)/(2 * b2^2)){p_end}
{p2coldent :. {it:string} = x}{cmd:Heat Capacity: }Y = b0 + b1 * X + b2/X^2{p_end}
{p2coldent :. {it:string} = y}{cmd:Rational: }Y = (b0 + b1 * X)/(1 + b2 * X + b3 * X^2){p_end}
{p2coldent :. {it:string} = ALL}refers to a total of above models {cmd:(Attention: it's uppercase!)}{p_end}
{p2coldent :* {cmdab:n:ograph}}Curve Estimation without curve fit graph.{p_end}
{p2coldent :* {cmdab:i:nitial(}{it:string}{cmd:)}}initial values for parameters.{p_end}
{p2coldent :* {cmdab:c:ount(}{it:integer}{cmd:)}}set order of model 'nth order Polynomial' (default=4).{p_end}
{p2coldent :* {cmdab:v:ce(}{it:string}{cmd:)}}may be {opt gnr}, {opt r:obust}, {opt boot:strap}, {opt jack:knife}, {opt hc2}, {opt hc3} or 'cluster {it: clustvar}'.{p_end}
{p2coldent :* {cmdab:sche:me}(string)}Set default {help scheme}.{p_end}
{p2coldent :* {cmdab:sav:ing}(string)}save graph to disk. '{cmd:saving(}{it:{help filename}} [{cmd:,} {it:suboptions}]{cmd:)}' specifies the name of the diskfile to be created or replaced.
 If {it:filename} is specified without an extension, {cmd:'.gph'} will be assumed. asis specifies that the graph be frozen and saved just as it is.  The alternative -- and the default if asis is not specified -- is known as live format.{p_end}
{synoptline}
{p2colreset}{...}

{pstd}
{cmd:Note:} 
(1)Some of the equations must initial values for parameters. (2)As for the model {cmd:'nth order Polynomial'}, you should use the option {cmdab:c:ount(}{it:integer}{cmd:)} to set the order of it. (3)aweights, fweights, and iweights are allowed.


{title:Examples}


{phang}(1) {stata sysuse auto}

{phang}. {cmd:curvefit} between variables weight and length for models {cmd:6, 8, 0} with a related plots: 

{phang}. {stata curvefit weight length if foreign==0, f(681a)}

{phang}. {cmd:curvefit} between variables with scheme 's2mono': 

{phang}. {stata curvefit weight length if foreign==0, f(124) sche(s2mono)}

{phang}. {cmd:curvefit} between variables and save graph 'curve_1.gph' to disk: 

{phang}. {stata curvefit weight length if foreign==0, f(124) sav(curve_1)}

{phang}. {cmd:curvefit} between variables and replace with the asis graph 'curve_1.gph': 

{phang}. {stata curvefit weight length if foreign==0, f(124) sav(curve_1, replace asis)}

{phang}. {cmd:curvefit} for all models with no related plots: 

{phang}. {stata curvefit weight length, f(ALL) n}

{phang}. then choose models with bigger adjusted R-squared which {cmd:curvefit} the data better: 

{phang}. {stata curvefit weight length, f(681abfg)}

{phang}(2) {stata sysuse temptime} -- You can get the data file from {stata net get curvefit.pkg:here}

{phang}. {cmd:curvefit} for {cmd:5th order Polynomial} models:

{phang}. {stata curvefit temperature time, f(h) c(5)}

{phang}. {cmd:curvefit} for {cmd:Logistic} models with initial values for parameters: 

{phang}. {stata curvefit temperature time, f(9) i(b0 2 b1 1.5 b2 0.1)}

{phang}. {cmd:curvefit} for {cmd:Reciprocal Quadratic} models with initial values for parameters: 

{phang}. {stata curvefit temperature time, f(l) i(b0 1 b1 0 b2 3)}

{phang}. {cmd:curvefit} for {cmd:Sinusoidal} models with initial values for parameters:

{phang}. {stata curvefit temperature time, f(v) i(b0 3 b1 0.5 b2 0.05 b3 -5)}


{title:Acknowledgments}


{pstd}
I wish to thank Richard Williams (Notre Dame Dept of Sociology) for his good advise.
{break}


{title:For problems and suggestions}


{pstd}
{cmd:Author: Liu wei}, The School of Sociology and Population Studies, Renmin University of China. {cmd:Address: }Zhongguancun Street No. 59, Haidian District, Beijing, China. {cmd:ZIP Code:} 100872. 
{cmd:E-mail:} {browse "mailto:liuv@ruc.edu.cn":liuv@ruc.edu.cn} {break}


{title:Also see}


{pstd}
Other Commands I have written: {p_end}

{synoptset 30 }{...}
{synopt:{help deci} (if installed)} {stata ssc install deci} (to install){p_end}
{synopt:{help fdta} (if installed)} {stata ssc install fdta} (to install){p_end}
{synopt:{help ftrans} (if installed)} {stata ssc install ftrans} (to install){p_end}
{synopt:{help freplace} (if installed)} {stata ssc install freplace} (to install){p_end}
{synopt:{help elife} (if installed)} {stata ssc install elife} (to install){p_end}
{synopt:{help ftree} (if installed)} {stata ssc install ftree} (to install){p_end}
{synopt:{help fren} (if installed)} {stata ssc install fren} (to install){p_end}
{synopt:{help equation} (if installed)} {stata ssc install equation} (to install){p_end}
{p2colreset}{...}

