{smcl}
{hline}
{cmd:help: {helpb fxbcr}}{space 50} {cmd:dialog:} {bf:{dialog fxbcr}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf:fxbcr: Benefit-Cost Ratio (BCR)}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb fxbcr##01:Syntax}{p_end}
{p 5}{helpb fxbcr##02:Options}{p_end}
{p 5}{helpb fxbcr##03:Description}{p_end}
{p 5}{helpb fxbcr##04:References}{p_end}

{p 1}*** {helpb fxbcr##05:Applications}{p_end}

{p 5} {help fxbcr##05010:(1)  (CIF) Cash InFlow  (Benefit)}{p_end}
{p 5} {help fxbcr##05020:(2)  (COF) Cash OutFlow (Cost)}{p_end}
{p 5} {help fxbcr##05030:(3)  (NCF) Net Cash Flow}{p_end}

{p 5} {help fxbcr##05040:(4)  Nominal and Real Discount / Interest Rate}{p_end}
{p 5} {help fxbcr##05041:(4-1)  (IR) Interest Rate}{p_end}
{p 5} {help fxbcr##05042:(4-2)  (DR) Discount Rate}{p_end}
{p 5} {help fxbcr##05043:(4-3)  (SR) Simple Discount / Interest Rate}{p_end}
{p 5} {help fxbcr##05044:(4-4)  (Rn) Nominal Discount Rate}{p_end}
{p 5} {help fxbcr##05045:(4-5)  (Rr) Real Discount Rate}{p_end}
{p 5} {help fxbcr##05046:(4-6) (FVF) Future Value Factor}{p_end}
{p 5} {help fxbcr##05047:(4-7) (PVF) Present Value Factor}{p_end}
{p 5} {help fxbcr##05048:(4-8) (EAR) Effective Annual Rate}{p_end}
{p 5} {help fxbcr##05049:(4-9) Discount Rate Converter}{p_end}

{p 5} {helpb fxbcr##06:(6) Inflation and Deflation}{p_end}

{p 5} {helpb fxbcr##07:(7) (BCR) Benefit-Cost Ratio (Profitability Index) (PI)}{p_end}

{p 5} {helpb fxbcr##08:(8) (CBR) Cost-Benefit Ratio}{p_end}


{p 1}*** {helpb fxbcr##09:Examples}{p_end}

{p 5}{helpb fxbcr##10:Authors}{p_end}

{p2colreset}{...}
{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 3 5 6}
{opt fxbcr} lhs = rhs {ifin} , {err: [} {opt dr(#)} {opt ddr} {opt def(#)} {opt inf(#)} {opt pe:riod(#)}{p_end}
 {p 15 5 6}
 {opt l:ist} {opt pr:int} {opt sac(#)} {opt sap(#)}{err:]}{p_end}

{p2colreset}{...}
{marker 02}{bf:{err:{dlgtab:Options}}}

{col 3}{opt lhs}{col 15}Cash InFlow  (Benefit)

{col 3}{opt rhs}{col 15}Cash OutFlow (Cost)

{col 3}{opt dr(#)}{col 15}Discount Rate (Integer Number) i.e, (8) that means (8 % or 0.08)
{col 15}dr(#) default = (10%)

{col 3}{opt ddr}{col 15}Decimal Discount Rate, i.e, (7.6) that means (7.6 % or 0.076)

{col 3}{opt def(#)}{col 15}Use Deflation to Convert Cash Flows from Nominal to Real Values
{col 15}Inflation Rate (Integer Number) i.e, (8) that means (8 % or 0.08)
{col 15}inf(#) default = (0%)

{col 3}{opt inf(#)}{col 15}Use Inflation to Convert Cash Flows from Real to Nominal Values
{col 15}Inflation Rate (Integer Number) i.e, (8) that means (8 % or 0.08)
{col 15}inf(#) default = (0%)

{col 3}{opt sap(#)}{col 15}Sensitivity Analysis Scenario to Decrease/Increase Cash Inflow (Benefit)
{col 15}sap(#) default = (10%)

{col 3}{opt sac(#)}{col 15}Sensitivity Analysis Scenario to Increase/Decrease Cash Outflow (Cost)
{col 15}sac(#) default = (10%)

{col 3}{opt l:ist}{col 15}Add UnDiscounted and Discounted Cash Flow Variables to Data List:

{col 3}{opt pr:int}{col 15}Display UnDiscounted and Discounted Cash Flow Values:
{col 10} (CIFu): UnDiscounted Cash Inflow  (Benefit    or Revenue)
{col 10} (COFu): UnDiscounted Cash Outflow (Investment or Cost)
{col 10} (NCFu): UnDiscounted Net Cash Flow
{col 10} (CIFd):   Discounted Cash Inflow  (Benefit)
{col 10} (COFd):   Discounted Cash Outflow (Cost)

{col 3}{opt pe:riod(#)}{col 15}Period for Seasonal Discount Rate; default is (1)
{col 10}pe(#) must be:
{col 10}pe({it:1})   {cmd:Yearly Rate}
{col 10}pe({it:2})   {cmd:Half-Yearly Rate}
{col 10}pe({it:3})   {cmd:Third-Yearly Rate}
{col 10}pe({it:4})   {cmd:Quarter-Yearly Rate}
{col 10}pe({it:12)}  {cmd:Monthly Rate}
{col 10}pe({it:7)}   {cmd:Weekly Rate}
{col 10}pe({it:365)} {cmd:Daily Rate}

{bf:{err:*** Important Notes:}}
{cmd:fxbcr} generates some variables names starting with prefix "_":
{cmd:So, you must avoid to include variables names with these prefixes}

{p2colreset}{...}
{marker 03}{bf:{err:{dlgtab:Description}}}
{pstd}
{cmd:fxbcr} estimates Benefit-Cost Ratio (BCR).
{cmd:fxbcr} can estimate many projects at once, for comparison.
{cmd:fxbcr} can estimate seasonal data.

{p2colreset}{...}
{marker 04}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Frank J. Fabozzi & Pamela P. Peterson (2003)
{cmd: "Financial Management and Analysis, 2nd Edition",}
{it:John Wiley & Sons, Inc.}.

{p2colreset}{...}
{marker 05}{bf:{err:{dlgtab:Applications}}}

{p2colreset}{...}
{marker 05010}{bf:{err:{dlgtab:(1) (CIF) Cash InFlow (Profit - Benefit)}}}

{bf:* Definition:}
* (CIF) = Summation of Cash Inflow values (Profit - Benefit)

{p2colreset}{...}
{marker 05020}{bf:{err:{dlgtab:(2) (COF) Cash OutFlow (Cost- Investment)}}}

{bf:* Definition:}
* (COF) = Summation of Cash Outflow values (Cost- Investment)

{p2colreset}{...}
{marker 05030}{bf:{err:{dlgtab:(3) (NCF) Net Cash Flow}}}

{bf:* Formula:}
  {bf:(NCF) = (CIF) Cash InFlow (Benefit) - (COF) Cash OutFlow (Cost)}
  {bf:(NCF) = CIF - COF}

{bf:* Definition:}
* (NCF) = Summation of Net Cash Flow values

 * Note:
   1- (NCF) Must be Negative Number at least in First Observation
   2- (NCF) Summation must be Positive

{bf:* Example:}
  {stata clear all}
  {stata sysuse fxbcr.dta, clear}
  {stata "fxbcr p1 = k1 , pe(1)"}

{pstd}
Suppose you have investment with the following expected cash flows, with discount rate (0.08)

+------+------------------------+-------------------------------+
|      | (UnDiscounted Values)  |      (Discounted Values)      |
| Time |------------------------+-------------------------------+
|      | Cost    Profit   NCF   |   Cost     Profit     NCF     |
|      | COFu    CIFu     NCFu  |   COFd      CIFd      NCFd    |
|------+------------------------+-------------------------------|
|  0   | 500     400     -100   |   500       400       -100    |
|  1   |  30      60       30   |   27.778    55.556     27.778 |
|  2   |  40      70       30   |   34.294    60.014     25.720 |
|  3   |  50     110       60   |   39.692    87.322     47.630 |
|------+------------------------+-------------------------------|
| Sum  | 620     640       20   |  601.763    602.891     1.128 |
+------+------------------------+-------------------------------+

+---+------------------------+------------------------+-------------------------+
| T |          COFd          |           CIFd         |       NCFd (NPV)        |
|---+------------------------+------------------------+-------------------------+
| 0 | 500*(1+0.08)^0= 500    | 400*(1+0.08)^0= 400    | 400    - 500   =-100    |
| 1 |  30*(1+0.08)^1= 27.778 |  60*(1+0.08)^1= 55.556 | 55.556 - 27.778= 27.778 |
| 2 |  40*(1+0.08)^2= 34.294 |  70*(1+0.08)^2= 60.014 | 60.014 - 34.294= 25.720 |
| 3 |  50*(1+0.08)^3= 39.692 | 110*(1+0.08)^3= 87.322 | 87.322 - 39.692= 47.630 |
|---+------------------------+------------------------|-------------------------+
| Sum              = 601.763 |              = 602.891 |                = 1.128  |
+----------------------------+------------------------+-------------------------+

{p2colreset}{...}
{marker 05040}{bf:{err:{dlgtab:(4) Nominal and Real Discount / Interest Rate}}}
{p2colreset}{...}
{marker 05041}{bf:{err:{dlgtab:(4-1) (IR) Interest Rate}}}

{bf:* Definition:}
{pstd}
* The rate that will be between the commercial banks and their customers, whether they are individuals or companies

{p2colreset}{...}
{marker 05042}{bf:{err:{dlgtab:(4-2) (DR) Discount Rate}}}

{bf:* Definition:}
{pstd}
* The rate that will be between the Central Bank and Domestic Commercial Banks. This means that the central bank takes from commercial banks to cover liquidity needs.

{pstd}
* the interest rate, which the Central Bank lends to Domestic Commercial Banks.

{pstd}
* the interest rate at which future value are discounted to present value and vice versa.

{p2colreset}{...}
{marker 05043}{bf:{err:{dlgtab:(4-3) (SR) Simple Discount / Interest Rate}}}

{bf:* Formula:}
  {bf:SR = Pmt x R * n}

where:
 Pmt= Payment
 FV = Future Value
  R = Discount Rate
  n = Number of Periods

{bf:* Definition:}
{pstd}
* Simple Discount / Interest Rate is used to calculate the interest accrued on a loan or savings account that has simple interest.
 The simple interest formula is fairly simple to compute and to remember as principal times rate times time.

{pstd}
* The borrower pays the lender interest at regular periods within the term of the loan plus the principal and a single interest period payment at the end of the term.
 In this case interest accrues only on the original principal sum and does not compound.

{bf:* Example:}
 SR = Pmt x R * n
    = 100 * 0.08 * 4 = 32

 FV = Pmt + SR
 FV = 100 + 32 = 132

 FV = Pmt x (1+ R * n )
    = 100 * (1 + 0.08 * 4) = 132

{pstd}
 Investment $100 this year at 8% interest rate over 4 years will give $132

{p2colreset}{...}
{marker 05044}{bf:{err:{dlgtab:(4-4) (Rn) Nominal Discount Rate}}}

{bf:* Formula:}
* Real Discount Rate (Rr):
  Rr = (1 + Rn) ÷ (1 + F) – 1
  Rr = (Rn- F)  ÷ (1 + F)
  Rr =~ Rn – F

where:
 Rn = Nominal Discount Rate
 Rr = Real    Discount Rate
  F = Inflation Rate

{bf:* Definition:}
{pstd}
* Nominal Discount Rate is the rate before taking inflation into account.

{pstd}
* Nominal Discount Rate is the rate before removing inflation

{bf:* Example:}
*** if Nominal Discount Rate (Rn = 8%), Inflation Rate (F = 5%)
* Real Discount Rate (Rr):
  Rr = (1 + Rn) ÷ (1 + F) – 1 = (1 + 8%)  ÷ (1 + 5%) – 1 = 2.857%
  Rr = (Rn- F)  ÷ (1 + F)     = (8% - 5%) ÷ (1 + 5%)     = 2.857%
  Rr =~ Rn – F                = 8% - 5%                  = 3.000%

{p2colreset}{...}
{marker 05045}{bf:{err:{dlgtab:(4-5) (Rr) Real Discount Rate}}}

{bf:* Formula:}
*** if Real Discount Rate (Rr = 8%), Inflation Rate (F = 5%)
* Nominal Discount Rate (Rn):
  Rn = (1 + Rr) x (1 + F) - 1 = (1 + 8%)  x (1 + 5%) – 1 = 13.400%
  Rn = (Rr+ F)  + (Rr x F)    = (8% + 5%) x (8% x 5%)    = 13.400%
  Rr = (Rn+ F)  x (1 + F)     = (8% + 5%) x (1 + 5%)     = 13.650%
  Rn~= Rr + F                 = (8% + 5%)                = 13.000%

where:
 Rn = Nominal Discount Rate
 Rr = Real    Discount Rate
  F = Inflation Rate

{bf:* Definition:}
{pstd}
* Real Discount Rate is the rate after taking inflation into account.

{pstd}
* Real Discount Rate is the rate after removing inflation (deflation)

{pstd}
* Real Discount Rate is the rate that has been adjusted to remove the effects of inflation to reflect the real cost of capital, and the real yield to the lender.
 The real interest rate of an investment is calculated as the amount by which the nominal interest rate is higher than the inflation rate.

{pstd}
* Real Discount Rate approximation is: Nominal Discount Rate - Inflation Rate.

 Rr ~= Rn - F

{pstd}
* For example if Nominal Discount Rate (Rn = 5%), and Inflation Rate (F 3%), and the starting balance is $1000. Using the real rate of return formula would return a real rate of 1.942%.

 Rr = [(1 + 0.05)/ (1 + 0.03)] - 1 = 0.01942 = 1.942%

{pstd}
 With a $1000 starting balance, the individual could purchase $1019.42 of goods based on today's cost.
 
 = 1000 * (1 + 0.01942) = 1019.42
 
{pstd}
This example of real rate of return formula can be checked by multiplying $1019.42 by (1.03), inflation rate plus one, which results in a $1050 balance which would be the normal return on a 5% yield.

 = 1019.42 * (1 + 0.03) = 1050
 = 1000.00 * (1 + 0.05) = 1050

{bf:* Example:}
 Rr =  [(1 + Rn) ÷ (1 + F)] - 1
 Rr = ([(1 + Rn) ÷ (1 + F)] - 1) x 100
 Rr =  [(1 + 0.05) / (1 + 0.03)] - 1       = 0.01942
 Rr = ([(1 + 0.05) / (1 + 0.03)] - 1)* 100 = 1.942

{p2colreset}{...}
{marker 05046}{bf:{err:{dlgtab:(4-6) (FVF) Future Value Factor}}}

{bf:* Formula:}
  {bf:FVF = (1 + R)^n}

where:
 R = Discount Rate
 n = Number of Periods

{bf:* Definition:}
{pstd}
 Interest Rate Factor = V x (1 + R) = 1*1.10 = $1.10 ($ tomorrow /$ today)

{pstd}
 Discount Rate Factor = V ÷ (1 + R) = 1/1.10 = $0.91 ($ today    /$ tomorrow)

{p2colreset}{...}
{marker 05047}{bf:{err:{dlgtab:(4-7) (PVF) Present Value Factor}}}

{bf:* Formula:}
  {bf:PVF = 1/(1 + R)^n}

where:
 R = Discount Rate
 n = Number of Periods

{p2colreset}{...}
{marker 05048}{bf:{err:{dlgtab:(4-8) (EAR) Effective Annual Rate}}}

* (EAR) or Effective Interest/Discount Rate (EIR)  

{bf:* Formula:}
  {bf:EAR = (1 + R/n)^n - 1}

where:
 R = Periodic Interest Rate (day, week, month, ... etc.)
 n = Number of Periods in the Year

{bf:* Definition:}
{pstd}
* The equivalent simple annual interest rate resulting from the compounding frequency for a nominal annual interest rate. 

{bf:* Example:}
 if annual interest rate (R=10%),
 if there is Semi-Annual compounding, then (n=2)

Effective Annual Rate:
  EAR = (1 + R/n)^n - 1
      = (1 + 0.10/2)^2 - 1
      = 1.05^2 - 1
      = 0.1025 or 10.25%

----------------------------------------------------------
Frequency   | Rate |  t  |  Formula        | Effective Annual Rate
----------------------------------------------------------
Annual      | 10%  | 1   |  R              | 10.00%
Semi-Annual | 10%  | 2   | (1+R/2)^2-1     | 10.25%
Qua.-Annual | 10%  | 4   | (1+R/4)^4-1     | 10.38%
Monthly     | 10%  | 12  | (1+R/12)^12-1   | 10.47%
Daily       | 10%  | 365 | (1+R/365)^365-1 | 10.5156%
Continuous  | 10%  |     | exp^R-1         | 10.5171%
----------------------------------------------------------

-------------------------------------------
* {cmd:Quarter-Effective Annual Rate (R = 0.08)}
-------------------------------------------
 Time |  PMT    |   NFV    |   Diff.
-------------------------------------------
      |   (1)   |   (2)     |   (3)
-------------------------------------------
   1  |  1.0000 |  1.02000  |  0.02000
   2  |  1.0200 |  1.04040  |  0.02040
   3  |  1.0404 |  1.06121  |  0.02081
   4  |  1.0612 |  1.08243  |  0.02122
-------------------------------------------
 Sum  |         |           |  0.08243
-------------------------------------------

 (1) = Beginning Value in Period (m)
 (2) = Ending    Value in Period (m) = [(1 + R/m)^n]
 (3) = (2) - (1)
   n = Total Number of Periods in the Year
   m = Period Number (m) in the Year

  EAR = (0.02000 + 0.02040 + 0.02081 + 0.02122)
      = 0.08243 = 8.243%

  EAR = (1.08243 - 1) / 1 = 0.08243 = 8.243%

  EAR = (1 + R/n)^n - 1
      = (1 + 0.08/4)^4 - 1
      = 0.08243 = 8.243%

{p2colreset}{...}
{marker 05049}{bf:{err:{dlgtab:(4-9) Discount Rate Converter}}}

{bf:* Formula:}
-----------------------------------------------------------------------------------------------
From \ To   |       Month         |     Quarter-Year  |     Half-Year     |      Year         |
-----------------------------------------------------------------------------------------------
Month       |((1+R/12)^1-1)*12    |((1+R/12)^3-1)*4   |((1+R/12)^6-1)*2   |((1+R/12)^12-1)*1  |
Quarter-Year|((1+R/4)^(1/3)-1)*12 |((1+R/4)^1-1)*4    |((1+R/4)^2-1)*2    |((1+R/4)^4-1)*1    |
Half-Year   |((1+R/2)^(1/6)-1)*12 |((1+R/2)^(1/2)-1)*4|((1+R/2)^(1/1)-1)*2|((1+R/2)^2-1)*1    |
Year        |((1+R/1)^(1/12)-1)*12|((1+R/1)^(1/4)-1)*4|((1+R/1)^(1/2)-1)*2|((1+R/1)^(1/1)-1)*1|
-----------------------------------------------------------------------------------------------

{pstd}
* Interest Rate Converter enables you to convert interest rate payable at any frequency into an equivalent rate in another frequency.
 For instance, you can convert interest rate from annual to semi  annual or monthly to annual, quarterly etc.

{pstd}
* If the cash flows are NOT yearly but at any other uniform intervals like monthly, quarterly, semi annual, etc, IRR needs to be annualized with appropriate factor to calculate effective annual (IRR);

{pstd}
* to calculate Interest Rate (R) or (IRR) for monthly cash flows, we have to first calculate IRR for these cash flows using IRR function and then we need to annualize the result by using the factor [(1+IRR)^12]-1,
 where IRR is the IRR calculated for montly cash flows.

{col 5}for seasonal cash flow, the period transformations will be:
{col 5}----------------------------------------------------------------------------
{col 5}{cmd:| Year | Half-Year | Third-Year | Quarter-Year |  Month  |  Week    |  Day |}
{col 5}{cmd:|   1  |     2     |      3     |      4       1  2.167  |  52.143  |  365 |}
{col 5}----------------------------------------------------------------------------

{p2colreset}{...}
{marker 06}{bf:{err:{dlgtab:(6) Inflation and Deflation}}}

{pstd}
* Inflation: convert value in present time (2015) to equivalent value in future  time (2020)

{pstd}
* Deflating: convert value in future  time (2020) to equivalent value in present time (2015)

 - if Nominal Discount Rate (Rn) > Inflation Rate (F)
     ==> Real Discount Rate (Rr) == Positive

 - if Nominal Discount Rate (Rn) < Inflation Rate (F)
     ==> Real Discount Rate (Rr) == Negative

{bf:** Irving Fisher’s (1930) Equation}
{pstd}
generalized relationship between real discount rate of and nominal discount rate is expressed as follow under Fisher’s equation:

  {bf:(1 + Rn) = (1 + Rr) × (1 + F)}

where:
 Rn = Nominal Discount Rate
 Rr = Real    Discount Rate
  F = Inflation Rate

  {bf:Nominal Cash Flows = Real    Cash Flows × (1 + F)^t}
  {bf:Real    Cash Flows = Nominal Cash Flows ÷ (1 + F)^t}

-------------------------------------------------------------------
*** if Nominal Discount Rate (Rn = 8%), Inflation Rate (F = 5%)
* Real Discount Rate (Rr):
  Rr = (1 + Rn) ÷ (1 + F) – 1 = (1 + 8%)  ÷ (1 + 5%) – 1 = 2.857%
  Rr = (Rn- F)  ÷ (1 + F)     = (8% - 5%) ÷ (1 + 5%)     = 2.857%
  Rr = Rn – F                 = 8% - 5%                  = 3.000%

-------------------------------------------------------------------
*** if Real Discount Rate (Rr = 8%), Inflation Rate (F = 5%)
* Nominal Discount Rate (Rn):
  Rn = (1 + Rr) x (1 + F) - 1 = (1 + 8%)  x (1 + 5%) – 1 = 13.400%
  Rn = (Rr+ F)  + (Rr x F)    = (8% + 5%) x (8% x 5%)    = 13.400%
  Rr = (Rn+ F)  x (1 + F)     = (8% + 5%) x (1 + 5%)     = 13.650%
  Rn = Rr + F                 = (8% + 5%)                = 13.000%

-------------------------------------------------------------------
*** (Rnr): Convert Nominal to Real Cash Flow Variables:
 NCFu_n = UnDiscounted Nominal Net Cash Flow
 NCFu_r = UnDiscounted Real    Net Cash Flow (Deflated)
 NCFd_n =   Discounted Nominal Net Cash Flow
 NCFd_r =   Discounted Real    Net Cash Flow (Deflated)
 Nominal Discount Rate (Rn = 8%)
 Inflation Rate        ( F = 5%)
-------------------------------------------------------------------
           Deflation Method (1)             | Deflation Method (2)
-------------------------------------------------------------------
   | F(5%) |NCFu_n| NCFu_r | Rn(8%)| NCFd_r | Rnr   |NCFu_n| NCFd_r
 t |---------------------------------------------------------------
   | (1)   | (2)  | (3)    | (4)   | (5)    | (6)   | (7)  |(8)
-----------------------------------|-------------------------------
 0 | 1     |-100  |-100    | 1     |{red:-100}    | 1     | -100 |{red:-100}
 1 | 0.952 | 30   | 28.571 | 0.926 | {red:26.455} | 0.882 |  30  | {red:26.455}
 2 | 0.907 | 30   | 27.211 | 0.857 | {red:23.329} | 0.778 |  30  | {red:23.329}
 3 | 0.864 | 60   | 51.830 | 0.794 | {red:41.145} | 0.686 |  60  | {red:41.145}
-------------------------------------------------------------------
                            NPV   -9.0715   |      NPV   -9.0715
                            IRR1   3.3842 % |      IRR1   8.5534 %
                            IRR2   8.5534 % |      IRR2   3.3842 %
-------------------------------------------------------------------
 (1) = 1/(1+F)^t                       | Rnr =(1+Rn)x(1+F)-1=13.4%
 (3) = (1) x (2)                       | (6) = 1/(1+Rrn)^t
 (4) = 1/(1+Rn)^t                      | (8) = (6) x (7)
 (5) = (3) * (4)                       | IRR2= (1+IRR1) ÷ (1+F)-1
 IRR2= (1+IRR1) x (1+F)-1              |
-------------------------------------------------------------------

-------------------------------------------------------------------
*** (Rrn): Convert Real to Nominal Cash Flow Variables:
 NCFu_n = UnDiscounted Nominal Net Cash Flow
 NCFu_r = UnDiscounted Real    Net Cash Flow (Deflated)
 NCFd_n =   Discounted Nominal Net Cash Flow
 Nominal Discount Rate (Rn = 8%)
 Inflation Rate        ( F = 5%)
------------------------------------------------------------
         No Inflation       |            Inflation
----------------------------|-------------------------------
   | Rn(8%)| NCFu_n| NCFd_n | F(5%) | NCFu_r| Rrn   | NCFd_n
 t -------------------------|-------------------------------
   | (1)   | (2)  | (3)     | (4)   | (5)   | (6)   | (7)
----------------------------|-------------------------------
 0 | 1     | -100 | {red:-100}    | 1     |-100   | 1     | {red:-100}
 1 | 0.926 |  30  |  {red:27.778} | 0.952 | 28.57 | 0.972 |  {red:27.778}
 2 | 0.857 |  30  |  {red:25.720} | 0.907 | 27.21 | 0.945 |  {red:25.720}
 3 | 0.794 |  60  |  {red:47.630} | 0.864 | 51.83 | 0.919 |  {red:47.630}
----------------------------|--------------------------------
             NPV   1.1279   |              NPV    1.1279
             IRR1  8.5534 % |              IRR1   3.3842 %
             IRR2  3.3842 % |              IRR2   8.5534 %
----------------------------|--------------------------------
 (1) = 1/(1+Rn)^t           | (4) = 1/(1+F)^t
 (3) = (1) x (2)            | (5) = (2) x (4) 
                            | (6) = 1/(1+Rrn)^t
 Rrn = (Rn-F)/(1+F)= 2.86%  | (7) = (4) x (6)
--------------------------------------------------------------------

--------------------------------------------------------------------------------------
 NCFu_n = UnDiscounted Nominal Net Cash Flow
 NCFu_r = UnDiscounted Real    Net Cash Flow (Deflated)
 NCFd_n =   Discounted Nominal Net Cash Flow
 NCFd_r =   Discounted Real    Net Cash Flow (Deflated)
 Nominal Discount Rate (Rn = 8%)
 Inflation Rate        ( F = 5%)
--------------------------------------------------------------------------------------
  |     No Inflation      |        Nominal to Real          |   Real to Nominal        
t |-----------------------------------------------------------------------------------
  |Rn(8%) |NCFu_n| NCFd_n | F(5%) | NCFu_r |Rn(8%) | NCFd_r | NCFd_r | NCFd_n | NCFu_n
--------------------------------------------------------------------------------------
  |  (1)  |  (2) |   (3)  |  (4)  |  (5)   | (6)   |   (7)  | (8)    |   (9)  | (10)
--------------------------------------------------------------------------------------
0 | 1     | {red:-100} | {red:-100}   | 1     | -100   | 1     | {red:-100}   | -100   |-100    | {red:-100}
1 | 0.926 |  {red:30}  | {red:27.778} | 0.952 | 28.571 | 0.926 | {red:26.455} | 26.455 | 27.778 | {red:30}
2 | 0.857 |  {red:30}  | {red:25.720} | 0.907 | 27.211 | 0.857 | {red:23.329} | 23.329 | 25.720 | {red:30}
3 | 0.794 |  {red:60}  | {red:47.630} | 0.864 | 51.830 | 0.794 | {red:41.145} | 41.145 | 47.630 | {red:60}
--------------------------------------------------------------------------------------
- |       |  {red:20}  | {red:1.1279} |       | 7.6126 |       |{red:-9.0715} |-9.0715 | 1.1279 | {red:20}
--------------------------------------------------------------------------------------
 (1) = 1/(1+Rn)^t         | (4) = 1/(1+F)^t                 | (8) = (7)   
 (3) = (1) x (2)          | (5) = (2) x (4)                 | (9) = (8) ÷ (4)
                          | (6) = 1/(1+Rn)^t                | (10)= (9) ÷ (1)
                          | (7) = (5) x (6)                 |
--------------------------------------------------------------------------------------

 Rnr =(1+Rn)x(1+F)-1=13.4%

 (1) = 1/(1+Rn)^t    [Rn = 0.8%)]
 (3) = (1) x (2)
 (4) = 1/(1+F)^t
--------------------------------------------------------
 (5) = (2) x (4) 
 (6) = 1/(1+Rnr)^t   [Rnr = (Rn-F)/(1+F) = 2.86%]
 (7) = (5) x (6)
--------------------------------------------------------
 (8) = (1+Rrn)^t   [Rrn = (1+Rnr) * (1+F) - 1 = 0.8%]
 (9) = (7)
 (10)= (8) x (9)
--------------------------------------------------------

{p2colreset}{...}
{marker 07}{bf:{err:{dlgtab:(7) (BCR) Benefit-Cost Ratio (Profitability Index) (PI)}}}

* {bf:Profitability Index (PI) = Benefit-Cost Ratio (BCR)}

{bf:* Formula:}
  {bf:(BCR) = (CIF) Cash InFlow (Benefit) ÷ (COF): Cash OutFlow (Cost)}

{bf:* Definition:}
{pstd}
* (BCR) Benefit-Cost Ratio or Profitability Index (PI) is ratio of present value of future operating cash inflows to present value of investment cash flows.
(PI) tells us whether investment would increase owners’ wealth.
Because (PI) does not give us a dollar measure of the increase in value, we cannot use it to choose among mutually exclusive projects.
But (PI) does help us to rank projects when there is capital rationing.

{bf:* Decision Rule:}
 1- if (BCR>1): Accept Project (Investment is Expected to Increase Profit)
              Investment Returns more than $1 in present value for every $1 invested.

 2- if (BCR<1): Regect Project (Investment is Expected to Decrease Profit)
              Investment Returns less than $1 in present value for every $1 invested

 3- if (BCR=1): Accept or Regect Project (Investment is Expected Not to Change Profit)
              Investment Returns $1 in present value for every $1 invested

{bf:{err:* (PI) Advantages:}}
{p 2 5 5}1. Tells whether an investment increases the firm's value{p_end}
{p 2 5 5}2. Considers all cash flows of the project{p_end}
{p 2 5 5}3. Considers the time value of money{p_end}
{p 2 5 5}4. Considers the risk of future cash flows (through the cost of capital){p_end}
{p 2 5 5}5. Useful in ranking and selecting projects when capital is rationed{p_end}

{bf:{err:* (PI) Disadvantages:}}
{p 2 5 5}1. Requires an estimate of the cost of capital in order to calculate the profitability index{p_end}
{p 2 5 5}2. May not give the correct decision when used to compare mutually exclusive projects.{p_end}

{bf:* Example:}
 (BCR) = (CIF) Cash InFlow (Benefit) ÷ (COF): Cash OutFlow (Cost)
 (BCRu)= [(30.000 + 30.000 + 60.000) ÷ 100] = 120.0000 ÷ 100 = {bf:{err:1.2000}} = (120.00 %)
 (BCRd)= [(27.778 + 25.720 + 47.630) ÷ 100] = 101.1279 ÷ 100 = {bf:{err:1.0113}} = (101.13 %)

{p2colreset}{...}
{marker 08}{bf:{err:{dlgtab:(8) (CBR) Cost-Benefit Ratio}}}

{bf:* Formula:}
  {bf:(CBR) = (COF): Cash Outflow (Cost) ÷ (CIF) Cash Inflow (Benefit)}

{bf:* Definition:}
{pstd}
* (CBR) Cost-Benefit Ratio is the inverse of Profitability Index (PI), it is the ratio of present value of investment cash flows to present value of the future operating cash inflows. (CBR) tells us whether investment would increase owners’ wealth.
Because (CBR) does not give us a dollar measure of the increase in value, we cannot use it to choose among mutually exclusive projects.
But (CBR) does help us to rank projects when there is capital rationing.

{bf:* Decision Rule:}
 1- if (CBR<1): Accept Project (Investment is Expected to Increase Profit)
              Investment Returns more than $1 in present value for every $1 invested.

 2- if (CBR>1): Regect Project (Investment is Expected to Decrease Profit)
              Investment Returns less than $1 in present value for every $1 invested

 3- if (CBR=1): Accept or Regect Project (Investment is Expected Not to Change Profit)
              Investment Returns $1 in present value for every $1 invested

{bf:{err:* (CBR) Advantages:}}
{p 2 5 5}1. Tells whether an investment increases the firm's value{p_end}
{p 2 5 5}2. Considers all cash flows of the project{p_end}
{p 2 5 5}3. Considers the time value of money{p_end}
{p 2 5 5}4. Considers the risk of future cash flows (through the cost of capital){p_end}
{p 2 5 5}5. Useful in ranking and selecting projects when capital is rationed{p_end}

{bf:{err:* (CBR) Disadvantages:}}
{p 2 5 5}1. Requires an estimate of the cost of capital in order to calculate the profitability index{p_end}
{p 2 5 5}2. May not give the correct decision when used to compare mutually exclusive projects.{p_end}

{bf:* Example:}
 (CBR) = (COF): Cash Outflow (Cost) ÷ (CIF) Cash Inflow (Benefit)
 (CBRu)= [100 ÷ (30.000 + 30.000 + 60.000)] = 100 ÷ 120.0000 = {bf:{err:0.8333}} = (83.33 %)
 (CBRd)= [100 ÷ (27.778 + 25.720 + 47.630)] = 100 ÷ 101.1279 = {bf:{err:0.9888}} = (98.88 %)

{p2colreset}{...}
{marker 09}{bf:{err:{dlgtab:Examples}}}

  {stata clear all}

  {stata sysuse fxbcr.dta, clear}
  
  {stata "fxbcr p1 = k1 , pe(1) dr(8) print list"}
  
  {stata "fxbcr p1 = k1 , pe(1) dr(8) print list inf(5)"}

  {stata "fxbcr p1 = k1 , pe(1) dr(8) print list def(5)"}

  {stata "fxbcr p1 = k1 , pe(1) dr(8) print list"}

  {stata "fxbcr p1 = k1 , pe(1) dr(8) print list sac(1) sap(-1)"}

----------------------------------------------------------

  {stata "fxbcr p1 p2 p3 p4 p5 = k1 k2 k3 k4 k5 , print list"}

----------------------------------------------------------

  {stata "fxbcr p1 = k1 , pe(1) print list"}

  {stata "fxbcr p1 = k1 , pe(12) print list"}

  {stata "fxbcr p1 = k1 , pe(1) dr(8) print list"}

  {stata "fxbcr p1 = k1 , pe(1) dr(8) print list sac(5) sap(5)"}

  {stata "fxbcr p1 = k1 , pe(1) dr(8) print list sac(5) sap(-5)"}
{hline}

  {stata "clear all"}
  {stata "sysuse fxbcr.dta, clear"}
  {stata "fxbcr p1 = k1 , pe(1) print list"}

========================================================================================
                   *** Benefit-Cost Ratio (BCR) ***
----------------------------------------------------------------------------------------

========================================================================================
*** Benefit-Cost Ratio (BCR) for Project (1): [ p1 = k1 ]
----------------------------------------------------------------------------------------
*   (AN): Number of Periods                              =        4      (Year)
----------------------------------------------------------------------------------------
*  (ADR): Discount Rate                    (8.000 %)     =   0.0800      (Year)
----------------------------------------------------------------------------------------
          *** Criterion ***        * UnDiscount *        | * Discount * (adr= 8.00 %)
----------------------------------------------------------------------------------------
 1- (CIF): Cash Inflow  (Benefit)  =      640.000        |      602.891
 2- (COF): Cash Outflow (Cost)     =      620.000        |      601.763
 3- (NCF): Net Cash Flow           =       20.000        |        1.128
----------------------------------------------------------------------------------------
 4- (BCR): Benefit-Cost Ratio      =  1.200  (120.00 %)  | 1.011 (101.13 %)(Year)
----------------------------------------------------------------------------------------
 5- (CBR): Cost-Benefit Ratio      =  0.833  ( 83.33 %)  | 0.989 ( 98.88 %)(Year)
----------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------
*** UnDiscounted and Discounted Cash Flow Values ***

+-----------------------------------------------------------------------------+
|      Time      CIF_u      COF_u      NCF_u      CIF_d      COF_d      NCF_d |
|-----------------------------------------------------------------------------|
|     0.000    400.000    500.000   -100.000    400.000    500.000   -100.000 |
|     1.000     60.000     30.000     30.000     55.556     27.778     27.778 |
|     2.000     70.000     40.000     30.000     60.014     34.294     25.720 |
|     3.000    110.000     50.000     60.000     87.322     39.692     47.630 |
|-----------------------------------------------------------------------------|
|     6.000    640.000    620.000     20.000    602.891    601.763      1.128 |
+-----------------------------------------------------------------------------+
 * (CIF_u) & (CIF_d): UnDiscounted & Discounted Cash INFlow   (Benefit)
 * (COF_u) & (COF_d): UnDiscounted & Discounted Cash OUTFlow  (Cost)
 * (NCF_u) & (NCF_d): UnDiscounted & Discounted Net Cash Flow (Benefit-Cost)
----------------------------------------------------------------------------------------

{p2colreset}{...}
{marker 10}{bf:{err:{dlgtab:Authors}}}

- {hi:Emad Abd Elmessih Shehata}
  {hi:Professor (PhD Economics)}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email: {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

- {hi:Sahra Khaleel A. Mickaiel}
  {hi:Professor (PhD Economics)}
  {hi:Cairo University - Faculty of Agriculture - Department of Economics - Egypt}
  {hi:Email: {browse "mailto:sahra_atta@hotmail.com":sahra_atta@hotmail.com}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/pmi764.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/pmi764.htm"}}

{bf:{err:{dlgtab:FXBCR Citation}}}

{p 1}{cmd:Mickaiel, Sahra Khaleel A. & Emad Abd Elmessih Shehata (2016)}{p_end}
{p 1 10 1}{cmd:FXBCR: "Stata Module to Estimate Benefit-Cost Ratio (BCR)"}{p_end}

{title:Online Help:}

{hline 83}
{bf:{err:*** Distributed Lag Models:}}
{helpb almon1}{col 9}Shirley Almon Polynomial Distributed Lag Model{col 72}(ALMON1)
{helpb almon}{col 9}Shirley Almon Generalized Polynomial Distributed Lag Model{col 72}(ALMON)
{helpb dlagaj}{col 9}Alt France-Jan Tinbergen Distributed Lag Model{col 72}(DLAGAJ)
{helpb dlagdj}{col 9}Dale Jorgenson Rational Distributed Lag Model{col 72}(DLAGDJ)
{helpb dlagfd}{col 9}Frank De Leeuw Inverted V Distributed Lag Model{col 72}(DLAGFD)
{helpb dlagif}{col 9}Irving Fisher Arithmetic Distributed Lag Model{col 72}(DLAGIF)
{helpb dlagmf}{col 9}Milton Fridman Partial Adjustment-Adaptive Expectations
{col 9}Distributed Lag Model{col 72}(DLAGMF)
{helpb dlagmn}{col 9}Marc Nerlove Partial Adjustment Distributed Lag Model{col 72}(DLAGMN)
{helpb dlagrs}{col 9}Robert Solow Pascal Triangle Distributed Lag Model{col 72}(DLAGRS)
{helpb dlagrw}{col 9}Rudolf Wolffram Segmenting Partial Adjustment Distributed Lag{col 72}(DLAGRW)
{helpb dlagtq}{col 9}Tweeten-Quance Partial Adjustment Distributed Lag Model{col 72}(DLAGTQ)
{hline 83}
{bf:{err:*** Demand System Models:}}
{helpb dles}{col 9}Linear Expenditure System (LES){col 72}(DLES)
{helpb deles}{col 9}Extended Linear Expenditure System (ELES){col 72}(DELES)
{helpb dqes}{col 9}Quadratic Expenditure System (QES){col 72}(DQES)
{helpb drot}{col 9}Rotterdam Demand System{col 72}(DROT)
{helpb droti}{col 9}Inverse Rotterdam Demand System{col 72}(DROTI)
{helpb daidsla}{col 9}Linear Approximation Almost Ideal Demand System (AIDS-LA){col 72}(DAIDSLA)
{helpb daidsfd}{col 9}First Difference Almost Ideal Demand System (AIDS-FD){col 72}(DAIDSFD)
{helpb daidsi}{col 9}Inverse Almost Ideal Demand System(AIDS-I) {col 72}(DAIDSI)
{helpb darmin}{col 9}Primal Armington Demand System{col 72}(DARMIN)
{helpb dengel}{col 9}Engel Demand System{col 72}(DENGEL)
{helpb dgads}{col 9}Generalized AddiLog Demand System (GADS){col 72}(DGADS)
{helpb dtlog}{col 9}Transcendental Logarithmic Demand System{col 72}(DTLOG)
{helpb dwork}{col 9}Working Demand System{col 72}(DWORK)
{hline 83}
{helpb pfm}{col 9}Production Function Models{col 72}(PFM)
{helpb pfmnl}{col 9}Non-Linear Production Function Models{col 72}(PFMNL)
{hline 83}
{helpb cfm}{col 9}Cost Function Models{col 72}(CFM)
{helpb costreg}{col 9}Quadratic and Cubic Cost Functions{col 72}(COSTREG)
{hline 83}
{helpb ffm}{col 9}Profit Function Models{col 72}(FFM)
{hline 83}
{helpb iic}{col 9}Investment Indicators Criteria{col 72}(IIC)
{hline 83}
{helpb index}{col 9}Index Numbers{col 72}(INDEX)
{hline 83}
{helpb iot}{col 9}Leontief Input - Output Table{col 72}(IOT)
{hline 83}
{helpb mef}{col 9}Marketing Efficiency Models{col 72}(MEF)
{hline 83}
{helpb pam}{col 9}Policy Analysis Matrix{col 72}(PAM)
{helpb pem}{col 9}Partial Equilibrium Model{col 72}(PEM)
{hline 83}
{bf:{err:*** Financial Analysis Models:}}
{helpb fam}{col 9}Financial Analysis Models{col 72}(FAM)
{helpb fbep}{col 9}Financial Break-Even Point Analysis (BEP){col 72}(FBEP)
{helpb fxbcr}{col 9}Benefit-Cost Ratio (BCR){col 72}(FXBCR)
{helpb fxirr}{col 9}Internal Rate of Return (IRR-XIRR){col 72}(FXIRR)
{helpb fxmirr}{col 9}Modified Internal Rate of Return (MIRR-XMIRR){col 72}(FXMIRR)
{helpb fxnfv}{col 9}Net Future Value (NFV-XNFV){col 72}(FXNFV)
{helpb fxnpv}{col 9}Net Present Value (NPV-XNPV){col 72}(FXNPV)
{helpb fxpp}{col 9}Payback Period (PP){col 72}(FXPP)
{hline 83}
{bf:{err:*** Black-Scholes European Option Pricing:}}
{helpb bsopm}{col 9}Black-Scholes European Option Pricing Model{col 72}(BSOPM)
{helpb imvol}{col 9}Implied Volatility Black-Scholes European Option Pricing Model{col 72}(IMVOL)
{hline 83}
{bf:{err:*** Trade Models:}}
{helpb wtm}{col 9}World Trade Models{col 72}(WTM)
{helpb wtic}{col 9}World Trade Indicators Criteria{col 72}(WTIC)
{helpb wtrca}{col 9}World Trade Revealed Comparative Advantage{col 72}(WTRCA)
{helpb wtrgc}{col 9}World Trade Regional Geographical Concentration{col 72}(WTRGC)
{helpb wtsgc}{col 9}World Trade Sectoral Geographical Concentration{col 72}(WTSGC)
{hline 83}
{bf:{err:*** Forecasting Models:}}
{helpb arfimax}{col 9}Autoregressive Fractionally Integrated Moving Average Models{col 72}(ARFIMAX)
{helpb arimax}{col 9}Autoregressive Integrated Moving Average Models{col 72}(ARIMAX)
{helpb varx}{col 9}Vector Autoregressive Models{col 72}(VARX)
{helpb vecx}{col 9}Vector Error Correction Models{col 72}(VECX)
{hline 83}
{bf:{err:*** Spatial Econometrics Regression Models:}}
{helpb spregcs}{col 9}Spatial Cross Section Regression Econometric Models{col 72}(SPREGCS)
{helpb spregxt}{col 9}Spatial Panel Regression Econometric Models{col 72}(SPREGXT)
{hline 83}

{psee}
{p_end}

