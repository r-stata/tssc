{smcl}
{hline}
{cmd:help: {helpb lmavon}}{space 55} {cmd:dialog:} {bf:{dialog lmavon}}
{hline}


{bf:{err:{dlgtab:Title}}}

{bf: lmavon: Von Neumann Ratio Autocorrelation Test at Higher Order AR(p)}


{bf:{err:{dlgtab:Syntax}}}

{p 8 16 2}
{opt lmavon} {depvar} {indepvars} {ifin} {weight} , [ {opt lag:s(numlist)} {opt nocons:tant} {opth vce(vcetype)} ]{p_end} 

{bf:{err:{dlgtab:Options}}}
{synoptset 20 tabbed}{...}

{synopt :{opt lag:s(#)}}determine Order of Lag Length; default is lag(1).{p_end}

{synopt :{opt nocons:tant}}suppress constant term{p_end}

{syntab:SE/Robust}
{synopt :{opth vce(vcetype)}}{it:vcetype} may be {opt ols},
   {opt r:obust}, {opt cl:uster} {it:clustvar}, {opt boot:strap}, 
   {opt jack:knife}, {opt hc2}, or {opt hc3}{p_end}


{bf:{err:{dlgtab:Description}}}

{p 2 2 2}{cmd:lmavon} computes Von Neumann Ratio Autocorrelation Test after {helpb regress} command.{p_end} 
{p 2 2 2}{cmd:lmavon} detects autocorrelation at Higher Order AR(p), more than AR(1).{p_end}


   {cmd: Von Neumann Ratio Test} = DW(i)*N/(N-1)

where
    DW(i) = Durbin-Watson Test = sum((E-`E'[n-i])^2)/sum(E^).
        N = Number of Observations.
    Rho_i = Autoregressive Coefficient of Lag i.


{bf:{err:{dlgtab:Saved Results}}}

{pstd}
{cmd:lmadurh} saves the following in {cmd:r()}:

{synoptset 12 tabbed}{...}
{p2col 5 10 10 2: Scalars}{p_end}
{synopt:{cmd:r(rho_#)}}Rho Value at Order AR(i){p_end}
{synopt:{cmd:r(von_#)}}Von Neumann Ratio Autocorrelation Test at Order AR(i){p_end}


{bf:{err:{dlgtab:Examples}}}

	{stata clear all}

	{stata db lmavon}

	{stata sysuse lmavon.dta , clear}

	{stata lmavon y x1 x2 , lags(1)}

	{stata lmavon y x1 x2 , lags(4)}

	{stata return list}


   ====================================================
   * Von Neumann Ratio Autocorrelation Test           *
   ====================================================
    Ho: No Autocorrelation - Ha: Autocorrelation
   ---------------------------------------------------------------------------
   * Rho Value for              AR(1) =   -0.1455
   * Von Neumann Ratio Test     AR(1) =    2.1447   df: (3 , 17)
   ---------------------------------------------------------------------------
   * Rho Value for              AR(2) =   -0.2231
   * Von Neumann Ratio Test     AR(2) =    2.1632   df: (3 , 17)
   ---------------------------------------------------------------------------
   * Rho Value for              AR(3) =    0.1871
   * Von Neumann Ratio Test     AR(3) =    1.2703   df: (3 , 17)
   ---------------------------------------------------------------------------
   * Rho Value for              AR(4) =   -0.3002
   * Von Neumann Ratio Test     AR(4) =    2.1391   df: (3 , 17)
   ---------------------------------------------------------------------------


{bf:{err:{dlgtab:References}}}

{p 4 8 2}Maddala, G. (1992)
{cmd: "Introduction to Econometrics",}
{it:2nd ed., Macmillan Publishing Company, New York, USA}; 245.

{p 4 8 2}Von, Neumann (1941)
{cmd: "Distribution of the Ratio of the Mean Square Successive Difference to the Variance",}
{it:Annals Math. Stat., Vol. 12}; 367-395.


{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Assistant Professor}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email:   {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage:{col 27}{browse "http://emadstat.110mb.com/stata.htm"}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}


{bf:{err:{dlgtab:lmavon Citation}}}

{phang}Shehata, Emad Abd Elmessih (2011){p_end}
{phang}{cmd: "lmavon: Stata Module to Compute Von Neumann Ratio Autocorrelation Test at Higher Order AR(p) after OLS Regression"}{p_end}


{title:Also see}

{p 4 12 2}Online: {helpb lmareg3}, {helpb lmadurh}, {helpb lmalb}, {helpb lmabp}, {helpb lmadw}, {helpb lmavon} {opt (if installed)}.{p_end}

{psee}
{p_end}

