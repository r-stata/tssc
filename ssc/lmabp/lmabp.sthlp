{smcl}
{hline}
{cmd:help: {helpb lmabp}}{space 55} {cmd:dialog:} {bf:{dialog lmabp}}
{hline}


{bf:{err:{dlgtab:Title}}}

{bf: lmabp: Box-Pierce Autocorrelation LM Test at Higher Order AR(p)}


{bf:{err:{dlgtab:Syntax}}}

{p 8 16 2}
{opt lmabp} {depvar} {indepvars} {ifin} {weight} , [ {opt lag:s(numlist)} {opt nocons:tant} {opth vce(vcetype)} ]{p_end} 

{bf:{err:{dlgtab:Options}}}
{synoptset 20 tabbed}{...}

{synopt :{opt lag:s(#)}}determine Order of Lag Length; default is lag(1).{p_end}

{synopt :{opt nocons:tant}}suppress constant term{p_end}

{syntab:SE/Robust}
{synopt :{opth vce(vcetype)}}{it:vcetype} may be {opt ols},
   {opt r:obust}, {opt cl:uster} {it:clustvar}, {opt boot:strap}, 
   {opt jack:knife}, {opt hc2}, or {opt hc3}{p_end}


{bf:{err:{dlgtab:Description}}}

{p 2 2 2}{cmd:lmabp} computes Box-Pierce Autocorrelation LM Test after {helpb regress} command.{p_end} 
{p 2 2 2}{cmd:lmabp} detects autocorrelation at Higher Order AR(p), more than AR(1).{p_end}


                              J
   {cmd: Box-Pierce LM test} = N [ Sum(Rho_i) ] ~ Chi2(J)
                             i=1
where
       N = Number of Observations.
       J = Order of Lag Length.
   Rho_i = Autoregressive Coefficient of Lag i.


{bf:{err:{dlgtab:Saved Results}}}

{pstd}
{cmd:lmadurh} saves the following in {cmd:r()}:

{synoptset 12 tabbed}{...}
{p2col 5 10 10 2: Scalars}{p_end}
{synopt:{cmd:r(rho_#)}}Rho Value at Order AR(i){p_end}
{synopt:{cmd:r(bp_#)}}Box-Pierce Autocorrelation LM Test at Order AR(i){p_end}
{synopt:{cmd:r(bpp_#)}}Box-Pierce Autocorrelation LM Test P-Value at Order AR(i){p_end}


{bf:{err:{dlgtab:Examples}}}

	{stata clear all}

	{stata db lmabp}

	{stata sysuse lmabp.dta , clear}

	{stata lmabp y x1 x2 , lags(1)}

	{stata lmabp y x1 x2 , lags(4)}

	{stata return list}


   ===================================================
   * Box-Pierce Autocorrelation LM Test              *
   ===================================================
    Ho: No Autocorrelation - Ha: Autocorrelation
   ------------------------------------------------------------
   * Rho Value for         AR(1) =   -0.1455
   * Box-Pierce LM Test    AR(1) =    0.3598   P>Chi2(1) 0.5486
   ------------------------------------------------------------
   * Rho Value for         AR(2) =   -0.2231
   * Box-Pierce LM Test    AR(2) =    1.2062   P>Chi2(2) 0.5471
   ------------------------------------------------------------
   * Rho Value for         AR(3) =    0.1871
   * Box-Pierce LM Test    AR(3) =    1.8016   P>Chi2(3) 0.6146
   ------------------------------------------------------------
   * Rho Value for         AR(4) =   -0.3002
   * Box-Pierce LM Test    AR(4) =    3.3334   P>Chi2(4) 0.5037
   ------------------------------------------------------------


{bf:{err:{dlgtab:References}}}

{p 4 8 2}Damodar Gujarati (1995)
{cmd: "Basic Econometrics"}
{it:3rd Edition, McGraw Hill, New York, USA}; 717.

{p 4 8 2}Box, George & Pierce D. (1970)
{cmd: "Distribution of Residual Autocorrelations in Autoregressive Integrated Moving Average Time Series Models",}
{it:J. Am. Stat. Assoc., Vol. 65}; 1509-1526.

{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Assistant Professor}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email:   {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage:{col 27}{browse "http://emadstat.110mb.com/stata.htm"}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}


{bf:{err:{dlgtab:lmabp Citation}}}

{phang}Shehata, Emad Abd Elmessih (2011){p_end}
{phang}{cmd: "lmabp: Stata Module to Compute Box-Pierce Autocorrelation LM Test at Higher Order AR(p) after OLS Regression"}{p_end}


{title:Also see}

{p 4 12 2}Online: {helpb lmareg3}, {helpb lmadurh}, {helpb lmalb}, {helpb lmabp}, {helpb lmadw}, {helpb lmavon} {opt (if installed)}.{p_end}

{psee}
{p_end}

