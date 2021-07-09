help gsdata                                                                                                                                                                               
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Title

gsdata --Downloads high frequency data for a list of stock in ShangHai or ShenZhen from Net Ease (a web site providing financial information in China, www.163.com).


Syntax

        gsdata <ticker symbol>,y(year) m(month) d(day)

Description

gsdata currently queries Net Ease's API for stock transaction data in a day, but you should notice that our codes can only download trading data in recent
two weeks. Examples may be out of date,you can try recent trading days to use the codes. 

Examples

    . gsdata 000001,y(2016) m(09) d(01) 
	. use 000001.dta,clear  
    

Authors
        
        Zhiyong Li
        University of International Business and Economics
        Beijing,China
        lizhiyong618@foxmail.com

Acknowledgement

Professor Christopher F. Kit Baum (College of Boston) also contributed to the codes, his patience and profession impressed me. 
