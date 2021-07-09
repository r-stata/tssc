{smcl}
{* *! version 1.0  April 2014}{...}
{vieweralsosee "mipllest" "help mipllest"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[MI] mi" "help mi"}{...}
{vieweralsosee "[MI] mi estimate" "help mi estimate"}{...}
{viewerjumpto "Syntax" "mirubin##syntax"}{...}
{viewerjumpto "Description" "mirubin##description"}{...}
{viewerjumpto "Options" "mirubin##options"}{...}
{viewerjumpto "Examples" "mirubin##examples"}{...}
{viewerjumpto "Remarks" "mirubin##remarks"}{...}
{viewerjumpto "Stored results" "mirubin##results"}{...}
{title:Title}


    {cmd:mirubin} {hline 2} Combine estimation results from multiply imputed datasets by Rubin's rule {...}
{right:(Version 1.0)}


{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{cmd:mirubin} [{cmd:,} {it:options}] 
{* [Imputations(numlist) force repost ]}


{synoptset 29 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt stub(name)}}specify the stub of the estimation results{p_end}
{synopt:{opth i:mputations(numlist)}}specify which imputations to use{p_end}
{synopt:{opt force}}ignore checks before combining results ({help mirubin##description:see below}){p_end}
{synopt:{opt nosmall}}same as the {opt nosmall} option in {help mi estimate}{p_end}
{synopt:{opt repost}}Advanced option: see {help mirubin##options:options} below{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:mirubin} combines stored {help estimates store:estimation results} that share the same {it:stub} using 
{help mi estimate##R1987:Rubin's rule}. 
As such, it is trying to do the same thing as {help mi estimate}, except that users can
input their own estimation results rather than rely on {cmd:mi estimate} to derive them. 
At the same time, many of the checks that are performed by {cmd:mi estimate} are not done by
{cmd:mirubin}. 

{pstd}
{cmd:mirubin}, however, does check the following to ensure that the estimation results
are from the same estimation command. 

{phang2}
1.  The column names of the {cmd:e(b)} matrix, the column and row names of the {cmd:e(V)} matrix 
have to be the same in all estimation results and in the same order. 
{p_end}
{phang2}
2.  All the {cmd:e(N)} have to be the same.
{p_end}
{phang2}
3.  All the {cmd:e(depvar)} have to be the same. 
{p_end}
{phang2}
4.  All the {cmd:e(cmd)} have to be the same. 
{p_end}
{phang2}
5.  All the {cmd:e(converged)} have to be 1. 
{p_end}

{pstd}
However, the above can be overridden with the {opt force} option. 


{marker options}{...}
{title:Options}

{phang}
{opt stub(name)} specifies the stub of names of the estimation results from the 
different imputed datasets. Stored results must have the following form: 
{it:stub}1, {it:stub}2, {it:stub}3, etc. If the numbering of the results does not
go from 1 to n, then the {opt imputations(numlist)} option must be specified. If 
{opt stub(name)} is not specified, {cmd:mirubin} replays the last estimation results.  

{phang}
{opth imputations(numlist)} specifies which imputations to use.  If it is not specified, 
{cmd:mirubin} searches for {it:stub}1, {it:stub}2, {it:stub}3, ..., and stops when
{it:stub}# does not exist. 

{phang}
{cmd:force} disables the checks that are done to the stored results before applying 
Rubin's rule. See {help mirubin##description:Description} above. 

{phang}
{cmd:nosmall} See {help mi_estimate##options:mi estimate, nosmall}. 

{phang}
{cmd:repost} specifies instead of issuing {help ereturn post}, {cmd:mirubin} should
instead issue {help ereturn repost}. This has the effect of keeping the other {cmd:e()}
macros, scalars, and matrices of the {cmd:first} estimation results. Without this option, 
{cmd:mirubin} only returns {cmd:e(b)} and {cmd:e(V)} which are the combined estimated coefficients 
and variance. With {opt repost} we can access other returned results such as {cmd:e(N)}
but users should keep in mind that not all of the results would be relevant. 


{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:mirubin} generally produces results identical to those which would have been 
obtained using {help mi estimate}. However, at the moment, multivariate statistics 
and tests are not calculated. (Users are welcome to contribute codes.) This means 
that {cmd:mi postestimation} commands such as {help mi test} are not available after
{cmd:mirubin}. 


{marker examples}{...}
{title:Example}

{phang}
{cmd:mirubin} is generally used together with {help mipllest}, e.g.: 

{phang2}
{cmd:parallel setclusters 2}
{p_end}
{phang2}
{cmd:webuse mheart1s20}
{p_end}
{phang2}
{cmd:mi describe}
{p_end}
{phang2}
{cmd:mipllest: logit attack smokes age bmi hsgrad female}
{p_end}
{phang2}
{cmd:est dir _mipllest*}
{p_end}
{phang2}
{cmd:mirubin, stub(_mipllest_)}
{p_end}

{phang}
However, another use of {cmd:mirubin} is to obtain marginal effects from multiply
imputed datasets without having to define your own program. 

{phang2}
{cmd:webuse mheart1s20}
{p_end}
{phang2}
{cmd:mi convert flong} // This is needed in order for {cmd:margins} below to work properly. 
{p_end}
{phang2}
{cmd:forval i=1/20 {c -(}}
{p_end}
{phang3}
{cmd:mi xeq `i' : logit attack smokes i.female##c.age bmi hsgrad}
{p_end}
{phang3}
{cmd:margins if _mi_m == `i', dydx(age) predict(xb) post noesample}
{p_end}
{phang3}
{cmd:est store marginage`i'}
{p_end}
{phang2}
{cmd:{c )-}}
{p_end}{phang2}
{cmd:mirubin, stub(marginage)}
{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:mirubin} stores the following in {cmd:e()}:

{synoptset 15 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}Estimated coefficients combined by Rubin's rule{p_end}
{synopt:{cmd:e(V)}}Variance of estimated coefficients combined by Rubin's rule{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:mirubin}{p_end}
{synopt:{cmd:e(depvar)}}Dependent variable{p_end}
{synopt:{cmd:e(properties)}}b V{p_end}
{synopt:{cmd:e(mi)}}mi{p_end}

{pstd}
In addition, it also saves {cmd:e(b_mi)}, {cmd:e(V_mi)}, {cmd:e(B_mi)}, {cmd:e(W_mi)}, 
{cmd:e(df_mi)}, {cmd:e(fmi_mi)}, {cmd:e(pise_mi)}, {cmd:e(rvi_mi)}, {cmd:e(re_mi)}, 
details of which can be found in {help mi_estimate##results}. Note that 
{cmd:e(b)}={cmd:e(b_mi)} and {cmd:e(V)}={cmd:e(V_mi)}. Moreover, see the {opt repost} option, 
which allows other results to be returned. 


{marker author}{...}
{title:Author}

    Timothy Mak, University of Hong Kong
    tshmak@hku.hk
    April 2014

	
	
