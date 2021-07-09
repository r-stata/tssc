{smcl}
{* 05Aug2010}{...}
{* *! Version 11 }
{hline}
help for {hi:gmmcovearn}{right:(update August 2010)}
{hline}

{title:Title}

{phang}
{bf: GMM estimator for covariance structure of earnings}


{title:Syntax}
{p 8 17 2}
{cmdab: gmmcovearn}
{it:earningsvar} {ifin}, {it:required options}
[{it:other options}]

{synoptset 20 tabbed}
{marker required_opts}{...}
{synopthdr :required_opts}
{synoptline}
{synopt:{opt modeln}} specifies the type of model to be estimated. The default is {cmd:modeln(1)}{p_end}

{tab}{tab}{tab}{tab}AR, no heterogeneity: {cmd:modeln(1)}
{tab}{tab}{tab}{tab}ARMA, no heterogeneity: {cmd:modeln(2)}
{tab}{tab}{tab}{tab}AR, random growth: {cmd:modeln(3)}
{tab}{tab}{tab}{tab}ARMA, random growth: {cmd:modeln(4)}
{tab}{tab}{tab}{tab}AR, random walk: {cmd:modeln(5)}
{tab}{tab}{tab}{tab}ARMA, random walk: {cmd:modeln(6)}
{tab}{tab}{tab}{tab}AR, combined random growth and random walk: {cmd:modeln(7)}
{tab}{tab}{tab}{tab}ARMA, combined random growth and random walk: {cmd:modeln(8)}

{tab}{tab}{tab}{tab}All models include time factor loadings on the permanent and transitory components. 

{synopt:{opt yearn}} specifies the number of years used for the analysis{p_end}

{synoptset 20 tabbed}
{marker other_opts}{...}
{synopthdr :other_opts}
{synoptline}
{synopt:{opt expvar}} specifies the name of the experience variable to be used for models that allow for heterogeneity in the life-cycle earnings profile ({cmd: modeln(3)} to {cmd: modeln(8)}).{p_end}
{synopt:{opt firstyr}} specifies the numeric year indicator attached to the first wave of earnings. The default value is 1. {it:earningsvar} and {it:expvar} are assumed to be indexed in consecutive integers from {it:firstyr} to ({it:firstyr} +              {it:yearn} -1).{p_end}
{synopt:{opt cohortn}} specifies the number of cohorts used for the analysis. The default is 1.{p_end}
{synopt:{opt cohortvar}} specifies the name of the cohort indicator variable. The default is {it: cohort}{p_end}
{synopt:{opt firstcohort}} specifies the numeric indicator of the first cohort. The default value is 1. Cohorts are assumed to be coded in consecutive integers from {it:firstcohort} to ({it:firstcohort} + {it:cohortn} -1). [e.g. In a model with                                  four                                cohorts {it: cohortvar} could contain values such as 1 to 4 or 1994 to 1997. However values such as 1960, 1970, 1980 and 1990 would have to be recoded before being used.]
{p_end}
{synopt:{opt stvalue}} specifies the starting values for the estimation. For T years of data and C cohorts,  values are entered in the following order, separated by commas: sigalpha, rho, sigv1, sige, l2-lT, p2-pT, q2-qC, s2-sC, sigbeta,                                     covalphabeta, sigw, theta.                            The user should specify starting values only for the parameters estimated in the chosen model.The default values for the l’s, p’s, q’s and s’s are 1; for sigalpha and rho                       they are 0.5; for sigv1 and sige they are 0.1; for sigbeta, covalphabeta and sigw they are 0; and for theta it is -0.5.{p_end}
{synopt:{opt newdataname}} allows the user to create a dataset called {it:newdataname} containing the sample moments used in the estimation and the number of observations used in calculating each of these moments. If a heterogeneous model is                   specified the dataset will also contain the average of {it:expvar} and the                    average of squared {it:expvar}.{p_end}
{synopt:{opt graph}} 1 if the user wants a graphical display of the estimated variance decomposition, 0 otherwise. The default value is 0.{p_end}





{synoptline}


{title:Description}

{pstd}{cmd:gmmcovearn} provides GMM estimates of the parameters of the covariance structure of earnings using the earnings variable specified in {it: earningsvar}. 

{tab}{tab}{tab}{tab}{pstd}The general earnings dynamics model ({cmd:modeln(8)}) for individual i, belonging to cohort c, with x years of experience, at time t, y_icxt, is specified as

{tab}{tab}{tab}{tab}y_icxt=q_c*p_t*(alpha_ix)+s_c*l_t*v_it

{tab}{tab}{tab}{tab}alpha_ix=alpha_i(x-1)+b_i+w_ix

{tab}{tab}{tab}{tab}And 

{tab}{tab}{tab}{tab}v_it=rho*v_i(t-1)+theta*e_i(t-1)+e_it

{tab}{tab}{tab}{tab}The parameters estimated are sigalpha, rho, sigv1, sige, l2-lT, 
{tab}{tab}{tab}{tab}p2-pT, q2-qC, s2-sC, sigbeta, covalphabeta, sigw, theta. 

{tab}{tab}{tab}{tab}The model is described in more detail in Doris et al (2010a).


{pstd} The command makes use of an additional program {cmd:nlgmmcovearn} that must be downloaded along with {cmd:gmmcovearn}. 
A detailed analysis of this approach to estimating the covariance structure of earnings  can be found in Doris et al (2010b).

{pstd} The program requires that the data be in wide format. It must contain an earnings (or earnings residual) variable. If using a model with                                                   heterogeneous profiles, it must also include a                  labour market experience variable. If using a model with cohort effects, it must also include a cohort indicator variable. 

{pstd}The Identity matrix is used as the GMM weighting matrix and standard errors are adjusted for unbalanced data using the approach reported in Haider(2001)





{title:Examples}
{bf: Example 1: NLS Earnings Data}
{pstd} In this example we make use of the NLS panel data set used in Wooldridge (2002) and available for download from within Stata. The dataset provides an unbalanced panel of data on earnings, schooling, and demographic information for 530                    individuals from the National Longitudinal Survey for the years 1981-1987.

. use http://www.stata.com/data/jwooldridge/eacsap/nls81_87.dta

{pstd}Since the data is in long format we must first reshape it prior to using gmmcovearn.

. keep id year exper lwage

. reshape wide lwage exper, i(id) j(year)

{pstd}We estimate a earnings covariance structure model on log wages without heterogeneous profiles and an AR(1) model for the transitory component as follows:

. gmmcovearn lwage, yearn(7) modeln(1) cohortn(1) firstyr(81)
(obs = 28)

Iteration 0:  residual SS =  .1643298
Iteration 1:  residual SS =    .05161
Iteration 2:  residual SS =  .0017779
Iteration 3:  residual SS =  .0016158
Iteration 4:  residual SS =   .001615
Iteration 5:  residual SS =   .001615
Iteration 6:  residual SS =   .001615
Iteration 7:  residual SS =   .001615
Iteration 8:  residual SS =   .001615
Iteration 9:  residual SS =   .001615

      Source |       SS       df       MS
-------------+------------------------------         Number of obs =        28
       Model |  .796840451    16  .049802528         R-squared     =    0.9980
    Residual |  .001614961    12   .00013458         Adj R-squared =    0.9953
-------------+------------------------------         Root MSE      =  .0116009
       Total |  .798455413    28  .028516265         Res. dev.     = -193.8376

------------------------------------------------------------------------------
      moment |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
   /sigalpha |   .0683058   .0088071     7.76   0.000     .0491168    .0874948
        /rho |   .3130349   .0608686     5.14   0.000     .1804137    .4456561
      /sigv1 |    .201089   .0144893    13.88   0.000     .1695194    .2326586
       /sige |   .0588356   .0375667     1.57   0.143    -.0230152    .1406864
         /l2 |   1.209775   .3380594     3.58   0.004     .4732069    1.946343
         /l3 |   1.497133    .496198     3.02   0.011     .4160105    2.578256
         /l4 |   1.142064   .3835471     2.98   0.012     .3063868    1.977742
         /l5 |   1.317238   .4160183     3.17   0.008     .4108118    2.223664
         /l6 |   1.438042    .464473     3.10   0.009     .4260424    2.450042
         /l7 |   1.706241   .5657103     3.02   0.011     .4736643    2.938818
         /p2 |   .9159306   .0803285    11.40   0.000     .7409098    1.090951
         /p3 |   1.112308   .0998032    11.15   0.000      .894856    1.329761
         /p4 |   1.307378   .1214745    10.76   0.000     1.042708    1.572048
         /p5 |   1.449588   .1411007    10.27   0.000     1.142156     1.75702
         /p6 |   1.466273   .1388268    10.56   0.000     1.163796    1.768751
         /p7 |   1.470464   .1267276    11.60   0.000     1.194348     1.74658
------------------------------------------------------------------------------
 coefficients and corrected standard errors below
------------------------------------------------------------------------------
             |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
    sigalpha |   .0683058    .024722     2.76   0.006     .0198516    .1167599
         rho |   .3130349    .077011     4.06   0.000     .1620961    .4639736
       sigv1 |    .201089   .0402344     5.00   0.000      .122231     .279947
        sige |   .0588356   .0456725     1.29   0.198    -.0306809    .1483521
          l2 |   1.209775   .4187484     2.89   0.004     .3890433    2.030507
          l3 |   1.497133   .6406559     2.34   0.019     .2414706    2.752796
          l4 |   1.142064   .4497494     2.54   0.011     .2605716    2.023557
          l5 |   1.317238   .5380952     2.45   0.014     .2625906    2.371885
          l6 |   1.438042   .5672408     2.54   0.011     .3262706    2.549814
          l7 |   1.706241   .6850775     2.49   0.013     .3635139    3.048968
          p2 |   .9159306   .1452523     6.31   0.000     .6312413     1.20062
          p3 |   1.112308   .2170894     5.12   0.000     .6868211    1.537796
          p4 |   1.307378    .237724     5.50   0.000     .8414475    1.773308
          p5 |   1.449588   .2657075     5.46   0.000     .9288111    1.970366
          p6 |   1.466273    .270121     5.43   0.000     .9368458    1.995701
          p7 |   1.470464   .3122724     4.71   0.000     .8584214    2.082507
-------------+----------------------------------------------------------------



{pstd}Hypothesis tests can be carried out using {cmd:test} after running the gmmcovearn command. For example a test that the permanent factor loadings, the p_t’s, are constant over time can be carried out using a Wald test as follows:

. test _b[p2]=_b[p3]=_b[p4]=_b[p5]=_b[p6]=_b[p7]=1

 ( 1)  p2 - p3 = 0
 ( 2)  p2 - p4 = 0
 ( 3)  p2 - p5 = 0
 ( 4)  p2 - p6 = 0
 ( 5)  p2 - p7 = 0
 ( 6)  p2 = 1

           chi2(  6) =   12.14
         Prob > chi2 =    0.0588


{pstd}In this example we reject constant permanent factor loadings at the 10% significance level. 


{bf: Example 2: German Earnings Data}
{pstd}To illustrate the use of gmmcovearn for a more complicated model including cohort effects we use data taken from the eight waves of the European Community Household Panel for Germany. This data set has earnings for 8 years denoted yi1994                             to yi2001, a potential experience variable denoted potexp1994 to potexp2001 and 4 cohorts labeled 1 to 4. To estimate a random growth model of the covariance structure with these data we type:

{pstd} {cmd:gmmcovearn} yi, yearn(8) modeln(3) cohortn(4) expvar(potexp) firstyr(1994){p_end}


Iteration 0:  residual SS =  .4483834
Iteration 1:  residual SS =  .0186083
Iteration 2:  residual SS =  .0086681
Iteration 3:  residual SS =  .0070441
Iteration 4:  residual SS =  .0070062
Iteration 5:  residual SS =  .0070061
Iteration 6:  residual SS =  .0070061
Iteration 7:  residual SS =  .0070061
Iteration 8:  residual SS =  .0070061

      Source |       SS       df       MS
-------------+------------------------------         Number of obs =       144
       Model |  2.16612446    26  .083312479         R-squared     =    0.9968
    Residual |  .007006143   118  .000059374         Adj R-squared =    0.9961
-------------+------------------------------         Root MSE      =  .0077055
       Total |  2.17313061   144  .015091185         Res. dev.     = -1021.378

------------------------------------------------------------------------------
      moment |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
   /sigalpha |   .4386704   .0605217     7.25   0.000      .318821    .5585198
        /rho |   .3417541   .0361788     9.45   0.000     .2701102    .4133979
      /sigv1 |   .0742456   .0062163    11.94   0.000     .0619355    .0865556
       /sige |   .0301694   .0112735     2.68   0.009     .0078448    .0524939
         /l2 |   1.498371   .2427683     6.17   0.000     1.017624    1.979118
         /l3 |   1.312379   .2569202     5.11   0.000     .8036072    1.821151
         /l4 |   1.162531   .2301328     5.05   0.000     .7068056    1.618257
         /l5 |   1.193413   .2324563     5.13   0.000     .7330861     1.65374
         /l6 |   1.297056   .2507765     5.17   0.000     .8004506    1.793662
         /l7 |   1.279366   .2507241     5.10   0.000     .7828636    1.775868
         /l8 |   1.428739   .2791012     5.12   0.000     .8760424    1.981435
         /p2 |   .9842998   .0222086    44.32   0.000     .9403208    1.028279
         /p3 |    1.07534   .0254406    42.27   0.000     1.024961    1.125719
         /p4 |    1.08418   .0279634    38.77   0.000     1.028804    1.139555
         /p5 |   1.148706   .0318299    36.09   0.000     1.085674    1.211738
         /p6 |   1.168077    .033754    34.61   0.000     1.101235    1.234919
         /p7 |   1.205651   .0364914    33.04   0.000     1.133388    1.277914
         /p8 |   1.219382   .0372949    32.70   0.000     1.145528    1.293236
         /q2 |    .989772   .0419597    23.59   0.000     .9066803    1.072864
         /q3 |   .7322496   .0536754    13.64   0.000     .6259578    .8385415
         /q4 |   .4866869   .0387748    12.55   0.000     .4099022    .5634715
         /s2 |   .6293472   .0447309    14.07   0.000     .5407679    .7179265
         /s3 |   .8336288   .0377501    22.08   0.000     .7588734    .9083842
         /s4 |   1.214287   .0390211    31.12   0.000     1.137014    1.291559
    /sigbeta |   .0003872   .0000489     7.92   0.000     .0002904    .0004841
/covalphab~a |   -.012158    .001729    -7.03   0.000    -.0155819   -.0087341
------------------------------------------------------------------------------
 coefficients and corrected standard errors below
------------------------------------------------------------------------------
             |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
    sigalpha |   .4386704   .1706614     2.57   0.010     .1041801    .7731606
         rho |   .3417541   .0361377     9.46   0.000     .2709254    .4125827
       sigv1 |   .0742456   .0118533     6.26   0.000     .0510135    .0974776
        sige |   .0301694   .0104324     2.89   0.004     .0097223    .0506164
          l2 |   1.498371   .2208264     6.79   0.000     1.065559    1.931183
          l3 |   1.312379   .2312379     5.68   0.000     .8591613    1.765597
          l4 |   1.162531   .1944341     5.98   0.000     .7814474    1.543615
          l5 |   1.193413   .1942618     6.14   0.000     .8126667    1.574159
          l6 |   1.297056   .2167269     5.98   0.000     .8722795    1.721833
          l7 |   1.279366   .2119609     6.04   0.000     .8639299    1.694801
          l8 |   1.428739   .2584156     5.53   0.000     .9222535    1.935224
          p2 |   .9842998   .0313717    31.38   0.000     .9228123    1.045787
          p3 |    1.07534   .0433522    24.80   0.000     .9903711    1.160309
          p4 |    1.08418    .050535    21.45   0.000     .9851328    1.183226
          p5 |   1.148706   .0694794    16.53   0.000     1.012529    1.284883
          p6 |   1.168077   .0789378    14.80   0.000     1.013362    1.322793
          p7 |   1.205651   .0887034    13.59   0.000     1.031796    1.379507
          p8 |   1.219382   .0922591    13.22   0.000     1.038558    1.400207
          q2 |    .989772    .111584     8.87   0.000     .7710713    1.208473
          q3 |   .7322496   .1311763     5.58   0.000     .4751487    .9893505
          q4 |   .4866869   .1032265     4.71   0.000     .2843667     .689007
          s2 |   .6293472   .0628975    10.01   0.000     .5060703    .7526241
          s3 |   .8336288   .0684399    12.18   0.000     .6994891    .9677684
          s4 |   1.214287   .0917179    13.24   0.000     1.034523    1.394051
     sigbeta |   .0003872   .0001758     2.20   0.028     .0000426    .0007319
covalphabeta |   -.012158    .005614    -2.17   0.030    -.0231613   -.0011547
------------------------------------------------------------------------------




{title:Saved results}

{pstd}
{cmd:gmmcovearn} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(nummomnent)}}number of moment conditions used in estimation{p_end}

{p2col 5 20 24 2: Vectors and Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}
{synopt:{cmd:e(momentc)}}sample moments for earnings variable for cohort c, c=1 to {it: cohortn}{p_end}
{synopt:{cmd:e(permc)}}predicted permanent component of earnings variance for cohort c, c=1..{it: cohortn}{p_end}
{synopt:{cmd:e(tempc)}}predicted transitory component of earnings variance for cohortc, c=1..{it: cohortn}{p_end}

{title:References}

{p 5 5} Doris, A, D. O’Neill and O.Sweetman (2010a) “GMMCOVEARN: A Stata Module for GMM Estimation of the Covariance Structure of Earnings.,” NUIM Economics Working paper No.212-10.


{p 5 5} Doris, A, D. O’Neill and O.Sweetman (2010b) “Identification of the Covariance Structure of Earnings using the GMM Estimator,” IZA Working paper No. 4952.

{p 5 5} Haider, S. (2001), “Earnings Instability and Earnings Inequality of Males in the United States: 1967-1991’, Journal of Labor Economics, Vol. 19(4), pp. 799-836.

{p 5 5} Wooldridge, J. (2002), Econometric Analysis of Cross Section and Panel Data, MIT Press, Cambdridge, Massachusetts. 


{title:Authors}

{p 5 5}Aedin Doris, Donal O’Neill and Olive Sweetman, Economics, NUI Maynooth, Ireland.

{* Version 2.0 2010-08}
{* Version 1.0 2010-06-30}

