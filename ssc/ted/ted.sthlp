{smcl}
{hline}
{* 08jul2016}{...}
{cmd:help ted}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:ted} {hline 1}}Testing Stability of Regression Discontinuity Models{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmd:ted}
{it: outcome} 
{it: run_var}
{it: treat_var}
{ifin}
{weight}{cmd:,}
{cmd:model}{cmd:(}{it:{help ted##modeltype:modeltype}}{cmd:)}
{cmd:m}{cmd:(}{it:number}{cmd:)}
{cmd:h}{cmd:(}{it:number}{cmd:)}
{cmd:k}{cmd:(}{it:{help ted##kerneltype:kerneltype}}{cmd:)}
[{cmd:l}{cmd:(}{it:number}{cmd:)}
{cmd:graph}
{cmd:vce(robust)}]


{pstd}{cmd:fweight}s, {cmd:iweight}s, and {cmd:pweight}s are allowed;
see {help weight}.



{title:Description}

{pstd} {cmd:ted} estimates the "local average treatment effect" (LATE), 
the "compliers' probabilty discontinuity" (CPD), and "treatment effect derivative" (TED)
for either {it:sharp} or {it:fuzzy} Regression Discontinuity (RD) models.
Estimation and inference for TED are especially useful for testing the 
stability of LATE estimates in RD models when infinitesimal changes of the threshold value
are allowed. According to Dong and Lewbel (2015) and Cerulli, et al. (2016), 
a TED which is significantly different from zero signals that LATE estimate is instable
any time very small changes of the threshold value are considered, thus questioning the validity of RD 
results. In the fuzzy case, standard errors for LATE, CPD, and TED are estimated using the delta method.
{cmd:ted} provides also a graphical representation of LATE and TED, by jointly plotting the potential
outcome functions and their tangents at threshold. 

     
{title:Options}
    
{phang} {cmd:model}{cmd:(}{it:{help ted##modeltype:modeltype}}{cmd:)} specifies the RD model
to be estimated, where {it:modeltype} must be one of the following two
models: "sharp", "fuzzy".
it is always required to specify one model.   

{phang} {cmd:m}{cmd:(}{it:number}{cmd:)} sets the polynomial degree of the left and right "conditional expectation 
of the outcome given the running variable" equal to the number specified in parenthesis.

{phang} {cmd:h}{cmd:(}{it:number}{cmd:)} sets a specific value of the bandwidth for the local RD estimation.
For identifying optimal bandwidth, please refer to the user-written command {helpb rdbwselect} provided by
Calonico, Cattaneo, and Vazquez-Bare (2014).
 
{phang} {cmd:c}{cmd:(}{it:number}{cmd:)} sets the threshold (or cut-off).

{phang} {cmd:l}{cmd:(}{it:number}{cmd:)} sets the interval of the running variable to consider in the graphical representation.

{phang} {cmd:k}{cmd:(}{it:{help ted##kerneltype:kerneltype}}{cmd:)} sets the type of kernel function to 
consider in the local polynomial estimation of the potential outcomes at threshold.

{phang} {cmd:graph}{cmd:} allows for a graphical representation of both sharp and fuzzy RD.
 
{phang} {cmd:vce(robust)} allows for robust regression standard errors. It is optional for all models.



{marker modeltype}{...}
{synopthdr:modeltype_options}
{synoptline}
{syntab:Model}
{p2coldent : {opt sharp}}Sharp RD design{p_end}
{p2coldent : {opt fuzzy}}Fuzzy RD design{p_end}
{synoptline}

{marker kerneltype}{...}
{synopthdr:kerneltype_options}
{synoptline}
{syntab:k}
{p2coldent : {opt epan}}Epanechnikov weighting scheme{p_end}
{p2coldent : {opt normal}}Normal weighting scheme{p_end}
{p2coldent : {opt biweight}}Biweight (or Quartic) scheme{p_end}
{p2coldent : {opt uniform}}Uniform weighting scheme{p_end}
{p2coldent : {opt triangular}}Triangular weighting scheme{p_end}
{p2coldent : {opt tricube}}Tricube weighting scheme{p_end}
{synoptline}


{pstd}
{cmd:ted} creates a number of variables:

{pmore}
{inp:_x} is the running variable centered at zero.

{pmore}
{inp:_T} is the the "above-threshold" indicator (i.e., _T=1[S > S*]).

{pmore}
{inp:_x_m} is the polynomial term for the running variable of degree m.

{pmore}
{inp:_T_x_m} is the polynomial term for the interaction between the running variable and
the above-threshold indicator of degree m.



{pstd}
{cmd:ted} returns the following scalars:

{pmore}
{inp:e(N_tot)} is the total number of (used) observations.

{pmore}
{inp:e(N_treated)} is the number of (used) treated units.

{pmore}
{inp:e(N_untreated)} is the number of (used) untreated units.

{pmore}
{inp:e(LATE)} is the value of the local average treatment effect.

{pmore}
{inp:e(TED)} is the value of the treatment effect derivative.

{pmore}
{inp:e(CPD)} is the value of the compliers' probability discontinuity.



{title:Remarks} 

{pstd} The variable specified in {it:treat_var} has to be a 0/1 binary variable (1 = treated, 0 = untreated).

{pstd} The standard errors for LATE, TED, and CPD in the fuzzy case are obtained using the delta method.

{pstd} Please remember to re-download this command frequently 
to make sure you have an up-to-date version installed.



{title:Examples}


{pstd} {cmd:*** 1. EXAMPLE WITH SHARP RD ***}

   {inp:. #delimit ;}
   {inp:. set more off}
   {inp:. ted y s w , model(sharp) h($band) c($s_star) }  
   {inp:. m($M) l($L) k($kernel) graph vce(robust)}
   {inp:. ;}



{pstd} {cmd:*** 2. EXAMPLE WITH FUZZY RD ***}

   {inp:. #delimit ;}
   {inp:. set more off}
   {inp:. ted y s w , model(fuzzy) h($band) c($s_star) }  
   {inp:. m($M) l($L) k($kernel) graph vce(robust)}
   {inp:. ;}

   
{title:References}

{phang}
Calonico, S., Cattaneo, M. D., and Vazquez-Bare, G. (2014), 
Robust data-driven inference in the regression-discontinuity design, 
{it:Stata Journal}, Vol. 14, N. 4, pp. 909-946.
{p_end}

{phang}
Cerulli, G., Dong, Y., Lewbel, A., and Paulsen, A. (forthcoming 2016), 
"Testing Stability of Regression Discontinuity Models", {it:Advances in Econometrics}, Volume 38.
Special issue on "Regression Discontinuity Designs: Theory and Applications",
Eds: Matias D. Cattaneo (University of Michigan) and Juan-Carlos Escanciano (Indiana University).
{p_end}

{phang}
Dong, Y., and Lewbel, A. (2015). Identifying the effect of changing the policy threshold 
in regression discontinuity models. {it:Review of Economics and Statistics}, Vol. 97, N. 5, pp. 1081-1092.
{p_end}



{title:Acknowledgment}

{pstd} I wish to thank Yingying Dong, Arthur Lewbel, and Alexander Poulsen for their helpful 
suggestions and support.



{title:Author}

{phang}Giovanni Cerulli{p_end}
{phang}Ceris-CNR{p_end}
{phang}CNR-IRCrES, Research Institute on Sustainable Economic Growth, National Research Council of Italy{p_end}
{phang}E-mail: {browse "mailto:giovanni.cerulli@ircres.cnr.it":giovanni.cerulli@ircres.cnr.it}{p_end}



{title:Also see}

{psee}
Online:  {helpb rdrobust}, {helpb rdbwselect}, {helpb rd} 


