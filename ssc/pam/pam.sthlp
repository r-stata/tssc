{smcl}
{hline}
{cmd:help: {helpb pam}}{space 50} {cmd:dialog:} {bf:{dialog pam}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf:pam: Policy Analysis Matrix (PAM)}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb pam##01:Syntax}{p_end}
{p 5}{helpb pam##02:Options}{p_end}
{p 5}{helpb pam##03:Description}{p_end}
{p 5}{helpb pam##04:Saved Results}{p_end}
{p 5}{helpb pam##05:References}{p_end}

{p 1}*** {helpb pam##06:PAM Applications}{p_end}

{p 1}*** {helpb pam##07:Examples}{p_end}

{p 5}{helpb pam##08:Authors}{p_end}

{p2colreset}{...}
{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 5 5 6}
{opt pam} Pd Pw {ifin} , {err: [ {opt dtc(vars)} {opt wtc(vars)} {opt ddf(vars)} {opt wdf(vars)}  {err:]}} {opt save(file_name)} {opt nolist} {p_end}

{p2colreset}{...}
{marker 02}{bf:{err:{dlgtab:Options}}}

{col 3}{varlist}{col 20}Two Variables only Pd & Pw respectively:
{col 24}1- {opt (Pd)} Private Total Revenue (Financial Price)
{col 24}2- {opt (Pw)} Social  Total Revenue (Economic Price)

{col 3}{opt dtc(vars)}{col 20}Private Tradable Inputs Costs (Financial Price)
{col 3}{opt wtc(vars)}{col 20}Social  Tradable Inputs Costs (Economic Price)
{col 20}variables in both {opt dtc(vars)} and {opt wtc(vars)} must be in the same order respectively

{col 3}{opt ddf(vars)}{col 20}Private Domestic Factors Costs (Financial Price)
{col 3}{opt wdf(vars)}{col 20}Social  Domestic Factors Costs (Economic Price)
{col 20}variables in both {opt ddf(vars)} and {opt wdf(vars)} must be in the same order respectively

{col 3}{opt nolist}{col 20}Don't Display All Indicators.
{col 3}{opt save(file_name)}{col 20}Save PAM Model Results in File (*.txt).

{bf:{err:*** Important Notes:}}
{cmd:pam} generates some variables names starting with prefix "_", i.e,:
{cmd:_PVA, _SVA, _NPCO, _NPRO, _NPCI, _NPRI, _EPC, _EPR}
{cmd:So, you must avoid to include variables names with these prefixes}

{p2colreset}{...}
{marker 03}{bf:{err:{dlgtab:Description}}}

{col 4}{cmd:pam} estimates Policy Analysis Matrix (PAM).
{p 2 2 2}Policy Analysis Matrix Describes the distorions in the market price of inputs and outputs
to know support or taxes imposed on the producer and consumer, and indicators to measure economic efficiency
and comparative advantage. PAM consists of revenues and costs, represented in Tradable inputs and domestic
factors, via using both domestic prices and world prices, 
the difference between domestic prices and world (border) prices is called transfers, whether surplus (support), or (deficit) taxes.{p_end} 
{p 2 2 2}(PAM) aims to analyze the impact of governmental intervention policies. represented in the policies for goods, such as support and taxes on inputs and outputs.{p_end} 

{bf:{err:** Components of Policy Analysis Matrix (PAM)}}
{bf:(1) Production Revenue:}
{p 2 2 2}- value of main product is calculated by domestic price when estimating value added at domestic prices{p_end} 
{p 2 2 2}- value of main product is calculated by border price when estimating value added at world prices{p_end} 
{p 2 2 2}- value of secondary product is calculated by domestic price if has no foreign trade{p_end} 
{p 2 2 2}- value of secondary product is calculated by border price if has foreign trade{p_end} 
{bf:(2) Production Costs: It is divided into two sections:}
  {bf:(A) Tradable Inputs that have foreign trade:}
   (Seeds - chemical fertilizers - Pesticides - Fuel )
  {bf:(B) Domestic Factors:}
   (Manure - Feed - Incidental Expenses - Workers Wages - Machines Wages - Rent - Capital)
{p 2 2 2}Working capital consists of: value of inventory, which is enough liquid cash to meet cash expenses
such as salaries, administrative expenses and marketing, and others, consumption of electricity, water, maintenance, transport and transfer ... etc.{p_end} 

{bf:{err:** Structure of Policy Analysis Matrix (PAM)}}
 {bf:{hline 70}}
 {bf:{err:                      Policy Analysis Matrix (PAM)}}
 {bf:{hline 70}}
 {bf:*      Item        |  Revenue  |  Tradable  |  Domestic |   Profit   *}
 {bf:*                  |           |   Inputs   |  Factors  |            *}
 {bf:{hline 70}}
 {bf:* Private Price    |     {bf:{red:A}}     |      {bf:{red:B}}     |     {bf:{red:C}}     |      {bf:{red:D}}     *}
 {bf:{hline 70}}
 {bf:* Social Price     |     {bf:{red:E}}     |      {bf:{red:F}}     |     {bf:{red:G}}     |      {bf:{red:H}}     *}
 {bf:{hline 70}}
 {bf:* Transfer         |     {bf:{red:I}}     |      {bf:{red:J}}     |     {bf:{red:K}}     |      {bf:{red:L}}     *}
 {bf:{hline 70}}

Where :
{bf:{err:** Private Price:}}
  A = Private Total Revenue at (Financial Price)
  B = Private Tradable Inputs Costs
  C = Private Domestic Factors Costs
  D = Private Profit at (Financial Price)
{bf:{err:** Social Price:}}
  E = Social Total Revenue at (Economic Price)
  F = Social Tradable Inputs Costs
  G = Social Domestic Factors Costs
  H = Social Profits at (Economic Price)

================================================================
{bf:{err:** (PAM) Economic Indicators:}}
{col 4}{cmd:pam} can estimate 30 Economic Indicators as follows:

 1  Private Value Added	   (PVA) = A - B
 2  Social Value Added	   (SVA) = E - F
 3  Private Profit	    (PP) = D = A - B - C
 4  Social Profit	    (SP) = H = E - F - G
 5  Private Cost	    (PC) = B + C
 6  Social Cost		    (SC) = F + G
 7  Output Transfer	    (OT) = I = A - E
 8  Input Transfer	    (IT) = J = B - F
 9  Factor Transfer 	    (FT) = K = C - G
 10 Net Transfer	    (NT) = L = D - H = I - J - K
 11 Economic Surplus Ratio (ESR) = L ÷ D
 12 Nominal Protection Coefficient on Tradable Outputs (NPCO) = A ÷ E
 13 Nominal Protection Rate on Tradable Outputs        (NPRO) = NPCO - 1
 14 Nominal Protection Coefficient on Tradable Inputs  (NPCI) = B ÷ F
 15 Nominal Protection Rate on Tradable Inputs         (NPRI) = NPCI - 1
 16 Effective Protection Coefficient     (EPC) = (A - B) ÷ (E - F)
 17 Effective Protection Rate            (EPR) = EPC - 1
 18 Domestic Resource Cost               (DRC) = G ÷ (E - F)
 19 Private Cost Ratio                   (PCR) = C ÷ (A - B)
 20 Profitability Coefficient            (PCO) = (ABC) ÷ (EFG) = D ÷ H
 21 Subsidy Ratio to Producer            (SRP) = (D - H) ÷ E = L ÷ E
 22 Private Cost-Benefit Ratio          (PCBR) = (B + C) ÷ A
    = Private Cost-Revenue Ratio        (PCRR) = (A - D) ÷ A
 23 Social Cost-Benefit Ratio           (SCBR) = (F + G) ÷ E
    = Social Cost-Revenue Ratio         (SCRR) = (E - H) ÷ E
 24 Private Profitability Ratio          (PPR) = (A - B - C) ÷ A = D ÷ A
 25 Social Profitability Ratio           (SPR) = (E - F - G) ÷ E = H ÷ E
 26 Private Cost Adjustment coefficient (PCAC) = A ÷ (B + C) - 1
 27 Social Cost Adjustment coefficient  (SCAC) = E ÷ (F + G) - 1
 28 Private Value Added Ratio           (PVAR) = (A - B) ÷ A
 29 Social Value Added Ratio            (SVAR) = (E - F) ÷ E
 30 Domestic Factors Ratio             (DOFAR) = C ÷ G 
================================================================

{bf:{err:** Interpretation of (PAM) Results:}}

{bf:{err:** (1) Private Value Added (PVA) = A - B}}
  (PVA) = Revenue - Tradable Inputs (Pd)

{bf:{err:** (2) Social Value Added (SVA) = E - F}}
  (SVA) = Revenue - Tradable Inputs (Pw)

{bf:{err:** (3) Private Profit (PP) = D = A - B - C}}
  (PP) = Revenue - Tradable Inputs - Domestic Factors (Pd)

{bf:{err:** (4) Social Profit (SP) = H = E - F - G}}
  (SP) = Revenue - Tradable Inputs - Domestic Factors (Pw)

{bf:{err:** (5) Private Cost (PC) = B + C}}
 (PC) Tradable Inputs + Domestic Factors (Pd)

{bf:{err:** (6) Social Cost (SC) = F + G}}
  (SC) Tradable Inputs (Pw) + Domestic Factors (shadow price)
  - Tradable Inputs are evaluated at (FOB) for export price or (CIF) for import price
  - Domestic Factors are evaluated at Shadow Price.

{bf:{err:** (7) Output Transfer (OT) = I = A - E}}
  (OT) = Revenue (Pd) - Revenue (Pw)
  - Increasing Output Transfer (surplus) means producer support (+) Producer Subsidy
  - Decreasing Output Transfer (deficit) means taxes on producer (-) Producer Taxes

{bf:{err:** (8) Input Transfer (IT) = J = B - F}}
  (IT) = Tradable Inputs (Pd) - Tradable Inputs (Pw)

  - Increasing Input Transfer (surplus) means taxes on producer (+) Producer Taxes
    Because of increasing Tradable Inputs prices
  - Decreasing Input Transfer (deficit) means producer support (-) Producer Subsidy
    Because of decreasing Tradable Inputs prices

{bf:{err:** (9) Factor Transfer (FT) = K = C - G}}
  (FT) = Domestic Factors (Pd) - Domestic Factors (shadow price)

  - Increasing Factor Transfer (surplus) means taxes on producer (+) Producer Taxes
    Because of increasing Domestic Factors prices
  - Decreasing Factor Transfer (deficit) means producer support (-) Producer Subsidy
    Because of decreasing Domestic Factors prices

{bf:{err:** (10) Net Transfer (NT) = L = D - H = I - J - K}}
   (NT) = Private Profit (Pd) - Social Profit (Pw)
   
  - Increasing Net Transfer (surplus) means producer support (+) Producer Subsidy
    Because of increasing Domestic Price than World Price
  - Decreasing Net Transfer (deficit) means taxes on producer (-) Producer Taxes
    Because of decreasing  Domestic Price than World Price

{bf:{err:** (11) Economic Surplus Ratio (ESR) = L ÷ D}}
   (ESR) = Net Transfer (NT) ÷ Private Profit (Pd)

{bf:{err:** (12) Nominal Protection Coefficient on Tradable Outputs (NPCO) = A ÷ E}}
   (NPCO) = Domestic Price ÷ World (Border) Price

 - Gross NPC = Domestic Price (Pd) ÷ World Price (Pw) [Unadjusted World (Border) Price]
 - Net   NPC = Domestic Price (Pd) ÷ World Price (Pw) [  Adjusted World (Border) Price]

* (NPCO = 1): Neutral Policy, where state does not impose taxes on producer or consumer,
              and do not take any protectionist policy to support the producer or the consumer.
* (NPCO > 1): Protection Policy to support the producer, because domestic price exceeds world price,
              and therefore supports the producer and impose taxes on consumer.
* (NPCO < 1): Taxing Policy on producer if commodity is export oriented,
              and support or Protection Policy for consumer if commodity import oriented,
              due to the decrease in domestic market prices.

{bf:{err:** (13) Protection Rate Coefficient on Tradable Outputs (NPRO) = NPCO - 1}}
   (NPRO) = (NPCO) - 1
 
* (NPRI = 0): Neutral Policy, state does not impose taxes and does not support producer or consumer.
* (NPRI > 0): Protection Policy to support producer, and Taxing Policy for consumer.
* (NPRI < 0): Taxing Policy on producer, and Protection Policy to support consumer.

{bf:{err:** (14) Nominal Protection Coefficient on Tradable Inputs (NPCI) = B ÷ F}}
   (NPCI) = Tradable Outputs (Pd) ÷ Tradable Outputs (Pw)

* (NPCI = 1): Neutral Policy, state not subsidies or impose taxes on Tradable Inputs prices.
* (NPCI > 1): Taxing Policy on producer to impose taxes on Tradable Inputs (Negative Transfer),
              because the prices of domestic Tradable Inputs are greater than the world prices.
* (NPCI < 1): Protection Policy to support Tradable Inputs, and it is called Positive Transfer,
              because the prices of domestic Tradable Inputs are less than world prices.

{bf:{err:** (15) Nominal Protection Rate on Tradable Inputs (NPRI) = NPCI - 1}}
* (NPRI = 0): Neutral Policy, which state not subsidies or impose taxes on Tradable Inputs prices.
* (NPRI > 0): Taxing Policy on prices of Tradable Inputs.
* (NPRI < 0): Protection Policy to support prices of Tradable Inputs.

{bf:{err:** (16) Effective Protection Coefficient (EPC) = (A - B) ÷ (E - F)}}
   (EPC) = Value Added (Pd) ÷ value added (Pw)

 - Gross EPC = Value Added (Pd) ÷ Value Added (Pw) [Unadjusted World (Border) Price]
 - Net   EPC = Value Added (Pd) ÷ Value Added (Pw) [  Adjusted World (Border) Price]

* (EPC = 1): Neutral Policy , where state does not impose taxes on the producer or consumer,
             and does not take any Protection Policy to support producer or consumer.
             This shows that value-added at local price equal to value added at border price
* (EPC > 1): Protection Policy to support producer, because domestic price exceeds world price,
             and therefore supports producer and impose a tax on consumer.
* (EPC < 1): Taxing Policy on producer if commodity is export oriented,
             and support or Protection Policy for consumer if commodity import oriented,
             due to the decrease in domestic market prices.

 EPC shows the joint effect of policy transfer affecting both
 Tradable outputs and Tradable inputs.
 Both EPC and NPC ignore the effects of transfers in factor market and therefore
 do not reflect the full extent of incentives to producers.

{bf:{err:** (17) Effective Protection Rate (EPR) = EPC - 1}}
* (EPR = 0): Neutral Policy, meaning failure to protect or to impose taxes on producer and consumer.
* (EPR > 0): Protection Policy to support producer, and Taxing Policy for consumer.
* (EPR < 0): Taxing Policy on producer , and Protection Policy to support consumer.

{bf:{err:** (18) Domestic Resource Cost (DRC) = G ÷ (E - F)}}
   (DRC) = Domestic Factors (shadow price) ÷ (Revenue - Tradable Inputs) (Pw)
   (DRC) = Domestic Factors (shadow price) ÷  Value Added (Pw)
 
 DRC illustrates Comparative Advantage of the commodity at the level of national economy,
  in terms of the possibility of continuity in domestic production, or to rely on imports.
  Thus, the activities of low value for the cost of local resources to be more efficient,
   and those resources should be directed in the production process.

* (DRC < 1): Comparative Advantage in production of commodity.
             Because costs of local resources at shadow prices less than value added at world price.
             It is advisable to increase local production and decrease dependence on imports.
             where get profits if commodity is exported, or provide foreign currency if imported.
* (DRC > 1): No Comparative Advantage in the production of commodity.
             Because costs of local resources at shadow prices higher than value added at world price.
             It is advisable to decrease production and increase dependence on imports.
* (DRC = 1): balance status, because the state dont gain or sace of local production of that commodity.

 There is another criterion for judging the comparative advantage:
 Shadow Exchange Rate (SER):
	SER = EER ÷ OER
	EER = Effective Exchange Rate
	OER = Official Exchange Rate
 
* (SER > DRC): Comparative Advantage:    must increase production and increase export commodity.
* (SER < DRC): No Comparative Advantage: must decrease production and increase import commodity.

{bf:{err:** (19) Private Cost Ratio (PCR) = C ÷ (A - B)}}
   (PCR) = Domestic Factors ÷ (Revenue - Tradable Inputs) (Pd)
   (PCR) = Domestic Factors ÷  Value Added (Pd)

 (PCR) is a criterion to measure Competitive Advantage of the commodity at domestic prices.

* (PCR < 1): Competitive Advantage in the production of commodity.
             Because costs of Domestic Factors at domestic prices less than Private Value Added.
             (PCR) clarifies that spending on Domestic Factors is less than value added,
             and the rest of the ratio represents profits for producer.
* (PCR > 1): No Competitive Advantage in the production of commodity.
             Because costs of Domestic Factors at domestic prices greater than Private Value Added.
             (PCR) clarifies that spending on Domestic Factors is more than value added,
             and the rest of the ratio represents losses for producer.
* (PCR = 1): No Competitive Advantage in the production of commodity.
             Because costs of Domestic Factors at domestic prices equal Private Value Added.

{bf:{err:** (20) Profitability Coefficient (PCO) = (A - B - C) ÷ (E - F - G) = D ÷ H}}
   (PCO) = Private Profit (Pd) ÷ Social Profit (Pw)
   
 (PCO) measures all transfers effects on Private Profit
 
* (PCO < 1): Low profitability of producer with respect to state
             (policy of imposing taxes on the producer).
             Because Private Profit of producer is less than Social Profit of state.
* (PCO > 1): High profitability of producer with respect to state
             (Protection Policy to support producer).
             Because Private Profit of producer is greater than Social Profit of state.

{bf:{err:** (21) Subsidy Ratio to Producer (SRP) = (D - H) ÷ E = L ÷ E}}
   (SRP) = {Private Profit (Pd) ÷ Social Profit (Pw)} ÷ Revenue (Pw)

 (SRP) measures all transfers effects on increasing or decreasing Social Revenue,
       and measures the net transfers of producer as a ratio social revenue.

* (SRP = 0): balance status, because of no transfers.
* (SRP < 0): Taxing Policy on producer,
             thus increasing net transfers to state at the expense of producer.
* (SRP > 0): Protection Policy to producer,
             thus increasing net transfers to producer at the expense of state.

{bf:{err:** (22) Private Cost-Benefit Ratio (PCBR) = (B + C) ÷ A}}
   (PCBR) = (Tradable Inputs + Domestic Factors) ÷ Revenue (Pd)
 (PCBR) measures the ratio of costs revenue with respect to producer at domestic price.
 (PCBR) is called also as: Private Cost-Revenue Ratio (PCRR) = (A-D) / A

* (PCBR < 1): Costs < Revenue (producer gains).
* (PCBR > 1): Costs > Revenue (producer losses).
* (PCBR = 1): Costs = Revenue (producer does not achieve either gains or losses).

{bf:{err:** (23) Social Cost-Benefit Ratio (SCBR) = (F + G) ÷ E}}
   (SCBR) = (Tradable Inputs + Domestic Factors) ÷ Revenue (Pw)
 (SCBR) measures the ratio of costs revenue at with respect to state world price.
 (SCBR) is called also as: Social Cost-Revenue Ratio (SCRR) = (E-H) / E

* (SCBR < 1): Costs < Revenue (state gains).
* (SCBR > 1): Costs > Revenue (state losses).
* (SCBR = 1): Costs = Revenue (state does not achieve either gains or losses).

{bf:{err:** (24) Private Profitability Ratio (PPR) = (A - B - C) ÷ A = D ÷ A}}
   (PPR) = Profit ÷ Revenue (Pd)

 (PPR) measures the ratio of profit to revenue with respect to producer at domestic price.
* (PPR < 1): Profit < Costs (low profits).
* (PPR > 1): Profit > Costs (high profits).

{bf:{err:** (25) Social Profitability Ratio (SPR) = (E - F - G) ÷ E = H ÷ E}}
   (SPR) = Profit ÷ Revenue (Pw)

 (SPR) measures the ratio of profit to revenue with respect to state at world price.
* (SPR < 1): Profit < Costs (low profits).
* (SPR > 1): Profit > Costs (high profits).

{bf:{err:** (26) Private Cost Adjustment coefficient (PCAC) = A ÷ (B + C) - 1}}
   (PCAC) =(Revenue ÷ Costs) - 1 (Pd)

 (PCAC) measures the coverage ratio of revenue to costs with respect to producer at domestic price.
 
* (PCAC = 0): Revenue = Costs: producer does not achieve either gains or losses.
* (PCAC < 1): Profit < Costs.
* (PCAC > 1): Profit > Costs.

{bf:{err:** (27) Social Cost Adjustment coefficient (SCAC) = E ÷ (F + G) - 1}}
   (SCAC) =(Revenue ÷ Costs) - 1 (Pd)

 (SCAC) measures the coverage ratio of revenue to costs with respect to state at world price.
* (SCAC = 0): Revenue = Costs: state does not achieve either gains or losses.
* (SCAC < 1): Profit < Costs.
* (SCAC > 1): Profit > Costs.

{bf:{err:** (28) Private Value Added Ratio (PVAR) = (A - B) ÷ A}}
   (PVAR) = (Revenue - Tradable Inputs) ÷ Revenue (Pd)

 (PVAR) measures the coverage ratio of value added to revenue with respect to producer at domestic price.
 * Increase (PVAR): shows Increasing Value Added contribution in Private Revenue of the producer.
 * Decrease (PVAR): shows Decreasing Value Added contribution in Private Revenue of the producer.

{bf:{err:** (29) Social Value Added Ratio (SVAR) = (E - F) ÷ E}}
   (SVAR) = (Revenue - Tradable Inputs) ÷ Revenue (Pw)

 (SVAR) measures the coverage ratio of value added to revenue with respect to state at domestic price.
 * Increase (SVAR): shows Increasing Value Added contribution in Private Revenue of the state.
 * Decrease (SVAR): shows Decreasing Value Added contribution in Private Revenue of the state.

{bf:{err:** (30) Domestic Factors Ratio (DOFAR) = C ÷ G}}
   (DOFAR) = Domestic Factors (Pd) ÷ Domestic Factors (Pw)

 (DOFAR) measures the ratio coverage of Domestic Factors at domestic price
       to Domestic Factors at shadow price

* (DOFAR = 1): Producer buys Domestic Factors at domestic prices equal to world prices.
* (DOFAR < 1): Producer buys Domestic Factors at domestic prices less than world prices.
               Positive transfer to producer, and Negative transfers to state
* (DOFAR > 1): Producer buys Domestic Factors at domestic prices greater than world prices.
               Positive transfer to state, and Negative transfers to producer

{p2colreset}{...}
{marker 04}{bf:{err:{dlgtab:Saved Results}}}

{p 2 4 2 }{cmd:pam} saves the following results in {cmd:e()}:

Matrixes       
{col 4}{cmd:e(pam)}{col 20}PAM Model Results

{marker 05}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Bale, Malcolm D. & Ernst Lutz (1981)
{cmd: "Price Distortions in Agriculture and Their Effects: An International Comparison",}
{it:Am. J. Ag. Econ., Vol. 63, No. 1, Feb., 1981}; 8-22.

{p 4 8 2}Monke, Eric & Scott R. Perason (1989)
{cmd: "The Policy Analysis Matrix For Agricultural Development",}
{it:Cornell Univ. Press, London, UK}.

{p 4 8 2}Sadoulet, Elisabeth & Alain Dejanvry (1993)
{cmd: "Quantitative Development Policy Analysis",}
{it:Agric. and Resource Econ., Univ. of California, USA}.

{p 4 8 2}Tsakok, Isabelle (1990)
{cmd: "Agricultural Price Policy: A Practitioner's Guide to Partial Equilibrium Analysis",}
{it:Cornell Univ. Press, London, UK}.

{p2colreset}{...}
{marker 06}{bf:{err:{dlgtab:PAM Applications:}}}

{bf:{hline 85}}
* Rice Border Price
{bf:{hline 85}}
FOB ($/ton)					 150		1	= 1
Freight & Insurance ($/ton)			 20		2	= 2
CIF Import Price ($/ton)			 170		3	= 1 + 2
Exchange rate (Rp/$)				 9,000		4	= 4
Exchange rate premium (%)			 0.0		5	= 5
Equilibrium exchange rate (Rp/$)		 9,000		6	= 4(1 + 5)
CIF Import Price (Rp/ton)			 1,530,000	7	= 3 * 6
Weight conversion factor (kg/ton)		 1,000		8	= 8
CIF Import Price (Rp/kg)			 1,530		9	= 7 / 8
Transportation costs to wholesale market (Rp/kg) 133		10	= 10
Value before processing (Rp/kg)			 1,663		11	=  9 + 10
Processing conversion factor (%)		 0.64		12	= 12
Cost of rice milling net of value of rice bran	 50		13	= 13
Distribution costs to farm (Rp/kg)	50	 		14	= 14
Import parity value at farm gate (Rp/kg)	 964.3		15	= 11*12-13-14
Import parity value at farm gate (Rp/ton)	 {bf:0.964}	     16	     = 15/1000
{bf:{hline 85}}

{bf:{hline 71}}
Item	Type		     Quantity	P-Price	S-Price	P-Value	S-Value
{bf:{hline 71}}
{bf:* Tradable Inputs:}
   Fertilizer	
       Urea			240	1.1	1.1	264.0	264.0
       SP-36			100	1.4	1.4	140.0	140.0
       KCl			20	1.6	1.6	32.0	32.0
       ZA			150	1.0	1.0	150.0	150.0
       Liquid Pesticide		3	25.0	33.4	75.0	100.2
       Granulated Pesticide	15	8.0	10.0	120.0	150.0
   Seed				35	2.5	2.5	87.5	87.5
   Fuel				65	1.5	1.5	97.5	97.5
-----------------------------------------------------------------------
{bf:{err:* Total Tradable Inputs}}                                 {bf:{err:966.0   1021.2}}
{bf:{hline 71}}
{bf:* Domestic Factors:}
   Labor	
       Seedbed Prep		100	1.6	1.6	160.0	160.0
       Crop Care		600	1.6	1.6	960.0	960.0
       Harvesting		200	1.6	1.6	320.0	320.0
       Threshing		150	1.6	1.6	240.0	240.0
   Capital	
    	Working Capital	2000	5%	8%	100	160
	Tractor Services	20	12.5	12.5	250.0	250.0
	Thresher		35	1.5	1.5	52.5	52.5
-----------------------------------------------------------------------
{bf:{err:* Total Domestic Factors}}                                {bf:{err:2082.5  2142.5}}
{bf:{hline 71}}
{bf:{err:* Total Revenue}}                 6000    1.205   {bf:0.964}   {bf:{err:7230.0  5784.0}}
{bf:{hline 71}}

 {bf:{hline 70}}
 {bf:{err:                      Policy Analysis Matrix (PAM)}}
 {bf:{hline 70}}
 {bf:*      Item        |  Revenue  |  Tradable  |  Domestic |   Profit   *}
 {bf:*                  |           |   Inputs   |  Factors  |            *}
 {bf:{hline 70}}
 {bf:* Private Price    |     {bf:{red:A}}     |      {bf:{red:B}}     |     {bf:{red:C}}     |      {bf:{red:D}}     *}
 {bf:{hline 70}}
 {bf:* Social Price     |     {bf:{red:E}}     |      {bf:{red:F}}     |     {bf:{red:G}}     |      {bf:{red:H}}     *}
 {bf:{hline 70}}
 {bf:* Transfer         |     {bf:{red:I}}     |      {bf:{red:J}}     |     {bf:{red:K}}     |      {bf:{red:L}}     *}
 {bf:{hline 70}}

 {bf:{hline 70}}
 {bf:*      Item        |  Revenue  |   Tradable  | Domestic |  Profit    *}
 {bf:*                  |           |    Inputs   | Factors  |            *}
 {bf:{hline 70}}
 {bf:* Private Price    |  {bf:{red:7230.0}}   |   {bf:{red:966.0}}     |  {bf:{red:2082.5}}  |  {bf:{red:4181.5}}    *}
 {bf:{hline 70}}
 {bf:* Social Price     |  {bf:{red:5784.0}}   |   {bf:{red:1021.2}}    |  {bf:{red:2142.5}}  |  {bf:{red:2620.3}}    *}
 {bf:{hline 70}}
 {bf:* Transfer         |  {bf:{red:1446.0}}   |   {bf:{red:-55.2}}     |  {bf:{red:-60.0}}   |  {bf:{red:1561.2}}    *}
 {bf:{hline 70}}

{bf:{hline 82}}
 1  Private Value Added		     (PVA) = A – B		     = 6264.0
 2  Social Value Added		     (SVA) = E - F		     = 4762.8
 3  Private Profit	 	      (PP) = D= A - B - C	     = 4181.5
 4  Social Profit	 	      (SP) = H= E - F - G	     = 2620.3
 5  Private Cost	 	      (PC) = B + C		     = 3048.5
 6  Social Cost	 		      (SC) = F + G		     = 3163.7
 7  Output Transfer	 	      (OT) = I= A – E		     = 1446.0
 8  Input Transfer	 	      (IT) = J= B – F		     = -55.20
 9  Factor Transfer	 	      (FT) = K= C – G		     = -60.00
 10 Net Transfer	 	      (NT) = L= D – H = I - J - K    = 1561.2
 11 Economic Surplus Ratio           (ESR) = L ÷ D		     = 0.37
 12 NPC on Tradable Outputs	    (NPCO) = A ÷ E		     = 1.25
 13 NPR on Tradable Outputs	    (NPRO) = NPCO – 1		     = 0.25
 14 NPC on Tradable Inputs	    (NPCI) = B ÷ F		     = 0.95
 15 NPR on Tradable Inputs	    (NPRI) = NPCI  - 1		     = -0.05
 16 Effective Protection Coefficient (EPC) = (A - B) ÷ (E - F)	     = 1.32
 17 Effective Protection Rate	     (EPR) = EPC – 1		     = 0.32
 18 Domestic Resource Cost	     (DRC) = G ÷ (E - F)	     = 0.45
 19 Private Cost Ratio	 	     (PCR) = C ÷ (A - B)	     = 0.33
 20 Profitability Coefficient	     (PCO) = (A-B-C) ÷ (E-F-G) = D÷H = 1.60
 21 Subsidy Ratio to Producer	     (SRP) = (D - H) ÷ E = L ÷ E     = 0.27
 22 Private Cost Benefit Ratio	    (PCBR) = (B + C) ÷ A	     = 0.42
 23 Social Cost Benefit Ratio	    (SCBR) = (F + G) ÷ E	     = 0.55
 24 Private Profitability Ratio	     (PPR) = (A - B - C) ÷ A = D ÷ A = 0.58
 25 Social Profitability Ratio	     (SPR) = (E - F - G) ÷ E = H ÷ E = 0.45
 26 Private Cost Adjustment	    (PCAC) = A ÷ (B + C) - 1	     = 1.37
 27 Social Cost Adjustment	    (SCAC) = E ÷ (F + G) - 1	     = 0.83
 28 Private Value Added Ratio	    (PVAR) = (A - B) ÷ A	     = 0.87
 29 Social Value Added Ratio	    (SVAR) = (E - F) ÷ E	     = 0.82
 30 Domestic Factors Ratio	   (DOFAR) = C ÷ G		     = 0.97
{bf:{hline 82}}

{p2colreset}{...}
{marker 07}{bf:{err:{dlgtab:Examples:}}}

 {stata clear all}

 {stata sysuse pam1.dta, clear}

 {stata list}

 {stata "pam pd pw , dtc(dtc) wtc(wtc) ddf(ddf) wdf(wdf) save(D:\pam)"}

 {stata "pam pd pw in 1/1 , dtc(dtc) wtc(wtc) ddf(ddf) wdf(wdf) save(D:\pam)"}

 {stata "pam pd pw in 2/3 , dtc(dtc) wtc(wtc) ddf(ddf) wdf(wdf) save(D:\pam)"}

 {stata matlist e(pam)}
{hline}

 {stata clear all}

 {stata sysuse pam2.dta, clear}

{p 2 7 17}{stata "pam pd pw , dtc(dtc1 dtc2 dtc3 dtc4 dtc5 dtc6 dtc7 dtc8) wtc(wtc1 wtc2 wtc3 wtc4 wtc5 wtc6 wtc7 wtc8) ddf(ddf1 ddf2 ddf3 ddf4 ddf5 ddf6 ddf7) wdf(wdf1 wdf2 wdf3 wdf4 wdf5 wdf6 wdf7) save(D:\pam)"}{p_end}
{hline}

. clear all
. sysuse pam1.dta, clear
. list

     +--------------------------------------------------+
     |    pd      pw     dtc      wtc      ddf      wdf |
     |--------------------------------------------------|
  1. |  7230    5784     966   1021.2   2082.5   2142.5 |
  2. | 27.42   22.79    9.53    11.79      7.4     7.97 |
  3. |  1214    3009     119       83      468      297 |
  4. |  1836    4552     181      128      709      362 |
  5. |   450     456   17.41    13.26   532.79   498.76 |
     |--------------------------------------------------|
  6. |  2000    2100    1100     1050      800      800 |
     +--------------------------------------------------+

. pam pd pw , dtc(dtc) wtc(wtc) ddf(ddf) wdf(wdf) save(D:\pam)

======================================================================
                      Policy Analysis Matrix (PAM)
----------------------------------------------------------------------
*      Item        |  Revenue  |  Tradable  |  Domestic |   Profit   *
*                  |           |   Inputs   |  Factors  |            *
----------------------------------------------------------------------
* Private Price    |     A     |      B     |     C     |      D     *
----------------------------------------------------------------------
* Social Price     |     E     |      F     |     G     |      H     *
----------------------------------------------------------------------
* Transfer         |     I     |      J     |     K     |      L     *
----------------------------------------------------------------------

---------------------------------------------------------------------------
 *  (1)  (PVA) Private Value Added: A - B

     +--------+
     |   _PVA |
     |--------|
  1. |   6264 |
  2. |  17.89 |
  3. |   1095 |
  4. |   1655 |
  5. | 432.59 |
     |--------|
  6. |    900 |
     +--------+
---------------------------------------------------------------------------
 *  (2)  (SVA) Social Value Added: E - F

     +--------+
     |   _SVA |
     |--------|
  1. | 4762.8 |
  2. |     11 |
  3. |   2926 |
  4. |   4424 |
  5. | 442.74 |
     |--------|
  6. |   1050 |
     +--------+
---------------------------------------------------------------------------
 *  (3)   (PP) Private Profit: D = A - B - C

     +--------+
     |    _PP |
     |--------|
  1. | 4181.5 |
  2. |  10.49 |
  3. |    627 |
  4. |    946 |
  5. | -100.2 |
     |--------|
  6. |    100 |
     +--------+
---------------------------------------------------------------------------
 *  (4)   (SP) Social Profit: H = E - F - G

     +-----------+
     |       _SP |
     |-----------|
  1. |    2620.3 |
  2. |  3.030001 |
  3. |      2629 |
  4. |      4062 |
  5. | -56.02001 |
     |-----------|
  6. |       250 |
     +-----------+
---------------------------------------------------------------------------
 *  (5)   (PC) Private Cost: B + C

     +--------+
     |    _PC |
     |--------|
  1. | 3048.5 |
  2. |  16.93 |
  3. |    587 |
  4. |    890 |
  5. |  550.2 |
     |--------|
  6. |   1900 |
     +--------+
---------------------------------------------------------------------------
 *  (6)   (SC) Social Cost: F + G

     +--------+
     |    _SC |
     |--------|
  1. | 3163.7 |
  2. |  19.76 |
  3. |    380 |
  4. |    490 |
  5. | 512.02 |
     |--------|
  6. |   1850 |
     +--------+
---------------------------------------------------------------------------
 *  (7)   (OT) Output Transfer: I = A - E

     +----------+
     |      _OT |
     |----------|
  1. |     1446 |
  2. | 4.629999 |
  3. |    -1795 |
  4. |    -2716 |
  5. |       -6 |
     |----------|
  6. |     -100 |
     +----------+
---------------------------------------------------------------------------
 *  (8)   (IT) Input Transfer: J = B - F

     +-----------+
     |       _IT |
     |-----------|
  1. | -55.20001 |
  2. |     -2.26 |
  3. |        36 |
  4. |        53 |
  5. |      4.15 |
     |-----------|
  6. |        50 |
     +-----------+
---------------------------------------------------------------------------
 *  (9)   (FT) Factor Transfer: K = C - G

     +-----------+
     |       _FT |
     |-----------|
  1. |       -60 |
  2. | -.5699997 |
  3. |       171 |
  4. |       347 |
  5. |  34.02997 |
     |-----------|
  6. |         0 |
     +-----------+
---------------------------------------------------------------------------
 * (10)   (NT) Net Transfer: L = D - H = I - J - K

     +-----------+
     |       _NT |
     |-----------|
  1. |    1561.2 |
  2. |  7.459999 |
  3. |     -2002 |
  4. |     -3116 |
  5. | -44.17997 |
     |-----------|
  6. |      -150 |
     +-----------+
---------------------------------------------------------------------------
 * (11)  (ESR) Economic Surplus Ratio: L ÷ D

     +-----------+
     |      _ESR |
     |-----------|
  1. |  .3733588 |
  2. |  .7111534 |
  3. | -3.192982 |
  4. | -3.293869 |
  5. |  .4409179 |
     |-----------|
  6. |      -1.5 |
     +-----------+
---------------------------------------------------------------------------
 * (12) (NPCO) Nominal Protection Coefficient on Tradable Outputs: A ÷ E

     +----------+
     |    _NPCO |
     |----------|
  1. |     1.25 |
  2. | 1.203159 |
  3. | .4034563 |
  4. | .4033392 |
  5. | .9868421 |
     |----------|
  6. |  .952381 |
     +----------+
---------------------------------------------------------------------------
 * (13) (NPRO) Nominal Protection Rate on Tradable Outputs: NPCO - 1

     +-----------+
     |     _NPRO |
     |-----------|
  1. |       .25 |
  2. |  .2031592 |
  3. | -.5965437 |
  4. | -.5966609 |
  5. | -.0131579 |
     |-----------|
  6. |  -.047619 |
     +-----------+
---------------------------------------------------------------------------
 * (14) (NPCI) Nominal Protection Coefficient on Tradable Inputs: B ÷ F

     +--------------------------+
     |    _NPCI   _NPCI_dtc_wtc |
     |--------------------------|
  1. | .9459459        .9459459 |
  2. | .8083121        .8083121 |
  3. | 1.433735        1.433735 |
  4. | 1.414063        1.414063 |
  5. | 1.312971        1.312971 |
     |--------------------------|
  6. | 1.047619        1.047619 |
     +--------------------------+
---------------------------------------------------------------------------
 * (15) (NPRI) Nominal Protection Rate on Tradable Inputs: NPCI - 1

     +---------------------------+
     |     _NPRI   _NPRI_dtc_wtc |
     |---------------------------|
  1. | -.0540541       -.0540541 |
  2. | -.1916879       -.1916879 |
  3. |  .4337349         .433735 |
  4. |  .4140625        .4140625 |
  5. |  .3129714        .3129713 |
     |---------------------------|
  6. |  .0476191         .047619 |
     +---------------------------+
---------------------------------------------------------------------------
 * (16)  (EPC) Effective Protection Coefficient: (A - B) ÷ (E - F)

     +----------+
     |     _EPC |
     |----------|
  1. | 1.315193 |
  2. | 1.626364 |
  3. |  .374231 |
  4. | .3740958 |
  5. | .9770746 |
     |----------|
  6. | .8571429 |
     +----------+
---------------------------------------------------------------------------
 * (17)  (EPR) Effective Protection Rate: EPC - 1

     +-----------+
     |      _EPR |
     |-----------|
  1. |  .3151927 |
  2. |  .6263635 |
  3. |  -.625769 |
  4. | -.6259042 |
  5. | -.0229254 |
     |-----------|
  6. | -.1428571 |
     +-----------+
---------------------------------------------------------------------------
 * (18)  (DRC) Domestic Resource Cost: G ÷ (E - F)

     +----------+
     |     _DRC |
     |----------|
  1. | .4498404 |
  2. | .7245454 |
  3. | .1015038 |
  4. | .0818264 |
  5. |  1.12653 |
     |----------|
  6. | .7619048 |
     +----------+
---------------------------------------------------------------------------
 * (19)  (PCR) Private Cost Ratio: C ÷ (A - B)

     +----------+
     |     _PCR |
     |----------|
  1. | .3324553 |
  2. | .4136389 |
  3. | .4273973 |
  4. | .4283988 |
  5. | 1.231628 |
     |----------|
  6. | .8888889 |
     +----------+
---------------------------------------------------------------------------
 * (20)  (PCO) Profitability Coefficient: (A - B - C) ÷ (E - F - G) = D ÷ H

     +----------+
     |     _PCO |
     |----------|
  1. |  1.59581 |
  2. | 3.462045 |
  3. | .2384937 |
  4. | .2328902 |
  5. | 1.788646 |
     |----------|
  6. |       .4 |
     +----------+
---------------------------------------------------------------------------
 * (21)  (SRP) Subsidy Ratio to Producer: (D - H) ÷ E = L ÷ E

     +-----------+
     |      _SRP |
     |-----------|
  1. |   .269917 |
  2. |  .3273365 |
  3. | -.6653373 |
  4. | -.6845343 |
  5. | -.0968859 |
     |-----------|
  6. | -.0714286 |
     +-----------+
---------------------------------------------------------------------------
 * (22) (PCBR) Private Cost-Benefit Ratio: (B + C) ÷ A

     +----------+
     |    _PCBR |
     |----------|
  1. | .4216459 |
  2. | .6174325 |
  3. | .4835255 |
  4. | .4847495 |
  5. | 1.222667 |
     |----------|
  6. |      .95 |
     +----------+
---------------------------------------------------------------------------
 * (23) (SCBR) Social Cost-Benefit Ratio: (F + G) ÷ E

     +----------+
     |    _SCBR |
     |----------|
  1. | .5469744 |
  2. | .8670469 |
  3. | .1262878 |
  4. |  .107645 |
  5. | 1.122851 |
     |----------|
  6. | .8809524 |
     +----------+
---------------------------------------------------------------------------
 * (24)  (PPR) Private Profitability Ratio: (A - B - C) ÷ A = D ÷ A

     +-----------+
     |      _PPR |
     |-----------|
  1. |  .5783541 |
  2. |  .3825675 |
  3. |  .5164745 |
  4. |  .5152506 |
  5. | -.2226666 |
     |-----------|
  6. |       .05 |
     +-----------+
---------------------------------------------------------------------------
 * (25)  (SPR) Social Profitability Ratio: (E - F - G) ÷ E = H ÷ E

     +-----------+
     |      _SPR |
     |-----------|
  1. |  .4530256 |
  2. |  .1329531 |
  3. |  .8737122 |
  4. |   .892355 |
  5. | -.1228509 |
     |-----------|
  6. |  .1190476 |
     +-----------+
---------------------------------------------------------------------------
 * (26) (PCAC) Private Cost Adjustment coefficient: A ÷ (B + C) - 1

     +-----------+
     |     _PCAC |
     |-----------|
  1. |  1.371658 |
  2. |  .6196102 |
  3. |  1.068143 |
  4. |  1.062921 |
  5. | -.1821156 |
     |-----------|
  6. |  .0526316 |
     +-----------+
---------------------------------------------------------------------------
 * (27) (SCAC) Social Cost Adjustment coefficient: E ÷ (F + G) - 1

     +-----------+
     |     _SCAC |
     |-----------|
  1. |  .8282391 |
  2. |  .1533401 |
  3. |  6.918421 |
  4. |  8.289796 |
  5. | -.1094098 |
     |-----------|
  6. |  .1351351 |
     +-----------+
---------------------------------------------------------------------------
 * (28) (PVAR) Private Value Added Ratio: (A - B) ÷ A

     +----------+
     |    _PVAR |
     |----------|
  1. |   .86639 |
  2. | .6524435 |
  3. | .9019769 |
  4. | .9014161 |
  5. | .9613111 |
     |----------|
  6. |      .45 |
     +----------+
---------------------------------------------------------------------------
 * (29) (SVAR) Social Value Added Ratio: (E - F) ÷ E

     +----------+
     |    _SVAR |
     |----------|
  1. |  .823444 |
  2. | .4826679 |
  3. | .9724161 |
  4. | .9718805 |
  5. |  .970921 |
     |----------|
  6. |       .5 |
     +----------+
---------------------------------------------------------------------------
 * (30) (DOFAR) Domestic Factors Ratio: C ÷ G

     +---------------------------+
     |   _DOFAR   _DOFAR_ddf_wdf |
     |---------------------------|
  1. | .9719954         .9719954 |
  2. | .9284818         .9284818 |
  3. | 1.575758         1.575758 |
  4. | 1.958564         1.958564 |
  5. | 1.068229         1.068229 |
     |---------------------------|
  6. |        1                1 |
     +---------------------------+
---------------------------------------------------------------------------

===========================================================================
*** Policy Analysis Matrix (PAM) Results: ***
===========================================================================

+------------------------------------------------------------------------------------------+
|                 |         r1          r2          r3          r4          r5          r6 |
|-----------------+------------------------------------------------------------------------|
|            _PVA |  6264.0000     17.8900   1095.0000   1655.0000    432.5900    900.0000 |
|-----------------+------------------------------------------------------------------------|
|            _SVA |  4762.7998     11.0000   2926.0000   4424.0000    442.7400   1050.0000 |
|-----------------+------------------------------------------------------------------------|
|             _PP |  4181.5000     10.4900    627.0000    946.0000   -100.2000    100.0000 |
|-----------------+------------------------------------------------------------------------|
|             _SP |  2620.3000      3.0300   2629.0000   4062.0000    -56.0200    250.0000 |
|-----------------+------------------------------------------------------------------------|
|             _PC |  3048.5000     16.9300    587.0000    890.0000    550.2000   1900.0000 |
|-----------------+------------------------------------------------------------------------|
|             _SC |  3163.7000     19.7600    380.0000    490.0000    512.0200   1850.0000 |
|-----------------+------------------------------------------------------------------------|
|             _OT |  1446.0000      4.6300  -1795.0000  -2716.0000     -6.0000   -100.0000 |
|-----------------+------------------------------------------------------------------------|
|             _IT |   -55.2000     -2.2600     36.0000     53.0000      4.1500     50.0000 |
|-----------------+------------------------------------------------------------------------|
|             _FT |   -60.0000     -0.5700    171.0000    347.0000     34.0300      0.0000 |
|-----------------+------------------------------------------------------------------------|
|             _NT |  1561.2000      7.4600  -2002.0000  -3116.0000    -44.1800   -150.0000 |
|-----------------+------------------------------------------------------------------------|
|            _ESR |     0.3734      0.7112     -3.1930     -3.2939      0.4409     -1.5000 |
|-----------------+------------------------------------------------------------------------|
|           _NPCO |     1.2500      1.2032      0.4035      0.4033      0.9868      0.9524 |
|-----------------+------------------------------------------------------------------------|
|           _NPRO |     0.2500      0.2032     -0.5965     -0.5967     -0.0132     -0.0476 |
|-----------------+------------------------------------------------------------------------|
|           _NPCI |     0.9459      0.8083      1.4337      1.4141      1.3130      1.0476 |
|-----------------+------------------------------------------------------------------------|
|   _NPCI_dtc_wtc |     0.9459      0.8083      1.4337      1.4141      1.3130      1.0476 |
|-----------------+------------------------------------------------------------------------|
|           _NPRI |    -0.0541     -0.1917      0.4337      0.4141      0.3130      0.0476 |
|-----------------+------------------------------------------------------------------------|
|   _NPRI_dtc_wtc |    -0.0541     -0.1917      0.4337      0.4141      0.3130      0.0476 |
|-----------------+------------------------------------------------------------------------|
|            _EPC |     1.3152      1.6264      0.3742      0.3741      0.9771      0.8571 |
|-----------------+------------------------------------------------------------------------|
|            _EPR |     0.3152      0.6264     -0.6258     -0.6259     -0.0229     -0.1429 |
|-----------------+------------------------------------------------------------------------|
|            _DRC |     0.4498      0.7245      0.1015      0.0818      1.1265      0.7619 |
|-----------------+------------------------------------------------------------------------|
|            _PCR |     0.3325      0.4136      0.4274      0.4284      1.2316      0.8889 |
|-----------------+------------------------------------------------------------------------|
|            _PCO |     1.5958      3.4620      0.2385      0.2329      1.7886      0.4000 |
|-----------------+------------------------------------------------------------------------|
|            _SRP |     0.2699      0.3273     -0.6653     -0.6845     -0.0969     -0.0714 |
|-----------------+------------------------------------------------------------------------|
|           _PCBR |     0.4216      0.6174      0.4835      0.4847      1.2227      0.9500 |
|-----------------+------------------------------------------------------------------------|
|           _SCBR |     0.5470      0.8670      0.1263      0.1076      1.1229      0.8810 |
|-----------------+------------------------------------------------------------------------|
|            _PPR |     0.5784      0.3826      0.5165      0.5153     -0.2227      0.0500 |
|-----------------+------------------------------------------------------------------------|
|            _SPR |     0.4530      0.1330      0.8737      0.8924     -0.1229      0.1190 |
|-----------------+------------------------------------------------------------------------|
|           _PCAC |     1.3717      0.6196      1.0681      1.0629     -0.1821      0.0526 |
|-----------------+------------------------------------------------------------------------|
|           _SCAC |     0.8282      0.1533      6.9184      8.2898     -0.1094      0.1351 |
|-----------------+------------------------------------------------------------------------|
|           _PVAR |     0.8664      0.6524      0.9020      0.9014      0.9613      0.4500 |
|-----------------+------------------------------------------------------------------------|
|           _SVAR |     0.8234      0.4827      0.9724      0.9719      0.9709      0.5000 |
|-----------------+------------------------------------------------------------------------|
|          _DOFAR |     0.9720      0.9285      1.5758      1.9586      1.0682      1.0000 |
|-----------------+------------------------------------------------------------------------|
|  _DOFAR_ddf_wdf |     0.9720      0.9285      1.5758      1.9586      1.0682      1.0000 |
+------------------------------------------------------------------------------------------+

*** Save Policy Analysis Matrix (PAM) ***
*** Policy Analysis Matrix (PAM) Results File Has Been saved in:

 Data Directory:   D:\Stata

 Open File:        D:\pam.txt
--------------------------------------------------

{p2colreset}{...}
{marker 08}{bf:{err:{dlgtab:Authors}}}

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
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/pmi520.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/pmi520.htm"}}

{bf:{err:{dlgtab:PAM Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih & Sahra Khaleel A. Mickaiel (2013)}{p_end}
{p 1 10 1}{cmd:PAM: "Stata Module to Estimate Policy Analysis Matrix (PAM)"}{p_end}

	{browse "http://ideas.repec.org/c/boc/bocode/s457738.html"}

	{browse "http://econpapers.repec.org/software/bocbocode/s457738.htm"}

{title:Online Help:}

{helpb index}{col 8}Index Numbers{col 57}(index)
{helpb cfm}{col 8}Cost Function Models{col 57}(CFM)
{helpb fam}{col 8}Financial Analysis Models{col 57}(FAM)
{helpb gcrtm}{col 8}Geographical Concentration Regional Trade Models{col 57}(GCRTM)
{helpb gcstm}{col 8}Geographical Concentration Sectoral Trade Models{col 57}(GCSTM)
{helpb iic}{col 8}Investment Indicators Criteria{col 57}(IIC)
{helpb iot}{col 8}Leontief Input - Output Table{col 57}(IOT)
{helpb mef}{col 8}Marketing Efficiency Models{col 57}(MEF)
{helpb pam}{col 8}Policy Analysis Matrix{col 57}(PAM)
{helpb pem}{col 8}Partial Equilibrium Model{col 57}(PEM)
{helpb rcatm}{col 8}Revealed Comparative Advantage Trade Models{col 57}(RCATM)
{helpb tic}{col 8}Trade Indicators Criteria{col 57}(TIC)
{helpb tim}{col 8}Trade Indicators Models{col 57}(TIM)
{helpb xbcr}{col 8}Benefit-Cost Ratio{col 57}(BCR)
{helpb xirr}{col 8}Internal Rate of Return{col 57}(xirr)
{helpb xmirr}{col 8}Modified Internal Rate of Return{col 57}(MIRR)
{helpb xnfv}{col 8}Net Future Value{col 57}(NFV)
{helpb xnpv}{col 8}Net Present Value{col 57}(XNPV)
{helpb xpp}{col 8}Payback Period{col 57}(PP)

{psee}
{p_end}
