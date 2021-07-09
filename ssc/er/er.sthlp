{smcl}
{* April 2014}{...}
{hline}
help for {hi:er (Version 1.1)}{right:Carlos Gradín (April 2014)}
{hline}

{title:Polarization index, Esteban and Ray (Econometrica, 1994)}

{title:Syntax}

{p 8 17 2} 
{cmd:er} {it:varname} [{it:weights}] [{cmd:if} {it:exp}] [{cmd:in} {it:range}] [, {cmdab:a:lpha}{it:(# [# # ...])} {cmdab:n:ormalize}{it:(ln | mean | none)} {cmdab:n:onaggregate} ]

{p 12 4 2} 
{it:varname} indicates the variable of interest (ex. income, expenditure, ...).

{p 12 4 2} 
{cmd:fweights}, {cmd:aweights} and {cmd:aweights} are allowed; see {help weights}.

{title:Description}

{p 4 4 2} 
{cmd:er} computes the polarization index proposed by Esteban and Ray (1994) for the requested values of the {it:alpha} parameter (the degree of "polarization sensitivity").

It uses either individual data or data aggregated by groups.

{title:Formula} 

ER(alpha) = sum_i {sum_j [{it:pi}^(1+{it:alpha})*{it:pj}*|{it:yi}-{it:yj}|]}

{p 8 4 2} 
Where {it:yi} is each (normalized) value of {it:varname}, {it:pi} is the (weighted) proportion of individuals with {it:yi}, and {it:alpha} (between 1.0 and 1.6) is the degree of "polarization sensitivity".

{p 4 4 2} 
- Aggregation

{p 8 4 2}
By default, {it:yi} represents each distinct value of {it:varname}, pi is the weighted proportion of observations with same {it:yi}, and the number of groups equals the number of distinct values of {it:varname}.
That is, two or more observations with the same value of {it:varname} are aggregated as if they belonged to the same group. 
This uses the command {cmd:tabulate}, so the maximum number of groups depends on the limit applicable for the number of rows in that command).

{p 8 4 2}
To treat each observation as a separate group, use the option {cmdab:n:onaggregate}. In that case, the number of groups equals the number of observations.
Given that it does not use {cmd:tabulate}, this option might also be useful to overcome the limit of distinct groups of that command.
For that, make sure that you collapse your dataset so that each observation is a different group, before running {cmd:er} (see example below).

{p 4 4 2} 
- Normalization

{p 8 4 2}
By default, {it:yi} is ln({it:varname}). For alternative normalizations (none or division by the mean) use the corresponding options.


{p 4 4 2}
Warning: The time needed for the computation might be long if the number of groups is large. Especially, if the option {cmdab:n:onaggregate} is used with a large number of observations.

{title:Options}

{p 4 8 2}
{cmdab:a:lpha} : values of {it:alpha} to be reported. By default: {cmdab:a:lpha}(1.0 1.3 1.6).

{p 4 8 2}
{cmdab:n:ormalize}{it:()} to choose how to normalize {it:varname}. By default: {cmdab:n:ormalize}{it:(ln)}.

{p 8 8 2}
{cmdab:n:ormalize}{it:(ln)} to compute natural log of {it:varname}, the default.

{p 8 8 2}
{cmdab:n:ormalize}{it:(mean)} to divide {it:varname} by the mean.

{p 8 8 2}
{cmdab:n:ormalize}{it:(none)} to use unnormalized {it:varname}.

{p 4 8 2}
{cmdab:n:onaggregate} to treat each observation as a distinct group (prevent eggregating observations with same values of {it:varname})


{title:Saved results} 

{p 4 4 2} 
Scalars:

{p 8 8 2} 
r(er_1), r(er_2) ...

{title:Examples} 

{p 4 8 2}
. {stata use erdata.dta, clear }

{p 4 8 2}
. {stata list }

{p 4 8 2}
Observations with same income are aggregated (ex. 1 and 2, 3 and 4, ...):

{p 4 8 2}
. {stata er income [aw=weight] }

{p 8 8 2}
Or equivalently, collapsing by income to avoid the limits of tabulate

{p 4 8 2}
. {stata collapse (sum) weight, by(income) }

{p 4 8 2}
. {stata list }

{p 4 8 2}
. {stata er income [aw=weight], n }


{p 4 8 2}
Changing normalization and requested values of alpha, using a subsample


{p 4 8 2}
. {stata use erdata.dta, clear }

{p 4 8 2}
. {stata er income [aw=weight] if region==1, a(1.0 1.2 1.4) n(mean) }

{p 4 8 2}
. {stata er income [aw=weight], a(1.3) n(none) }


{p 4 8 2}
Observations with same income are not aggregated (they are treated as different groups):

{p 4 8 2}
. {stata er income [aw=weight], n }


{p 4 8 2}
For bootstrapping (BC estimates), using saved scalars

{p 8 8 2}
 cap program drop estray

{p 8 8 2}
 program def estray

{p 12 8 2}
 er income [aw=weight]

{p 8 8 2}
 end

{p 8 8 2}
 bootstrap r(er_1) r(er_2) r(er_3) , reps(1000): estray

{p 8 8 2}
 estat bootstrap


{title:Author}

{p 4 4 2}{browse "http://webs.uvigo.es/cgradin": Carlos Gradín}
<cgradin@uvigo.es>{break}
Facultade de CC. Económicas{break}
Universidade de Vigo{break} 
36310 Vigo, Galicia, Spain.

{title:References}

{p 4 8 2}

Esteban, Joan Maria and Debraj Ray (1994), On the Measurement of Polarization, Econometrica, 62(4):819-851.


{title:Also see}

{p 4 13 2}
{help rq} if installed.
