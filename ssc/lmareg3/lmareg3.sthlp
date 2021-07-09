{smcl}
{hline}
{cmd:help: {helpb lmareg3}}{space 55} {cmd:dialog:} {bf:{dialog lmareg3}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf: lmareg3: Overall System Autocorrelation Tests after (3SLS-SURE) Regressions}

{bf:{err:{dlgtab:Syntax}}}

     {cmd: lmareg3}

{bf:{err:{dlgtab:Description}}}

{p 2 2 2}lmareg3 computes overall system autocorrelation, after:{p_end}
{p 2 2 2}- (3SLS) Three-Stage Least Squares {helpb reg3} for systems of simultaneous equations.{p_end}
{p 2 2 2}- (SURE) Seemingly Unrelated Regression Estimation {helpb sureg} for sets of equations.{p_end}

{p 2 2 2}lmareg3 calculates Harvey and Guilkey autocorrelation LM tests:{p_end}
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
{cmd:lmareg3} saves the following in {cmd:r()}:

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

	{stata clear all}

	{stata sysuse lmareg3.dta , clear}

   * (1) SUR Model:

	{stata sureg (y1 x1 z1) (y2 x2 z2) (y3 x3 z3) (y4 x4 z4)}

	{stata lmareg3}

	{stata return list}


   * (2) 3SLS Model:

	{stata reg3 (y1 x1 z1) (y2 x2 z2) (y3 x3 z3) (y4 x4 z4)}

	{stata lmareg3}

	{stata return list}

* If you want to use dialog box: Press OK to compute lmareg3

	{stata db lmareg3}


. clear all
. sysuse lmareg3.dta , clear
. reg3 (y1 x1 z1) (y2 x2 z2) (y3 x3 z3) (y4 x4 z4)
. lmhreg3

=================================================
* System Autocorrelation Tests (3sls) 
=================================================
*** Single Equation Autocorrelation Tests:
 Ho: No Autocorrelation in eq. #: Pij=0 

 Eq. y1    : Harvey LM Test =  4.8859   Rho = 0.2443  P-Value > Chi2(1) 0.0271
 Eq. y2    : Harvey LM Test =  0.0028   Rho = 0.0001  P-Value > Chi2(1) 0.9577
 Eq. y3    : Harvey LM Test =  4.9830   Rho = 0.2492  P-Value > Chi2(1) 0.0256
 Eq. y4    : Harvey LM Test =  4.4273   Rho = 0.2214  P-Value > Chi2(1) 0.0354
------------------------------------------------------------------------------
 Eq. y1    : Durbin-Watson DW Test =  0.9323
 Eq. y2    : Durbin-Watson DW Test =  1.9417
 Eq. y3    : Durbin-Watson DW Test =  1.0017
 Eq. y4    : Durbin-Watson DW Test =  1.0510
------------------------------------------------------------------------------
*** Overall System Autocorrelation Tests:
 Ho: No Overall System Autocorrelation: P11 = P22 = PMM = 0

 - Harvey  LM Test =              14.2991        P-Value > Chi2(4)   0.0064
 - Guilkey LM Test =              22.6759        P-Value > Chi2(16)  0.1227
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


{bf:{err:{dlgtab:lmareg3 Citation}}}

{phang}Shehata, Emad Abd Elmessih (2011){p_end}
{phang}{cmd:LMAREG3: "Stata Module to Compute Overall System Autocorrelation Tests after (3SLS-SURE) Regressions"}{p_end}

	{browse "http://ideas.repec.org/c/boc/bocode/s457345.html"}

	{browse "http://econpapers.repec.org/software/bocbocode/s457345.htm"}

{title:Online Help:}

{p 4 12 2}
{helpb lmareg} {helpb lmareg2} {helpb lmareg3} {opt (if installed)}.{p_end}

{psee}
{p_end}

{psee}
{p_end}

