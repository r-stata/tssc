 ** cmline command 
  * Testing the examples of mvport v2.0
  * Alberto Dorantes, Aug 27, 2016


* Collect online monthly stock data (adjusted prices) from Yahoo Finance with the user command returnsyh. This command also calculates simple and continuous compounded returns:
    . returnsyh AAPL MSFT GE GM WMT XOM, fm(1) fd(1) fy(2012) lm(12) ld(31) ly(2015) frequency(m) price(adjclose)

*    Run the capital market line using a monthly risk-free rate of 0% with the continuously compounded returns, and creates 100 portfolios along the efficient frontier:
    . cmline r_AAPL r_MSFT r_GE r_GM r_WMT r_XOM, nport(100) rfrate(0)

*    Run the capital market line without allowing for short sales:
    . cmline r_AAPL r_MSFT r_GE r_GM r_WMT r_XOM, nport(100) rfrate(0) noshort

*     --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
         
*    Run the capital market line without allowing for short sales, restricting periods starting from Jan 2013. The default values for risk-free rate (0%) and number of portfolios (100) will be used:
    . cmline r_* if period>=tm(2013m1), noshort

*    Calculates the capital market line restricting the weights to be at least 10% for all instruments:
    . cmline r_* , noshort minweight(0.10)

*    Calculates the capital market line restricting the weights to be less or equal to 30% :
    . cmline r_* , noshort maxweight(0.30)

*    Calculates the capital market line restricting the weights to be less or equal to 30% and greater or equal to 10%:
    . cmline r_* , noshort maxw(0.30) minw(0.10)

*    Calculates the capital market line with different minimum weights for each instrument:
    . cmline r_* , rminweights(0 0.1 0.1 0 0.16 0)
*    Negative minimum weights for each instrument can also be specified.

*    Calculates the capital market line with different maximum weights for each instrument:
    . cmline r_* , rmaxweights(0.5 0.2 0.4 0.4 0.25 0.15)

*     --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

*    Calculates the expected returns of the instruments using the Exponential Weighted Moving Average (EWMA) method with a constant lamda=0.94:
    . meanrets r_AAPL r_MSFT r_GE r_GM , lew(0.94)
*    Saving the matrix of expected returns in a vector:
    . matrix mrets=r(meanrets)

 *   Calculates the variance-covariance matrix of the instruments using the EWMA method with a constant lamda=0.94:
    . varrets r_AAPL r_MSFT r_GE r_GM , lew(0.94)
*    Saving the variance-covariance matrix in a local matrix:
    . matrix cov=r(cov)

*    Calculates the capital market line using the calculated expected returns and variance-covariance matrix using the EWMA method:
    . cmline r_AAPL r_MSFT r_GE r_GM, covm(cov) mrets(mrets)
*    Any variance-covariance matrix can be used for the calculation of the global minimum variance portfolio.

*    Store stock weights, standard deviation and expected return of the 100 portfolios that lie on the efficient frontier (using Stata matrices):
    . matrix alphacml_weights=r(walphacml)
    . matrix cml_port_ret=r(vrcml)
    . matrix cml_port_sd=r(vsdcml)
    . matrix sharpe_ratio=r(sharpe)
    . matrix port_weights_no_shorting=r(wef)
    . matrix port_std_dev_no_shorting=r(vsdef)
    . matrix port_ret_no_shorting=r(vref)
    . matrix port_sharpe_ratios=r(vsharpe)

*    Display the return and risk of the tangency (optimal) portfolio:
    . display "The expected return of the tangency portfolio is " r(rop) ", and its standard deviation of returns is " r(sdop)

*    Display the weight vector of the tangency portfolio:
    . matrix list r(wop)

*    Storing weights, standard deviation, expected returns and Sharpe ratios of the efficient frontier portfolios in one matrix:
    . matrix portfolios = port_weights_no_shorting, port_std_dev_no_shorting, port_ret_no_shorting, port_sharpe_ratios

*    Storing weights, standard deviation, expected returns of the portfolios that lie on the capital market line :
    . matrix cml = alphacml_weights, cml_port_sd, cml_port_ret

*    Write both matrices to an Excel Workbook (cmline.xls) in 2 sheets using the user command xml_tab:
    . xml_tab portfolios using "cmline.xls", replace sheet("Efrontier w Sharpe R") format ((S3120) (N1118)) title(Efficient Frontier Portfolios and its Sharpe Ratios (without allowing for short sales))
    . xml_tab cml using "cmline.xls", append sheet("Portfolios along the CML") format ((S3120) (N1118)) title(Capital Market Line Portfolios)

