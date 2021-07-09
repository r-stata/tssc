* Authors:
* Chuntao Li, Ph.D. , China Stata Club(爬虫俱乐部)(chtl@zuel.edu.cn)
* Zijian LI, China Stata Club(爬虫俱乐部)(jeremylee_41@163.com)
* Yuan Xue, China Stata Club(爬虫俱乐部)(xueyuan@hust.edu.cn)
* Updated on Oct 31th, 2018
* Fix some bugs and make this command run faster
* Original Data Source: http://quote.cfi.cn/stockList.aspx
* Please do not use this code for commerical purpose
program define cnstock
	
	if _caller() < 14.0 {
		disp as error "this is version `=_caller()' of Stata; it cannot run version 14.0 programs"
		exit 9
	}
	
	syntax anything(name = exchange), [path(string)]
	
	clear

	if "`path'" != "" {
		capture mkdir `"`path'"'
	}

	if "`path'" == "" {
		local path `"`c(pwd)'"'
		disp `"`path'"'
	}

	if "`exchange'"== "all" {
		local exchange SHA SZM SZSM SZGE SHB SZB
	}

	qui {
		tempfile `exchange'

		foreach name in `exchange'{
			
			if "`name'" == "SHA" local c "11"
			else if "`name'" == "SZM" local c "12"
			else if "`name'" == "SZSM" local c "13"
			else if "`name'" == "SZGE" local c "14"
			else if "`name'" == "SHB" local c "15"
			else if "`name'" == "SZB" local c "16"
			else {
				disp as error `"`name' is an invalid exchange"'
				exit 601
			}

			infix strL v 1-100000 using "http://quote.cfi.cn/stockList.aspx?t=`c'", clear
			keep if index(v, "<div id='divcontent' runat=")
			split v, p("</a></td>")
			local nvars = r(nvars)
			drop v
			set obs `nvars'
			forvalues vari = 2/`nvars' {
				replace v1 = v`vari'[1] in `vari'
			}
			keep v1
			gen stknm = ustrregexs(1) if ustrregexm(v1, `".html">(.*?)\(\d"')
			gen stkcd = ustrregexs(1) if ustrregexm(v1, "\((.*?)\)")
			drop v
			keep if ustrregexm(stkcd, "^000") | ustrregexm(stkcd, "^001") | ustrregexm(stkcd, "^002") | ustrregexm(stkcd, "^2") | ustrregexm(stkcd, "^3") | ustrregexm(stkcd, "^6") |ustrregexm(stkcd, "^9")
			destring stkcd, replace
			format %06.0f stkcd 
			save `"``name''"', replace
		}
		
		clear
		foreach name in `exchange' {
			append using `"``name''"'
		}
		drop if stkcd == 963 & stknm == "中证下游"

		label var stkcd stockcode
		label var stknm stockname
	}

	di "You've got the stock names and stock codes from `exchange'"
	save `"`path'/cnstock.dta"', replace
end
