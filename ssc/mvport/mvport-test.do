  ** mvport command
  * Testing the examples of mvport v2.0
  * Alberto Dorantes, Aug 27, 2016
    
*Collects online monthly stock data (adjusted prices) from Yahoo Finance with the user command returnsyh. This command also calculates simple and continuous compounded returns:
    . returnsyh AAPL MSFT GE GM WMT XOM, fm(1) fd(1) fy(2012) lm(12) ld(31) ly(2015) frequency(m) price(adjclose)

  
*    Estimates the global minimum variance portfolio :
    . gmvport r_AAPL r_MSFT r_GE r_GM r_WMT r_XOM

*    Estimates the minimum variance portfolio with a monthly required return of 0.50%:
    . mvport r_AAPL r_MSFT r_GE r_GM r_WMT r_XOM, ret(0.005)

 *   Estimates the minimum variance portfolio with a monthly required return of 0.50%, but now without allowing for short sales:
    . mvport r_AAPL r_MSFT r_GE r_GM r_WMT r_XOM, ret(0.005) noshort

 *    --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
         
 *   Estimates the same as above, but restricting periods starting from Jan 2013:
    . mvport r_* if period>=tm(2013m1), ret(0.005) noshort

  *  Calculates the minimum variance portfolio restricting the weights to be at least 10% for all instruments, with a required rate of 1.0%:
    . mvport r_* , ret(0.01) minweight(0.10)

   * Calculates the minimum variance portfolio restricting the weights to be less or equal to 30% with a required rate of 1.0% :
    . mvport r_* , ret(0.01) noshort maxweight(0.30)

    *Calculates the minimum variance portfolio restricting the weights to be less or equal to 30% and greater or equal to 10% (with a required rate of 1.0%):
    . mvport r_* , ret(0.01) noshort maxw(0.30) minw(0.10)

 *   Calculates the minimum variance portfolio with different minimum weights for each instrument with a required rate of 1.0%:
    . mvport r_* , ret(0.01) rminweights(0.1 0.1 0.1 0 0.16 0)
 *   Negative minimum weights for each instrument can also be specified.

 *   Calculates the minimum variance portfolio with different maximum weights for each instrument with a required rate of 1.0%:
    . mvport r_* , ret(0.01) rmaxweights(0.5 0.2 0.4 0.4 0.25 0.15)

  *   --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  *  Calculates the expected returns of the instruments using the Exponential Weighted Moving Average (EWMA) method with a constant lamda=0.94:
    . meanrets r_AAPL r_MSFT r_GE r_GM , lew(0.94)
 *   Saving the matrix of expected returns in a vector:
    . matrix mrets=r(meanrets)

 *   Calculates the variance-covariance matrix of the instruments using the EWMA method with a constant lamda=0.94:
    . varrets r_AAPL r_MSFT r_GE r_GM , lew(0.94)
 *   Saving the variance-covariance matrix in a local matrix:
    . matrix cov=r(cov)

 *   Calculates the minimum variance portfolio using the calculated expected returns and variance-covariance matrix using the EWMA method, and with a required rate of 1.5%:
    . mvport r_AAPL r_MSFT r_GE r_GM, ret(0.015) covm(cov) mrets(mrets)
