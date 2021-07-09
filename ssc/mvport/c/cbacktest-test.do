 ** cbacktest command 
  * Testing the examples of mvport v2.0
  * Alberto Dorantes, Aug 27, 2016

*    Collects online daily stock data from Yahoo Finance for 2014 and 2015.
    . returnsyh AAPL MSFT GE, fm(1) fd(1) fy(2014) lm(12) ld(31) ly(2015) frequency(d) price(adjclose)

*     --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

*    Defines two weight matrices for two portfolios:
*    Portfolio 1: 30% for Apple, Inc, 20% for Microsoft Corp, and 50% for General Electric, Co.:
*    Portfolio 2: 50% for Apple, Inc, 25% for Microsoft Corp, and 25% for General Electric, Co.:
    . matrix WPORT1=(0.3\0.2\0.5)
    . matrix WPORT2=(0.5\0.25\0.25)

 *    --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

 *   Generates the cumulative holding returns of the portfolios for the whole period. For each period, the holding period return of the portfolio is calculated:
    . cbacktest p_adjclose_AAPL p_adjclose_MSFT p_adjclose_GE, gen(portret1) timevar(period) weights(WPORT1) nograph
    . cbacktest p_adjclose_AAPL p_adjclose_MSFT p_adjclose_GE, gen(portret2) timevar(period) weights(WPORT2) nograph

 *    --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

 *   Makes a graph to compare the performance of both portfolios over time:
    . tsline portret1 portret2

  *   --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  *  Generates and graphs the cumulative holding return of the portfolio 1 for a specified period. The holding period return of the portfolio for all days in 2015 (starting from Jan 01 2015) is calculated:
    . cbacktest p_adjclose_AAPL p_adjclose_MSFT p_adjclose_GE if period>=td(01jan2015) & period<=td(31dec2015), gen(portret1_1) timevar(period) weights(WPORT1)

