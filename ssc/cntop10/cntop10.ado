* Authors:
* Chuntao Li, Ph.D. , China Stata Club(爬虫俱乐部)(chtl@zuel.edu.cn)
* Xueli Sun, China Stata Club(爬虫俱乐部)(13212746629@163.com)
* Yuan Xue, China Stata Club(爬虫俱乐部)(xueyuan@hust.edu.cn)
* December 26th, 2018
* Program written by Dr. Chuntao Li, Xueli Sun and Yuan Xue
* Used to download information of top 10 shareholders for listed Chinese Firms
* Can only be used in Stata version 14.0 or above
* Original Data Source: http://stockdata.stock.hexun.com
* Please do not use this code for commerical purpose
program define cntop10

	if _caller() < 14.0 {
		disp as error "this is version `=_caller()' of Stata; it cannot run version 14.0 programs"
		exit 9
	}
	version 14
	syntax anything(name = tickers), [path(string)]

	if "`path'" != "" cap mkdir `"`path'"'
	else {
		local path `"`c(pwd)'"'
		di `"`path'"'
	}

	if regexm("`path'", "(/|\\)$") local path = regexr("`path'", ".$", "")
	
	tempfile sctemp

	qui {
		foreach name in `tickers' {
			if length("`name'") > 6 {
				di as error `"`name' is an invalid stock code"'
				exit 601
			}
			while length("`name'") < 6 {
				local name = "0" + "`name'"
			}

			cap copy "http://stockdata.stock.hexun.com/2009_sdgd_`name'.shtml" `"`sctemp'"', replace
			local times = 0
			while _rc != 0 & _rc != 1 {
				if _rc == 601 {
					clear
					di as error "`name' is an invalid stock code"
					exit 601
				}
				else {
					local times = `times' + 1
					sleep 1000
					cap copy "http://stockdata.stock.hexun.com/2009_sdgd_`name'.shtml" `"`sctemp'"', replace
					if `times' > 10 {
						di as error "Internet speeds is too low to get the data"
						exit 2
					}
				}
			}

			clear
			set obs 1
			gen v = fileread(`"`sctemp'"')
			replace v = ustrfrom(v, "gb18030", 1)
			replace v = ustrregexs(1) if ustrregexm(v, "dateArr =(.*?);</script>")
			split v ,p('],[')
			local n = r(nvars)
			drop v
			set obs `n'
			forvalue a = 2/`n' {
				replace v1 = v`a'[1] in `a'
			}
			keep v1
			keep if index(v1, "年度")
			if _N == 0 {
				noisily di in green "The annual report of `name' is unavailable since it has just been public this year."
				clear
				continue, break 
			}
			replace v1 = subinstr(v1,"[['","",.)
			replace v1 = substr(v1,1,4)
			local saveornot = 0
			levelsof v1, local(levels)

			foreach y of local levels {

				cap copy "http://stockdata.stock.hexun.com/2008/sdgd.aspx?stockid=`name'&accountdate=`y'-12-31" `"`sctemp'"', replace
				local times1 = 0
				while _rc != 0 & _rc != 1 {
					if _rc == 601 {
						clear
						di as error "`name' is an invalid stock code"
						exit 601
					}
					else {
						local times1 = `times1' + 1
						sleep 1000
						cap copy "http://stockdata.stock.hexun.com/2008/sdgd.aspx?stockid=`name'&accountdate=`y'-12-31" `"`sctemp'"', replace
						if `times1' > 10 {
							di as error "Internet speeds is too low to get the data"
							exit 2
						}
					}
				}
				
				clear
				set obs 1
				gen v = fileread(`"`sctemp'"')
				replace v = ustrfrom(v, "gb18030", 1)
				if index(v, `"<div class="tishi">"') == 0 {
					continue
				}
				replace v = ustrregexs(1) if ustrregexm(v, `"<div class="tishi">(.*)</span></td></tr>"')
				split v, p("</tr>")
				local nvars = r(nvars)
				drop v
				set obs `nvars'
				forvalues i = 2/`nvars' {
					replace v1 = v`i'[1] in `i'
				}
				keep v1
				split v1, p("</td>")
				drop v1
				foreach v of varlist _all {
					replace `v' = ustrregexra(`v', "<.*?>", "")
					replace `v' = "" if `v' == "-"              
				}
				destring v12 v13 v15, ignore(",") percent force replace 
				rename _all (shareholder shares shareratio nature change)
				label var shareholder "name of shareholders"
				label var shares "number of shares(ten thousand shares)"
				label var shareratio "shareholding ratio"
				label var nature "nature of shares"
				label var change "change of shareholding ratio"
				gen stkcd = `name'
				gen year = `y'
				label var stkcd "stock code"
				order stkcd year
				gsort -shareratio
				gen rank = _n
				keep if rank <= 10
				label var rank "rank of shareholding ratio"
				compress
				if `saveornot' == 0 {
					save `"`path'/`name'"', replace
					local saveornot = 1
				}
				else {
					append using `"`path'/`name'"'
					sort stkcd year rank
					format %50s shareholder
					save `"`path'/`name'"', replace
				}
			}
			cap use `"`path'/`name'"', clear
			if _rc == 601 {
				clear
				noisily disp as text "The shareholder information of `name' is unavailable since there is no annual data"
			}
			else {
				noisily disp as text "You've got the `name''s information of top 10 shareholders"
			}
		}
	}
end
