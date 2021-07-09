{smcl}
{hline}
{cmd:help: {helpb imvol}}{space 55} {cmd:dialog:} {bf:{dialog imvol}}
{hline}

{bf:{err:{dlgtab:Title}}}

{p 4 8 2}
{bf:imvol - Implied Volatility Black-Scholes European Option Pricing Model}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb imvol##01:Syntax}{p_end}
{p 5}{helpb imvol##02:Options}{p_end}
{p 5}{helpb imvol##03:Description}{p_end}
{p 5}{helpb imvol##04:References}{p_end}

{p 1}*** {helpb imvol##05:Examples}{p_end}

{p 5}{helpb imvol##06:Author}{p_end}

{p2colreset}{...}
{marker 01}{bf:{err:{dlgtab:Syntax}}}

{p 5 5 6}
{opt imvol} Stock_Price Strike_Price , {opt ir(var)} {opt t:ime(var)} {opt opt:ion(new_var)}{p_end}

{p2colreset}{...}
{marker 02}{bf:{err:{dlgtab:Options}}}

{synoptset 15 tabbed}{...}

{col 4}{cmd:{opt ir(var)}}{col 17}Interest Rate Ratio (%).
{col 4}{cmd:{opt t:ime(var)}}{col 17}Expiration Time.
{col 4}{cmd:{opt opt:ion(var)}}{col 17}Call/Put Option Price.

{p2colreset}{...}
{marker 03}{bf:{err:{dlgtab:Description}}}

{p 2 2 2} {cmd:imvol} computes Implied Volatility from Black-Scholes European Option Pricing Model.{p_end}

{p 2 2 2}Fischer Black & Myron Scholes are 2 economist, who in 1973 published a paper which redefined finance and derivatives, with "The Pricing of Options & Corporate Liabilities" featured in the Journal of Political Economy in May of that year.
The piece is arguably one of the most important papers within finance theory
to date and allows us to price various derivatives, including options
on commodities, financial assets and even pricing of employee stock options.{p_end}

{p 2 2 2}Assumptions of Black-Scholes Option Pricing:{p_end} 
	1. No dividends are paid out on the underlying stock during the option life.
	2. The option can only be exercised at expiry (European characteristics)
	3. Efficient markets (Market movements cannot be predicted)
	4. Commissions are non-existent
	5. Interest rates do not change over the life of the option (and are known)
	6. Stock returns follow a lognormal distribution.

{p 2 2 2}European Options Pricing: are options which are only exercisable on the expiry date of the option and are valued using the Black Scholes option pricing forumla. There are only five inputs to the classic Black Scholes model:
spot price, strike price, time until expiry, interest rate, and volatility. As such European options are typically the simplest options to value The dividend or yield on the underlying asset can also be an input on some extentions of the model.
In contrast American Options can be exercised at any time up until and including the expiry date of the option.{p_end}

{p 2 2 2}The term European is confined to describing the exercise feature of the option (ie exercisable only on the expiry date) and is does not describe the geographic region of the underlying asset. For example, a European Option can be issued on a stock of a company listed on an Asian exchange.{p_end} 

{p 2 2 2}Spot Price: The market price of the underlying asset on the valuation date. This can be a difficult input to estimate for options on illiquid assets,
however under normal circumstances the closing market price can usually be used.{p_end}

{p 2 2 2}Strike Price: The price level at which the option holder has the right to buy or sell the underlying asset. It is the most straightforward input as it will always be given in the option contract.{p_end}

{p 2 2 2}Time to Maturity: Time (in years) until the option expires and the holder is no longer entitled to exercise the option.{p_end}

{p 2 2 2}Interest Rate: Risk free interest rate for the period until the option expires. The risk free rate should typically be a zero coupon government bond yield.{p_end}

{p 2 2 2}Volatility: Probably the most important single input to any option pricing model.{p_end}

{p 2 2 2}Implied Volatility: The volatility implied by the market price of traded options. As the price is already known and the volatility (which is typically an input) is unknown the pricing model is reversed to determine the volatility.
When using the implied volatility it is important to be aware of the volatility surface.
The volatility surface is the 3 dimensional representation of the relationship between volatility, option life and exercise price.
Thus to use implied volatility the option from which the volatility is implied should have a similar life and exercise price (or ratio of market price to exercise price) as the option being valued.{p_end}

{marker 04}{bf:{err:{dlgtab:References}}}

{p 4 8 2}Black, F., and M.S. Scholes (1973)
{cmd: "The Pricing of Options and Corporate Liabilities",}
{it:Journal of Political Economy, 81 (May/June)}. 637-659

{p2colreset}{...}
{marker 05}{bf:{err:{dlgtab:Examples}}}

  {stata clear all}

  {stata sysuse imvol.dta, clear}

  {stata db imvol}

  {stata imvol ps pk , ir(ir)   time(t)    option(put)}

  {stata imvol ps pk , ir(ir)   time(t)    option(call)}
  
  {stata imvol ps pk , ir(0.12) time(0.50) option(call)}

. imvol ps pk , ir(ir) time(t) option(put)

===============================================================
* Black-Scholes European Pricing Option Model
===============================================================
- Ps     = Stock  Pric                           =   100.0000
- Pk     = Strike Price                          =   110.0000
- Pf     = Frame Prime                           =    26.3878
- Time   = Expiration Time                       =     0.5000
- IR     = Interest Rate                         =     0.1200
- Option = CALL or Put Price Option              =     2.0000
- Imv    = Implied Volatility CaLL or Put Option =     0.1222
===============================================================

{marker 06}{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Assistant Professor}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email:   {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage:{col 27}{browse "http://emadstat.110mb.com/stata.htm"}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

  {hi:Sahra Khaleel A. Mickaiel}
  {hi:Professor}
  {hi:Cairo University - Faculty of Agriculture - Department of Economics - Egypt}
  {hi:Email:   {browse "mailto:sahra_atta@hotmail.com":sahra_atta@hotmail.com}}

{bf:{err:{dlgtab:imvol Citation}}}

{phang}Shehata, Emad Abd Elmessih & Sahra Khaleel A. Mickaiel (2012){p_end}
{phang}{cmd:IMVOL: "Stata Module to Compute Implied Volatility Black-Scholes European Option Pricing Model"}{p_end}

{title:Online Help:}

{p 2 12 2} {helpb bsopm}, {helpb imvol}. {opt (if installed)}.{p_end}

{psee}
{p_end}

