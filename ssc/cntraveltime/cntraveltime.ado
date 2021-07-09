* Authors:
* Chuntao Li, Ph.D. , China Stata Club(爬虫俱乐部)(chtl@hust.edu.cn)
* Xueren Zhang, China Stata Club(爬虫俱乐部)(zhijunzhang_hi@163.com)
* Yuan Xue, China Stata Club(爬虫俱乐部)(xueyuan@hust.com)
* December 4th, 2018
* Program written by Dr. Chuntao Li, Xueren Zhang and Yuan Xue
* Used to get the information of distance and time from one location to another from Baidu Map API
* and can only be used in Stata version 14.0 or above
* Original Data Source: http://api.map.baidu.com
* Please do not use this code for commerical purpose
program define cntraveltime
	
	if _caller() < 14.0 {
		disp as error "this is version `=_caller()' of Stata; it cannot run version 14.0 programs"
		exit 9
	}
	version 14
	syntax, baidukey(string) startlat(string) startlng(string) endlat(string) endlng(string) [transport(string) instruction ///
		intercity(numlist int max=2 >=0 <=2 ) tactic(real 0)]

	if "`transport'" == "" local transport = "bus"
	if !inlist("`transport'", "car", "bus", "bike") {
		disp as error "you specify the option routetype() wrongly."
		exit 198
	}

	if "`transport'" != "bus" & "`intercity'" != "" {
		disp as error `"you could not specify the option intercity() when you specify "bike" in the option transport()."'
		exit 198
	}

	if "`tactic'" == "" local tactic = 0
	else if ("`transport'" == "bus" & !inrange(`tactic', 0, 5)) ///
	| ("`transport'" == "car" & !inlist(`tactic', 0, 1)) ///
	| ("`transport'" == "bike" & `tactic' != 0 & !inrange(`tactic', 3, 11)) {
		disp as error "you specify a wrong number in the option tactic()"
		exit 198
	}

	if "`intercity'" == "" {
		local intercitytrans = 0
		local intercitytactic = 0
	}
	else {
		numlist `"`intercity'"'
		if wordcount(r(numlist)) == 1 {
			local intercitytrans = word(r(numlist), 1)
			local intercitytactic = 0
		}
		else {
			local intercitytrans = word(r(numlist), 1)
			local intercitytactic = word(r(numlist), 2)
		}
	}

	qui {
		tempvar baidumap

		if "`transport'" == "bus" {
			local url1 = "http://api.map.baidu.com/direction/v2/transit?origin="
			local url2 = "&ak=`baidukey'&tactics_incity=`tactic'&trans_type_intercity=`intercitytrans'&tactics_intercity=`intercitytactic'&output=xml"
		}
		else if "`transport'" == "bike" {
			local url1 = "http://api.map.baidu.com/direction/v2/riding?origin="
			local url2 = "&ak=`baidukey'&riding_type=`tactic'&output=xml"
		}
		else {
			local url1 = "http://api.map.baidu.com/direction/v2/driving?origin="
			local url2 = "&ak=`baidukey'&tactics=`tactic'&output=xml"
		}

		gen `baidumap' = ""
		forvalues i = 1/`=_N' {
			replace `baidumap' = fileread("`url1'`=`startlat'[`i']',`=`startlng'[`i']'&destination=`=`endlat'[`i']',`=`endlng'[`i']'`url2'") in `i'
			local times = 0
			while filereaderror(`baidumap'[`i']) != 0 {
				sleep 1000
				local times = `times' + 1
				replace `baidumap' = fileread("`url1'`=`startlat'[`i']',`=`startlng'[`i']'&destination=`=`endlat'[`i']',`=`endlng'[`i']'`url2'") in `i'
				if `times' > 10 {
					disp as error "Internet speeds is too low to get the data"
					exit `=filereaderror(`baidumap'[`i'])'
				}
			}
			if !index(`baidumap'[`i'],"<status>0</status>") {
				noisily disp as text "please check the information of location in `i'"
				continue
			}
			if index(`baidumap'[`i'],"AK有误请检查再重试") {
				disp as error "error: please check your baidukey"
				exit 198
			}
		}
		replace `baidumap' = ustrregexra(`baidumap', "\s", "")
		replace `baidumap' = substr(`baidumap', index(`baidumap', "<routes>"), index(`baidumap', "</routes>") - index(`baidumap', "<routes>") + length("</routes>"))
		gen distance = real(ustrregexs(1)) if ustrregexm(`baidumap', `"<distance>(.*?)</distance>"')
		gen duration = real(ustrregexs(1)) if ustrregexm(`baidumap', `"<duration>(.*?)</duration>"')
		
		if "`instruction'" != "" {
			replace `baidumap' = substr(`baidumap', index(`baidumap', "<steps>"), index(`baidumap', "</steps>") - index(`baidumap', "<steps>") + length("</steps>"))
			replace `baidumap' = ustrregexra(`baidumap', "&lt;.*?&gt;", "")
			if "`transport'" == "bus" {
				replace `baidumap' = ustrregexra(`baidumap', "^.*?<instructions>", "")
				replace `baidumap' = ustrregexra(`baidumap', "</instructions>.*?<instructions>", ",")
				replace `baidumap' = ustrregexra(`baidumap', "</instructions>.*$", "")
			}
			else if "`transport'" == "bike" {
				replace `baidumap' = ustrregexra(`baidumap', "^.*?<instructions>", "")
				replace `baidumap' = ustrregexra(`baidumap', "</instructions>.*?<turn_type>", ",")
				replace `baidumap' = ustrregexra(`baidumap', "</turn_type>.*?<instructions>", ",")
				replace `baidumap' = ustrregexra(`baidumap', "</turn_type>.*$", "")
				replace `baidumap' = ustrregexra(`baidumap', ",+$", "")
			}
			else {
				replace `baidumap' = ustrregexra(`baidumap', "^.*?<road_name>", "")
				replace `baidumap' = ustrregexra(`baidumap', "</road_name>.*?<road_name>", ",")
				replace `baidumap' = ustrregexra(`baidumap', "</road_name>.*$", "")
			}
			gen instruction = `baidumap'
		}
	}
end
