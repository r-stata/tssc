* Authors:
* Chuntao Li, Ph.D. , China Stata Club(爬虫俱乐部)(chtl@hust.edu.cn)
* Xueren Zhang, China Stata Club(爬虫俱乐部)(zhijunzhang_hi@163.com)
* Yuan Xue, China Stata Club(爬虫俱乐部)(xueyuan@hust.com)
* December 4th, 2018
* Program written by Dr. Chuntao Li, Xueren Zhang and Yuan Xue
* Used to get information about a given keyword location within a certain range of a place from Baidu Map API
* and can only be used in Stata version 14.0 or above
* Original Data Source: http://api.map.baidu.com
* Please do not use this code for commerical purpose
program define cnmapsearch
	
	if _caller() < 14.0 {
		disp as error "this is version `=_caller()' of Stata; it cannot run version 14.0 programs"
		exit 9
	}
	version 14
	syntax, baidukey(string) LATitude(string) LONGitude(string) KEYword(string) ///
		[NUMber(real 10) RADius(real 2000) FILter(string asis) seefilter prefix(string) ///
		result(string asis)]

	qui {
		tempvar baidumap

		if `"`filter'"' == "" {
			gen `prefix'filter_type = ""
			gen `prefix'sort_name = ""
		}
		else {
			mata filter_token(`"`filter'"')
			if `filter_error' == 1 {
				disp as error "more than 2 parts in the option filter()"
				exit 198
			}
			if !inlist("`filter_type'", "cater", "life", "hotel") {
				disp as error "you specify wrong category in the option filter()"
				exit 198
			}
			if ("`filter_type'" == "cater" & !inlist("`filter_sort'", "distance", "price", "overall_rating", "taste_rating", "service_rating", "")) ///
			 | ("`filter_type'" == "life" & !inlist("`filter_sort'", "distance", "price", "overall_rating", "comment_rating", "")) ///
			 | ("`filter_type'" == "hotel" & !inlist("`filter_sort'", "distance", "price", "total_score", "level", "health_score", "")) {
				disp as error "you specify wrong preference in the option filter()"
				exit 198
			}
			gen `prefix'filter_type = "`filter_type'"
			gen `prefix'sort_name = "`filter_sort'"
		}

		if `"`result'"' == "" local result = `"name address telephone tag distance"'
		mata result_token(`"`result'"')
		if `result_error' == 1 {
			disp as error "you specify the option result() wrongly"
			exit 198
		}


		gen `baidumap' = ""
		forvalues i = 1/`=_N' {
			replace `baidumap' = fileread(`"http://api.map.baidu.com/place/v2/search?query=`keyword'&page_size=`number'&page_num=0&scope=2&location=`=`latitude'[`i']',`=`longitude'[`i']'&radius=`radius'&filter=industry_type:`=`prefix'filter_type[1]'|sort_name:`=`prefix'sort_name[1]'&output=xml&ak=`baidukey'"') in `i'
			local times = 0
			while filereaderror(`baidumap'[`i']) != 0 {
				sleep 1000
				local times = `times' + 1
				replace `baidumap' = fileread(`"http://api.map.baidu.com/place/v2/search?query=`keyword'&page_size=`number'&page_num=0&scope=2&location=`=`latitude'[`i']',`=`longitude'[`i']'&radius=`radius'&filter=industry_type:`=`prefix'filter_type[1]'|sort_name:`=`prefix'sort_name[1]'&output=xml&ak=`baidukey'"') in `i'
				if `times' > 10 {
					noi disp as error "Internet speeds is too low to get the data"
					exit `=filereaderror(`baidumap'[`i'])'
				}
			}
			if index(`baidumap'[`i'], "AK有误请检查再重试") {
				noisily di as error "error: please check your baidukey"
				exit 198
			}
			else if index(`baidumap'[`i'],"<status>2</status>") {
				di in red "error: please check your location in `i'"
				continue
			}
		}
		replace `baidumap' = ustrregexra(`baidumap', "\s*", "")

		replace `baidumap' = substr(`baidumap', index(`baidumap', "<result>"), .)
		replace `baidumap' = substr(`baidumap', 1, index(`baidumap', "</results>") - 1)
		split `baidumap', p(`"</result>"')
		local nvars = r(nvars)
		forvalues var_i = 1/`nvars' {
			forvalues r_i = 1/`result_num' {
				gen `prefix'`result_`r_i''`var_i' = ustrregexs(1) if ustrregexm(`baidumap'`var_i', "<`result_`r_i''>(.*?)</`result_`r_i''>")
			}
		}
		if "`seefilter'"==""{
			drop `prefix'filter_type `prefix'sort_name
		}
		drop `baidumap'*
		cap destring distance*, replace
	}
end

cap mata mata drop filter_token()
mata
	void function filter_token(string scalar filter_list) {

		string rowvector filter_vector

		filter_vector = tokens(filter_list)
		st_local("filter_error", "0")
		if (cols(filter_vector) == 1) {
			st_local("filter_type", filter_vector[1, 1])
			st_local("filter_sort", "")
		}
		else if (cols(filter_vector) == 2) {
			st_local("filter_type", filter_vector[1, 1])
			st_local("filter_sort", filter_vector[1, 2])
		}
		else st_local("filter_error", "1")
	}
end

cap mata mata drop result_token()
mata
	void function result_token(string scalar result_list) {

		string rowvector result_vector
		string rowvector all_vector

		result_vector = tokens(result_list)
		all_vector = tokens("name lat lng address province city area telephone tag detail_url distance overall_rating service_rating environment_rating hygiene_rating facility_rating")
		st_local("result_error", "0")
		for (i = 1; i <= cols(result_vector); i++) {
			if ((all_vector :== result_vector[1, i]) == J(1, cols(all_vector), 0)) {
				st_local("result_error", "1")
				break
			}
			st_local(sprintf("result_%g", i), result_vector[1, i])
		}
		st_local("result_num", sprintf("%g", cols(result_vector)))
	}
end
