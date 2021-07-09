* Authors:
* Chuntao Li, Ph.D. , China Stata Club(爬虫俱乐部)(chtl@zuel.edu.cn)
* Yuan Xue, China Stata Club(爬虫俱乐部)(xueyuan19920310@163.com)
* October 16st, 2019
* Program written by Dr. Chuntao Li and Yuan Xue
* Used to converts a location (pair of longitude and latitude) into the corresponding address in Chinese with Baidu Map API v3.0
* and can only be used in Stata version 14.0 or above
* Original Data Source: http://api.map.baidu.com
* Please do not use this code for commerical purpose

cap prog drop cnaddress

program cnaddress
	version 14.0
	syntax, baidukey(string) LATitude(string) LONGitude(string) [COUNtry(string) PROvince(string) CITy(string) DIStrict(string) STReet(string) ADDress(string) COORDtype(string)]

	if "`coordtype'" == "" local coordtype = "bd09ll"
	else if !inlist("`coordtype'", "bd09ll", "bd09mc", "gcj02ll", "wgs84ll") {
		di as error "You can only specify the option coordtype() among bd09ll, bd09mc, gcj02ll or wgs84ll"
	}
	
	quietly {
		tempvar baidumap
		if "`country'" == "" local country country
		if "`province'" == "" local province province
		if "`city'" == "" local city city
		if "`district'" == "" local district district
		if "`street'" == "" local street street
		if "`address'" == "" local address address

		gen `baidumap' = ""
		forvalues i = 1/`=_N' {
			if `latitude'[`i'] == . | `longitude'[`i'] == . {
				noisily di as text "Location in Obs `i' is missing, no address extracted"
				continue
			}
			replace `baidumap' = fileread(`"http://api.map.baidu.com/reverse_geocoding/v3/?ak=`baidukey'&output=json&coordtype=`coordtype'&location=`=string(`latitude'[`i'])',`=string(`longitude'[`i'])'"') in `i'
			local times = 0
			while filereaderror(`baidumap'[`i']) != 0 {
				local times = `times' + 1
				replace `baidumap' = fileread(`"http://api.map.baidu.com/reverse_geocoding/v3/?ak=`baidukey'&output=json&coordtype=`coordtype'&location=`=string(`latitude'[`i'])',`=string(`longitude'[`i'])'"') in `i'
				if `times' > 10 {
					disp as error "Internet speeds is too low to get the data"
					exit `=filereaderror(`baidumap'[`i'])'
				}
			}
			if index(`baidumap'[`i'],"AK有误请检查再重试") {
				di as error "error: please check your baidukey"
				continue, break
			}
			else if index(`baidumap'[`i'], `"address":"",""') {
				noisily di as text "Location in Obs `i' is wrong, no address extracted"
				replace `baidumap' = "" in `i'
			}
		}
		gen `country' = ustrregexs(1) if ustrregexm(`baidumap', `""country":"(.*?)",""')
		gen `province' = ustrregexs(1) if ustrregexm(`baidumap', `"province":"(.*?)",""')
		gen `city' = ustrregexs(1) if ustrregexm(`baidumap', `"city":"(.*?)",""')
		gen `district' = ustrregexs(1) if ustrregexm(`baidumap', `"district":"(.*?)",""')
		gen `street' = ustrregexs(1) if ustrregexm(`baidumap', `"street":"(.*?)",""')
		gen `address' = ustrregexs(1) if ustrregexm(`baidumap', `"address":"(.*?)",""')
	}
end
