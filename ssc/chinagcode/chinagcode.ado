* Authors:
* Chuntao Li, Ph.D. , China Stata Club(爬虫俱乐部)(chtl@zuel.edu.cn)
* Yuan Xue, China Stata Club(爬虫俱乐部)(xueyuan19920310@163.com)
* Updated on October 21st, 2017
* Updated on November 5th, 2018
* Program written by Dr. Chuntao Li and Yuan Xue
* Used to extracts the longitude and latitude of Chinese address from Baidu Map API
* and can only be used in Stata version 14.0 or above
* Original Data Source: http://api.map.baidu.com
* Please do not use this code for commerical purpose
program define chinagcode

	if _caller() < 14.0 {
		disp as error "this is version `=_caller()' of Stata; it cannot run version 14.0 programs"
		exit 9
	}

	syntax, baidukey(string) [PROvince(string) CITy(string) ADDress(string) DIStrict(string) FULLADDress(string) LATitude(string) LONGitude(string) ffirst]
	
	if "`province'" == "" & "`city'" == "" & "`address'" == "" & "`district'" == "" & "`fulladdress'" == "" {
		di as error "error: must specify at least one option of 'province', 'city', 'district', 'address' and 'fulladdress'"
		exit 198
	}
	
	if "`ffirst'" != "" & "`fulladdress'" == "" {
		di as error "error: must specify specify option 'fulladdress' in order to use ffirst"
		exit 198
	}
	
	qui {
		tempvar blank work1 work2 baidumap
		gen `blank' = ""
		if "`province'" == "" local province `blank'
		if "`city'" == "" local city `blank'
		if "`district'" == "" local district `blank'
		if "`address'" == "" local address  `blank'
		if "`longitude'" == "" local longitude longitude
		if "`latitude'" == "" local latitude latitude
		if "`ffirst'" != "" {
			gen `work1' = `fulladdress'
			gen `work2' = `province' + `city' + `district' + `address'
		}
		else if "`province'" == "`blank'" & "`city'" == "`blank'" & "`district'" == "`blank'" & "`address'" == "`blank'" {
			gen `work1' = `fulladdress'
			gen `work2' = `province' + `city' + `district' + `address'
		}
		else {
			gen `work1' = `province' + `city' + `district' + `address'
			if "`fulladdress'" == "" gen `work2' = ""
			else gen `work2' = `fulladdress'
		}
				
		drop `blank'
		if c(stata_version) >= 15 {
			replace `work1' = geturi(`work1')
			replace `work2' = geturi(`work2')
		}
		else {
			replace `work1' = upper(subinstr(tobytes(`work1', 1), "\x", "%", .))
			replace `work2' = upper(subinstr(tobytes(`work2', 1), "\x", "%", .))
		}

		gen `baidumap' = ""		
		forvalues i = 1/`=_N' {
			replace `baidumap' = fileread(`"http://api.map.baidu.com/geocoder/v2/?output=json&ak=`baidukey'&address=`=`work1'[`i']'"') in `i'
			local times = 0
			while filereaderror(`baidumap'[`i']) != 0 {
				sleep 1000
				local times = `times' + 1
				replace `baidumap' = fileread(`"http://api.map.baidu.com/geocoder/v2/?output=json&ak=`baidukey'&address=`=`work1'[`i']'"') in `i'
				if `times' > 10 {
					noi disp as error "Internet speeds is too low to get the data"
					exit `=filereaderror(`baidumap'[`i'])'
				}
			}
			if index(`baidumap'[`i'], "AK有误请检查再重试") {
				noisily di as error "error: please check your baidukey"
				exit 198
			}
			else if index(`baidumap'[`i'], "lack address or location") | index(`baidumap'[`i'], "无相关结果") {
				noisily di as text "the address is wrong or missing in `i', neither longitude nor latitude can be extracted"
			}	
		}
		gen `longitude' = ustrregexs(1) if ustrregexm(`baidumap', `""lng":(.*?),"')
		gen `latitude'  = ustrregexs(1) if ustrregexm(`baidumap', `""lat":(.*?)\}"')
		destring `longitude' `latitude', replace
	}
end
