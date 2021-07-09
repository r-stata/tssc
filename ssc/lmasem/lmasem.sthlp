{smcl}
{hline}
{cmd:help: {helpb lmasem}}{space 55} {cmd:dialog:} {bf:{dialog lmasem}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf: lmasem: Overall System Autocorrelation Tests after (SEM) Regressions}

{bf:{err:{dlgtab:Syntax}}}

     {cmd: lmasem}

{bf:{err:{dlgtab:Description}}}

{p 2 2 2}lmasem computes overall system autocorrelation, after:{p_end}
{p 2 2 2}- (SEM) Structural Equation Modeling Regressions {helpb sem} for system of simultaneous equations.{p_end}

{p 2 2 2}lmasem calculates Harvey and Guilkey autocorrelation LM tests:{p_end}
{p 4 2 2}- Harvey LM test, see Judge et al(1985, p.494) eq.12.3.45.{p_end}
{p 4 2 2}- Guilkey LM test, see Judge et al(1985, p.494) eq.12.3.46.{p_end}
{p 4 2 2}- Durbin-Watson DW test.{p_end}


   {cmd:1- Harvey Single Equation LM test} = N(Rho_i)  ~ Chi2(1)
           Ho: No Autocorrelation in eq. # : Pij=0

                                           Q
   {cmd:2- Harvey Overall System LM test} = N [ Sum(Rho_i) ] ~ Chi2(Q)
                                          i=1

   {cmd:3- Guilkey Overall System LM test} = R'[ inv(Sig) # E1'E1 ] R  ~ Chi2(Q^2)
           Ho: No Autocorrelation in the Overall System: P11 = P22 = PMM = 0

where
       N = Number of Observations.
       Q = Number of Equations.
   Rho_i = Autoregressive Coefficient of eq. i
      E1 = Lagged Residuals Matrix [(N-1)xQ].
       R = Vector of Rho Coefficients.
     Sig = Sigma hat Matrix.

{bf:{err:{dlgtab:Saved Results}}}

{pstd}
{cmd:lmasem} saves the following in {cmd:r()}:

{synoptset 12 tabbed}{...}
{p2col 5 12 12 2: Scalars}{p_end}

{synopt:{cmd:r(rho_#)}}Rho Value for eq.#{p_end}
{synopt:{cmd:r(lmh_#)}}Durbin-Watson Single Equation Test for eq.#{p_end}
{synopt:{cmd:r(lmh_#)}}Harvey Single Equation LM Test for eq.#{p_end}
{synopt:{cmd:r(lmhp_#)}}Harvey Single Equation LM Test P-Value for eq.#{p_end}
{synopt:{cmd:r(lmh)}}Harvey Overall System Autocorrelation LM test{p_end}
{synopt:{cmd:r(lmhp)}}Harvey Overall System Autocorrelation LM test P-Value{p_end}
{synopt:{cmd:r(lmg)}}Guilkey Overall System Autocorrelation LM test{p_end}
{synopt:{cmd:r(lmgp)}}Guilkey Overall System Autocorrelation LM test P-Value{p_end}

{bf:{err:{dlgtab:Examples}}}

 in this example FIML will be used as follows:

	{stata clear all}

	{stata sysuse lmasem.dta , clear}

	{stata sem (y1 <- y2 x1 x2) (y2 <- y1 x3 x4), cov(e.y1*e.y2)}

	{stata lmasem}

	{stata return list}

 * If you want to use dialog box: Press OK to compute lmcovsem

	{stata db lmasem}


. clear all
. sysuse lmasem.dta , clear
. sem (y1 <- y2 x1 x2) (y2 <- y1 x3 x4 x1), cov(e.y1*e.y2)

Structural equation model                       Number of obs      =        17
Estimation method  = ml
Log likelihood     = -363.31131
------------------------------------------------------------------------------
             |                 OIM
             |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
Structural   |
  y1 <-      |
          y2 |   .2425937   .2106232     1.15   0.249    -.1702201    .6554075
          x1 |   .2568409    .462485     0.56   0.579     -.649613    1.163295
          x2 |  -1.037016   .3154059    -3.29   0.001      -1.6552   -.4188317
       _cons |   147.0826    54.4491     2.70   0.007     40.36431    253.8009
  -----------+----------------------------------------------------------------
  y2 <-      |
          y1 |  -.6282929   .6148239    -1.02   0.307    -1.833326    .5767398
          x3 |  -.5226661   .3235637    -1.62   0.106    -1.156839    .1115071
          x4 |     3.4208   1.440664     2.37   0.018     .5971513    6.244449
       _cons |   62.44495   42.36071     1.47   0.140    -20.58052    145.4704
-------------+----------------------------------------------------------------
Variance     |
        e.y1 |   80.17577   28.99122                      39.46865    162.8673
        e.y2 |   142.4478   80.80501                      46.86006    433.0208
-------------+----------------------------------------------------------------
Covariance   |
  e.y1       |
        e.y2 |   25.62619   53.75243     0.48   0.634    -79.72665     130.979
------------------------------------------------------------------------------
LR test of model vs. saturated: chi2(2)   =      0.12, Prob > chi2 = 0.9408

. lmasem
==============================================================================
* SEM Autocorrelation Tests (ml) 
* Structural Equation Modeling: SEM - Method(ml)
==============================================================================
*** Single Equation Autocorrelation Tests:
 Ho: No Autocorrelation in eq. #: Pij=0 

 Eq. 1     : Harvey LM Test =  0.1236   Rho = 0.0073  P-Value > Chi2(1) 0.7251
 Eq. 2     : Harvey LM Test =  0.0784   Rho = 0.0046  P-Value > Chi2(1) 0.7794
------------------------------------------------------------------------------
 Eq. 1     : Durbin-Watson DW Test =  2.1245
 Eq. 2     : Durbin-Watson DW Test =  2.1245
------------------------------------------------------------------------------
*** Overall SEM Autocorrelation Tests:
 Ho: No Overall SEM Autocorrelation: P11 = P22 = PMM = 0

 - Harvey  LM Test =               0.2021        P-Value > Chi2(2)   0.9039
 - Guilkey LM Test =               4.1344        P-Value > Chi2(4)   0.3881
------------------------------------------------------------------------------

{bf:{err:{dlgtab:References}}}

{p 4 8 2}Guilkey, David K. (1974)
{cmd: "Alternative Tests for a First-Order Vector Autoregressive Error Specification",}
{it:Journal of Econometrics, vol.2(1)}; 95-104.

{p 4 8 2}Guilkey, David K. (1975)
{cmd: "A Test for the Presence of First-Order Vector Autoregressive Errors When Lagged Endogenous Variables Are Present",}
{it:Econometrica, vol.43, July}; 711-117.

{p 4 8 2}Guilkey, David K. Peter Schmidt (1973)
{cmd: "Estimation of Seemingly Unrelated Regression Equations with First-Order Autoregressive Errors",}
{it:Journal of the American Statistical Association, vol. 68, September; 642-647.

{p 4 8 2}Harvey, Andrew C. (1982)
{cmd: "A Test of Misspecification for Systems of Equations",}
{it:Discussion Paper No. A31, London School of. Economics Econometrics Programme, London, England}.

{p 4 8 2}Harvey, Andrew C. (1990)
{cmd: "The Econometric Analysis of Time Series",}
{it:2nd Edition, MIT Press Books, The MIT Press, edition 2, volume 1, number 026208189x}.

{p 4 8 2}Judge, Georege, W. E. Griffiths, R. Carter Hill, Helmut Lutkepohl, & Tsoung-Chao Lee(1985)
{cmd: "The Theory and Practice of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}; 494.


{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Assistant Professor}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email:   {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage:{col 27}{browse "http://emadstat.110mb.com/stata.htm"}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}


{bf:{err:{dlgtab:lmasem Citation}}}
{phang}{cmd:Shehata, Emad Abd Elmessih (2012)}{p_end}
{phang}{cmd:LMASEM: "Stata Module to Compute Overall System Autocorrelation Tests after Structural Equation Modeling (SEM) Regressions"}{p_end}

{title:Online Help:}

{p 2 10 2}
{helpb lmasem}, {helpb lmhsem}, {helpb lmnsem}, {helpb lmcovsem}, {helpb r2sem},{p_end}
{p 2 10 2}
{helpb lmareg3}, {helpb lmhreg3}, {helpb lmnreg3}, {helpb lmcovreg3}, {helpb r2reg3}. {opt (if installed)}.{p_end}

{psee}
{p_end}

