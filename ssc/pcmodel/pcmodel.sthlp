{smcl}
{* Mars 2012}{...}
{hline}
help for {hi:pcmodel}
{hline}


{title:Estimation of the parameters of a Partial Credit Model}

{p 8 14 2}{cmd:pcmodel} (varlist) [{help if}], 
[{cmdab:cat:egorical}({it:varlist})
{cmdab:cont:inuous}({it:varlist}) 
{cmdab:dif:ficulties}({it:matrix list}) 
{cmdab:it:erate}(#)
{cmdab:ad:apt} 
{cmdab:ro:bust}
{cmdab:f:rom}(matrix)
{cmdab:rsm:}
{cmdab:est:imateonly}]


{title:Description}

{p 8 14 2}{cmd:pcmodel} allows estimating the parameters of a random effect
 partial credit model or a random effect rating scale model 
 (the item difficulties, and the covariates
  that may influence the considered latent trait are considered as fixed 
effects, and the individual latent traits are considered as a normally distributed
    random effect){p_end}
{p 14 14 2}Two situations are possible:{p_end}
{p 16 18 2}- The item difficulties can be considered as already known 
(for example provided by the scale developer). 
In this case, they do not have to be estimated during the analysis.{p_end}
{p 16 18 2}- The difficulties are considered as unknowns and will
   be estimated during the analysis. {p_end} 
   
{p 14 14 2}{cmd:pcmodel} allows including covariates that 
can possibly influence the individual latent traits in the considered model 
(partial credit or rating scale). These covariates
  can either be categorical or continuous. {p_end}
  
{p 14 14 2}{cmd:pcmodel} provides assistance for interpreting both the quality 
of model fit (by estimating the marginal McFadden's pseudo R2) and the
 contribution of covariates to the model 
  (by estimating the the type III sum of squares, the percentage
  of variance explained with the introduction of each covariates and the percentage
   of McFadden's pseudo R2 explained with the introduction of each
    covariate). {p_end}
    
{p 14 14 2}It is finally possible to test the fit using {cmd:pcmtest} after
 estimating parameters of the model with {cmd:pcmodel}


{title:Options}

{p 4 8 2}{cmd:categorical} List of the categorical covariates included in
 the Partial Credit model or the Rating Scale model.

{p 4 8 2}{cmd:continuous} List of the continuous covariates included in
 the Partial Credit model or the Rating Scale model.

{p 4 8 2}{cmd:difficulties} Row vectors containing the known values
 of each item difficulty (if they are known).
  A row vector must match with each item, and have the
  same name as the corresponding item. If the option {cmd:difficulties} 
  is not filled, the item difficulties are
    considered as unknown, and they are estimated during the analysis. 
    (this option cannot be used with the {cmd:rsm} option

{p 4 8 2}{cmd:iterate} specifies the (maximum) number of iterations. With the
 adapt option, use of the iterate(#) option will cause pcmodel to skip the
  "Newton Raphson" iterations usually performed at the end without updating
   the quadrature locations.

{p 4 8 2}{cmd:adapt} causes adaptive quadrature to be used instead of
 ordinary quadrature.

{p 4 8 2}{cmd:robust} specifies that the Huber/White/sandwich estimator of the
 covariance matrix of the parameter estimates is to be used. 

{p 4 8 2}{cmd:from} specifies a row vector to be used for the initial values.
 It is not necessary to specify column-names or equation-names for this line vector,
 but this vector must have exactly the number of parameters to be estimated,
   starting with the difficulties parameters, the parameters associated
    with the covariates, and ending with the estimated standard deviation
     of the latent trait.

{p 4 8 2}{cmd:rsm} performs a Rating Scale model instead of a Partial Credit model.

{p 4 8 2}{cmd:estimateonly} Do not perform the Marginal McFadden's pseudo R2 
nor the type III sums of square computations


{title:Outputs}

{p 4 8 2}{cmd:e(mll)}: marginal log-likelihood

{p 4 8 2}{cmd:e(cn)}: Condition number

{p 4 8 2}{cmd:e(N)}: Number of observations

{p 4 8 2}{cmd:e(Nit)}: Number of items

{p 4 8 2}{cmd:e(Ncat)}: Number of categorical covariates

{p 4 8 2}{cmd:e(Ncont)}: Number of continuous covariates

{p 4 8 2}{cmd:e(sigma)}: Estimated standard deviation of the latent trait

{p 4 8 2}{cmd:e(Varsigma)}: Variance of the estimated standard deviation of
 the latent trait

{p 4 8 2}{cmd:e(b)}: coefficient vector of the parameters associated with
 the latent trait covariates (if no covariate is included in the model, value
  of the average latent trait).

{p 4 8 2}{cmd:e(V)}: Covariance matrix for the latent trait covariates.

{p 4 8 2}{cmd:e(delta)}: Estimated difficulty parameters

{p 4 8 2}{cmd:e(Vardelta)}: Covariance matrix for the estimated difficulty
 parameters


{marker example}{...}
{title:Example}

{pstd}
Simulation of the data (using {help simirt}):

	. {cmd:simirt, nbobs(200) dim(5) rsm1(0.2) group(0.5) deltagroup(0.4) clear}{right:(1)    }

{pstd}
Estimating a Partial Credit Model with {cmd:pcmodel}:

	. {cmd:pcmodel item*}{right:(2)    }

{pstd}
Estimating a Rating Sacle Model with {cmd:pcmodel}:

	. {cmd:pcmodel item*, rsm}{right:(3)    }

{pstd}
Testing the fit of the previously performed model with {help pcmtest}:

	. {cmd:pcmtest, si }{right:(4)    }

{pstd}
Estimating a Partial Credit Model with {cmd:pcmodel}, considering that the item difficulties 
are provided by the scale developer (-1 & -0.8 for item1, -0.5 & -0.3 for item2, 0 & 0.2 for 
item3, 0.5 & 0.7 for item4 and 1 & 1.2 for item5) and that the {it:group} covariate may 
influence the individual latent trait:

{p 6 9 2}
1/ Defining the row vectors containing the known values of each item difficulty, with the 
same name as the corresponding item:

	. {cmd:matrix item1=(-1,-0.8)}{right:(5)    }
	. {cmd:matrix item2=(-0.5,-0.3)}{right:(6)    }
	. {cmd:matrix item3=(0,0.2)}{right:(7)    }
	. {cmd:matrix item4=(0.5,0.7)}{right:(8)    }
	. {cmd:matrix item5=(1,1.2)}{right:(9)    }

{p 6 9 2}
2/ Estimating the Partial Credit Model with item difficulties already known, including 
the {it:group} covariate as a categorical covariate:

	. {cmd:pcmodel item*, difficulties(item1 item2 item3 item4 item5) cat(group)}{right:(10)    }


{title:Author}

{p 4 8 2}Jean-François Hamel{p_end}
{p 4 8 2}Email:
{browse "mailto:jeanfrancois.hamel@chu-angers.fr":jeanfrancois.hamel@chu-angers.fr}{p_end}


{title:Also see}

{p 4 13 2}Online: help for {help pcmtest}, {help gllamm}, {help simirt},
 {help raschtest}.{p_end}
