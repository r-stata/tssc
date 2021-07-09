{smcl}
{* April 2014}{...}
{hline}
help for {hi:rq (Version 1)}{right:Carlos Gradín (April 2014)}
{hline}

{title:Ethnic Polarization index, Reynal-Querol (J. of Conflict Resolution, 2002)}

{title:Syntax}

{p 8 17 2} 
{cmd:rq} {it:varname} [{it:weights}] [{cmd:if} {it:exp}] [{cmd:in} {it:range}]

{p 12 4 2} 
{it:varname} indicates the variable of interest (ex. ethnic group, religion, ...).

{p 12 4 2} 
{cmd:fweights}, {cmd:aweights} and {cmd:aweights} are allowed; see {help weights}.

{title:Description}

{p 4 4 2} 
{cmd:rq} computes the ethnic polarization index proposed by Reynal-Querol (2002), related to Esteban and Ray (Econometrica, 1994) polarization measure, using either individual data or data aggregated by groups.


{title:Formula} 

RQ = 1 - sum_i [(.5-pi)^2*pi / .25 ] = 4*sum_i [pi^2*(1-pi)]

{p 8 4 2} 
where pi is the proportion of members of the ith group. RQ is between 0 and 1.

{title:Saved results} 

{p 4 4 2} 
Scalar:

{p 8 8 2} 
r(rq)

{title:Examples} 

{p 4 4 2} 
Example of data: individual

ethnicity	weight
1		2
2		2
2		3
3		1
3		1
3		1

{p 4 8 2}
. {stata rq ethnicity [aw=weight]}

{p 4 4 2} 
Example of data: aggregated by groups

ethnicity	weight
1		.2
2		.5
3		.3

{p 4 8 2}
. {stata rq ethnicity [aw=weight]}


In both cases the result is the same:
. Reynal-Querol index (J of Conflict Resolution, 2002) =    0.8800


{p 4 8 2}
For bootstrapping (BC estimates), using saved scalars

{p 8 8 2}
 cap program drop reyq

{p 8 8 2}
 program def reyq

{p 12 8 2}
 rq ethnicity [aw=weight]

{p 8 8 2}
 end

{p 8 8 2}
 bootstrap r(rq) , reps(1000): reyq

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

Montalvo, José G. and Marta Reynal-Querol (2005), "Ethnic Polarization, Potential Conflict, and Civil Wars", American Economic Review, 95(3): 796-816.

Reynal-Querol, Marta (2002), Ethnicity, Political Systems, and Civil Wars, Journal of Conflict Resolution, 46(1): 29-54.


{title:Also see}

{p 4 13 2}
{help er} if installed.


