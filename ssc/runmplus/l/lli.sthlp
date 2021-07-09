{smcl}
{hline}
Help file for {hi:lli}
{hline}

{p 4 4 2}
Calculate the Satorra-Bentler Scaled Chi-Square using the loglikelihood following an Mplus ML, MLM, MLR or WLSMV 
see http://www.statmodel.com/chidiff.shtml for more information. Also see a note in Mplus discussion from B. Muthén
(e.g., http://www.statmodel.com/discussion/messages/9/189.html#POST7445)


{hline}

{p 8 17 2}
{cmd: lli}  ,  
 {hi:l0(}{it:string}{hi:)} 
 {hi:p0(}{it:string}{hi:)} 
 [ {hi:c0(}{it:string}{hi:)} ]
 {hi:l1(}{it:string}{hi:)} 
 {hi:p1(}{it:string}{hi:)} 
[ {hi:c1(}{it:string}{hi:)} 
]

{title:Required commands}

{p 0 8 2}
{cmd:l0} - Loglikelihood in analysis model

{cmd:l1} - Loglikelihood in the unconstrained or less constrained model

{cmd:p0} - Number of parameters in the analysis model

{cmd:p1} - Number of parameters in the unconstrained or less constrained model


{title:Options}

{p 0 8 2}
{cmd:c0} {cmd:c1} - Specify the scaling correction factor, default = 1

{title:Example}

{p 8 8 2}
. {hi: lli , l0(-2606) l1(-2583) c0(1.450) c1(1.546) p0(39) p1(47)}
{p_end}{p 8 8 2}
difference test scaling correction (cd) =         2.014
{p_end}{p 8 8 2}
Chi-square difference test              =        22.840
{p_end}{p 8 8 2}
P                                       =         0.004
{p_end}



{title:Author}
{p 8 8 2}Richard N Jones, ScD{break}
Brown University{break}
richard_jones@brown.edu{break}



