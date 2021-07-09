* Authors:
* Chuntao Li, Ph.D. , China Stata Club(爬虫俱乐部)(chtl@zuel.edu.cn)
* Jinyang Li, China Stata Club(爬虫俱乐部)(ljy940704@163.com)
* Yuan Xue, China Stata Club(爬虫俱乐部)(xueyuan@hust.edu.cn)
* November 26th, 2018
* Program written by Dr. Chuntao Li, Jinyang Li and Yuan Xue
* Used to download financial data for listed Chinese Firms
* A new program substitute for chinafin 
* use Chinese name of account as variables' names
* and can only be used in Stata version 14.0 or above
* Original Data Source: http://stockdata.stock.hexun.com
* Please do not use this code for commerical purpose

program define cnar

	if _caller() < 14.0 {
		disp as error "this is version `=_caller()' of Stata; it cannot run version 14.0 programs"
		exit 9
	}

	syntax anything(name = tickers), [path(string)]

	if "`path'" != "" {
		cap mkdir `"`path'"'
	}
	else {
		local path `"`c(pwd)'"'
		di `"`path'"'
	}
	if regexm("`path'", "(/|\\)$") { 
		local path = regexr("`path'", ".$", "")
	}

	tempfile sctemp xjll lr zcfz

	qui {
		foreach name in `tickers' {
			if length("`name'") > 6 {
				di as error `"`name' is an invalid stock code"'
				exit 601
			}
			while length("`name'") < 6 {
				local name = "0"+"`name'"
			}

			foreach annual in lr xjll zcfz {
				cap copy "http://stockdata.stock.hexun.com/2008/`annual'.aspx?stockid=`name'&accountdate=2018.12.31" `"`sctemp'"', replace
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
						cap copy "http://stockdata.stock.hexun.com/2008/`annual'.aspx?stockid=`name'&accountdate=2018.12.31" `"`sctemp'"', replace
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
				replace v = ustrregexs(1) if ustrregexm(v, "dateArr = \[\['(.*?)'\]\];</script>")
				split v ,p('],[')
				drop v
				unab allvar: _all
				mata tokennumber("`allvar'")
				set obs `=scalar(tokennumber)'
				gen v = ""
				forvalues v_i = 1/`=scalar(tokennumber)' {
					replace v = v`v_i'[1] in `v_i'
				}
				keep v
				keep if index(v,"年度")
				local hasdata = 1
				if _N == 0 {
					noisily di in green "The annual report of `name' is unavailable since it has just been public this year."
					local hasdata = 0
					clear
					continue, break 
				}

				replace v = substr(v, 1, 4)
				destring, replace
				sort v
				local begin = v[1]
				levelsof v, local(year)

				foreach i in `year' {

					ifhasdata, type(`"`annual'"') stockid(`"`name'"') year(`"`i'"') save(`"`sctemp'"') time(0)

					replace v = substr(v, strpos(v, `"<span id="ControlEx1_lbl">"') + 91, strpos(v, `"</div></td></span>"') - strpos(v, `"<span id="ControlEx1_lbl">"') - 91)
					split v, p(<strong>)
					drop v
					unab allvar: _all
					mata tokennumber("`allvar'")
					set obs `=scalar(tokennumber)'
					gen v = ""
					forvalues v_i = 1/`=scalar(tokennumber)' {
						replace v = v`v_i'[1] in `v_i'
					}
					keep v
					split v, p(</strong>) 
					drop v
					replace v2 = ustrregexra(v2, "<.*?>", "") 
					replace v1 = ustrregexra(v1, "^（.*）", "") 
					replace v2 = subinstr(v2, "--", "", .)
					replace v1 = "四（2）、其他原因对现金的影响" if v1 == "四(2)、其他原因对现金的影响"
					replace v1 = "附注2、不涉及现金收支的重大投资和筹资活动" if v1 == "2、不涉及现金收支的重大投资和筹资活动"
					replace v1 = "附注3、现金及现金等价物净变动情况" if v1 == "3、现金及现金等价物净变动情况" 
					forvalues n_i = 1/`=_N' {
						gen `=v1[`n_i']' = `"`=v2[`n_i']'"'
					}
					drop v1 v2
					keep in 1
					if `i' == `begin' {
						save `"``annual''"', replace
					}
					else {
						append using `"``annual''"'
						save `"``annual''"', replace
					}
				}
				
				if "`annual'" == "lr" {
					rename 备注 利润表备注 
					destring 一、营业收入 - 稀释每股收益, replace ignore(",") 
				}
				else if "`annual'" == "xjll" {
					rename 报告年度 会计年度 
					rename 备注 现金流量表备注
					cap destring 一、经营活动产生的现金流量-现金及现金等价物净增加额, ignore(",") replace
					cap destring 一、经营活动产生的现金流量-期末现金及现金等价物余额, ignore(",") replace
				}
				else {
					rename 备注 资产负债表备注
					cap destring 货币资金-负债和所有者（或股东权益）合计, ignore(",") replace
					cap destring 现金及存放同业款项-负债和所有者权益（或股东权益）总计, ignore(",") replace
				}
				sort 会计年度
				save `"``annual''"', replace
			}
			
			if `hasdata' == 0 {
				continue
			}

			**merge data**
			use `"`zcfz'"', clear
			merge 1:1 会计年度 using `"`xjll'"'
			drop _m
			merge 1:1 会计年度 using `"`lr'"'
			drop _m
			sort 会计年度
			compress
			gen stkcd = `name'
			gen year = real(substr(会计年度, 1, 4))
			cap drop 五、每股收益
			cap drop 六、每股收益
			drop 会计年度 一、经营活动产生的现金流量 二、投资活动产生的现金流量 三、筹资活动产生的现金流量 四、汇率变动对现金的影响 四（2）、其他原因对现金的影响 五、现金及现金等价物净增加额 
			order stkcd year
			save `"`path'/`name'"', replace
		}
	}	
end

cap program drop getsourcecode
program define getsourcecode
	syntax, type(string) stockid(string) year(string) save(string) time(real)

	clear
	cap copy "http://stockdata.stock.hexun.com/2008/`type'.aspx?stockid=`stockid'&accountdate=`year'.12.31" `"`save'"', replace	
	if  _rc != 0 & _rc != 1 & `time' <= 10 {
		local time = `time' + 1
		sleep 1000
		getsourcecode, type(`"`type'"') stockid(`"`stockid'"') year(`"`year'"') save(`"`save'"') time(`time')
	}
	else if `time' > 10 {
		disp as error "Internet speeds is too low to get the data"
		exit 2
	}
end

cap program drop ifhasdata
program define ifhasdata
	syntax, type(string) stockid(string) year(string) save(string) time(real)

	getsourcecode, type(`"`type'"') stockid(`"`stockid'"') year(`"`year'"') save(`"`save'"') time(`time')

	set obs 1
	gen v = fileread(`"`save'"')
	replace v = ustrfrom(v, "gb18030", 1) 
	if !index(v, "</div></td></span>") {
		sleep 1000
		ifhasdata, type(`"`type'"') stockid(`"`stockid'"') year(`"`year'"') save(`"`save'"') time(`time')
	}
end

cap mata mata drop tokennumber()
mata
	function tokennumber(string scalar tokenstring) {
		token = tokens(tokenstring)
		st_numscalar("tokennumber", cols(token))
	}
end
