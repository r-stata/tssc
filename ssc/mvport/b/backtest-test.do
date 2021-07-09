  ** backtest command 
  * Testing the examples of mvport v2.0
  * Alberto Dorantes, Aug 27, 2016

* Collects online daily stock data from Yahoo Finance for 2014 and 2015.
    . returnsyh AAPL MSFT GE, fm(1) fd(1) fy(2014) lm(12) ld(31) ly(2015) frequency(d) price(adjclose)

 *    --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

 *   Defines a portfolio weight matrix indicating 30% for Apple, Inc, 20% for Microsoft Corp, and 50% for General Electric Co.:
    . matrix WPORT1=(0.3\0.2\0.5)

 *    --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

 *   Labels the row names for the matrix with the company/ticker names:
    . matrix rownames WPORT1=APPLE MICROSOFT GENERAL_ELECTRIC


 *    --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

         
 *   Performs the backtest for the whole period. The holding period return of the portfolio for the whole period is calculated:
    . backtest p_adjclose_AAPL p_adjclose_MSFT p_adjclose_GE, weights(WPORT1)

 *    --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

 *   Performs the backtest for a specified period. The holding period return of the portfolio for 2015 is calculated:
    . backtest p_adjclose_AAPL p_adjclose_MSFT p_adjclose_GE if period>=td(01jan2015) & period<=td(31dec2015), weights(WPORT1)

