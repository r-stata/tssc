{smcl}
{* Last modified 24th June 2015}{...}
{hline}
help for {hi:revcat}
{hline}

{title:Reversible catalytic models}

{p 8 16 2}{cmd:revcat}{space 1}{it:depvar} {it:agevar} [{it:datevar}]
{weight} {ifin}
[, {opt minage(#)} {opt change(numlist)} {opt age}
{opt smooth} {opt rr} {opt lambda(varlist)}
{opt init(matname)} {opt l:evel(#)} {it:maximize_options} ] {p_end}


{p 8 16 2}{cmd:revcat_pred}  {dtype} {it:predvar} {ifin} [ , {it:parameter} {opt l:evel(#)} ] {p_end}

{pstd}{cmd:by} {it:...} {cmd::} may be used with {cmd:revcat}; see help
{help by}.{p_end}

{pstd}{cmd:fweight}s and {cmd:pweight}s are allowed; see help {help weights}.{p_end}

{title:Description}

{pstd}{cmd:revcat} fits a reversible catalytic model, i.e. a model in which people start off negative for some measured outcome, become positive at rate {it:lambda} and then become negative at rate {it:rho}.
If {it:lambda} and {it:rho} are constant, then someone born negative has probability of being positive at age {it:a} given by:{p_end}
{pmore}p(a) = lambda/(lambda+rho)*(1-exp(-(lambda+rho)*a)){p_end}
{pstd}{p_end}

{pstd}{it:depvar} is the variable recording whether each person is positive or negative, and (if not missing) may only take values 0 or 1.
{it:agevar} is the person's age when the outcome was measured.
If specified, {it:datevar} is the date that the measurement was recorded.
There is assumed to be a single measurement per person.
For each set of parameters, the model calculates the predicted probability of being positive, and then assumes a binomial likelihood.{p_end}

{title:Options}

{phang}{opt minage(#)} is the minimum age that is included in the estimation sample. The default is one.{p_end}

{phang}{opt change(numlist)} is a list of one or more times at which {it:lambda} is assumed to change.
These numbers can have one of three meanings:{p_end}
{phang3}1. If the option {cmd:age} is specified then {cmd:change()} represents ages at which {it:lambda} changes.{p_end}
{phang3}2. If {cmd:age} is not specified and {it:datevar} is supplied then {it:lambda} changed at the times in {cmd:change()}, which represent calendar time.{p_end}
{phang3}3. If {cmd:age} is not specified and {it:datevar} is not supplied then the times in {cmd:change()} are the times since the changes in {it:lambda}.{p_end}

{pmore}Suppose that there are {it:n} values in {cmd:change()}.
Then {it:lambda} takes {it:n+1} values, {it:lambda1}, {it:lambda2}, {it:lambda3},....
{it:lambda1} is the value at the earliest calendar time, or at the youngest age if {cmd:age} is specified.{p_end}
{pmore}
If {cmd:age} is specified then {it:datevar} is irrelevant.
If {cmd:change()} is not specified then both {cmd:age} and {it:datevar} are irrelevant.
{it:agevar}, {it:datevar}, {cmd:change()} and {cmd:minage()} must all be in the same units, e.g. years.
{p_end}

{phang}{opt smooth} specifies that the log of the ratio between successive values of {it:lambda} follows a normal distribution with mean zero and standard deviation {it:sigma}, where {it:sigma} is estimated.{p_end}

{phang}{cmd:rr} specifies that the model be parameterised in terms of {it:lambda1}, {it:r2}, {it:r3},...,
where {it:ri} = {it:lambdai}/{it:lambda1}, {it:i}=2,...,{it:n}+1.
The default parameterisation is in terms of {it:lambda1}, {it:lambda2}, {it:lambda3},....{p_end}

{phang}{opt lambda(varlist)} is a list of variables on which {it:lambda1} depends.
If there is at least one value in {cmd:change()} and {cmd:lambda()} is specified, then the option {cmd:rr} must be specified.{p_end}

{phang}{opt init(matname)} supplies a matrix of initial values.{p_end}

{phang}{opt level(#)} specifies the confidence level, in percent,
for the confidence intervals of the coefficients and for predictions; see help {help level}.{p_end}

{phang}{it:maximize_options} control the maximization process; see help {help maximize}.{p_end}

{title:Predictions}

{pstd}{cmd:revcat_pred} generates predictions with confidence limits after fitting a model using {cmd:revcat}.
Predictions are generated in {it:predvar} and confidence limits in {it:l_predvar} and {it:u_predvar}. 
The default prediction is the probability of being positive.
If {it:parameter} is specified then that quantity is generated instead.
{it:parameter} may be {it:lambda}, {it:rho}, or  one of {it:lambda1}, {it:lambda2},... .
If {it:predvar} is {it:lambda}, then {it:lambda1}, {it:lambda2},... are generated with names {it:predvar}1,{it:predvar}2,... and corresponding confidence intervals.
Otherwise a single quantity is generated with its confidence interval.{p_end}

{title:Examples}

{phang}Simulate some data:{p_end}
{pmore}{cmd}
drop _all{break}
set obs 1000{break}
gen age=-log(runiform())*10{break}
global lambda=0.1{break}
global rho=0.03{break}
gen byte pos=runiform()<$lambda/($lambda+$rho)*(1-exp(-($lambda+$rho)*age)){break}
gen int year=2012{break}
gen byte g=runiform()<0.5
{p_end}

{phang}{text}Fit models:{p_end}
{pmore}{cmd}
revcat pos age{break}
revcat pos age year, change(2008){break}
revcat pos age year, change(2008) rr{break}
revcat pos age, change(16) age{break}
revcat pos age year, change(2008) rr lambda(g){break}
{p_end}

{phang}{text}Generate predictions:{p_end}
{pmore}{cmd}
revcat_pred p{break}
revcat_pred lambda, lambda{break}
{p_end}

{phang}
{text}The following two commands are equivalent, if {it:year} only takes the value 2012:{break}{cmd}
revcat pos age, change(4){break}
revcat pos age year, change(2008)
{p_end}

{pmore}
{text}
{p_end}

{title:Author}
{pin2}
Jamie Griffin{break}
Department of Infectious Disease Epidemiology{break}
Imperial College London{break}
jamiegriffin19@gmail.com
{p_end}

{pin2}Updated 24th June 2015{p_end}

