  ** simport command 
  * Testing the examples of mvport v2.0
  * Alberto Dorantes, Aug 27, 2016

 * Collects online monthly stock data (adjusted prices) from Yahoo Finance with the user command returnsyh. This command also calculates simple and continuous compounded returns:
    . returnsyh AAPL MSFT GE GM WMT, fm(1) fd(1) fy(2012) lm(12) ld(31) ly(2015) frequency(m) price(adjclose)

 *   Generates 6,000 random portfolios inside the efficient frontier using 4 continuously compounded returns:
    . simport r_AAPL r_MSFT r_GE r_GM, nport(6000)

 *   Generates 4,000 random portfolios inside the efficient frontier using the 5 continuously componded returns of the dataset, and excluding observations if a missing value is found:
    . simport r_*, nport(4000) casewise

  