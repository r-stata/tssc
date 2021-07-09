* Authors:
* Chuntao Li, Ph.D. , China Stata Club(爬虫俱乐部)(chtl@zuel.edu.cn)
* Yuan Xue, China Stata Club(爬虫俱乐部)(xueyuan19920310@163.com)
* October 27th, 2016
* Updated on November 2nd, 2018
* Original Data Source: https://finance.sina.com.cn/
* Please do not use this code for commerical purpose
capture program drop cnintraday

program cnintraday
	
	if _caller() < 12.0 {
		disp as error "this is version `=_caller()' of Stata; it cannot run version 12.0 programs"
		exit 9
	}

	syntax anything(name=tickers), [date(string) path(string)]

	local currentdate: di %dCY-N-D date("`c(current_date)'","DMY")
	if "`date'" == "" local date "`currentdate'"
	if "`date'" != "" {
		if length("`date'") != 10 {
			disp as error `"`date' is an invalid date"'
			exit 601
		}
	}
	if "`date'" == "`currentdate'" {
		local url = "http://vip.stock.finance.sina.com.cn/quotes_service/view/vMS_tradedetail.php?symbol="
	}
	else {
		local url = "http://market.finance.sina.com.cn/transHis.php?symbol="
	}

	if "`path'" != "" capture mkdir `"`path'"'
	else {
		local path `"`c(pwd)'"'
		di "`path'"
	}

	foreach name in `tickers' {
		if length("`name'") > 6 {
			disp as error `"`name' is an invalid stock code"'
			exit 601
		} 

		while length("`name'") < 6 {
			local name = "0`name'"
		}

		tempfile sctemp
		tempname td

		qui {
			if `name' >= 600000 {
				local urluse = "`url'sh"
			}
			else {
				local urluse = "`url'sz"
			}
			
			postfile `td' str8 time str10 price str10 chngprc str20 volume str20 transaction str9 tradedirection using `"`path'/`name'_`date'.dta"', replace

			forvalues i = 1/10000 {
				
				cap copy `"`urluse'`name'&date=`date'&page=`i'"' `"`sctemp'"', replace
				local times = 0
				while _rc != 0 {
					local times = `times' + 1
					sleep 1000
					cap copy `"`urluse'`name'&date=`date'&page=`i'"' `"`sctemp'"', replace
					if `times' > 10 {
						disp as error "Internet speeds is too low to get the data"
						exit 601
					}
				}

				infix strL v 1-100000 using `"`sctemp'"', clear
				if c(stata_version) >= 14.0 {
					replace v = ustrfrom(v, "gb18030", 1)
				}
				keep if index(v,"</th></tr>")
				if _N == 0 {
					continue, break
				}
				split v, p("<th>" "</th>" "<td>" "</td>")
				if "`date'" == "`currentdate'" {
					keep v2 v4 v8 v10 v12 v14
				}
				else {
					keep v2 v4 v6 v8 v10 v12
				}
				rename _all (var1 var2 var3 var4 var5 var6)
				replace var6 = regexs(1) if regexm(var6,">(.+)<")
				forvalues j = 1/`=_N' {
					post `td' (var1[`j']) (var2[`j']) (var3[`j']) (var4[`j']) (var5[`j']) (var6[`j'])
				}
			}
			postclose `td'
			use `"`path'/`name'_`date'.dta"', clear
			if _N == 0 {
				clear
				erase `"`path'/`name'_`date'.dta"'
				disp as error `"please check the date and stock code"'
				exit 601
			}

			sort time
			gen stkcd = "`name'"
			label var stkcd "Stock Code"
			gen date = "`date'"
			label var date "Trading Date"
			label var time "Trading Time"
			label var price "Trading Price"
			label var chngprc "Price Change"
			label var volume "Trading volume(hundred shares)"
			label var transaction "Trading Amount in RMB"
			label var tradedirection "Buying, Selling or Neutral"
			if c(stata_version) >= 14 {
				replace tradedirection = "Buying" if tradedirection == ustrunescape("\u4e70\u76d8")
				replace tradedirection = "Selling" if tradedirection == ustrunescape("\u5356\u76d8")
				replace tradedirection = "Neutral" if tradedirection == ustrunescape("\u4e2d\u6027\u76d8")
			}
			else {
				replace tradedirection = "Buying" if index(tradedirection, "`=char(242)'")
				replace tradedirection = "Selling" if index(tradedirection, "`=char(244)'")
				replace tradedirection = "Neutral" if index(tradedirection, "`=char(214)'")
			}
			destring stkcd price volume transaction, replace ignore(",")
			order stkcd date
			sort time
			drop if time == ""
			drop if price == 0
			drop if tradedirection == "--"
			duplicates drop
			destring chngprc, ignore("+") force replace
			bysort time (chngprc): keep if _n == 1
			replace chngprc = price - price[_n - 1] if chngprc == . | chngprc == price
			compress
		}
		save `"`path'/`name'_`date'.dta"', replace
		di as text "You've got the `name''s trading detail data in `date'"
	}
end
