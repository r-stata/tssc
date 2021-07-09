{smcl}
{hline}
{cmd:help: {helpb lmadw}}{space 55} {cmd:dialog:} {bf:{dialog lmadw}}
{hline}


{bf:{err:{dlgtab:Title}}}

{bf: lmadw: Durbin-Watson Autocorrelation Test at Higher Order AR(p)}


{bf:{err:{dlgtab:Syntax}}}

{p 8 16 2}
{opt lmadw} {depvar} {indepvars} {ifin} {weight} , [ {opt lag:s(numlist)} {opt nocons:tant} {opth vce(vcetype)} ]{p_end} 

{bf:{err:{dlgtab:Options}}}
{synoptset 20 tabbed}{...}

{synopt :{opt lag:s(#)}}determine Order of Lag Length; default is lag(1).{p_end}

{synopt :{opt nocons:tant}}suppress constant term{p_end}

{syntab:SE/Robust}
{synopt :{opth vce(vcetype)}}{it:vcetype} may be {opt ols},
   {opt r:obust}, {opt cl:uster} {it:clustvar}, {opt boot:strap}, 
   {opt jack:knife}, {opt hc2}, or {opt hc3}{p_end}


{bf:{err:{dlgtab:Description}}}

{p 2 2 2}{cmd:lmadw} computes Durbin-Watson Autocorrelation Test after {helpb regress} command.{p_end} 
{p 2 2 2}{cmd:lmadw} detects autocorrelation at Higher Order AR(p), more than AR(1).{p_end}


   {cmd: DW(i): Durbin-Watson Test = sum((E-`E'[n-i])^2)/sum(E^)


     **************************************************************
     ***** Positive Auto ***** (DW Test) **** Negative Auto *******
     *       DW >  Du   (No+)      *          DW *  4-Du   (No-)  *
     *  0  < DW <  DL   (  +)      *  4-DL <  DW <  4      (  -)  *
     *  DL * DW *  Du   (Inc)      *  4-Du <= DW *  4-DL   (Inc)  *
     **************************************************************


{bf:{err:{dlgtab:Saved Results}}}

{pstd}
{cmd:lmadurh} saves the following in {cmd:r()}:

{synoptset 12 tabbed}{...}
{p2col 5 10 10 2: Scalars}{p_end}
{synopt:{cmd:r(rho_#)}}Rho Value at Order AR(i){p_end}
{synopt:{cmd:r(dw_#)}}Durbin-Watson Test at Order AR(i){p_end}


{bf:{err:{dlgtab:Examples}}}

	{stata clear all}

	{stata db lmadw}

	{stata sysuse lmadw.dta , clear}

	{stata lmadw y x1 x2 , lags(1)}

	{stata lmadw y x1 x2 , lags(4)}

	{stata return list}


   ================================================
   * Durbin-Watson Autocorrelation Test           *
   ================================================
    Ho: No Autocorrelation - Ha: Autocorrelation

   ---------------------------------------------------------------------------
   * Rho Value for              AR(1) =   -0.1455
   * Durbin-Watson Test         AR(1) =    2.0185   df: (3 , 17)
   ---------------------------------------------------------------------------
   * Rho Value for              AR(2) =   -0.2231
   * Durbin-Watson Test         AR(2) =    2.0359   df: (3 , 17)
   ---------------------------------------------------------------------------
   * Rho Value for              AR(3) =    0.1871
   * Durbin-Watson Test         AR(3) =    1.1956   df: (3 , 17)
   ---------------------------------------------------------------------------
   * Rho Value for              AR(4) =   -0.3002
   * Durbin-Watson Test         AR(4) =    2.0133   df: (3 , 17)
   ---------------------------------------------------------------------------


{bf:{err:{dlgtab:References}}}

{p 4 8 2}Durbin, James & Watson G (1950)
{cmd: "Testing for Serial Correlation in Least Square Regression",}
{it:Biometrika, vol.37}; 409-428.

{p 4 8 2}Durbin, James & Watson G (1951)
{cmd: "Testing for Serial Correlation in Least Square Regression",}
{it:Biometrika, Vol. 38}; 159-178.

{p 4 8 2}Maddala, G. (1992)
{cmd: "Introduction to Econometrics",}
{it:2nd ed., Macmillan Publishing Company, New York, USA}; 245.


{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Assistant Professor}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email:   {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage:{col 27}{browse "http://emadstat.110mb.com/stata.htm"}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}


{bf:{err:{dlgtab:lmadw Citation}}}

{phang}Shehata, Emad Abd Elmessih (2011){p_end}
{phang}{cmd: "lmadw: Stata Module to Compute Durbin-Watson Autocorrelation Test at Higher Order AR(p) after OLS Regression"}{p_end}

 
{title:Also see}

{p 4 12 2}Online: {helpb lmareg3}, {helpb lmadurh}, {helpb lmalb}, {helpb lmabp}, {helpb lmadw}, {helpb lmavon} {opt (if installed)}.{p_end}

{psee}
{p_end}

