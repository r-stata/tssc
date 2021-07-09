{smcl}
{hline}
Help file for {hi:runmplus_fits}
{hline}

{p 4 4 2}
Save selected results (fits and/or parameter estimates) from across multiple {hi:runmplus} sessions. 
Fits are accumulated in a matrix return in {hi:e(fits)}. 
Use {it:replace} option to start a new collection of fits. 
Identify fits you want to save using {hi: return list} after a {hi:runmplus} session. 
You may also save parameter estimates [{it:estimate}(blah)] and their standard errors[{it:se}(blah)]. 

Note: this command is case sensitive.

{hline}

{p 8 17 2}
{cmd: runmplus_fits} anything  [ ,  
 {hi:REPlace}
 {hi:ESTimate(}{it:string}{hi:)} 
 {hi:se(}{it:string}{hi:)} 
]

{title:Options}

{p 0 8 2}
{cmd:anything} - Specify fits (e.g., LL_H0, aBIC, free_parameters, CFI). By default, fits for Loglikelihood Loglikelihood_cf free_parameters aBIC are saved.

{p 0 8 2}
{cmd:ESTimate(}{it:string}{hi:)} - identify a parameter estimate or two or any number to accumulate over multiple sessions. 

{title:Example}

{hi:. runmplus y1-y4 , model(i s | y1@0 y2@1 y3@2 y4@3;)}
{hi:. runmplus_fits LL_H0 free_parameters aBIC CFI , est(mean_s) replace}
{hi:. runmplus y1-y4 , model(i s | y1@0 y2@1 y3@2 y4*3; )}
{hi:. runmplus_fits LL_H0 free_parameters aBIC CFI , est(mean_s)}
{hi:. mat list e(fits)}

e(fits)[2,5]
              LL_H0  free_parameters             aBIC              CFI          means_s
r1        -2631.622                9         5297.521             .993            -.051
r1        -2631.028               10         5300.141             .993            -.049

{hi:. mat fits=e(fits)}

{hi:. lli , l1(fits[2,1]) p1(fits[2,2]) l0(fits[1,1]) p0(fits[1,2])}
difference test scaling correction (cd) =         1.000
Chi-square difference test              =         1.188
P                                       =         0.276




{title:Author}
{p 8 8 2}Richard N Jones, ScD{break}
Brown University{break}
richard_jones@brown.edu{break}


{title:Also see}

{p 0 19}help for 
	{help runmplus}
	{help lli}
	{p_end}
