 ** gmvport command 
  * Testing the examples of mvport v2.0
  * Alberto Dorantes, Aug 27, 2016

  *  Collect online monthly stock data (adjusted prices) from Yahoo Finance with the user command returnsyh. This command also calculates simple and continuous compounded returns:
    . returnsyh AAPL MSFT GE GM WMT XOM, fm(1) fd(1) fy(2012) lm(12) ld(31) ly(2015) frequency(m) price(adjclose)

  *  Calculates the global variance minimum portfolio using 6 continuously compounded returns, and allowing for short sales :
    . gmvport r_AAPL r_MSFT r_GE r_GM r_WMT r_XOM

  *  Calculates the global variance minimum portfolio using 6 continuously compounded returns, without allowing for short sales :
    . gmvport r_AAPL r_MSFT r_GE r_GM r_WMT r_XOM, noshort

  *   --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  *  Calculates the global variance minimum portfolio without allowing for short sales, restricting periods starting from Jan 2013:
    . gmvport r_* if period>=tm(2013m1), noshort

  *  Calculates the global variance minimum portfolio restricting the weights to be at least 10% for all instruments:
    . gmvport r_* , noshort minweight(0.10)

  *  Calculates the global variance minimum portfolio restricting the weights to be less or equal to 30% :
    . gmvport r_* , noshort maxweight(0.30)

  *  Calculates the global variance minimum portfolio restricting the weights to be less or equal to 30% and greater or equal to 10%:
    . gmvport r_* , noshort maxw(0.30) minw(0.10)

  *  Calculates the global variance minimum portfolio with different minimum weights for each instrument:
    . gmvport r_* , rminweights(0 0.1 0.1 0 0.15 0)
  *  Negative minimum weights for each instrument can also be specified.

  *  Calculates the global variance minimum portfolio with different maximum weights for each instrument:
    . gmvport r_* , rmaxweights(0.5 0.2 0.4 0.4 0.25 0.15)

  *   --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  *  Calculates the expected returns of the instruments using the Exponential Weighted Moving Average (EWMA) method with a constant lamda=0.94:
    . meanrets r_* , lew(0.94)
  *  Saving the matrix of expected returns in a vector:
    . matrix mrets=r(meanrets)

  *  Calculates the variance-covariance matrix of the instruments using the EWMA method with a constant lamda=0.94:
    . varrets r_* , lew(0.94)
  *  Saving the variance-covariance matrix in a local matrix:
    . matrix cov=r(cov)

  *  Calculates the global variance minimum portfolio using the calculated expected returns and variance-covariance matrix using the EWMA method:
    . gmvport r_* , covm(cov) mrets(mrets)
  *  Any variance-covariance matrix can be used for the calculation of the global minimum variance portfolio.
