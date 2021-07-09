{smcl}
{* *! version 1.0.2  16jun2020}{...}

{p2colset 1 16 18 2}{...}
{p2col:{bf:[R] mhtreg} {hline 2}}Multiple hypothesis correction{p_end}
{p2colreset}{...}

{marker syntx}
{title:Syntax}

{p 8 16 2}
{opt mhtreg} ({depvar} {indepvars} [{help if}]) ({depvar} {indepvars} [{help if}]) [({depvar} {indepvars} {help if}) ] ... [{cmd:,}  {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt :{opth bootstrap(integer)}}number of simulated samples; default is {cmd:bootstrap(3000)}{p_end}
{synopt :{opt robust}}Huber/White/sandwich estimator for standard errors{p_end}
{synopt :{opth cluster(clustvar)}}clustvar specifies to which group each observation belongs {p_end}
{synopt :{opth cltype(#)}}specifies if an how clustering should be applied; default is {0}, i.e. no clustering {p_end}
{synopt :{opth seed(#)}} seed for bootstrap resampling {p_end}
{synopt :{opt replace}} replaces the data in memory with {cmd:mhtreg} results {p_end}

{synoptline}
{p 4 6 2}Weights and factor variables are not allowed.{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:mhtreg} provides a procedure for multiple hypothesis testing that asymptotically controls familywise error rate and is asymptotically balanced. It is based on List et al. (2019) but modified to be used in a multivariate regression setting. In each of the regressions specified, only the coefficient on the first independent variable will be included in the set of hypotheses to be tested. The procedure allows testing families of hypotheses based on combinations of multiple outcomes, multiple subgroubs, and multiple treatments (from the same or different regressions). It is suitable for experimental settings without or with covariates (if researchers want to address imbalances in covariates or reduce the error variance), and observational settings. Users who want to include more than one coefficient from the same regression should include the same regression twice but change the order of the independent variables, e.g. {cmd:mhtreg (y x1 x2) (y x2 x1)}. {cmd:mhtreg} can be used in settings where clustering of standard errors is required.{p_end}

{pstd}
The procedure provides bootstrap-based unadjusted p-values, adjusted p-values based on Theorem 3.1 in List et al. (2019) that take into account the dependence between the hypotheses, as well as p-values adjusted with the procedures by Bonferroni (1935) and Holm (1978) that treat the hypotheses as independent.{p_end}

{pstd}
For detailed information on the procedure and the modifications and extensions made compared to List et al. (2019) see Online Appendix D of Barsbai et al. (2020). This Online Appendix also provides some simulation results.
{p_end}


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}{opth bootstrap(integer)} the number of simulated samples. The default is {cmd:bootstrap(3000)} but a larger number is recommended when testing a large number of hypotheses.

{phang}{opt robust} Huber/White/sandwich estimator for standard errors

{phang}{opth cluster(clustvar)} clustvar specifies to which group each observation belongs. This option has to be specified jointly with the {cmd:cltype(byte)} option.

{phang}{opth cltype(#)} specifies how clustering is implemented. {cmd:cltype(1)} specifies that the sample drawn during each replication is a bootstrap sample of clusters but the model will be estimated with clustered standard errors. {cmd:cltype(2)} specifies that the model is estimated with clustered standard errors but the bootstrapped resampling is not clustered. {cmd:cltype(3)} specifies that the models are estimated with clustered standard errors and the bootstrapped resampling is clustered (default). If the user wants to apply clustering, specifying {cmd:cltype(3)} is recommended. {cmd:cltype(1)} and {cmd:cltype(2)} are of potential interest for simulations. It is currently not possible to vary the level of clustering for the individual models.

{phang}{opth seed(integer)} sets a seed for the bootstrap resampling.

{phang}{opt replace} replaces the data in memory with {cmd:mhtreg} results. May be useful for simulations but is not recommended.

{marker remarks}{...}
{title:Remarks}

{pstd}{cmd:mhtreg} is not an official Stata command. It comes without warranty of any kind. You may cite it as:

{pstd}Barsbai, T., V. Licuanan, A. Steinmayr, E. Tiongson, & D. Yang (2020). Information and the Formation of Social Networks. NBER Working Paper No. 27346 {p_end}

{pstd}Note that mhtreg requires the installation of the {cmd:moremata} package  {cmd:. ssc install moremata, replace}. {p_end}

{pstd}If you are running the command for the first time and receive an error message claiming certain functions are not found, make sure that lmhtreg.mlib exists in your current dir and enter the command {cmd:. mata: mata mlib index}.{p_end}

{pstd}The code of {cmd:mhtreg} is partly based on the {cmd:mhtexp} command available in the SSC archive. We thank Azeem Shaikh for helpful comments for the modifications.{p_end}

{title:Examples}

{phang2}{cmd:. sysuse auto, clear}

{pstd}Example 1: Different outcomes (The first regressor in each model is included, i.e. the two null hypotheses are that the coefficients of length are zero in the respective regressions.){p_end}
{phang2}{cmd:. mhtreg (price length trunk) (mpg length trunk)}

{pstd}Example 2: Different outcomes and subgroups (This specification provides adjusted p-values for four hypotheses, namely that the coefficients of length are zero in the respective regressions and subgroups.){p_end}
{phang2}{cmd:. mhtreg (price length trunk if foreign==0) (mpg length trunk if foreign==0) (price length trunk if foreign==1) (mpg length trunk if foreign==1)}

{pstd}Example 3: Different coefficients from the same regression with robust standard errors (By specifiyng the same regression multiple times but with different order of the independent variables, it is possible to obtain adjusted p-values for multiple coefficients from the same regression.{p_end}
{phang2}{cmd:. mhtreg (price length trunk foreign) (price trunk length foreign) (price foreign trunk length), robust}

{pstd}Example 4: Clustering with 5000 simulated samples (Using the options {cmd:cltype(3)} and {cmd:cluster(idvar)} specifies that all models are estimated with clustered standard errors and the bootstrapped resampling is also clustered. {p_end}
{phang2}{cmd:. webuse regsmpl, clear}

{phang2}{cmd:. mhtreg (ln_wage grade age tenure black) (ln_wage black grade age tenure), cluster(id) cltype(3) bootstrap(5000) }

{hline}

{marker saved}{...}
{title:Saved results}

{pstd}
{cmd:mhtreg} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(results)}}matrix of adjusted and unadjusted p-values{p_end}

{hline}

{title:References}

{phang}Barsbai, T., V. Licuanan, A. Steinmayr, E. Tiongson, & D. Yang (2020). Information and the Formation of Social Networks. NBER Working Paper No. 27346. Available from: {browse https://www.nber.org/papers/w27346.pdf}

{phang}List, J. A., Shaikh, A. M., & Xu, Y. (2019). Multiple hypothesis testing in experimental economics. {it:Experimental Economics}, 22: 773-793.

{phang}Romano, J. P., & Wolf, M. (2010). Balanced control of generalized error rates. {it:The Annals of Statistics}, 38(1), 598-633.


{title:Author}

{phang}
Andreas Steinmayr, LMU Munich. If you observe any problems or if 
you have comments or suggestions please contact
{browse andreas.steinmayr@econ.lmu.de}.

