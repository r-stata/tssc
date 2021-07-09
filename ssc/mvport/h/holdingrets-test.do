 ** holdingrets command 
  * Testing the examples of mvport v2.0
  * Alberto Dorantes, Aug 27, 2016
  
 *   Collects online daily stock data from Yahoo Finance for 2014 and 2015.
    . returnsyh AAPL MSFT, fm(1) fd(1) fy(2014) lm(12) ld(31) ly(2015) frequency(d) price(adjclose)

*     --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

*    Calculates the holding return of both stocks for the whole period.
    . holdingrets p_adjclose_AAPL p_adjclose_MSFT

*     --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

*    Calculates the holding return of both stocks from the first day of Jan 2015 to Dec 31, 2015.
    . holdingrets p_adjclose_AAPL p_adjclose_MSFT if period>=td(01jan2015) & period<=td(31dec2015)

