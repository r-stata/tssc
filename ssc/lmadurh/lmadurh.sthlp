{smcl}
{hline}
{cmd:help: {helpb lmadurh}}{space 55} {cmd:dialog:} {bf:{dialog lmadurh}}
{hline}


{bf:{err:{dlgtab:Title}}}

{bf: lmadurh: Dynamic Autocorrelation Tests after (OLS-ALS) Regressions}


{bf:{err:{dlgtab:Syntax}}}

{p 10 16 2}
{opt lmadurh} {depvar} {indepvars} {ifin} {weight} , [ {opt dlag(numlist)} {opt nocons:tant} {opth vce(vcetype)} ]{p_end} 

{bf:{err:{dlgtab:Options}}}
{synoptset 20 tabbed}{...}

{synopt :{opt dlag(#)}}determine location of lagged dependent variable among RHS regressors; default is 1.{p_end}

{synopt :{opt nocons:tant}}suppress constant term{p_end}

{syntab:SE/Robust}
{synopt :{opth vce(vcetype)}}{it:vcetype} may be {opt ols},
   {opt r:obust}, {opt cl:uster} {it:clustvar}, {opt boot:strap}, 
   {opt jack:knife}, {opt hc2}, or {opt hc3}{p_end}


{bf:{err:{dlgtab:Description}}}

{p 2 2 2}{cmd:lmadurh} computes dynamic autocorrelation tests after (OLS-ALS) Regression, via Durbin h, Harvey LM, and Wald LM Tests for residuals after {helpb regress} command.{p_end} 
{p 2 2 2}{cmd:lmadurh} detects autocorrelation after correction the residuals from first order AR(1) autocorrelation, via Autoregressive Least Squares (ALS), i.e., {helpb prais}.{p_end}

{p 2 2 2 }Durbin h Test can not be computed, if the square root has negative value.{p_end}

     **************************************************************
     *   h  > 1.96  (Autocorrelation)                             *
     *   h  < 1.96  (No Autocorrelation)                          *
     *          h(+3) > +1.96    Positive Autocorrelation         *
     *          h(-3) < -1.96    Negative Autocorrelation         *
     *  -1.96 < h(+1) < +1.96    No       Autocorrelation         *
     **************************************************************


{bf:{err:{dlgtab:Saved Results}}}

{pstd}
{cmd:lmadurh} saves the following in {cmd:e()}:

{synoptset 12 tabbed}{...}
{p2col 5 10 10 2: Scalars}{p_end}
{synopt:{cmd:e(durho)}}Durbin h Test after (OLS) (Lag DepVar){p_end}
{synopt:{cmd:e(durhop)}}Durbin h Test after (OLS) (Lag DepVar) P-Value{p_end}
{synopt:{cmd:e(hrvho)}}Harvey LM Test after (OLS) (Lag DepVar){p_end}
{synopt:{cmd:e(hrvhop)}}Harvey LM Test after (OLS) (Lag DepVar) P-Value{p_end}
{synopt:{cmd:e(waldt)}}Wald T Test{p_end}
{synopt:{cmd:e(waldtp)}}Wald T Test P-Value{p_end}
{synopt:{cmd:e(waldchi)}}Wald Chi2 Test{p_end}
{synopt:{cmd:e(waldchip)}}Wald Chi2 Test P-Value{p_end}
{synopt:{cmd:e(durha)}}Durbin h Test after ALS(1) (Lag DepVar){p_end}
{synopt:{cmd:e(durhap)}}Durbin h Test after ALS(1) (Lag DepVar) P-Value{p_end}
{synopt:{cmd:e(hrvha)}}Harvey LM Test after ALS(1) (Lag DepVar){p_end}
{synopt:{cmd:e(hrvhap)}}Harvey LM Test after ALS(1) (Lag DepVar) P-Value{p_end}


{bf:{err:{dlgtab:Examples}}}

	{stata clear all}

	{stata db lmadurh}

	{stata sysuse lmadurh.dta, clear}

	{stata lmadurh y y1 x1 x2, dlag(1)}

	{stata lmadurh y x1 x2 y1, dlag(3)}

	{stata ereturn list}


   ============================================================
   * Dynamic Autocorrelation Tests after (OLS-ALS) Regression *
   ============================================================
   Ho: No Autocorrelation - Ha: Autocorrelation

   ----------------------------------------------------------------------
   * Durbin  h Test                AR(1) =    -0.351     P>Z       0.3628
   * Harvey LM Test                AR(1) =     0.123     P>Chi2(1) 0.7256
   ----------------------------------------------------------------------
   * Wald    T Test                AR(1) =    -0.280     P>Z       0.3896
   * Wald Chi2 Test                AR(1) =     0.079     P>Z       0.7792
   ----------------------------------------------------------------------
   * Durbin  h Test after ALS(1)   AR(1) =    -1.260     P>Z       0.1038
   * Harvey LM Test after ALS(1)   AR(1) =     1.588     P>Chi2(1) 0.2077
   ----------------------------------------------------------------------


{bf:{err:{dlgtab:References}}}

{p 4 8 2}Durbin, James (1970)
{cmd: "Testing for Serial Correlation in Least-Squares Regression When Some of the Regressors are Lagged Dependent Variables",}
{it:Econometrica, vol.38, no.3, May}; 410-421.

{p 4 8 2}Harvey, Andrew (1990)
{cmd: "The Econometric Analysis of Time Series",}
{it:2nd edition, MIT Press, Cambridge, Massachusetts}; 275-277.

{p 4 8 2}Judge, Georege, R. Carter Hill, William . E. Griffiths, Helmut Lutkepohl, & Tsoung-Chao Lee (1988)
{cmd: "Introduction To The Theory And Practice Of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}; 401.


{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Assistant Professor}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email:   {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage:{col 27}{browse "http://emadstat.110mb.com/stata.htm"}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}


{bf:{err:{dlgtab:lmadurh Citation}}}

{phang}Shehata, Emad Abd Elmessih (2011){p_end}
{phang}{cmd: "lmadurh: Stata Module to Compute Dynamic Durbin h, Harvey LM, and Wald LM Autocorrelation Tests after (OLS-ALS) Regressions"}{p_end}

	{browse "http://ideas.repec.org/c/boc/bocode/s457346.html"}

	{browse "http://econpapers.repec.org/software/bocbocode/s457346.htm"}


{title:Also see}

{p 4 12 2}Online: {helpb lmareg3}, {helpb lmadurh}, {helpb lmalb}, {helpb lmabp}, {helpb lmadw}, {helpb lmavon} {opt (if installed)}.{p_end}

{psee}
{p_end}

