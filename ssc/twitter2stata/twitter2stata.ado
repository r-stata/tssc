*! version 1.0.3 14dec2017
/*
Copyright 2007 Yusuke Yamamoto

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
Distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
/*
12dec2017
	Fix to extend the new 280 character limit for tweets.
    Fixed stack trace for -searchtweets- and -tweets- when no results were found
       Now these commands state -0 obs-.
14dec2017
	Fixed proxy bug so that -twitter2stata- now works with firewalls.
*/

program define twitter2stata
	version 15

	global twitter2stata_jar_ver `""twitter2stata-1.0.4.jar""'

	javacall com.stata.drd.stTwitter setProxySettings, args(`"`c(httpproxy)'"' ///
		`"`c(httpproxyhost)'"' `"`c(httpproxyport)'"' `"`c(httpproxyauth)'"' ///
		`"`c(httpproxyuser)'"' `"`c(httpproxypw)'"') jars($twitter2stata_jar_ver)
	
	gettoken subcmd 0 : 0, parse(" ,")

	if `"`subcmd'"' == "get"		twitterGetPin `macval(0)'
	else if `"`subcmd'"' == "getp"		twitterGetPin `macval(0)'
	else if `"`subcmd'"' == "getpi"		twitterGetPin `macval(0)'
	else if `"`subcmd'"' == "getpin"	twitterGetPin `macval(0)'
	else if `"`subcmd'"' == "setpin" 	twitterSetPin `macval(0)'
	else if `"`subcmd'"' == "setaccess"	twitterSetKey `macval(0)'
	//else if `"`subcmd'"' == "setaccess"	twitterSetAccess `macval(0)'
	//else if `"`subcmd'"' == "setk"	twitterSetKey `macval(0)'
	//else if `"`subcmd'"' == "setke"	twitterSetKey `macval(0)'
	//else if `"`subcmd'"' == "setkey"	twitterSetKey `macval(0)'
	else if `"`subcmd'"' == "searcht"	twitterSearch `macval(0)'
	else if `"`subcmd'"' == "searchtw"	twitterSearch `macval(0)'
	else if `"`subcmd'"' == "searchtwe"	twitterSearch `macval(0)'
	else if `"`subcmd'"' == "searchtwee"	twitterSearch `macval(0)'
	else if `"`subcmd'"' == "searchtweet"	twitterSearch `macval(0)'
	else if `"`subcmd'"' == "searchtweets"	twitterSearch `macval(0)'
	else if `"`subcmd'"' == "searchu"	twitterSearchUsers `macval(0)'
	else if `"`subcmd'"' == "searchus"	twitterSearchUsers `macval(0)'
	else if `"`subcmd'"' == "searchuse"	twitterSearchUsers `macval(0)'
	else if `"`subcmd'"' == "searchuser"	twitterSearchUsers `macval(0)'
	else if `"`subcmd'"' == "searchusers"	twitterSearchUsers `macval(0)'
	else if `"`subcmd'"' == "lik"		twitterFav `macval(0)'
	else if `"`subcmd'"' == "like"		twitterFav `macval(0)'
	else if `"`subcmd'"' == "likes"		twitterFav `macval(0)'
	else if `"`subcmd'"' == "followi"	twitterFri `macval(0)'
	else if `"`subcmd'"' == "followin"	twitterFri `macval(0)'
	else if `"`subcmd'"' == "following"	twitterFri `macval(0)'
	else if `"`subcmd'"' == "followe"	twitterFol `macval(0)'
	else if `"`subcmd'"' == "follower"	twitterFol `macval(0)'
	else if `"`subcmd'"' == "followers"	twitterFol `macval(0)'
	else if `"`subcmd'"' == "lists"		twitterUserLists `macval(0)'
	else if `"`subcmd'"' == "listu"		twitterListUsers `macval(0)'
	else if `"`subcmd'"' == "listus"	twitterListUsers `macval(0)'
	else if `"`subcmd'"' == "listuse"	twitterListUsers `macval(0)'
	else if `"`subcmd'"' == "listuser"	twitterListUsers `macval(0)'
	else if `"`subcmd'"' == "listusers"	twitterListUsers `macval(0)'
	else if `"`subcmd'"' == "listt"		twitterListTweets `macval(0)'
	else if `"`subcmd'"' == "listtw"	twitterListTweets `macval(0)'
	else if `"`subcmd'"' == "listtwe"	twitterListTweets `macval(0)'
	else if `"`subcmd'"' == "listtwee"	twitterListTweets `macval(0)'
	else if `"`subcmd'"' == "listtweet"	twitterListTweets `macval(0)'
	else if `"`subcmd'"' == "listtweets"	twitterListTweets `macval(0)'
	else if `"`subcmd'"' == "tweets"	twitterGetUserTweets `macval(0)'
	else if `"`subcmd'"' == "place2shp"	twitterPlace2Shp `macval(0)'
	else if `"`subcmd'"' == "getuser"	twitterGetUser `macval(0)'
	else if `"`subcmd'"' == "getstatus"	twitterGetStatus `macval(0)'
	else {
		di as err `"twitter2stata: unknown subcommand `subcmd'"'
		exit 198
	}

	capture compress
end

program twitterGetPin
	version 15
	javacall com.stata.drd.stTwitter getPinUrl, args() jars($twitter2stata_jar_ver)
end

program twitterSetPin
	version 15

	syntax anything(name=pin id="pin")
	javacall com.stata.drd.stTwitter setPin, args(`"`pin'"') jars($twitter2stata_jar_ver)
end

program twitterSetKey
	version 15

	syntax anything(name=tokens id="tokens")

	tokenize `"`tokens'"'
	if `"`1'"' == "" {
		di as err "consumer key required"
		exit 100
	}
	if `"`2'"' == "" {
		di as err "consumer secret required"
		exit 100
	}
	if `"`3'"' == "" {
		di as err "access token required"
		exit 100
	}
	if `"`4'"' == "" {
		di as err "access token secret required"
		exit 100
	}
	if `"`5'"' != "" {
		di as err "too many arguments"
		exit 198
	}

	javacall com.stata.drd.stTwitter setKeys, args(`"`1'"' `"`2'"' `"`3'"' `"`4'"') jars($twitter2stata_jar_ver)
end

program twitterSetAccess
	version 15

	syntax anything(name=tokens id="tokens")

	tokenize `"`tokens'"'
	if `"`1'"' == "" {
		di as err "access token required"
		exit 100
	}
	if `"`2'"' == "" {
		di as err "access token secret required"
		exit 100
	}

	javacall com.stata.drd.stTwitter setAccess, args(`"`1'"' `"`2'"') jars($twitter2stata_jar_ver)
end

program twitterSearch, rclass
	version 15

	syntax anything(name=srch id="search string")	///
		[, lang(string)				///
		NUMTweets(integer 15000)		///
		DATErange(string)			///
		geo(string)				///
		type(string)				///
		sinceid(string)				///
		maxid(string)				///
		verbose					///
		clear]

	if ((c(changed) | c(k) | c(N)) & "`clear'" == "") {
		di as err "no; data in memory would be lost"
		exit 4
	}

	if `"`lang'"' == "" {
		local lang "en"
	}
	else if `"`lang'"' == "all" {
		local lang ""
	}

	tokenize `"`daterange'"', parse(" ,")
	if `"`daterange'"' != "" {
		if `"`1'"' == "," {
			local since ""
			local until `"`2'"'
		}
		else if `"`2'"' == "," {
			if `"`4'"' != "" {
				di as err "invalid {bf:daterange()} specification"
				di as err "    syntax is {bf:daterange([YYYY-MM-DD], [YYYY-MM-DD])}"
				exit 198
			}
			else {
				local since `"`1'"'
				local until `"`3'"'
			}
		}
		else if `"`2'"' == "" {
			local since `"`1'"'
			local until ""
		}
		else {
			di as err "invalid {bf:daterange()} specification"
			di as err "    syntax is {bf:daterange([YYYY-MM-DD], [YYYY-MM-DD])}"
			exit 198
		}

		// check syntax of since datestring
		tokenize `"`since'"', parse("-")
		if `"`since'"' != "" {
			if `"`2'"' != "-" | `"`4'"' != "-" {
				di as err "invalid {bf:daterange()} specification"
				di as err "    syntax is {bf:daterange([YYYY-MM-DD], [YYYY-MM-DD])}"
				exit 198
			}
			if length(`"`1'"') != 4 {
				di as err "invalid year in {bf:daterange()} specification"
				di as err "    syntax is {bf:daterange([YYYY-MM-DD], [YYYY-MM-DD])}"
				exit 198
				}
			if length(`"`3'"') != 2 {
				di as err "invalid month in {bf:daterange()} specification"
				di as err "    syntax is {bf:daterange([YYYY-MM-DD], [YYYY-MM-DD])}"
				exit 198
			}
			if length(`"`5'"') != 2 {
				di as err "invalid day in {bf:daterange()} specification"
				di as err "    syntax is {bf:daterange([YYYY-MM-DD], [YYYY-MM-DD])}"
				exit 198
			}
			capture confirm integer number `1'
			if _rc {
			di as err "invalid year in {bf:daterange()} specification"
				di as err "    syntax is {bf:daterange([YYYY-MM-DD], [YYYY-MM-DD])}"
				exit 198
			}
			capture confirm integer number `3'
			if _rc {
				di as err "invalid month in {bf:daterange()} specification"
				di as err "    syntax is {bf:daterange([YYYY-MM-DD], [YYYY-MM-DD])}"
				exit 198
			}
			if `3' > 12 {
				di as err "invalid month in {bf:daterange()} specification"
				di as err "    syntax is {bf:daterange([YYYY-MM-DD], [YYYY-MM-DD])}"
				exit 198
			}
			capture confirm integer number `5'
			if _rc {
				di as err "invalid day in {bf:daterange()} specification"
				di as err "    syntax is {bf:daterange([YYYY-MM-DD], [YYYY-MM-DD])}"
				exit 198
			}
			if `5' > 31 {
				di as err "invalid day in {bf:daterange()} specification"
				di as err "    syntax is {bf:daterange([YYYY-MM-DD], [YYYY-MM-DD])}"
				exit 198
			}
		}

		// check syntax of until datestring
		tokenize `"`until'"', parse("-")
		if `"`until'"' != "" {
			if `"`2'"' != "-" | `"`4'"' != "-" {
				di as err "invalid {bf:daterange()} specification"
				di as err "    syntax is {bf:daterange([YYYY-MM-DD], [YYYY-MM-DD])}"
				exit 198
			}
			if length(`"`1'"') != 4 {
				di as err "invalid year in {bf:daterange()} specification"
				di as err "    syntax is {bf:daterange([YYYY-MM-DD], [YYYY-MM-DD])}"
				exit 198
				}
			if length(`"`3'"') != 2 {
				di as err "invalid month in {bf:daterange()} specification"
				di as err "    syntax is {bf:daterange([YYYY-MM-DD], [YYYY-MM-DD])}"
				exit 198
			}
			if length(`"`5'"') != 2 {
				di as err "invalid day in {bf:daterange()} specification"
				di as err "    syntax is {bf:daterange([YYYY-MM-DD], [YYYY-MM-DD])}"
				exit 198
			}
			capture confirm integer number `1'
			if _rc {
			di as err "invalid year in {bf:daterange()} specification"
				di as err "    syntax is {bf:daterange([YYYY-MM-DD], [YYYY-MM-DD])}"
				exit 198
			}
			capture confirm integer number `3'
			if _rc {
				di as err "invalid month in {bf:daterange()} specification"
				di as err "    syntax is {bf:daterange([YYYY-MM-DD], [YYYY-MM-DD])}"
				exit 198
			}
			if `3' > 12 {
				di as err "invalid month in {bf:daterange()} specification"
				di as err "    syntax is {bf:daterange([YYYY-MM-DD], [YYYY-MM-DD])}"
				exit 198
			}
			capture confirm integer number `5'
			if _rc {
				di as err "invalid day in {bf:daterange()} specification"
				di as err "    syntax is {bf:daterange([YYYY-MM-DD], [YYYY-MM-DD])}"
				exit 198
			}
			if `5' > 31 {
				di as err "invalid day in {bf:daterange()} specification"
				di as err "    syntax is {bf:daterange([YYYY-MM-DD], [YYYY-MM-DD])}"
				exit 198
			}
		}

		// check if since and until are equal
		if `"`since'"' != "" & `"`since'"' == `"`until'"' {
			di as err "invalid {bf:daterange()} specification"
			di as err "    The two dates in the specification cannot be the same date."
			exit 198
		}
	}

	tokenize `"`geo'"', parse(" ,")
	if `"`geo'"' != "" {
		capture confirm number `1'
		if _rc {
			di as err "invalid latitude in {bf:geo()} specification"
			di as err "    syntax is {bf:geo(lat,long,rad[,unit])}"
			exit 198
		}
		if `1' > 90 | `1' < -90 {
			di as err "invalid latitude in {bf:geo()} specification"
			di as err "    syntax is {bf:geo(lat,long,rad[,unit])}"
			exit 198
		}
		capture confirm number `3'
		if _rc {
			di as err "invalid longitude in {bf:geo()} specification"
			di as err "    syntax is {bf:geo(lat,long,rad[,unit])}"
			exit 198
		}
		if `3' > 180 | `3' < -180 {
			di as err "invalid longtitude in {bf:geo()} specification"
			di as err "    syntax is {bf:geo(lat,long,rad[,unit])}"
			exit 198
		}
		capture confirm number `5'
		if _rc {
			di as err "invalid radius in {bf:geo()} specification"
			di as err "    syntax is {bf:geo(lat,long,rad[,unit])}"
			exit 198
		}
		if `5' < 0 {
			di as err "invalid radius in {bf:geo()} specification"
			di as err "    syntax is {bf:geo(lat,long,rad[,unit])}"
			exit 198
		}
		if `"`7'"' != "" {
			if `"`7'"' != "mi" & `"`7'"' != "km" {
				di as err "invalid unit in {bf:geo()} specification"
				di as err "    syntax is {bf:geo(lat,long,rad[,unit])}"
				exit 198
			}
		}
		else {
			local 7 "mi"
		}

		local geocode `"`1';`3';`5';`7'"'
	}

	if `"`type'"' != "" {
		if `"`type'"' != "popular" & `"`type'"' != "mixed" & `"`type'"' != "recent" {
			di as err "invalid {bf:type()} specification"
			di as err "    syntax is {bf:type(popular|mixed|recent)}"
			exit 198
			dibel as err "invalid {bf:daterange()} specification"
			di as err "    syntax is {bf:daterange([YYYY-MM-DD], [YYYY-MM-DD])}"
			exit 198
		}
	}

	preserve

	if `"`clear'"' != "" {
		clear
	}

	javacall com.stata.drd.stTwitter searchTwitter, args(`"`srch'"' ///
		`"`numtweets'"' `"`lang'"' `"`locale'"' `"`since'"' `"`until'"' `"`sinceid'"' ///
		`"`maxid'"' `"`geocode'"' `"`type'"' `"`verbose'"') jars($twitter2stata_jar_ver)

	restore, not

	return local since_id = tweet_id[1]
	return local max_id = tweet_id[_N]

	convertToDate "tweet_created_at"
	convertToDate "user_account_timestamp"
	displayVarObs
end

program twitterFav
	version 15

	local numtweets = 500
	syntax anything(name=user id="user") [, clear sinceid(string) verbose]

	if ((c(changed) | c(k) | c(N)) & "`clear'" == "") {
		di as err "no; data in memory would be lost"
		exit 4
	}

	preserve

	if `"`clear'"' != "" {
		clear
	}

	javacall com.stata.drd.stTwitter getFavorites, args(`"`user'"' `"`sinceid'"' `"`verbose'"' `"`numtweets'"') jars($twitter2stata_jar_ver)
	convertToDate "tweet_created_at"
	convertToDate "user_account_timestamp"

	restore, not
	displayVarObs
end

program twitterFri
	version 15

	local numusers = 3000
	syntax anything(name=user id="user") [, clear verbose]

	if ((c(changed) | c(k) | c(N)) & "`clear'" == "") {
		di as err "no; data in memory would be lost"
		exit 4
	}

	preserve

	if `"`clear'"' != "" {
		clear
	}

	javacall com.stata.drd.stTwitter getFriendsList, args(`"`user'"' `"`verbose'"' `"`numusers'"') jars($twitter2stata_jar_ver)
	convertToDate "user_account_timestamp"

	restore, not
	displayVarObs
end

program twitterFol
	version 15

	local numusers = 3000
	syntax anything(name=user id="user") [, clear verbose]

	if ((c(changed) | c(k) | c(N)) & "`clear'" == "") {
		di as err "no; data in memory would be lost"
		exit 4
	}

	preserve

	if `"`clear'"' != "" {
		clear
	}

	javacall com.stata.drd.stTwitter getFollowersList, args(`"`user'"' `"`verbose'"' `"`numusers'"') jars($twitter2stata_jar_ver)
	convertToDate "user_account_timestamp"

	restore, not
	displayVarObs
end

program twitterUserLists
	version 15

	syntax anything(name=user id="user") [, members clear]

	if ((c(changed) | c(k) | c(N)) & "`clear'" == "") {
		di as err "no; data in memory would be lost"
		exit 4
	}

	preserve

	if `"`clear'"' != "" {
		clear
	}

	if `"`members'"' != "" {
		javacall com.stata.drd.stTwitter getUserListMemberships, args(`"`user'"') jars($twitter2stata_jar_ver)
	}
	else {
		javacall com.stata.drd.stTwitter getUserListSubscriptions, args(`"`user'"') jars($twitter2stata_jar_ver)
	}
	convertToDate "list_created_at"

	restore, not
	displayVarObs
end

program twitterListUsers
	version 15

	syntax anything(name=list id="list") [, members clear]

	if ((c(changed) | c(k) | c(N)) & "`clear'" == "") {
		di as err "no; data in memory would be lost"
		exit 4
	}

	tokenize `"`list'"'
	if `"`2'"' == "" {
		local listId `"`1'"'
	}
	else {
		local slug `"`1'"'
		local owner `"`2'"'
	}

	preserve

	if `"`clear'"' != "" {
		clear
	}

	if `"`members'"' == "" & `"`2'"' == "" {
		javacall com.stata.drd.stTwitter getUserListSubscribers, args(`"`listId'"') jars($twitter2stata_jar_ver)
	}
	else if `"`members'"' == "" & `"`2'"' != "" {
		javacall com.stata.drd.stTwitter getUserListSubscribers, args(`"`slug'"' `"`owner'"') jars($twitter2stata_jar_ver)
	}
	else if `"`members'"' != "" & `"`2'"' == "" {
		javacall com.stata.drd.stTwitter getUserListMembers, args(`"`listId'"') jars($twitter2stata_jar_ver)
	}
	else {
		javacall com.stata.drd.stTwitter getUserListMembers, args(`"`slug'"' `"`owner'"') jars($twitter2stata_jar_ver)
	}
	convertToDate "user_account_timestamp"

	restore, not
	displayVarObs
end

program twitterListTweets
	version 15

	local numtweets = 1000
	syntax anything(name=list id="list") [, clear sinceid(string) maxid(string) verbose]

	if ((c(changed) | c(k) | c(N)) & "`clear'" == "") {
		di as err "no; data in memory would be lost"
		exit 4
	}

	tokenize `"`list'"'
	if `"`2'"' == "" {
		local listId `"`1'"'
	}
	else {
		local slug `"`1'"'
		local owner `"`2'"'
	}

	preserve

	if `"`clear'"' != "" {
		clear
	}

	if `"`2'"' == "" {
		javacall com.stata.drd.stTwitter getUserListStatuses, args(`"`numtweets'"' `"`sinceid'"' ///
			`"`maxid'"' `"`verbose'"' `"`listId'"') jars($twitter2stata_jar_ver)
	}
	else {
		javacall com.stata.drd.stTwitter getUserListStatuses, args(`"`numtweets'"' `"`sinceid'"' ///
			`"`maxid'"' `"`verbose'"' `"`slug'"' `"`owner'"') jars($twitter2stata_jar_ver)
	}
	convertToDate "tweet_created_at"
	convertToDate "user_account_timestamp"

	restore, not
	displayVarObs
end

program twitterSearchUsers
	version 15

	local numusers = 100
	syntax anything(name=srch id="search string") [, clear]

	if ((c(changed) | c(k) | c(N)) & "`clear'" == "") {
		di as err "no; data in memory would be lost"
		exit 4
	}

	preserve

	if `"`clear'"' != "" {
		clear
	}

	javacall com.stata.drd.stTwitter searchUsers, args(`"`srch'"' `"`numusers'"') jars($twitter2stata_jar_ver)
	convertToDate "user_account_timestamp"

	restore, not
	displayVarObs
end

program twitterGetUserTweets
	version 15

	local numtweets = 3200
	syntax anything(name=user id="user")	///
		[, clear sinceid(string) maxid(string) verbose]

	if ((c(changed) | c(k) | c(N)) & "`clear'" == "") {
		di as err "no; data in memory would be lost"
		exit 4
	}

	preserve

	if `"`clear'"' != "" {
		clear
	}

	javacall com.stata.drd.stTwitter getUserTweets, args(`"`user'"' `"`numtweets'"' `"`sinceid'"' `"`maxid'"' `"`verbose'"') jars($twitter2stata_jar_ver)
	convertToDate "tweet_created_at"
	convertToDate "user_account_timestamp"

	restore, not
	displayVarObs
end

program twitterGetUser
	version 15

	syntax anything(name=user id="user") [, clear]

	if ((c(changed) | c(k) | c(N)) & "`clear'" == "") {
		di as err "no; data in memory would be lost"
		exit 4
	}

	preserve

	if `"`clear'"' != "" {
		clear
	}

	javacall com.stata.drd.stTwitter getUser, args(`"`user'"') jars($twitter2stata_jar_ver)
	convertToDate "user_account_timestamp"

	restore, not
	displayVarObs
end

program twitterGetStatus
	version 15

	syntax anything(name=status id="status") [, clear]

	if ((c(changed) | c(k) | c(N)) & "`clear'" == "") {
		di as err "no; data in memory would be lost"
		exit 4
	}

	preserve

	if `"`clear'"' != "" {
		clear
	}

	javacall com.stata.drd.stTwitter getStatus, args(`"`status'"') jars($twitter2stata_jar_ver)
	convertToDate "tweet_created_at"
	convertToDate "user_account_timestamp"

	restore, not
	displayVarObs
end

program displayVarObs
	version 15

	if (`c(N)' == 0) {
		di as text "(0 obs)"
	}
	else if (`c(k)' == 1) {
		di as text "(`=c(k)' var, `=c(N)' obs)"
	}
	else {
		di as text "(`=c(k)' vars, `=c(N)' obs)"
	}
end

program convertToDate
	version 15

	args varname
	generate double new_`varname' = clock(`varname', "MDYhms"), before(`varname')
	format new_`varname' %tc
	label variable new_`varname' `"`: var label `varname''"'
	drop `varname'
	rename new_`varname' `varname'
end

program twitterPlace2Shp
	version 15

	syntax anything [, replace]

	tokenize `"`anything'"'
	local varname `1'
	macro shift
	local filename `*'

	if (`"`varname'"' != "tweet_place") {
		di as err `"`varname' is not a JSON object"'
		exit 198
	}

	capture confirm file `"`filename'.dta"'
	if (_rc == 0 & `"`replace'"' == "") {
		di as err `"file `filename'.dta already exists"'
		exit 602
	}
	else if (_rc == 0 & `"`replace'"' != "") {
		local replacefilename ", replace"
	}

	capture confirm file `"`filename'_shp.dta"'
	if (_rc == 0 & `"`replace'"' == "") {
		di as err `"file `filename'_shp.dta already exists"'
		exit 602
	}
	else if (_rc == 0 & `"`replace'"' != "") {
		local replacefilenameshp ", replace"
	}

	preserve
	keep `varname'

	javacall com.stata.drd.stTwitter place2shp, args(`"`varname'"') jars($twitter2stata_jar_ver)

	capture {
		quietly drop if _ID == .
		quietly compress

		tempfile file1
		quietly save `"`file1'"'

		keep _ID x_vals y_vals
		quietly generate double _X = .
		quietly generate double _Y = .
		local numobs `c(N)'
		forvalues i = 1/`numobs' {
			local j = `numobs' - `i' + 1
			local x_string = x_vals[`j']
			local y_string = y_vals[`j']
			tokenize `"`x_string'"', parse(",")
			local rest_x `*'
			tokenize `"`y_string'"', parse(",")
			local rest_y `*'
			while (`"`rest_x'"' != "") {
				quietly insobs 1, after(`j')
				local num = `j' + 1
				quietly replace _ID = `j' in `num'
				tokenize `"`rest_x'"', parse(",")
				quietly replace _X = `1' in `num'
				macro shift
					macro shift
				local rest_x `*'
				tokenize `"`rest_y'"', parse(",")
				quietly replace _Y = `1' in `num'
				macro shift
				macro shift
				local rest_y `*'
			}
		}
		drop x_vals y_vals
		save `"`filename'_shp"' `replacefilenameshp'

		use `"`file1'"'

		drop coordinates x_vals y_vals
		save `"`filename'"' `replacefilename'
	}
	if _rc != 0 {
		capture erase `"`file1'"'
		exit _rc
	}
	restore
end

