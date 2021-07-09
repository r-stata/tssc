  ** meanrets command
  * Testing the examples of mvport v2.0
  * Alberto Dorantes, Aug 27, 2016



 *   Collect online monthly stock data (adjusted prices) from Yahoo Finance with the user command returnsyh. This command also calculates simple and continuous compounded returns:
    . returnsyh AAPL MSFT GE, fm(1) fd(1) fy(2012) lm(12) ld(31) ly(2015) frequency(m) price(adjclose)

 *   Calculates the expected simple returns from continuously compounded (cc) return variables:
    . meanrets r_AAPL r_MSFT r_GE

 *   Calculates the expected simple returns from simple return variables:
    . meanrets R_AAPL R_MSFT R_GE, simplereturn

 *   Calculates the expected simple returns from cc return variables, and using the exponentially weighted moving average method with a lamda=0.94:
    . meanrets r_AAPL r_MSFT r_GE, leweight(0.94)
 *   The weights for each observation according to the EWMA method were stored in the r(W) matrix. The weights are adjusted so that the sum of all weights must be equal to one.
    . matrix list r(W)

 *   Calculates the expected simple returns from cc return variables. An existing variable is used to weight each observation to compute a weighted average:
    . meanrets r_AAPL r_MSFT r_GE, weightvar(vol_MSFT)


