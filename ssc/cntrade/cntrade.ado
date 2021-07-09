* Authors:
* Chuntao Li, Ph.D. , China Stata Club(爬虫俱乐部)(chtl@zuel.edu.cn)
* Xuan Zhang, Ph.D., China Stata Club(爬虫俱乐部)(zhangx@zuel.edu.cn)
* Yuan Xue, China Stata Club(爬虫俱乐部)(xueyuan19920310@163.com)
* January 30th, 2014
* Updated on July 24th, 2017
* Updated on Oct 29th, 2018
* Program written by Dr. Chuntao Li and Dr. Xuan Zhang, and updated by Yuan Xue
* Used to download stock tradding data for listed Chinese Firms
* Original Data Source: www.163.com 
* Please do not use this code for commerical purpose

program define cntrade
	
	if _caller() < 12.0 {
		disp as error "this is version `=_caller()' of Stata; it cannot run version 12.0 programs"
		exit 9
	}

	syntax anything(name = tickers), [ path(string) stock index]

	if "`stock'" != "" & "`index'" != "" {
		disp as error "you can not specify both 'stock' and 'index'"
		exit 198
	}
	
	local address "http://quotes.money.163.com/service/chddata.html"

	if "`index'" == "" local field "TCLOSE;HIGH;LOW;TOPEN;LCLOSE;CHG;PCHG;TURNOVER;VOTURNOVER;VATURNOVER;TCAP;MCAP"
	else local field "TCLOSE;HIGH;LOW;TOPEN;LCLOSE;CHG;PCHG;VOTURNOVER;VATURNOVER"

	local start 19900101
	local end: disp %dCYND date("`c(current_date)'", "DMY")

	if `"`path'"' != "" {
		capture mkdir `"`path'"'
	} 

	else {
		local path `"`c(pwd)'"'
		disp `"`path'"'
	}
	
	if regexm(`"`path'"', "(/|\\)$") local path = regexr(`"`path'"', ".$", "")

	foreach name in `tickers' {

		if length("`name'") > 6 {
			disp as error `"`name' is an invalid stock code"'
			exit 601
		} 
		while length("`name'") < 6 {
			local name = "0" + "`name'"
		}
		
		if "`index'" == "" {
			if `name' >= 600000 local url "`address'?code=0`name'&start=`start'&end=`end'&fields=`field'"
			else local url "`address'?code=1`name'&start=`start'&end=`end'&fields=`field'"
		}
				
		else {
			if `name' <= 1000 local url "`address'?code=0`name'&start=`start'&end=`end'&fields=`field'"
			else local url "`address'?code=1`name'&start=`start'&end=`end'&fields=`field'"
		}

		tempfile tempcsvfile
		
		qui {
			capture copy `"`url'"' `"`tempcsvfile'"', replace
			local times = 0
			while _rc != 0 {
				local times = `times' + 1
				sleep 1000
				cap copy `"`url'"' `"`tempcsvfile'"', replace
				if `times' > 10 {
					disp as error "Internet speeds is too low to get the data"
					exit 601
				}
			}

			if _caller() >= 14 {
				import delimited using `"`tempcsvfile'"', clear encoding("gb18030")
			}
			else {
				insheet using `"`tempcsvfile'"', clear
			}

			if `=_N' == 0 {
				disp as error `"`name' is an invalid stock code"'
				clear
				exit 601
			}

			if "`index'" == "" & c(stata_version) < 14 {
				gen date = date(v1, "YMD")
				drop v1 
				format date %dCY-N-D
				label var date "Trading Date"
				rename v2 stkcd 
				capture destring stkcd, replace force ignor(')
				label var stkcd "Stock Code"
				rename v3 stknme
				label var stknme "Stock Name"
				rename v4 clsprc 
				label var clsprc "Closing Price"
				drop if clsprc == 0
				rename v5 hiprc 
				label var hiprc  "Highest Price"
				rename v6 lowprc 
				label var lowprc "Lowest Price"
				rename v7 opnprc
				label var opnprc "Opening Price"
				destring v10, force replace
				rename v10 rit
				replace rit = 0.01 * rit
				label var rit "Daily Return"
				destring v11, force replace
				rename v11 turnover
				label var turnover "Turnover rate"
				rename v12 volume
				label var volume "Trading Volume"
				rename v13 transaction
				label var transaction "Trading Amount in RMB"
				rename v14 tcap
				label var tcap "Total Market Capitalization"
				rename v15 mcap
				label var mcap "Circulation Market Capitalization"
				drop v8 v9
				order stkcd date
			}
			else if "`index'" == "" {
				gen date = date(日期, "YMD")
				drop 日期 
				format date %dCY-N-D
				label var date "Trading Date"
				rename 股票代码 stkcd
				capture destring stkcd, replace force ignor(')
				label var stkcd "Stock Code"
				rename 名称 stknme
				label var stknme "Stock Name"
				rename 收盘价 clsprc
				label var clsprc "Closing Price"
				drop if clsprc == 0
				rename 最高价 hiprc
				label var hiprc  "Highest Price"
				rename 最低价 lowprc
				label var lowprc "Lowest Price"
				rename 开盘价 opnprc
				label var opnprc "Opening Price"
				destring 涨跌幅, replace force
				rename 涨跌幅 rit
				replace rit = 0.01 * rit
				label var rit "Daily Return"
				destring 换手率, replace force
				rename 换手率 turnover
				label var turnover "Turnover rate"
				rename 成交量 volume
				label var volume "Trading Volume"
				rename 成交金额 transaction
				label var transaction "Trading Amount in RMB"
				rename 总市值 tcap
				label var tcap "Total Market Capitalization"
				rename 流通市值 mcap
				label var mcap "Circulation Market Capitalization"
				drop 前收盘 涨跌额
				order stkcd date
			}
			else if c(stata_version) < 14 {
				gen date = date(v1, "YMD")
				drop v1 
				format date %dCY-N-D
				label var date "Trading Date"
				rename v2 indexcd 
				capture destring indexcd, replace force ignor(')
				label var indexcd "Index Code"
				rename v3 indexnme
				label var indexnme "Index Name"
				rename v4 clsprc
				label var clsprc "Closing Price"
				drop if clsprc == 0
				rename v5 hiprc
				label var hiprc  "Highest Price"
				rename v6 lowprc
				label var lowprc "Lowest Price"
				rename v7 opnprc
				label var opnprc "Opening Price"
				destring v10, replace force
				rename v10 rmt
				replace rmt = 0.01 * rmt
				label var rmt "Daily Return"
				rename v11 volume
				label var volume "Trading Volume"
				destring v12, replace force
				rename v12 transaction
				label var transaction "Trading Amount in RMB"
				drop v8 v9
				order indexcd date
			}
			else {
				gen date = date(日期, "YMD")
				drop 日期
				format date %dCY-N-D
				label var date "Trading Date"
				rename 股票代码 indexcd
				capture destring indexcd, replace force ignor(')
				label var indexcd "Index Code"
				rename 名称 indexnme
				label var indexnme "Index Name"
				rename 收盘价 clsprc
				label var clsprc "Closing Price"
				drop if clsprc == 0
				rename 最高价 hiprc
				label var hiprc "Highest Price"
				rename 最低价 lowprc
				label var lowprc "Lowest Price"
				rename 开盘价 opnprc
				label var opnprc "Opening Price"
				destring 涨跌幅, replace force
				rename 涨跌幅 rmt
				replace rmt = 0.01 * rmt
				label var rmt "Daily Return"
				rename 成交量 volume
				label var volume "Trading Volume"
				destring 成交金额, replace force
				rename 成交金额 transaction
				label var transaction "Trading Amount in RMB"
				drop 前收盘 涨跌额
			}
			sort date 
			save `"`path'/`name'"', replace
			noi disp as text `"file `name'.dta has been saved"'
		}		
	}
end 
