 ** ovport command 
  * Testing the examples of mvport v2.0
  * Alberto Dorantes, Aug 27, 2016

*    Collects online monthly stock data (adjusted prices) from Yahoo Finance with the user command returnsyh. This command also calculates simple and continuous compounded returns:
    . returnsyh AAPL MSFT GE GM WMT XOM, fm(1) fd(1) fy(2012) lm(12) ld(31) ly(2015) frequency(m) price(adjclose)

*    Estimates the optimal (tangency) portfolio using a monthly risk-free rate of 0% with the continuously compounded returns, and creates 100 portfolios along the efficient frontier:
    . ovport r_AAPL r_MSFT r_GE r_GM r_WMT r_XOM, nport(100) rfrate(0)

*    Estimates the optimal (tangency) portfolio without allowing for short sales:
    . ovport r_AAPL r_MSFT r_GE r_GM r_WMT r_XOM, nport(100) rfrate(0) noshort

*     --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
         
*    Estimates the optimal portfolio without allowing for short sales, restricting periods starting from Jan 2013. The default values for risk-free rate (0%) and number of portfolios (100) will be used:
    . ovport r_* if period>=tm(2013m1), noshort

*    Calculates the optimal portfolio restricting the weights to be at least 10% for all instruments:
    . ovport r_* , noshort minweight(0.10)

*    Calculates the optimal portfolio restricting the weights to be less or equal to 30% :
    . ovport r_* , noshort maxweight(0.30)

*    Calculates the optimal portfolio restricting the weights to be less or equal to 30% and greater or equal to 10%:
    . ovport r_* , noshort maxw(0.30) minw(0.10)

*    Calculates the optimal portfolio with different minimum weights for each instrument:
    . ovport r_* , rminweights(0 0.1 0.1 0 0.16 0)
*    Negative minimum weights for each instrument can also be specified.

*    Calculates the optimal portfolio with different maximum weights for each instrument:
    . ovport r_* , rmaxweights(0.5 0.2 0.4 0.4 0.25 0.15)

*     --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

*    Calculates the expected returns of the instruments using the Exponential Weighted Moving Average (EWMA) method with a constant lamda=0.94:
    . meanrets r_AAPL r_MSFT r_GE r_GM , lew(0.94)
*    Saving the matrix of expected returns in a vector:
    . matrix mrets=r(meanrets)

*    Calculates the variance-covariance matrix of the instruments using the EWMA method with a constant lamda=0.94:
    . varrets r_AAPL r_MSFT r_GE r_GM , lew(0.94)
*    Saving the variance-covariance matrix in a local matrix:
    . matrix cov=r(cov)

*    Calculates the optimal portfolio using the calculated expected returns and variance-covariance matrix using the EWMA method:
    . ovport r_AAPL r_MSFT r_GE r_GM, covm(cov) mrets(mrets)
*    Any variance-covariance matrix can be used for the calculation of the global minimum variance portfolio.

