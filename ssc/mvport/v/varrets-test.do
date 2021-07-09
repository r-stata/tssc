  ** varrets command v2.0
  * Testing the examples of mvport v2.0
  * Alberto Dorantes, Aug 27, 2016

 *   Collect online monthly stock data (adjusted prices) from Yahoo Finance with the user command returnsyh. This command also calculates simple and continuous compounded returns:
    . returnsyh AAPL MSFT GE, fm(1) fd(1) fy(2012) lm(12) ld(31) ly(2015) frequency(m) price(adjclose)

 *   Calculates the expected variance-covariance matrix of 3 asset returns (continuously compounded):
    . varrets r_AAPL r_MSFT r_GE

 *   Calculates the expected variance-covariance matrix of 3 asset returns assigning exponential weights for each observation according to the Exponential Weighted Moving Average method with a lamda=0.94:
    . varrets r_AAPL r_MSFT r_GE, leweight(0.94)
 *   The weights for each observation according to the EWMA method were stored in the r(W) matrix. The weights are adjusted so that the sum of all weights must be equal to one.
    . matrix list r(W)

 *   Calculates the expected variance-covariance matrix of 3 asset returns using an existing variable to weight each observation:
    . varrets r_AAPL r_MSFT r_GE, weightvar(vol_AAPL)
 