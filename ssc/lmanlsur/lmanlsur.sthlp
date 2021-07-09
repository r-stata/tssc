{smcl}
{hline}
{cmd:help: {helpb lmanlsur}}{space 50} {cmd:dialog:} {bf:{dialog lmanlsur}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf:lmanlsur: Overall System NL-SUR Autocorrelation Tests}

{bf:{err:{dlgtab:Syntax}}}

     {cmd: lmanlsur}

{bf:{err:{dlgtab:Description}}}

{p 2 2 2}lmanlsur computes overall NL-SUR system autocorrelation, after:{p_end}
{p 2 2 2}- (NL-SUR) Non Linear Seemingly Unrelated Regression Estimation {helpb nlsur} for sets of equations.{p_end}

{p 2 2 2}lmanlsur calculates Harvey and Guilkey autocorrelation LM tests:{p_end}
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
{cmd:lmanlsur} saves the following in {cmd:r()}:

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

{bf:{err:{dlgtab:Examples}}}

 {stata clear all}

 {stata sysuse lmanlsur.dta , clear}

* (1) NL-SUR Model:

 {stata nlsur (y1={B10}+{B11}*y2+{B12}*x1+{B13}*x2) (y2={B20}+{B21}*y1+{B22}*x3+{B23}*x4)}

 {stata lmanlsur}

 {stata return list}

* (2) SUR Model:

 {stata sureg (y1 y2 x1 x2) (y2 y1 x3 x4)}

 {stata lmanlsur}

 {stata return list}

. clear all
. sysuse lmanlsur.dta , clear
. nlsur (y1={B10}+{B11}*y2+{B12}*x1+{B13}*x2) (y2={B20}+{B21}*y1+{B22}*x3+{B23}*x4)

FGNLS regression 
---------------------------------------------------------------------
       Equation |       Obs  Parms       RMSE      R-sq     Constant
----------------+----------------------------------------------------
 1           y1 |        20      4   125.6433    0.8266          B10
 2           y2 |        20      4   19.52663    0.7801          B20
---------------------------------------------------------------------

------------------------------------------------------------------------------
             |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
        /B10 |  -68.61381   119.3219    -0.58   0.565    -302.4804    165.2528
        /B11 |   6.586666   .6994811     9.42   0.000     5.215708    7.957623
        /B12 |   .0771727   .0496441     1.55   0.120     -.020128    .1744733
        /B13 |  -.3247027   .2355698    -1.38   0.168    -.7864111    .1370056
        /B20 |    11.0109   24.11753     0.46   0.648    -36.25859    58.28038
        /B21 |    .137451   .0141117     9.74   0.000     .1097926    .1651094
        /B22 |  -.0018792   .0116164    -0.16   0.871    -.0246469    .0208885
        /B23 |  -.0024405   .0142685    -0.17   0.864    -.0304061    .0255252
------------------------------------------------------------------------------

. lmanlsur
==============================================================================
* NL-SUR System Autocorrelation Tests
==============================================================================
*** Single Equation Autocorrelation Tests:
 Ho: No Autocorrelation in eq. #: Pij=0 

 Eq. 1     : Harvey LM Test =  3.6355   Rho = 0.1818  P-Value > Chi2(1) 0.0566
 Eq. 2     : Harvey LM Test =  3.2207   Rho = 0.1610  P-Value > Chi2(1) 0.0727
------------------------------------------------------------------------------
 Eq. 1     : Durbin-Watson DW Test =  1.1244
 Eq. 2     : Durbin-Watson DW Test =  1.1598
------------------------------------------------------------------------------

*** Overall System NL-SUR Autocorrelation Tests:
 Ho: No Overall System Autocorrelation: P11 = P22 = PMM = 0

 - Harvey  LM Test =               6.8562        P-Value > Chi2(2)   0.0324
 - Guilkey LM Test =               4.3428        P-Value > Chi2(4)   0.3616
------------------------------------------------------------------------------

{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Assistant Professor}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email:   {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage:{col 27}{browse "http://emadstat.110mb.com/stata.htm"}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

{bf:{err:{dlgtab:lmanlsur Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih (2012)}{p_end}
{p 1 10 1}{cmd:LMANLSUR: "Overall System NL-SUR Autocorrelation Tests"}{p_end}

{title:Online Help:}

{p 2 10 2}
{helpb lmanlsur}, {helpb lmhnlsur}, {helpb lmnnlsur}, {helpb lmcovnlsur}, {helpb r2nlsur}{p_end}
{p 2 10 2}
{helpb lmareg3}, {helpb lmhreg3}, {helpb lmnreg3}, {helpb lmcovreg3}, {helpb r2reg3}{p_end}
{p 2 10 2}
{helpb lmasem}, {helpb lmhsem}, {helpb lmnsem}, {helpb lmcovsem}, {helpb r2sem}. {opt (if installed)}.{p_end}

{psee}
{p_end}

