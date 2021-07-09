  ** efrontier command 
  * Testing the examples of mvport v2.0
  * Alberto Dorantes, Aug 27, 2016

   
 *   Collect online monthly stock data (adjusted prices) from Yahoo Finance with the user command returnsyh. This command also calculates simple and continuous compounded returns:
    . returnsyh AAPL MSFT GE GM WMT XOM, fm(1) fd(1) fy(2012) lm(12) ld(31) ly(2015) frequency(m) price(adjclose)

 *   Calculates the efficient frontier with the continuously compounded returns, and creates 100 portfolios along the efficient frontier:
    . efrontier r_AAPL r_MSFT r_GE r_GM r_WMT r_XOM, nport(100)

 *    --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
         
 *   Calculates the efficient frontier restricting periods starting from Jan 2013. The default value for the number of portfolios (100) will be used:
    . efrontier r_* if period>=tm(2013m1)

 *   Calculates the efficient frontier restricting the weights to be at least 10% for all instruments:
    . efrontier r_* , minweight(0.10)

 *   Calculates the efficient frontier restricting the weights to be less or equal to 30% :
    . efrontier r_* , maxweight(0.30)

 *   Calculates the efficient frontier restricting the weights to be less or equal to 30% and greater or equal to 10%:
    . efrontier r_* , maxw(0.35) minw(0.05)

 *   Calculates the efficient frontier with different minimum weights for each instrument:
    . efrontier r_* , rminweights(0 0.1 0.1 0 0.16 0)
 *   Negative minimum weights for each instrument can also be specified.

 *   Calculates the efficient frontier with different maximum weights for each instrument:
    . efrontier r_* , rmaxweights(0.5 0.5 0.4 0.4 0.25 0.15)

  *   --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

 *   Calculates the expected returns of the instruments using the Exponential Weighted Moving Average (EWMA) method with a constant lamda=0.94:
    . meanrets r_AAPL r_MSFT r_GE r_GM , lew(0.94)
 *   Saving the matrix of expected returns in a vector:
    . matrix mrets=r(meanrets)

 *   Calculates the variance-covariance matrix of the instruments using the EWMA method with a constant lamda=0.94:
    . varrets r_AAPL r_MSFT r_GE r_GM , lew(0.94)
 *   Saving the variance-covariance matrix in a local matrix:
    . matrix cov=r(cov)

 *   Calculates the efficient frontier using the calculated expected returns and variance-covariance matrix using the EWMA method:
    . efrontier r_AAPL r_MSFT r_GE r_GM, covm(cov) mrets(mrets)
 *   Any variance-covariance matrix can be used for the calculation of the global minimum variance portfolio.

  *  Store stock weights, standard deviation and expected return of the 50 portfolios that lie on the efficient frontier (using Stata matrices):
    . matrix port_weighs_no_shorting=r(wefwos)
    . matrix port_weighs_shorting=r(wefws)
    . matrix port_std_dev_no_shorting=r(sdefwos)
    . matrix port_std_dev_shorting=r(sdefws)
    . matrix port_expected_ret_no_shorting=r(refwos)
    . matrix port_expected_ret_shorting=r(refws)

   * For both cases, with and without short sales, store weights, standard deviation and expected returns of portfolios in a matrix:
    . matrix port_no_shorting = port_weighs_no_shorting, port_std_dev_no_shorting, port_expected_ret_no_shorting
    . matrix port_shorting = port_weighs_shorting, port_std_dev_shorting, port_expected_ret_shorting

  *  Write both matrices to an Excel Workbook (efrontier.xls) in 2 sheets using the user command xml_tab (you must have the xml_tab command installed):
    . xml_tab port_no_shorting using "efrontier.xls", replace sheet("Port-NO short sells") format ((S3120) (N1118)) title(Efficient Frontier Portfolios without allowing for short sales)
    . xml_tab port_shorting using "efrontier.xls", append sheet("Port-short sells") format ((S3120) (N1118)) title(Efficient Frontier Portfolios allowing for short sales)

 
