{smcl}
{hline}
{cmd:help: {helpb pem}}{space 50} {cmd:dialog:} {bf:{dialog pem}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf:pem: Partial EquiLibrium Model (PEM)}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb pem##01:Syntax}{p_end}
{p 5}{helpb pem##02:Options}{p_end}
{p 5}{helpb pem##03:Models}{p_end}
{p 5}{helpb pem##04:Description}{p_end}
{p 5}{helpb pem##05:Saved Results}{p_end}
{p 5}{helpb pem##06:References}{p_end}

{p 1}*** {helpb pem##07:PEM Applications}{p_end}

{p 1}*** {helpb pem##08:Examples}{p_end}

{p 5}{helpb pem##09:Authors}{p_end}

{p2colreset}{...}
{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 5 5 6}
{opt pem} Pd Pw {ifin} , {err: [ {opt model(expbl|impbl|expd|expw|impd|impw)} {opt qp(var)} {opt qc(var)} {opt es(var)} {opt ed(var)} {err:]}} {opt nolist} {opt save(file_name)} {p_end}

{p2colreset}{...}
{marker 02}{bf:{err:{dlgtab:Options}}}

{col 3}{varlist}{col 20}Two Variables only Pd & Pw respectively:
{col 24}1- {opt (pd)} Private Domestic Price (Pd) (Financial Price)
{col 24}2- {opt (pw)} Social  World Price (Pw)    (Economic Price)

{col 3}{opt qp(var)}{col 20}Production Quantity
{col 3}{opt qc(var)}{col 20}Consumption Quantity

{col 3}{opt es(var)}{col 20}Supply Price Elasticity: (must be Positive (+) > 0)
{col 3}{opt ed(var)}{col 20}Demand Price Elasticity: (must be Negative (-) < 0)

{col 3}{opt nolist}{col 20}Don't Display All Indicators.
{col 3}{opt save(file_name)}{col 20}Save PEM Model Results in File (*.txt).

{bf:{err:*** Important Notes:}}
{cmd:pem} generates some variables names starting with prefix "_", i.e,:
{cmd:_NELp, _NELc, _PS, _CS, _GR, _FE, _NET,}
{cmd:So, you must avoid to include variables names with these prefixes}

{p2colreset}{...}
{marker 03}{bf:{err:{dlgtab:Models}}}

{cmd: 1-} {bf:model({err:{it:expbl}})}  Bale-Lutz (PEM) Model - Export Case

{cmd: 2-} {bf:model({err:{it:impbl}})}  Bale-Lutz (PEM) Model - Import Case

{cmd: 3-} {bf:model({err:{it:expd}})}    Export Tax: Private (Financial Price)    -    Intervention Case

{cmd: 4-} {bf:model({err:{it:expw}})} No Export Tax: Social (Economic Price)      - No Intervention Case

{cmd: 5-} {bf:model({err:{it:impd}})}    Import Tariff: Private (Financial Price) -    Intervention Case

{cmd: 6-} {bf:model({err:{it:impw}})} No Import Tariff: Social (Economic Price)   - No Intervention Case

{p2colreset}{...}
{marker 04}{bf:{err:{dlgtab:Description}}}

{col 4}{cmd:pem} estimates Partial EquiLibrium Model (PEM).

{pstd}{cmd:pem} estimates Partial EquiLibrium Model (PEM) to get Net Economic Loss in Production,
Net Economic Loss in Consumption, Change in Producer Surplus, Change in Consumer Surplus,
Change in Government Revenue, Change in Foreign Exchange, and Net Economic Loss in (Export/Import).{p_end}

{bf:{hline 65}}
{bf:{err:*** Partial EquiLibrium Model (PEM) Variables ***}}
{bf:{hline 65}}
{bf:{err:** Private Price:}}		   {bf:{err:** Social Price:}}
{bf:{hline 65}}
{bf:*  Pd = Domestic Price		*  Pw = Border Price}
{bf:{hline 65}}
{bf:* NPC = Nominal Protection Coefficient = Pd/Pw}
{bf:{hline 65}}
{bf:* Txd = Export Tax Rate		* Txw = No Export Tax Rate}
*     = (1-NPC)/NPC		    *     = 1-NPC
{bf:{hline 65}}
{bf:* Tmd = Import Tariff Rate		* Tmw = No Import Tariff Rate}
      = (NPC-1)/NPC		    *     = NPC-1
{bf:{hline 65}}
{bf:* QPd = Production Quantity		* QPw = Production Quantity}
*     = QP			    *     = QPd-(Esd*(Pd-Pw)*QPd/Pd)
{bf:{hline 65}}
{bf:* VPd = Production Value		* VPw = Production Value}
*     = Pd*QPd			    *     = Pw*QPw
{bf:{hline 65}}
{bf:* QCd = Consumption Quantity	* QCw = Consumption Quantity}
*     = QC			    *     = QCd-(Edd*(Pd-Pw)*QCd/Pd)
{bf:{hline 65}}
{bf:* VCd = Consumption Value		* VCw = Consumption Value}
*     = Pd*QCd			    *     = Pw*QCw
{bf:{hline 65}}
{bf:* Esd = Supply Price Elasticity	* Esw = Supply Price Elasticity}
*     = ES			    *     = Esd*(Pw*QPd)/(Pd*QPw)
{bf:{hline 65}}
{bf:* Edd = Demand Price Elasticity	* Edw = Demand Price Elasticity}
*     = ED			    *     = Edd*(Pw*QCd)/(Pd*QCw)
{bf:{hline 65}}

{bf:*   GR = Change in Government Revenue}
{bf:*   FE = Change in Foreign Exchange}
{bf:* NELp = Net Economic Loss in Production}
{bf:* NELc = Net Economic Loss in Consumption}
{bf:*   PS = Change in Producer Surplus}
{bf:*   CS = Change in Consumer Surplus}
{bf:*  NET = Net Economic Loss in (Export/Import)}
---------------------------------------------------------

{bf:{hline 85}}
{bf:{err:(1) * model(expbl): Bale-Lutz (PEM) Model - Export Case ***}}
{bf:{err:(2) * model(impbl): Bale-Lutz (PEM) Model - Import Case ***}}
{bf:{hline 85}}
 NELp=0.5*(QPw-QPd)*(Pw-Pd)
 NELc=0.5*(QCw-QCd)*(Pd-Pw)
  PS =QPd*(Pd-Pw)-NELp
  CS =QCd*(Pw-Pd)-NELc
  GR =-NELp-NELc-PS-CS
  FE =-Pw*(QPw-QPd+QCd-QCw)
 NET = PS+CS+GR = -(NELp+NELc)

{bf:{hline 85}}
{bf:{err:(3) * model(expd): Export Tax: Private (Financial Price) - Intervention Case in prevailing (Pd)}}
{bf:{hline 85}}
 NELp= 0.5*Esd*((1-NPC)/NPC)^2*VPd
 NELc= |(0.5*Edd*((1-NPC)/NPC)^2*VCd)|
  PS = -((((1-NPC)/NPC)*VPd)+NELp)
  CS = ((((1-NPC)/NPC)*VCd)-NELc)
  GR = ((1-NPC)/NPC)*(VPd-VCd)
  FE = -((1-NPC)/NPC^2)*(Esd*VPd-Edd*VCd)
 NET = PS+CS+GR = -(NELp+NELc)

{bf:{hline 85}}
{bf:{err:(4) * model(expw): No Export Tax: Social (Economic Price) - No Intervention Case in prevailing (Pw)}}
{bf:{hline 85}}
 NELp= 0.5*Esw*(1-NPC)^2*VPw
 NELc= |(0.5*Edw*(1-NPC)^2*VCw)|
  PS = -(((1-NPC)*VPw)-NELp)
  CS = ((1-NPC)*VCw)+NELc
  GR = (1-NPC)*(VPw*(1-Esw*(1-NPC))-VCw*(1-Edw*(1-NPC)))
  FE = -((1-NPC)*(Esw*VPw-Edw*VCw))
 NET = PS+CS+GR = -(NELp+NELc)

{bf:{hline 85}}
{bf:{err:(5) * model(impd): Import Tariff: Private (Financial Price) - Intervention Case in prevailing (Pd)}}
{bf:{hline 85}}
 NELp= 0.5*Esd*((NPC-1)/NPC)^2*VPd
 NELc= |(0.5*Edd*((NPC-1)/NPC)^2*VCd)|
  PS = (((NPC-1)/NPC)*VPd)-NELp
  CS = -((((NPC-1)/NPC)*VCd)+NELc)
  GR = ((NPC-1)/NPC)*(VCd-VPd)
  FE = -((NPC-1)/NPC^2)*(Esd*VPd-Edd*VCd)
 NET = PS+CS+GR = -(NELp+NELc)

{bf:{hline 85}}
{bf:{err:(6) * model(impw): No Import Tariff: Social (Economic Price) - No Intervention Case in prevailing (Pw)}}
{bf:{hline 85}}
 NELp= 0.5*Esw*((NPC-1)^2)*VPw
 NELc= |(0.5*Edw*(NPC-1)^2*VCw)|
  PS = ((NPC-1)*VPw)+NELp
  CS = -(((NPC-1)*VCw)-NELc)
  GR = (NPC-1)*(VCw*(1+Edw*(NPC-1))-VPw*(1+Esw*(NPC-1)))
  FE = -((NPC-1)*(Esw*VPw-Edw*VCw))
 NET = PS+CS+GR = -(NELp+NELc)

----------------------------------------------------------------------
{bf:{err:*** Interpretation of Partial Equilibrium Model (PEM): ***}}
----------------------------------------------------------------------
{bf:{err:1- (NELp) Net Economic Loss in Production:}}
{phang}* Increase (NELp): the producer increase using inputs of production as a result of lower inputs prices and supporting policies to inputs, and therefore inefficiency and irrational in distribution of inputs.{p_end}
{phang}* Decrease (NELp): the producer decrease using inputs of production as a result of higher inputs prices and taxing policies on inputs, and therefore efficiency and rational in distribution of inputs.{p_end}

----------------------------------------------------------------------
{bf:{err:2- (NELc) Net Economic Loss in Consumption:}}
{phang}* Increase (NELc): the consumer increase commodity consumption as a result of lower domestic price, and therefore inefficiency and irrational in the distribution of of consumer spending.{p_end}
{phang}* Decrease (NELc): the consumer decrease commodity consumption as a result of higher domestic price, and therefore efficiency and rational in the distribution of of consumer spending.{p_end}

----------------------------------------------------------------------
{bf:{err:3- (PS) Change in Producer Surplus:}}
{phang}* Gains in Producer Surplus (PS) due to increase revenue than costs as a result of higher domestic price than bprder price, so the producer gains from saling large quantities at high prices, and thus increasing revenue and higher producer welfare.{p_end}
{phang}* Losses in Producer Surplus (PS) due to decrease revenue than costs as a result of lower domestic price than bprder price, so the producer loss from saling small quantities at low prices, and thus decreasing revenue and lower producer welfare.{p_end}

----------------------------------------------------------------------
{bf:{err:4- (CS) Change in Consumer Surplus:}}
{phang}* Gains in Consumer Surplus (CS) due to increasing production with low price, so the consumer gains from consumption large quantities at low prices, thereby increasing consumer spending and higher consumer welfare.{p_end}
{phang}* Losses in Consumer Surplus (CS) due to decreasing production with high price, so the consumer loss from consumption small quantities at high prices, thereby decreasing consumer spending and lower consumer welfare.{p_end}

----------------------------------------------------------------------
{bf:{err:5- (GR) Change in Government Revenue:}}
{phang}* Gains in Government Revenue (GR) due to increasing production than consumption, so the government gains as a result of decrease in the value of imports and saving foreign currency.{p_end}
{phang}* Losses in Government Revenue (GR) due to decreasing production than consumption, so the government loss as a result of increase in the value of imports and non saving foreign currency.{p_end}

----------------------------------------------------------------------
{bf:{err:6- (FE) Change in Foreign Exchange:}}
{phang}* Increase Foreign Exchange (FE) paid because of increase the dependence on imports, and increase the value of imports, as a result of increase in consumption than production.{p_end}
{phang}* Decrease Foreign Exchange (FE) paid because of reduced the dependence on imports, and decline in the value of imports, as a result of decrease consumption than production.{p_end}

----------------------------------------------------------------------
{bf:{err:7- (NET) Net Economic Loss:}}
Consists of (NELp) and (NELc)
{phang}* Increase Net Economic Loss (NET): due to increase in (NELp) as a result inefficiency and irrational in distribution of inputs in the producer behavior, and due to increase in (NELc) as a result of inefficiency and irrational in the distribution of of consumer spending in the consumer behavior.{p_end}
{phang}* Decrease Net Economic Loss (NET): due to decrease in (NELp) as a result efficiency and rational in distribution of inputs in the producer behavior, and due to decrease in (NELc) as a result of efficiency and rational in the distribution of of consumer spending in the consumer behavior.{p_end}
----------------------------------------------------------------------

{p2colreset}{...}
{marker 05}{bf:{err:{dlgtab:Saved Results}}}

{p 2 4 2 }{cmd:pem} saves the following results in {cmd:e()}:

Matrixes       
{col 4}{cmd:e(pem)}{col 20}pem Model Results

{marker 06}{bf:{err:{dlgtab:References}}}

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
{marker 07}{bf:{err:{dlgtab:PEM Applications:}}}

 * Data of This example is taken from Isabelle Tsakok (1990), p(240)
 * Export Tax on Rice
 * according to (Bale-Lutz (PEM) Model) - Export Case

{stata clear all}
{stata sysuse pem.dta, clear}
{stata "pem pd pw in 1/1 , model(impbl) qp(qp) qc(qc) es(es) ed(ed) save(D:\pem)"}

---------------------------------------------------------
Export Tax on Rice				Value
---------------------------------------------------------
Domestic Price (Pd)				3200
Border Price   (Pw)				4000
---------------------------------------------------------
Production Quantity  (QPd) at (Pd)		0.50
Consumption Quantity (QCd) at (Pd)		0.40
---------------------------------------------------------
Supply Price Elasticity (Esd)			0.80
Demand Price Elasticity	(Edd)		       -0.50
---------------------------------------------------------
Production Quantity (QPw) at (Pw)		0.60
  QPw= QPd-[Esd(Pd-Pw)QPd/Pd]
     = 0.50-[0.8(3200-4000)0.50/3200]
---------------------------------------------------------
Consumption Quantity (QCw) at (Pw)		0.35
  QCw= QCd-[Edd(Pd-Pw)QCd/Pd]
     = 0.40-[-0.5(3200-4000)0.40/3200]
---------------------------------------------------------
** (1) Net Economic Loss in Production		40
  NELp= 0.5*(QPw-QPd)*(Pw-Pd)
      = 0.5*(0.60-0.50)*(4000-3200)
---------------------------------------------------------
** (2) Net Economic Loss in Consumption		20
  NELc= 0.5*(QCw-QCd)*(Pd-Pw)
      = 0.5*(0.35-0.40)*(3200-4000)
---------------------------------------------------------
** (3) Change in Producer Surplus		-440
  PS = QPd*(Pd-Pw)-NELp
     = 0.50*(3200-4000)-40
---------------------------------------------------------
** (4) Change in Consumer Surplus		300
  CS = QCd*(Pw-Pd)-NELc
     = 0.40*(4000-3200)-20
---------------------------------------------------------
** (5) Change in Government Revenue		80
  GR = -NELp-NELc-PS-CS
     = -40-20-(-440)-300
---------------------------------------------------------
** (6) Change in Foreign Exchange		-600
  FE = -Pw*(QPw-QPd+QCd-QCw)
     = -4000*(0.60-0.50+0.40-0.35)
---------------------------------------------------------
** (7) Net Economic Loss			-60
  NET = PS+CS+GR = -(NELp+NELc)
      = -440+300+80 = -(40+20)
------------------------------------------------------------------------

 * Data of This example is taken from Isabelle Tsakok (1990), p(241)
 * Import Tarrif on Wheat
 * according to (Bale-Lutz (PEM) Model) - Import Case

{stata clear all}
{stata sysuse pem.dta, clear}
{stata "pem pd pw in 2/2 , model(impbl) qp(qp) qc(qc) es(es) ed(ed) save(D:\pem)"}

---------------------------------------------------------
Import Tarrif on Wheat				Value
---------------------------------------------------------
Domestic Price (Pd)				400
Border Price   (Pw)				320
---------------------------------------------------------
Production Quantity  (QPd) at (Pd)		1,000
Consumption Quantity (QCd) at (Pd)		1,500
---------------------------------------------------------
Supply Price Elasticity (Esd)			0.50
Demand Price Elasticity	(Edd)		       -0.40
---------------------------------------------------------
Production Quantity (QPw) at (Pw)		900
  QPw= QPd-[Esd(Pd-Pw)QPd/Pd]
     = 1000-[0.5(400-320)1000/400]
---------------------------------------------------------
Consumption Quantity (QCw) at (Pw)		1,620
  QCw= QCd-[Edd(Pd-Pw)QCd/Pd]
     = 1500-[-0.4(400-320)1500/400]
---------------------------------------------------------
** (1) Net Economic Loss in Production		4,000
  NELp= 0.5*(QPw-QPd)*(Pw-Pd)
      = 0.5*(900-1000)*(320-400)
---------------------------------------------------------
** (2) Net Economic Loss in Consumption		4,800
  NELc= 0.5*(QCw-QCd)*(Pd-Pw)
      = 0.5*(1620-1500)*(400-320)
---------------------------------------------------------
** (3) Change in Producer Surplus		76,000
  PS = QPd*(Pd-Pw)-NELp
     = 1000*(400-320)-4000
---------------------------------------------------------
** (4) Change in Consumer Surplus		-124,800
  CS = QCd*(Pw-Pd)-NELc
     = 1500*(320-400)-4800
---------------------------------------------------------
** (5) Change in Government Revenue		40,000
  GR = -NELp-NELc-PS-CS
     = -4000-4800-76000-(-124800)
---------------------------------------------------------
** (6) Change in Foreign Exchange		70,400
  FE = -Pw*(QPw-QPd+QCd-QCw)
     = -320*(900-1000+1500-1620)
---------------------------------------------------------
** (7) Net Economic Loss			-8,800
  NET = PS+CS+GR = -(NELp+NELc)
      = 76000-124800+40000 = -(4000+4800)
---------------------------------------------------------

{p2colreset}{...}
{marker 08}{bf:{err:{dlgtab:Examples:}}}

 These examples are taken:
 * (1) Export Tax on Rice     - Isabelle Tsakok (1990), p(240)
 * (2) Import Tarrif on Wheat - Isabelle Tsakok (1990), p(241)
 * (3) Wheat                  - Bale, Malcolm D. & Ernst Lutz (1981), p(18)

{stata clear all}

{stata sysuse pem.dta, clear}

{stata list}

{stata "pem pd pw , model(expbl) qp(qp) qc(qc) es(es) ed(ed) save(D:\pem)"}

-----------------------------------------------------------

{stata "pem pd pw in 1/1 , model(expbl) qp(qp) qc(qc) es(es) ed(ed) save(D:\pem)"}

{stata "pem pd pw in 1/1 , model(expd)  qp(qp) qc(qc) es(es) ed(ed) save(D:\pem)"}

{stata "pem pd pw in 1/1 , model(expw)  qp(qp) qc(qc) es(es) ed(ed) save(D:\pem)"}

-----------------------------------------------------------

{stata "pem pd pw in 2/2 , model(impbl) qp(qp) qc(qc) es(es) ed(ed) save(D:\pem)"}

{stata "pem pd pw in 2/2 , model(impd)  qp(qp) qc(qc) es(es) ed(ed) save(D:\pem)"}

{stata "pem pd pw in 2/2 , model(impw)  qp(qp) qc(qc) es(es) ed(ed) save(D:\pem)"}

{stata matlist e(pem)}
{hline}

. clear all
. sysuse pem.dta, clear
. list

     +-------------------------------------------+
     |     pd     pw      qp      qc    es    ed |
     |-------------------------------------------|
  1. |   3200   4000      .5      .4    .8   -.5 |
  2. |    400    320       1     1.5    .5   -.4 |
  3. | 180.18    143   16.15   7.785   .42   -.1 |
     +-------------------------------------------+

. pem pd pw , model(expbl) qp(qp) qc(qc) es(es) ed(ed) save(D:\pem)


==============================================================================
*** Partial EquiLibrium Model (PEM) ***
------------------------------------------------------------------------------
* Bale-Lutz (PEM) Model - Export Case
==============================================================================

* Private (Financial Price) Variables:
* Txd : Export Tax Rate
* QPd : Production Quantity
* VPd : Production Value
* QCd : Consumption Quantity
* VCd : Consumption Value
* Esd : Supply Price Elasticity
* Edd : Demand Price Elasticity
------------------------------------------------------------------------------
* Social (Economic Price) Variables:
* Txw : No Export Tax Rate
* QPw : Production Quantity
* VPw : Production Value
* QCw : Consumption Quantity
* VCw : Consumption Value
* Esw : Supply Price Elasticity
* Edw : Demand Price Elasticity
------------------------------------------------------------------------------

+--------------------------------------------------------------------------------------------------+
|       |       _TXD |       _QPD |       _VPD |       _QCD |       _VCD |       _ESD |       _EDD |
|-------+------------+------------+------------+------------+------------+------------+------------|
|    r1 |      0.250 |      0.500 |   1600.000 |      0.400 |   1280.000 |      0.800 |     -0.500 |
|    r2 |     -0.200 |      1.000 |    400.000 |      1.500 |    600.000 |      0.500 |     -0.400 |
|    r3 |     -0.206 |     16.150 |   2909.907 |      7.785 |   1402.701 |      0.420 |     -0.100 |
+--------------------------------------------------------------------------------------------------+

+--------------------------------------------------------------------------------------------------+
|  Mean |     -0.052 |      5.883 |   1636.636 |      3.228 |   1094.234 |      0.573 |     -0.333 |
+--------------------------------------------------------------------------------------------------+

+--------------------------------------------------------------------------------------------------+
|       |       _TXW |       _QPW |       _VPW |       _QCW |       _VCW |       _ESW |       _EDW |
|-------+------------+------------+------------+------------+------------+------------+------------|
|    r1 |      0.200 |      0.600 |   2400.000 |      0.350 |   1400.000 |      0.833 |     -0.714 |
|    r2 |     -0.250 |      0.900 |    288.000 |      1.620 |    518.400 |      0.444 |     -0.296 |
|    r3 |     -0.260 |     14.750 |   2109.298 |      7.946 |   1136.227 |      0.365 |     -0.078 |
+--------------------------------------------------------------------------------------------------+

+--------------------------------------------------------------------------------------------------+
|  Mean |     -0.103 |      5.417 |   1599.099 |      3.305 |   1018.209 |      0.548 |     -0.363 |
+--------------------------------------------------------------------------------------------------+

==============================================================================
*** Partial EquiLibrium Model (PEM) Results ***
------------------------------------------------------------------------------
* NELp: Net Economic Loss in Production
* NELc: Net Economic Loss in Consumption
*  PS : Change in Producer Surplus
*  CS : Change in Consumer Surplus
*  GR : Change in Government Revenue
*  FE : Change in Foreign Exchange
* NET : Net Economic Loss in Export
==============================================================================

+--------------------------------------------------------------------------------------------------+
|       |      _NELp |      _NELc |        _PS |        _CS |        _GR |        _FE |       _NET |
|-------+------------+------------+------------+------------+------------+------------+------------|
|    r1 |     40.000 |     20.000 |   -440.000 |    300.000 |     80.000 |   -600.000 |    -60.000 |
|    r2 |      4.000 |      4.800 |     76.000 |   -124.800 |     40.000 |     70.400 |     -8.800 |
|    r3 |     26.020 |      2.986 |    574.437 |   -292.433 |   -311.011 |    223.124 |    -29.006 |
+--------------------------------------------------------------------------------------------------+

+--------------------------------------------------------------------------------------------------+
|  Mean |     23.340 |      9.262 |     70.146 |    -39.078 |    -63.670 |   -102.159 |    -32.602 |
+--------------------------------------------------------------------------------------------------+

*** Save Partial EquiLibrium Model (PEM) ***
*** Partial EquiLibrium Model (PEM) Results File Has Been saved in:

 Data Directory:   D:\Stata

 Open File:        D:\pem.txt
--------------------------------------------------

{p2colreset}{...}
{marker 09}{bf:{err:{dlgtab:Authors}}}

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

{bf:{err:{dlgtab:PEM Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih & Sahra Khaleel A. Mickaiel (2013)}{p_end}
{p 1 10 1}{cmd:PEM: "Stata Module to Estimate Partial Equilibrium Model (PEM)"}{p_end}

	{browse "http://ideas.repec.org/c/boc/bocode/s457758.html"}

	{browse "http://econpapers.repec.org/software/bocbocode/s457758.htm"}

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
