{smcl}
{hline}
{cmd:help: {helpb lmfreg}}{space 50} {cmd:dialog:} {bf:{dialog lmfreg}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf: lmfreg: OLS Linear vs Log-Linear Functional Form Tests}

{bf:{err:{dlgtab:Syntax}}}

{p 8 16 2}
{opt lmfreg} {depvar} {indepvars} {ifin} , [ {opt nocons:tant} {opt coll} ]{p_end} 

{bf:{err:{dlgtab:Options}}}
{synoptset 20 tabbed}{...}

{col 3}{opt nocons:tant}{col 20}suppress constant term

{col 3}{opt coll}{col 20}Keep Collinear Variables

{bf:{err:{dlgtab:Description}}}

{p 2 2 2}{cmd:lmfreg} computes OLS Linear vs Log-Linear Functional Form Tests.{p_end} 

	- R-squared
 	- Log Likelihood Function (LLF)
 	- Antilog R2
 	- Box-Cox Test
 	- Bera-McAleer BM Test
 	- Davidson-Mackinnon PE Test

{bf:{err:{dlgtab:Saved Results}}}

{pstd}
{cmd:lmfreg} saves the following in {cmd:e()}:

{synoptset 12 tabbed}{...}
{p2col 5 10 10 2: Scalars}{p_end}

{err:*** Linear vs Log-Linear Functional Form Tests:}
{col 4}{cmd:e(r2lin)}{col 20}Linear R2
{col 4}{cmd:e(r2log)}{col 20}Log-Log R2
{col 4}{cmd:e(llflin)}{col 20}LLF - Linear
{col 4}{cmd:e(llflog)}{col 20}LLF - Log-Log
{col 4}{cmd:e(r2lina)}{col 20}Antilog R2 Linear  vs Log-Log: R2Lin
{col 4}{cmd:e(r2loga)}{col 20}Antilog R2 Log-Log vs Linear: R2log
{col 4}{cmd:e(boxcox)}{col 20}Box-Cox Test
{col 4}{cmd:e(boxcoxp)}{col 20}Box-Cox Test P-Value
{col 4}{cmd:e(bmlin)}{col 20}Bera-McAleer BM Test - Linear ModeL
{col 4}{cmd:e(bmlinp)}{col 20}Bera-McAleer BM Test - Linear ModeL P-Value
{col 4}{cmd:e(bmlog)}{col 20}Bera-McAleer BM Test - Log-Log ModeL
{col 4}{cmd:e(bmlogp)}{col 20}Bera-McAleer BM Test - Log-Log ModeL P-Value
{col 4}{cmd:e(dmlin)}{col 20}Davidson-Mackinnon PE Test - Linear ModeL
{col 4}{cmd:e(dmlinp)}{col 20}Davidson-Mackinnon PE Test - Linear ModeL P-Value
{col 4}{cmd:e(dmlog)}{col 20}Davidson-Mackinnon PE Test - Log-Log ModeL
{col 4}{cmd:e(dmlogp)}{col 20}Davidson-Mackinnon PE Test - Log-Log ModeL P-Value

{bf:{err:{dlgtab:References}}}

{p 4 8 2}Judge, Georege, R. Carter Hill, William . E. Griffiths, Helmut Lutkepohl, & Tsoung-Chao Lee (1988)
{cmd: "Introduction To The Theory And Practice Of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}.

{p 4 8 2}Judge, Georege, W. E. Griffiths, R. Carter Hill, Helmut Lutkepohl, & Tsoung-Chao Lee(1985)
{cmd: "The Theory and Practice of Econometrics",}
{it:2nd ed., John Wiley & Sons, Inc., New York, USA}; 242.

{bf:{err:{dlgtab:Examples}}}

	{stata clear all}

	{stata db lmfreg}

	{stata sysuse lmfreg.dta, clear}

	{stata lmfreg y x1 x2}

	{stata ereturn list}

==============================================================================
* Ordinary Least Squares (OLS)
==============================================================================
  y = x1 + x2
------------------------------------------------------------------------------
  Sample Size       =          17
  Wald Test         =    273.3662   |   P-Value > Chi2(2)       =      0.0000
  F-Test            =    136.6831   |   P-Value > F(2 , 14)     =      0.0000
 (Buse 1973) R2     =      0.9513   |   Raw Moments R2          =      0.9986
 (Buse 1973) R2 Adj =      0.9443   |   Raw Moments R2 Adj      =      0.9984
  Root MSE (Sigma)  =      5.5634   |   Log Likelihood Function =    -51.6471
------------------------------------------------------------------------------
- R2h= 0.9513   R2h Adj= 0.9443  F-Test =  136.68 P-Value > F(2 , 14)  0.0000
- R2v= 0.9513   R2v Adj= 0.9443  F-Test =  136.68 P-Value > F(2 , 14)  0.0000
------------------------------------------------------------------------------
           y |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          x1 |   1.061709   .2666739     3.98   0.001     .4897506    1.633668
          x2 |  -1.382986   .0838143   -16.50   0.000    -1.562749   -1.203222
       _cons |   130.7066   27.09429     4.82   0.000     72.59515    188.8181
------------------------------------------------------------------------------
==============================================================================
*** OLS Linear vs Log-Linear Functional Form Tests
==============================================================================
 (1) R-squared
      Linear  R2                   =    0.9513
      Log-Log R2                   =    0.9711
---------------------------------------------------------------------------
 (2) Log Likelihood Function (LLF)
      LLF - Linear                 =  -51.6471
      LLF - Log-Log                =  -47.5914
---------------------------------------------------------------------------
 (3) Antilog R2
      Linear  vs Log-Log: R2Lin    =    0.9649
      Log-Log vs Linear : R2log    =    0.9576
---------------------------------------------------------------------------
 (4) Box-Cox Test                  =    4.0556   P-Value > Chi2(1)   0.0440
      Ho: Choose Log-Log Model - Ha: Choose Linear  Model
---------------------------------------------------------------------------
 (5) Bera-McAleer BM Test
      Ho: Choose Linear  Model     =   11.9464   P-Value > F(1, 13)  0.0043
      Ho: Choose Log-Log Model     =    6.1092   P-Value > F(1, 13)  0.0280
---------------------------------------------------------------------------
 (6) Davidson-Mackinnon PE Test
      Ho: Choose Linear  Model     =   11.9462   P-Value > F(1, 13)  0.0043
      Ho: Choose Log-Log Model     =    6.1092   P-Value > F(1, 13)  0.0280
------------------------------------------------------------------------------

{bf:{err:{dlgtab:Authors}}}

- {hi:Emad Abd Elmessih Shehata}
  {hi:Professor (PhD Economics)}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email:   {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage:{col 27}{browse "http://emadstat.110mb.com/stata.htm"}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

- {hi:Sahra Khaleel A. Mickaiel}
  {hi:Professor (PhD Economics)}
  {hi:Cairo University - Faculty of Agriculture - Department of Economics - Egypt}
  {hi:Email:   {browse "mailto:sahra_atta@hotmail.com":sahra_atta@hotmail.com}}
  {hi:WebPage:{col 27}{browse "http://sahraecon.110mb.com/stata.htm"}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/pmi520.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/pmi520.htm"}}

{bf:{err:{dlgtab:lmfreg Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih & Sahra Khaleel A. Mickaiel (2012)}{p_end}
{p 1 10 1}{cmd:LMFREG: "OLS Linear vs Log-Linear Functional Form Tests"}{p_end}

	{browse "http://ideas.repec.org/c/boc/bocode/s457507.html"}

	{browse "http://econpapers.repec.org/software/bocbocode/s457507.htm"}

{title:Online Help:}

{helpb lmfreg}{col 14}OLS Linear vs Log-Linear Functional Form Tests
{helpb lmfreg2}{col 14}2SLS-IV Linear vs Log-Linear Functional Form Tests

{psee}
{p_end}

