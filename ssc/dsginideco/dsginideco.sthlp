{smcl}
{* Help file revised 2017-07-24,2009-02-20}{...}
{hline}
help for {hi:dsginideco}{right:Jenkins and Van Kerm (February 2009, revised July 2017)}
{hline}

{title:Decomposition of inequality change into pro-poor growth and mobility components}


{p 4 14 2}
{cmdab:dsginideco}
{it:var0 var1} 
[{it:weight}] 
[{cmd:if} {it:exp}] 
[{cmd:in} {it:range}] 
[{cmd:,}
 {cmdab:p:arameters(}{it:numlist}{cmd:)}
 {cmdab:f:ormat}{cmd:(%}{it:fmt}{cmd:)}
 {cmdab:per:centage}
 {cmdab:percf:ormat}{cmd:(%}{it:fmt}{cmd:)}
 {cmdab:k:akwani}
 ]

{p 4 8 2}
{cmd:aweights}, {cmd:fweights}, {cmd:pweights} and {cmd:iweights} are allowed; see help {help weights:weights}.

{p 4 4 2}
{cmdab:dsginideco} requires panel data, in wide form, on income in two time periods.
{it:var0} contains the measure of income in the initial period for each observation. 
{it:var1} contains the measure of income in the final period for each observation.
If the data are held in long form, time-series operators may be used to define 
{it:var0} or {it:var1}: see the Examples. 


{title:Description}

{p 4 4 2}
{cmdab:dsginideco} decomposes the change in income inequality between two 
time periods into two components, one representing the progressivity 
(pro-poorness) of income growth, and the other representing reranking. 
Inequality is measured using the generalized Gini coefficient, 
also known as the S-Gini, {it:G}({it:v}). This is a distributionally-sensitive 
inequality index, with larger values of {it:v} placing greater weight on inequality 
differences among poorer (lower ranked) observations. The conventional Gini
coefficient corresponds to the case {it:v} = 2. The decomposition is of the form:

{p 8 4 2}
final-period inequality {c -} initial-period inequality = {it:R} {c -} {it: P}

{p 4 4 2}
where {it:R} is a measure of reranking, and {it:P} is a measure of the progressivity 
of income growth.

{p 4 4 2}
For full details of the decomposition and an application, see Jenkins and Van Kerm (2006). 
For an application to the related topic of cross-country convergence, see O'Neill
and Van Kerm (2008). 

{p 4 4 2}
See the {browse "http://medim.ceps.lu/stata/dsginideco_v1.pdf":online manual} 
for additional discussion and examples.


{title:Options}

{p 4 8 2}{cmd:parameters(}{it:numlist}{cmd:)} specifies a value or values 
for {it:v} in {it:G}({it:v}). The default value is 2, leading to a 
decomposition of the standard Gini coefficient. Multiple values of 
{it:v} can be given but every value specified must be greater than 1.

{p 4 8 2}{cmd:format(}{it:string}{cmd:)} specifies a format for the displayed results. 
The default is %5.3f.

{p 4 8 2}{cmd:percentage} requests that decomposition factors be reported as fractions 
of the initial-period {it:G}({it:v}).

{p 4 8 2}{cmd:percformat(}{it:string}{cmd:)} used in conjunction with {cmd:percentage} 
specifies a format for results expressed as a fraction of base-period Gini. 
The default is %4.1f.

{p 4 8 2}{cmd:kakwani} requests reporting of the Kakwani-type measure of 
progressivity of income growth, {it:K}. (See Jenkins and Van Kerm 2006 for the definition.)
This statistic is meaningful only when average income growth is not close to zero.


{title:Saved Results}

{p 4 17 2}Scalars: {p_end}

{p 4 17 2}{cmd:r(sgini0)}{space 8}{it:G}({it:v}) for initial period incomes {p_end}

{p 4 17 2}{cmd:r(sgini1)}{space 8}{it:G}({it:v}) for final period incomes {p_end}

{p 4 17 2}{cmd:r(dsgini)}{space 8}Change in inequality: final-period {it:G}({it:v}) {c -} initial-period {it:G}({it:v}) {p_end}

{p 4 17 2}{cmd:r(pi)}{space 12}Average income growth between initial and final period {p_end}

{p 4 17 2}{cmd:r(P)}{space 13}{it:P} {p_end}

{p 4 17 2}{cmd:r(R)}{space 13}{it:R} {p_end}

{p 4 17 2}{cmd:r(K)}{space 13}{it:K}, if requested {p_end}

{p 4 17 2}{cmd:r(N)}{space 13}Number of observations {p_end}

{p 4 17 2}{cmd:r(sum_w)}{space 9}Sum of weights {p_end}

{p 4 17 2}Macros: {p_end}

{p 4 17 2}{cmd:r(var0)}{space 10}The name of variable {it:var0} {p_end}

{p 4 17 2}{cmd:r(var1)}{space 10}The name of variable {it:var1} {p_end}

{p 4 17 2}{cmd:r(paramlist)}{space 5}The value(s) of {it:v} {p_end}

{p 4 17 2}Matrices: {p_end}

{p 4 17 2}{cmd:r(coeffs)}{space 8}All estimates: {it:G}({it:v}) for both periods, the change in {it:G}({it:v}), {it:P} and {it:R}, and {it:K} if requested {p_end}

{p 4 17 2}{cmd:r(parameters)}{space 4}Vector containing the value(s) of {it:v} {p_end}

{p 4 4 2}
When the {cmd:percentage} option is specified, an additional set of results is returned, each 
prefixed by {cmd:rel}, containing the estimates expressed as a fraction of the 
initial-period {it:G}({it:v}). Type {cmd:return list} after {cmd:dsginideco} 
to find out exactly what results are returned.


{title:Examples}

{p 8 12 2}{inp:. use http://www.stata-press.com/data/r9/nlswork , clear }

{p 8 12 2}{inp:. tsset idcode year }

{p 8 12 2}{inp:. gen w = exp(ln_wage) }

{p 8 12 2}{inp:. dsginideco L.w w }

{p 8 12 2}{inp:. dsginideco L.w w , percentage parameters(1.5 2 3 4) kakwani }

{p 8 12 2}{inp:. gen newid = idcode }

{p 8 12 2}{inp:. tsset newid year }

{p 8 12 2}{inp:. bootstrap dG=r(dsgini) R=r(R) P=r(P)	/// }

{p 8 12 2}{inp: {space 5} , cluster(idcode) idcluster(newid) reps(250) nodots: /// }

{p 8 12 2}{inp: {space 5} dsginideco L.w w if !mi(L.w) & !mi(w) }

{p 8 12 2}{inp:. jackknife dG=r(dsgini) R=r(R) P=r(P) /// }

{p 8 12 2}{inp: {space 5} , cluster(idcode) idcluster(newid) rclass nodots: /// }

{p 8 12 2}{inp: {space 5} dsginideco L.w w if !mi(L.w) & !mi(w) }


{title:References}

{p 4 8 2}Jenkins, S.P. and Van Kerm, P. (2006). Trends in income inequality, pro-poor income growth and
income mobility. {it:Oxford Economic Papers}, 58(3): 531{c -}548. {browse "http://oep.oxfordjournals.org/cgi/content/abstract/gpl014v1":[link]}

{p 4 8 2}O'Neill, D. and Van Kerm, P. (2008). An integrated framework for analysing income convergence. 
{it:The Manchester School}. 76(1): 1{c -}20. {browse "http://www3.interscience.wiley.com/journal/119420442/abstract":[link]}


{title:Authors}


   Stephen P. Jenkins
   ISER, University of Essex, UK
   
   Philippe Van Kerm
   CEPS/INSTEAD, Luxembourg
   philippe.vankerm@ceps.lu


{* Version 1.1.0 2017-07-24}
