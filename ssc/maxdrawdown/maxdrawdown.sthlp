
help gsdata                                                                                                                                                                               
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Title

maxdrawdown -- Calculate the maximum drawdown of a stock, fund or other financial product


Syntax

        maxdrawdown <varlist>

Description

In the industry, maximum drawdown is a very important risk management factor.When you are trying to evaluate a fund manager's performance,you cannot
miss the maximum drawdown.you must sort the date correctly before using the command.

Stored results

Scalars

r(drawdown)   the maximum drawdown

Examples

* if we want to calculate the S&P500's max drawdown in a given range,we can try the codes:
webuse sp500,clear
maxdrawdown close
    

Authors
        
        Zhiyong Li
        University of International Business and Economics
        Beijing,China
        lizhiyong618@foxmail.com

Acknowledgement

Thanks to Professor Christopher F. Kit Baum (College of Boston),I learned a lot from his book <Introduction to Stata Programming>.
