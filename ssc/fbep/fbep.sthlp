{smcl}
{hline}
{cmd:help: {helpb fbep}}{space 50} {cmd:dialog:} {bf:{dialog fbep}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf:fbep: Financial Break-Even Point Analysis (BEP)}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb fbep##01:Syntax}{p_end}
{p 5}{helpb fbep##02:Options}{p_end}
{p 5}{helpb fbep##03:Description}{p_end}

{p 5} {helpb fbep##031:(1) (BEPs) Break-Even Point (Single   Product)}{p_end}

{p 5} {helpb fbep##032:(2) (BEPm) Break-Even Point (Multiple Products)}{p_end}

{p 5} {helpb fbep##033:(3) Contribution Margin}{p_end}

{p 5} {helpb fbep##034:(4) Safety Margin}{p_end}

{p 5} {helpb fbep##035:(5) (WACC) Weighted Average Cost of Capital}{p_end}

{p 5}{helpb fbep##04:References}{p_end}

{p 1}*** {helpb fbep##05:Examples}{p_end}

{p 5}{helpb fbep##06:Authors}{p_end}

{p2colreset}{...}
{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 5 5 6}
{opt fbep} Pd Pw {ifin} , {opt tfc(var)} {err: [{opt pf(var)} {opt tax(var)} {opt qh(var)} {opt id(var)} {opt ratio(var)} {opt save(file_name)} {opt pcm list mp txt} {err:]}}{p_end}

{p2colreset}{...}
{marker 02}{bf:{err:{dlgtab:Options}}}

{col 3}{varlist}{col 20}Two Variables only uP & uVC respectively:
{col 24}1- {opt (uP)} Unit Price (uP)
{col 24}2- {opt (uVC)} Unit Variable Cost (uVC)

{col 3}{opt tfc(var)}{col 20}Total Fixed Cost (TFC)

{col 3}{opt id(var)}{col 20}ID Variable for Multiple Products (BEP)

{col 3}{opt ratio(var)}{col 20}Unit Price Ratio for Multiple Products (BEP)

{col 3}{opt pf(var)}{col 20}Target Profit

{col 3}{opt tax(var)}{col 20}Tax Rate (integer number (10, 20,...etc)

{col 3}{opt qh(var)}{col 20}Expected Quantity

{col 3}{opt mp}{col 20}Estimate Multiple Products (BEP)

{col 3}{opt list}{col 20}Add (BEP) Variables to Data List

{col 3}{opt pcm}{col 20}Print Contribution Margin output

{col 3}{opt txt}{col 20}Save Results in text File (*.txt) instead of (*.csv)

{col 3}{opt save(file_name)}{col 20}Save (BEP) Results in File (*.txt).

{bf:{err:*** Important Notes:}}
{cmd:fbep} generates some variables names starting with prefix "_":
{cmd:So, you must avoid to include variables names with these prefixes}

{p2colreset}{...}
{marker 03}{bf:{err:{dlgtab:Description}}}

{p 2 2 2}{cmd:fbep} estimates Financial Break-Even Point Analysis (BEP) with both Single and Multiple Products,
 at Units and Value, Target Profit, Target Profit before Tax, Safety Margin, Marginal Cost Ratio, Contribution Margin, Contribution Margin Ratio.{p_end}

{p2colreset}{...}
{marker 031}{bf:{err:{dlgtab:(1) (BEPs) Break-Even Point (Single   Product)}}}

{bf:* Definition:}
{pstd}
* Break-Even Point (BEP) is the point of zero loss or profit.

{pstd}
* Break-Even Point (BEP), is the point which let total revenue equal total cost

{pstd}
* Break-Even Point (BEP) is the minimum quantity of output sold at which total revenue equal total cost, and ensure at this point the project will not neither make profit nor make loses 

{pstd}
* before (BEP) the project will make loses, and after (BEP) the project will make profit

{bf:{err:* (BEP) Advantages:}}
{p 2 5 5}1. Quick and simple{p_end}
{p 2 5 5}2. Easy to understand{p_end}
{p 2 5 5}3. Helps spot potential problems{p_end}
{p 2 5 5}4. Can assist when applying for a loan{p_end}

{bf:{err:* (BEP) Disadvantages:}}
{p 2 5 5}1. It is only a forecast!{p_end}
{p 2 5 5}2. Assumes all products are made AND sold{p_end}
{p 2 5 5}3. Costs may change{p_end}
{p 2 5 5}4. Not very good for services because prices vary enormously{p_end}

{bf:* Formula:}
 At Break-Even Point, TR = TC.
 
 TR - TC = 0

where:
  TR = Total Revenue
  TC = Total Cost

  TR = TFC + TVC
  TC = TFC + TVC
 TVC = uVC x Q

 TFC = Total Fixed    Cost
 TVC = Total Variable Cost

 uVC = Unit Variable Cost
  uP = Unit Price
   Q = Quantity of Production

{bf: Marginal Cost Ratio = (Unit Variable Cost ÷ Unit Price)}
{err:                 MCR = (uVC ÷ uP) × 100}

{bf: Contribution Margin = (Unit Price - Unit Variable Cost)}
{err:                  CM = (uP - uVC)}

{bf:     Marginal Profit = Unit Price - Unit Variable Cost}
{bf: Contribution Margin =  Marginal Profit}

{bf: Contribution Margin Ratio = (Unit Price - Unit Variable Cost) ÷ Unit Price}
{err:                       CMR = (uP - uVC) ÷ uP × 100}

 Profit = TR - TC 
 set Profit = 0
 TR - TC = 0
 TR       - TVC       - TFC = 0
 (uP x Q) - (uVC x Q) - TFC = 0

 TFC = (uP x Q) - (uVC x Q)
 TFC =  Q  x (uP - uVC)
   Q = TFC ÷ (uP - uVC)

------------------------------------------------
{bf:{err:* (1) Break-Even Point:}}

 {bf:BEP(Q) = TFC ÷ (uP - uVC)}
 {bf:BEP(Q) = TFC ÷ CM}

 {bf:BEP(V) = BEP(Q) x uP} 
 {bf:BEP(V) = BEP(Q) ÷ [CM/uP]}
 {bf:BEP(V) = BEP(Q) ÷ CMR}
 {bf:BEP(V) = TFC ÷ [1 - (uVC/uP)]}
 {bf:BEP(V) = TFC ÷ [1 - MCR]}

where:
 BEP(Q) = Break-Even Point in Quantity (Units)
 BEP(V) = Break-Even Point in Value    (Sales)

------------------------------------------------
{bf:{err:* (2) Break-Even Point Target Profit:}}

 {bf:BEP(Qf) = (TFC + Target Profit) ÷ (uP - uVC)}

 {bf:BEP(Vf) = BEP(Q) x Pu}

where:
 BEP(Qf) = Break-Even Point Target Profit in Quantity (Units)
 BEP(Vf) = Break-Even Point Target Profit in Value    (Sales)

------------------------------------------------
{bf:{err:* (3) Break-Even Point Target Profit before Tax:}}

 {bf:Target Profit before Tax = Target Profit after Tax ÷ (1 - Tax Rate)}

 {bf:BEP(Qft) = (TFC + Target Profit before Tax) ÷ (uP - uVC)}

 {bf:BEP(Vft) = BEP(Qt) x Pu}

where:
 BEP(Qft) = Break-Even Point Target Profit before Tax in Quantity (Units)
 BEP(Vft) = Break-Even Point Target Profit before Tax in Value    (Sales)

{bf:* Decision Rule:}
 1- if Quantity > BEP(Q): Accept Project (Investment Make Profit)
 2- if Quantity < BEP(Q): Regect Project (Investment Make Loss)
 
 3- if Sales > BEP(V): Accept Project (Investment Make Profit)
 4- if Sales < BEP(V): Regect Project (Investment Make Loss)

------------------------------------------------
{bf:* Example:}
   Q = 100
 TFC = 1800
 uVC = 2
 
 Break-Even Point:
 Q x P = TFC  + uVC x Q
 100 P = 1800 +  (2 x 100)
 100 P = 1800 +  (200)
 100 P = 2000
     P = 2000 ÷ 100 = 20

------------------------------------------------
{bf:* Example:}

 TFC = Total Fixed   Cost = 250
 uVC = Unit Variable Cost = 10
  uP = Unit Price         = 15

------------------------------------------------
{bf:{err:* (1) Break-Even Point:}}

 TR       = TVC       + TFC = 0
 TR       - TVC       - TFC = 0
 (uP x Q) - (uVC x Q) - TFC = 0

 uP x Q = uVC x Q  + TFC
 15 x Q = (10 x Q) + 250

    250 = (15 x Q) - (10 x Q)
    250 =  Q x (15 - 10)

 BEP(Q) = TFC ÷ (uP - uVC)
        = 250 / (15-10)
        = 50
 BEP(Q) = 50

 BEP(V) = BEP(Q) x uP
        = 50    x 15
 BEP(V) = 750

------------------------------------------------
{bf:{err:* (2) Break-Even Point Target Profit:}}
{bf:* if Target Profit = 100}

 BEP(Qf) = (TFC + Target Profit) ÷ (uP - uVC)
 BEP(Qf) = (250 + 100) ÷ (15 - 10)
 BEP(Qf) = (350) / (15 - 10)
 BEP(Qf) = 70
 BEP(Vf) = BEP(Qf) x uP
 BEP(Vf) = 70      x 15
 BEP(Vf) = 1050

------------------------------------------------
{bf:{err:* (3) Break-Even Point Target Profit before Tax:}}
{bf:* if Target Profit after Tax = 100}
{bf:* if Tax Rate = 20%}

 Target Profit before Tax = Target Profit after Tax ÷ (1 - Tax Rate)
 Target Profit before Tax = 100 ÷ (1 - 0.20)
 Target Profit before Tax = 100 / (1 - 0.20) = 125

 BEP(Qft) = (TFC + Target Profit before Tax) ÷ (uP - uVC)
 BEP(Qft) = (250 + 125) ÷ (15 - 10)
 BEP(Qft) = (375) / (15 - 10)
 BEP(Qft) = 75

 BEP(Vft) = BEP(Qft) x uP
 BEP(Vft) = 75       x 15
 BEP(Vft) = 1125

{p2colreset}{...}
{marker 032}{bf:{err:{dlgtab:(2) (BEPm) Break-Even Point (Multiple Products}}}

{bf:* Definition:}
{pstd}
* A multi-product project means that a project sells two or more products. The procedure of computing break-even point of a multi product project is a little more complicated than that of a single product project.

{bf:* Formula:}
 BEPm(Q) = TFC ÷ (P_w - uVC_w)
 BEPm(Q) = TFC ÷ CM_w
 BEPm(V) = BEPm(Q) x P_w 
 BEPm(V) = BEPm(Q) ÷ [CM_w/P_w]
 BEPm(V) = BEPm(Q) ÷ CMR_w
 BEPm(V) = TFC ÷ [1 - (uVC_w/P_w)]

where:
 BEPm(Q) = Multiple Products Break-Even Point in Quantity (Units)
 BEPm(V) = Multiple Products Break-Even Point in Value    (Sales)
     TFC = Total Fixed    Cost
      uP = Unit Price
    uP_w = Weighted Average Unit Price
    uP_w = (uP1 × R1) + (uP2 × R2) + (uP3 × R3) +...

     uVC = Unit Variable Cost
   uVC_w = Weighted Average Unit Variable Cost
   uVC_w = (uVC1 × R1) + (uVC2 × R2) + (uVC3 × R3) +...

     Ri = Unit Price Percentage (%) of Product (i)

 Weighted Average Contribution Margin =
  CM_w = (uP_w - uVC_w)

 Weighted Average Contribution Margin Ratio =
  CMR_w = (uP_w - uVC_w) ÷ uP_w

{pstd}
* For computing Break-Even Point of a company with two or more products, we must know the sales percentage of individual products in the total sales mix. This information is used in computing weighted average selling price and weighted average variable costs.

{bf:* Example:}
* A Project has 3 products (A,B,C).
* Total Fixed Costs (TFC) = $50000 
  Unit Price ($), Unit Variable Costs ($), and Unit Price Percentage (%)

----------------------------------------------------
 Product                            A      B      C 
----------------------------------------------------
 Unit Price            (uP)   ($)   200    100    50 
 Unit Variable Costs  (uVC)   ($)   100    75     25 
 Unit Price Ratio       (R)   (%)   {err:20     30     50}
----------------------------------------------------

{bf:* Solution:}

** Total Fixed Costs:
   {err:(TFC) = 50000}

** Weighted Average Unit Price (P_w):
   (P_w) = (200 × {err:0.20}) + (100 × {err:0.30}) + (50 × {err:0.50})
         = 40 + 30 + 25
   {err:(P_w) = 95}

** Weighted Average Unit Variable Cost (uVC_w):
 (uVC_w) = (100 × {err:0.20}) + (75 × {err:0.30}) + (25 × {err:0.50})
         = 20 + 22.50 + 12.50
 {err:(uVC_w) = 55}

 {err:BEPm(Q) = TFC ÷ (P_w - uVC_w)}
 {err:BEPm(Q) = 50000 ÷ (95 – 55)}
         = 50000 ÷ 40
 BEPm(Q) = 1250 (Units)

 The Project will have to sell (1250) units to break-even.
 
 to compute the number of units of each product to be sold:

* BEPm(Q) = Multiple Products Break-Even Point in Quantity (Units)
-——------------------------------—--
  Product       No. of Units 
-——------------------------------—--
    (A)      (1250 × {err:0.20}) = 250
    (B)      (1250 × {err:0.30}) = 375
    (C)      (1250 × {err:0.50}) = 625
-——------------------------------—--
    Total                  = 1250
-——------------------------------—--
 Break-Even Point in Units = 1250
-——------------------------------—--

{pstd}
* As number of units of each individual product to be sold have been computed, break even point in Value, can be computed as follows:

* BEPm(V) = Multiple Products Break-Even Point in Value (Sales):
-——------------------------------—--
  Product       No. of dollars
-——------------------------------—--
    (A)        (250 × 200) = 50000
    (B)        (375 × 100) = 37500
    (C)        (625 × 50)  = 31250
-——------------------------------—--
  Total                    = 118750
-——------------------------------—--
 Break-Even Point in Value = $118750
-——------------------------------—--

{p2colreset}{...}
{marker 033}{bf:{err:{dlgtab:(3) Contribution Margin}}}

{pstd}
* It can be verified by preparing a Contribution Margin income statement as follows:

 Weighted Average Total Variable Cost =

{bf: TVC_w = (BEPm(Q1) x uVC1) + (BEPm(Q2) x uVC2) + (BEPm(Q3) x uVC3) + ...}

 TVC_w = (250 × 100) + (375 × 75) + (625 × 25)
       = $68750

{bf: Total Contribution Margin = Total Revenue - Total Variable Cost}
 
{bf:  TCM_w = sum(uP_w - uVC_w)}
        = 118750 - 68750 = 50000 

{bf: Net Profit = Total Revenue - Total Variable Cost - Total Fixed Cost}

 Net Profit = Total Contribution Margin - Total Fixed Cost
            = 50000  - 50000 
            = 0

----------------------------------------------
{bf:{err:** Weighted Contribution Margin:}}

 +--------------------------+
 |  CM     MCR       CMR    |
 |--------------------------|
 |  40     57.895    42.105 |
 |--------------------------|

  * Total Weighted Average Unit Price         (uPw)    =        95.000
  * Total Weighted Average Unit Variable Cost (uVCw)   =        55.000
  * Total Weighted Contribution Margin        (CMw)    =        40.000
  * Total Weighted Marginal Cost Ratio        (MCRw)   =        57.895
  * Total Weighted Contribution Margin Ratio  (CMRw)   =        42.105
  * Total Break-Even Point (Units)            (BEP[Q]) =      1250.000
  * Total Break-Even Point (Value)            (BEP[V]) =    118750.000
----------------------------------------------------------------------
 *  CMw = Total Weighted Contribution Margin
        = (uPw - uVCw)
        = (95 - 55)
    CMw = 40 $
----------------------------------------------
 * MCRw = Total Weighted Marginal Cost Ratio
        = (uVCw ÷ uPw) x 100
        = (55 ÷ 95) x 100
        = (55 / 95) * 100
   MCRw = 57.895 %
----------------------------------------------
 * CMRw = Total Weighted Contribution Margin Ratio
        = 1-  MCRw (%)
        = (uPw - uVCw) ÷ uPw
        = (95 - 55) ÷ 95
        = 40 / 95 * 100
   CMRw = 42.105 %
----------------------------------------------

{p2colreset}{...}
{marker 034}{bf:{err:{dlgtab:(4) Safety Margin}}}

{bf:* Definition:}
{pstd}
* Safety Margin is the amount of the increase in the target or actual sales from sales that achieve Break-Even Point

{pstd}
* Safety Margin is the amount that can be reduced without losses in sales

{pstd}
* Safety Margin is a measure of risk. It represents the amount of drop in sales which a company can tolerate.
 Higher the safety margin, the more the company can withstand fluctuations in sales. A drop in sales greater than safety margin will cause net loss for the period.

{bf:* Formula:}

{bf:Safety Margin of Quantity = [Expected Quantity - BEP(Q)]}
{err:  SM(Q) = [Q^ - BEP(Q)]}

{bf:Safety Margin of Value    = [Expected Value - BEP(V)]}
{err:  SM(V) = [V^ - BEP(V)]}

{bf:Safety Margin Ratio of Quantity = [Expected Quantity - BEP(Q)] ÷ Expected Quantity × 100}
{err:  SMR(Q) = [Q^ - BEP(Q)] ÷ Q^ × 100}

{bf:Safety Margin Ratio of Value = [Expected Value - BEP(V)] ÷ Expected Value × 100}
{err:  SMR(V) = [V^ - BEP(V)] ÷ V^ × 100}

where:
  SM(Q) = Safety Margin of Quantity
  SM(V) = Safety Margin of Value
 SMR(Q) = Safety Margin Ratio of Quantity
 SMR(V) = Safety Margin Ratio of Value
     Q^ = Expected Quantity
     V^ = Expected Value

------------------------------------------------
{bf:* Example:}
 TFC = 250
 uVC = 10
  uP = 15

{bf:{err:* (1) Break-Even Point:}}

 TR       = TVC       + TFC = 0
 TR       - TVC       - TFC = 0
 (uP x Q) - (uVC x Q) - TFC = 0

 uP x Q = uVC x Q  + TFC
 15 x Q = (10 x Q) + 250

    250 = (15 x Q) - (10 x Q)
    250 =  Q x (15 - 10)

----------------------------------------------
 * BEP(Q) = TFC ÷ (uP - uVC)
          = 250 / (15-10)
          = 50
   BEP(Q) = 50

----------------------------------------------
 * BEP(V) = BEP(Q) x uP
          = 50    x 15
   BEP(V) = 750

----------------------------------------------
** Contribution Margin

 +--------------------------+
 |    CM    MCR       CMR   |
 |--------------------------|
 |    5     66.67    33.33  |
 |--------------------------|

----------------------------------------------
 *   CM = Contribution Margin
        = (uP - uVC)
        = (15 - 10)
     CM = 5 $
----------------------------------------------
 *  MCR = Marginal Cost Ratio
        = (uVC ÷ uP) x 100
        = (10 ÷ 15) x100
        = (10 / 15)*100
    MCR = 66.67 %
----------------------------------------------
 *  CMR = Contribution Margin Ratio
        = 1-  MCR (%)
        = (uP - uVC) ÷ uP
        = (15 - 10) ÷ 15
        = 5 / 15
    CMR = 33.33 %
----------------------------------------------

----------------------------------------------
** Safety Margin

 +------------------------------------------+
 |     TFC     uP    uVC   BEP(Q)    BEP(V) |
 |------------------------------------------|
 |     250    15     10     50        750   |
 |------------------------------------------|
 +------------------------------------------------------------+
 |   Qh    SM_Q        SMR_Q        Vh      SM_V      SMR_V   |
 |------------------------------------------------------------|
 |   70    20         28.5714      1050     300       28.5714 |
 +------------------------------------------------------------+

 *    Qh = Expected Quantity = 70

----------------------------------------------
 *  SM_Q = Safety Margin of Quantity
         = [Qh - BEP(Q)]
    SM_Q = 70 - 50
    SM_Q = 20 
----------------------------------------------
 * SMR_Q = Safety Margin Ratio of Quantity
         = [Qh - BEP(Q)] ÷ Qh × 100
         = (70 - 50) ÷ 70 × 100
         = (70 - 50) / 70 * 100
   SMR_Q = 28.5714
----------------------------------------------
 *    Vh = Expected Value
         = [Qh ×  uP]
         = 70 x 15
      Vh = 1050
----------------------------------------------
 *  SM_V = Safety Margin of Value
         = [Vh - BEP(V)]
         = 1050 - 750
    SM_V = 300
----------------------------------------------
 * SMR_V = Safety Margin Ratio of Value
         = [Vh - BEP(V)] ÷ Vh × 100
         = [1050 - 750] ÷ 1050 × 100
         = (1050 - 750) / 1050 * 100
   SMR_V = 28.5714
----------------------------------------------

{p2colreset}{...}
{marker 035}{bf:{err:{dlgtab:(5) (WACC) Weighted Average Cost of Capital}}}

{bf:* Formula:}
  {bf:WACC = (W1 x R1) + (W2 x R2) + (W3 x R3) +...+ (WJ x RJ)}

where:
 Wi = Relative Weights for Project (i)
 Ri = Discount Rate for Project (i)
  J = Number of Projects

{pstd}
* Assume investor who would like to determine rate of return on 3 investment projects:

{pstd}
* Assume the investments are proportioned accordingly: 25% in investment A, 25% in investment B, and 50% in investment C. The rate of return is 5% for investment A, 6% for investment B, and 2% for investment C.

{pstd}
* (WACC) which would return a total weighted average of 3.75% on the total amount invested. If the investor had made the mistake of using the Arithmetic Average, the incorrect return on investment calculated would have been 4.33%.

* Arithmetic Average =(0.05 + 0.06 + 0.02)/3 = 0.0433 = 4.33%

{bf:* Example:}
  Project        Wi       Ri
-----------------------------
   (A)           25       5%
   (B)           25       6%
   (C)           50       2%
-----------------------------

 WACC = (W1 x R1) + (W2 x R2) + (W3 x R3) +...+ (WJ x RJ)
 WACC = (0.25 * 0.05) + (0.25 * 0.06) + (0.50 * 0.02) = .0375 = 3.75%

{marker 04}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Frank J. Fabozzi & Pamela P. Peterson (2003)
{cmd: "Financial Management and Analysis, 2nd Edition",}
{it:John Wiley & Sons, Inc.}.

{p2colreset}{...}
{marker 05}{bf:{err:{dlgtab:Examples:}}}

 {stata clear all}

 {stata sysuse fbep.dta, clear}

 {stata "fbep up uvc , tfc(stfc) pf(sprofit) tax(stax) qh(qh) pcm list mp id(id) ratio(ratio)"}

 {stata "fbep up uvc , tfc(mtfc) pf(mprofit) tax(mtax) qh(qh) pcm list mp id(id) ratio(ratio)"}
{hline}

 {stata clear all}

 {stata sysuse fbep.dta, clear}

 {stata "fbep up uvc , tfc(mtfc) pf(mprofit) tax(mtax) qh(qh) pcm list mp id(id) ratio(ratio) save(D:\fbep)"}

===========================================================================
     *** Multiple Products Break-Even Point Analysis (BEP) ***
===========================================================================

---------------------------------------------------------------------------
** Contribution Margin

     +-----------------------------------+
     | id    _CM        _MCR        _CMR |
     |-----------------------------------|
  1. |  1      5   66.666667   33.333333 |
     |-----------------------------------|
  2. |  2     20          50          50 |
  3. |  2    7.5          75          25 |
  4. |  2   12.5          50          50 |
     |-----------------------------------|
  5. |  3     20   66.666667   33.333333 |
  6. |  3      5          75          25 |
  7. |  3     10          50          50 |
     |-----------------------------------|
  8. |  4    600        62.5        37.5 |
     +-----------------------------------+
     *  CM = Contribution Margin = (uPw - uVCw)
     * MCR = Marginal Cost Ratio = (uVCw ÷ uPw) × 100
     * CMR = Contribution Margin Ratio = (uPw - uVCw) ÷ uPw × 100

---------------------------------------------------------------------------
** (1) Multiple Products Break-Even Point (BEP)
---------------------------------------------------------------------------
  * Product ( 1 )
  * Total Weighted Average Unit Price         (uPw)    =        15.000
  * Total Weighted Average Unit Variable Cost (uVCw)   =        10.000
  * Total Weighted Contribution Margin        (CMw)    =         5.000
  * Total Weighted Marginal Cost Ratio        (MCRw)   =        66.667
  * Total Weighted Contribution Margin Ratio  (CMRw)   =        33.333
  * Total Break-Even Point (Units)            (BEP[Q]) =        50.000
  * Total Break-Even Point (Value)            (BEP[V]) =       750.000
----------------------------------------------------------------------
  * Product ( 2 )
  * Total Weighted Average Unit Price         (uPw)    =        95.000
  * Total Weighted Average Unit Variable Cost (uVCw)   =        55.000
  * Total Weighted Contribution Margin        (CMw)    =        40.000
  * Total Weighted Marginal Cost Ratio        (MCRw)   =        57.895
  * Total Weighted Contribution Margin Ratio  (CMRw)   =        42.105
  * Total Break-Even Point (Units)            (BEP[Q]) =      1250.000
  * Total Break-Even Point (Value)            (BEP[V]) =    118750.000
----------------------------------------------------------------------
  * Product ( 3 )
  * Total Weighted Average Unit Price         (uPw)    =       100.000
  * Total Weighted Average Unit Variable Cost (uVCw)   =        65.000
  * Total Weighted Contribution Margin        (CMw)    =        35.000
  * Total Weighted Marginal Cost Ratio        (MCRw)   =        65.000
  * Total Weighted Contribution Margin Ratio  (CMRw)   =        35.000
  * Total Break-Even Point (Units)            (BEP[Q]) =        28.571
  * Total Break-Even Point (Value)            (BEP[V]) =      2857.143
----------------------------------------------------------------------
  * Product ( 4 )
  * Total Weighted Average Unit Price         (uPw)    =      1600.000
  * Total Weighted Average Unit Variable Cost (uVCw)   =      1000.000
  * Total Weighted Contribution Margin        (CMw)    =       600.000
  * Total Weighted Marginal Cost Ratio        (MCRw)   =        62.500
  * Total Weighted Contribution Margin Ratio  (CMRw)   =        37.500
  * Total Break-Even Point (Units)            (BEP[Q]) =         8.333
  * Total Break-Even Point (Value)            (BEP[V]) =     13333.333
----------------------------------------------------------------------

---------------------------------------------------------------------------
** (1-1) Safety Margin of Multiple Products (BEP)

     +-----------------------------------------------------------------------+
     | id    _Qh       _SM_Q       _SMR_Q       _Vh       _SM_V       _SMR_V |
     |-----------------------------------------------------------------------|
  1. |  1     70          20    28.571429      1050         300    28.571429 |
     |-----------------------------------------------------------------------|
  2. |  2    300          50    16.666667     60000       10000    16.666667 |
  3. |  2    300         -75          -25     30000       -7500          -25 |
  4. |  2    300        -325   -108.33333     15000      -16250   -108.33333 |
     |-----------------------------------------------------------------------|
  5. |  3    200   188.57143    94.285714     30000   28285.714    94.285714 |
  6. |  3    200   194.28571    97.142857     20000   19428.571    97.142857 |
  7. |  3    200   188.57143    94.285714     10000   9428.5714    94.285714 |
     |-----------------------------------------------------------------------|
  8. |  4   3900   3891.6667    99.786325   6240000   6226666.7    99.786325 |
     +-----------------------------------------------------------------------+
     *     Qh = Expected Quantity
     *  SM(Q) = Safety Margin of Quantity       [Qh - BEP(Q)]
     * SMR(Q) = Safety Margin Ratio of Quantity [Qh - BEP(Q)] ÷ Qh × 100
     *     Vh = Expected Value                  [Qh × _uP]
     *  SM(V) = Safety Margin of Value          [Vh - BEP(V)]
     * SMR(V) = Safety Margin Ratio of Value    [Vh - BEP(V)] ÷ Vh × 100
---------------------------------------------------------------------------

     +-----------------------------------------------------------------+
     | id    _TFC    _uP   _uVC   _uPw   _uVCw      _BEP_Q      _BEP_V |
     |-----------------------------------------------------------------|
  1. |  1     250     15     10     15      10          50         750 |
     |-----------------------------------------------------------------|
  2. |  2   50000    200    100     40      20         250       50000 |
  3. |  2   50000    100     75     30    22.5         375       37500 |
  4. |  2   50000     50     25     25    12.5         625       31250 |
     |-----------------------------------------------------------------|
  5. |  3    1000    150    100     60      40   11.428571   1714.2857 |
  6. |  3    1000    100     75     20      15   5.7142857   571.42857 |
  7. |  3    1000     50     25     20      10   11.428571   571.42857 |
     |-----------------------------------------------------------------|
  8. |  4    5000   1600   1000   1600    1000   8.3333333   13333.333 |
     +-----------------------------------------------------------------+
     *   TFC = Total Fixed Cost
     *    uP = Unit Price
     *   uVC = Unit Variable Cost
     *   uPw = Weighted Average Unit Price
     *  uVCw = Weighted Average Unit Variable Cost
     * BEP_Q = Break-Even Point in Quantity (Units)
     * BEP_V = Break-Even Point in Value    (Sales)

---------------------------------------------------------------------------
** (2) Multiple Products Break-Even Point Target Profit (BEPf)
---------------------------------------------------------------------------
  * Product ( 1 )
  * Total (BEP) Target Profit (Units) =              70.000
  * Total (BEP) Target Profit (Value) =            1050.000
----------------------------------------------------------------------
  * Product ( 2 )
  * Total (BEP) Target Profit (Units) =            1275.000
  * Total (BEP) Target Profit (Value) =          121125.000
----------------------------------------------------------------------
  * Product ( 3 )
  * Total (BEP) Target Profit (Units) =              42.857
  * Total (BEP) Target Profit (Value) =            4285.714
----------------------------------------------------------------------
  * Product ( 4 )
  * Total (BEP) Target Profit (Units) =              91.667
  * Total (BEP) Target Profit (Value) =          146666.667
----------------------------------------------------------------------

---------------------------------------------------------------------------
** (2-1) Safety Margin of Multiple Products Target Profit (BEPf)

     +---------------------------------------------------------------------+
     | id    _Qh      _SM_Qf     _SMR_Qf       _Vh      _SM_Vf     _SMR_Vf |
     |---------------------------------------------------------------------|
  1. |  1     70           0           0      1050           0           0 |
     |---------------------------------------------------------------------|
  2. |  2    300          45          15     60000        9000          15 |
  3. |  2    300       -82.5       -27.5     30000       -8250       -27.5 |
  4. |  2    300      -337.5      -112.5     15000      -16875      -112.5 |
     |---------------------------------------------------------------------|
  5. |  3    200   182.85714   91.428571     30000   27428.571   91.428571 |
  6. |  3    200   191.42857   95.714286     20000   19142.857   95.714286 |
  7. |  3    200   182.85714   91.428571     10000   9142.8571   91.428571 |
     |---------------------------------------------------------------------|
  8. |  4   3900   3808.3333   97.649573   6240000   6093333.3   97.649573 |
     +---------------------------------------------------------------------+
     *     Qh = Expected Quantity
     *  SM(Qf)= Safety Margin of Quantity       [Qh - BEP(Qf)]
     * SMR(Qf)= Safety Margin Ratio of Quantity [Qh - BEP(Qf)] ÷ Qh × 100
     *     Vh = Expected Value                  [Qh × _uP]
     *  SM(Vf)= Safety Margin of Value          [Vh - BEP(Vf)]
     * SMR(Vf)= Safety Margin Ratio of Value    [Vh - BEP(Vf)] ÷ Vh × 100
---------------------------------------------------------------------------

     +------------------------------------------------------------+
     | id   _Profit    _TFC    _uP   _uVC     _BEP_Qf     _BEP_Vf |
     |------------------------------------------------------------|
  1. |  1       100     250     15     10          70        1050 |
     |------------------------------------------------------------|
  2. |  2      1000   50000    200    100         255       51000 |
  3. |  2      1000   50000    100     75       382.5       38250 |
  4. |  2      1000   50000     50     25       637.5       31875 |
     |------------------------------------------------------------|
  5. |  3       500    1000    150    100   17.142857   2571.4286 |
  6. |  3       500    1000    100     75   8.5714286   857.14286 |
  7. |  3       500    1000     50     25   17.142857   857.14286 |
     |------------------------------------------------------------|
  8. |  4     50000    5000   1600   1000   91.666667   146666.67 |
     +------------------------------------------------------------+
     * Profit = Target Profit
     *    TFC = Total Fixed Cost
     *    TFC = Total Fixed Cost
     *     uP = Unit Price
     *    uVC = Unit Variable Cost
     * BEP_Qf = Break-Even Point Target Profit (Units)
     * BEP_Vf = Break-Even Point Target Profit (Value)

---------------------------------------------------------------------------
** (3) Multiple Products Break-Even Point Target Profit before Tax (BEPx)
---------------------------------------------------------------------------
  * Product ( 1 )
  * Total (BEP) Target Profit before Tax (Units) =         72.222
  * Total (BEP) Target Profit before Tax (Value) =       1083.333
----------------------------------------------------------------------
  * Product ( 2 )
  * Total (BEP) Target Profit before Tax (Units) =       1281.250
  * Total (BEP) Target Profit before Tax (Value) =     121718.750
----------------------------------------------------------------------
  * Product ( 3 )
  * Total (BEP) Target Profit before Tax (Units) =         46.429
  * Total (BEP) Target Profit before Tax (Value) =       4642.857
----------------------------------------------------------------------
  * Product ( 4 )
  * Total (BEP) Target Profit before Tax (Units) =         96.053
  * Total (BEP) Target Profit before Tax (Value) =     153684.211
----------------------------------------------------------------------

---------------------------------------------------------------------------
** (3-1) Safety Margin of Multiple Products Target Profit before Tax (BEPx)

     +-------------------------------------------------------------------------+
     | id    _Qh       _SM_Qx      _SMR_Qx       _Vh       _SM_Vx      _SMR_Vx |
     |-------------------------------------------------------------------------|
  1. |  1     70   -2.2222223   -3.1746032      1050   -33.333334   -3.1746032 |
     |-------------------------------------------------------------------------|
  2. |  2    300        43.75    14.583333     60000         8750    14.583333 |
  3. |  2    300      -84.375      -28.125     30000      -8437.5      -28.125 |
  4. |  2    300     -340.625   -113.54167     15000    -17031.25   -113.54167 |
     |-------------------------------------------------------------------------|
  5. |  3    200    181.42857    90.714286     30000    27214.286    90.714286 |
  6. |  3    200    190.71429    95.357143     20000    19071.429    95.357143 |
  7. |  3    200    181.42857    90.714286     10000    9071.4286    90.714286 |
     |-------------------------------------------------------------------------|
  8. |  4   3900    3803.9474    97.537112   6240000    6086315.8    97.537112 |
     +-------------------------------------------------------------------------+
     *     Qh = Expected Quantity
     *  SM(Qx)= Safety Margin of Quantity       [Qh - BEP(Qx)]
     * SMR(Qx)= Safety Margin Ratio of Quantity [Qh - BEP(Qx)] ÷ Qh × 100
     *     Vh = Expected Value                  [Qh × _uP]
     *  SM(Vx)= Safety Margin of Value          [Vh - BEP(Vx)]
     * SMR(Vx)= Safety Margin Ratio of Value    [Vh - BEP(Vx)] ÷ Vh × 100
---------------------------------------------------------------------------

     +-------------------------------------------------------------------+
     | id   _Profit   _Tax    _TFC    _uP   _uVC     _BEP_Qx     _BEP_Vx |
     |-------------------------------------------------------------------|
  1. |  1       100     .1     250     15     10   72.222222   1083.3333 |
     |-------------------------------------------------------------------|
  2. |  2      1000     .2   50000    200    100      256.25       51250 |
  3. |  2      1000     .2   50000    100     75     384.375     38437.5 |
  4. |  2      1000     .2   50000     50     25     640.625    32031.25 |
     |-------------------------------------------------------------------|
  5. |  3       500     .2    1000    150    100   18.571429   2785.7143 |
  6. |  3       500     .2    1000    100     75   9.2857143   928.57143 |
  7. |  3       500     .2    1000     50     25   18.571429   928.57143 |
     |-------------------------------------------------------------------|
  8. |  4     50000    .05    5000   1600   1000   96.052632   153684.21 |
     +-------------------------------------------------------------------+
     * Profit = Target Profit
     *    Tax = Tax Rate
     *    TFC = Total Fixed Cost
     *     uP = Unit Price
     *    uVC = Unit Variable Cost
     * BEP_Qx = Break-Even Point Target Profit before Tax (Units)
     * BEP_Vx = Break-Even Point Target Profit before Tax (Value)
---------------------------------------------------------------------------

*** Save Break-Even Point Analysis ***
*** (BEP) Results File Has Been saved in:

 Data Directory:   D:\Stata\SSC

 Open File:        D:\fbep.csv
--------------------------------------------------

{p2colreset}{...}
{marker 06}{bf:{err:{dlgtab:Authors}}}

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

{bf:{err:{dlgtab:FBEP Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih & Sahra Khaleel A. Mickaiel (2016)}{p_end}
{p 1 10 1}{cmd:FBEP: "Stata Module to Estimate Financial Break-Even Point Analysis (BEP) for Single and Multiple Products"}{p_end}

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

