
help cnindex                                                                                                                                                                                 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Title

cnindex --Downloads historical Market Quotations for a list of stock index data in ShangHai or ShenZhen from Net Ease (a web site providing financial information in China, www.163.com).


Syntax

        cnindex codelist, [options]

    options                               Description
    ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      path(foldername)                    Specify a folder where output .dta files will be saved in

    ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    codelist codelist is a list of index codes to be downloaded from Net. They are separated by spaces. For each valid index code, there will be one stata format data file as an output
    containing all the trading information for that stock.  ck code will be the file name, with .dta as the extension. In China, index are identified by a six digit numbers, not tickers
    as in the United States. Examples of Stock Codes and the name of the list firms are as following:
    000001 The Shanghai Composite Index
    000300 CSI 300 Index
    399001 Shenzhen Component Index
    
    path specifies the folder where the output .dta files are to be saved.
    The folders can be either existed or a new folder.
    If the folder specified does not exist, . cnindex will create it automatically.


Examples

    . cnindex 000001
    . cnindex 000001, path(c:/temp/)
    . cnindex 000001 000300 399001, path(c:/temp/)
    . cnindex 000001 000300 399001

Authors
	
	Zhiyong Li
	Beijing Idata Education&Technology Co., Ltd.
	Beijing,china
	lizhiyong618@foxmail.com
