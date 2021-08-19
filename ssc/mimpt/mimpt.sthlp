{smcl}
{cmd:help mimpt}
{hline}

{title:Title}

{p 4 8 2}
{cmd:mimpt} {hline 2} Impute missing values, 
persist in case of non-convergence


{title:Syntax}

{p 8 16 2}
{cmd:mimpt} 
{it:{help mi_impute:...}}
{cmd:,} 
{opt add(#)} 
{opt skipnonconvergence(#)} 
[ {it:options} ]


{p 4 10 2}
where {it:{help mi_impute:...}} is the standard {helpb mi impute} syntax


{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}
{p2coldent:* {cmd:add(#)}}specify number of imputations to add; same as 
with {help mi_impute##impopts:mi impute}
{p_end}
{p2coldent:* {cmd:skipnonconvergence(#)}}specify how many non-convergence 
errors to ignore
{p_end}
{synopt:{opt blocksize(#)}}specify number of imputations to add at a time; 
default is {cmd:blocksize(1)}
{p_end}
{synopt:{help mi_impute##impopts:{it:impute_options}}}any options for 
{help mi impute}
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}* {opt add(#)} is required{p_end}{...}
{p 4 6 2}* {opt skipnonconvergence(#)} is required{p_end}


{title:Description}

{pstd}
{cmd:mimpt} is a wrapper for {helpb mi impute} that does not stop if the 
imputation model fails to converge. Instead of stopping if the imputation 
model fails to converge, {cmd:mimpt} repeats the imputation process for 
the respective dataset. 

{pstd}
The problem: Multiple imputations {help mi_impute_chained:via chained equations} 
often fails because one of the models, usually {help mlogit},  fails to 
converge. If this happens, Stata's {help mi impute} command will stop with the
respective error message and return code {search r(430), local:r(430)}. Stata's 
{help mi impute} will also discard all imputations that have been added so far. 

{pstd}
Non-convergence of the imputation model might indicate problems. If a model 
fails to converge early on during the imputation process or if a model fails 
to converge repeatedly, the model should be inspected and fixed. If, however, 
the model fails to converge in, say, iteration 7 on {it:m}=42, the respective 
model has successfully converged 416 times (assuming the default burin-in) 
before it failed once. Chances are, there is no systematic problem with that 
model; chances are, the model will converge again in iteration 8 on 
{it:m}=42. It is this situation for which {cmd:mimpt} is designed. Instead of 
stopping the imputation process altogether and discarding all 41 completed 
datasets, {cmd:mimpt} repeats the imputation process for {it:m}=42 
(but see {help mimpt##blocksize:option {bf:blocksize()}}).


{pstd}
Disclaimer: I am not aware of any literature that discusses potential problems 
when (occasional) non-convergence is ignored during the imputation process. I 
believe that this approach is preferable to what is currently the only 
alternative: modify the respective model. Modifying the respective model will 
have a much larger impact on the imputations because the modifications affect 
every iteration in every imputed dataset. Ignoring occasional non-convergence 
appears to be much less invasive. 


{title:Options}

{phang}
{opt add(#)} is the same as with {help mi_impute##options:mi impute} and 
specifies the number of imputations to add. 

{phang}
{opt skipnonconvergence(#)} is required and it specifies how many 
non-convergence errors are ignored. If the imputation model fails 
to converge more often than {it:#}, {cmd:mimpt} will stop with return 
code {search r(430), local:r(430)} and discard all imputed datasets. 

{marker blocksize}{...}
{phang}
{opt blocksize(#)} specifies the number of imputations to add at a time. This 
is a technical option that is best explained technically. Let {it:M} be the 
number of imputations specified in option {opt add(M)}, and let {it:s} be the 
number specified in option {opt blocksize(s)}. {cmd:mimpt} calls 
{help mi impute} {it:M}/{it:s} times. If a model fails to converge, {cmd:mimpt} 
repeats at least 1 at at most {it:s} imputations. For example, if we specify 
{cmd:add(10)} and {cmd:blocksize(5)}, and a model fails to converge on {it:m}=7, 
{cmd:mimpt} repeats the imputation process for {it:m}=6 and {it:m}=7.

{p 8 8 2}
{opt blocksize()} does not affect the number of imputed datasets, {it:M}. If 
the imputation model fails to converge at least once, different values of 
{opt blocksize()} are likely to produce different results. 


{title:Examples}

{pstd}
Generic

{phang2}{cmd:. mimpt {it:...} mlogit {it:...} , add(100) skipnonconvergence(5)}{p_end}


{title:Stored results}

{pstd}
{cmd:mimpt} does not save anything in {cmd:r()}. Results in {cmd:r()} are 
those of the last call to {help mi impute}.


{title:Author}

{pstd}
Daniel Klein{break}
University of Kassel{break}
klein.daniel.81@gmail.com


{title:Also see}

{psee}
Online: {helpb mi}, {helpb mi impute}{p_end}

{psee}
if installed: {helpb ice}{p_end}
