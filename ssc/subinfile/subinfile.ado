program define subinfile
	version 14.0
	syntax anything(id="file source" name=filesource), ///
		[from(string asis) to(string asis) replace append ///
		save(string) fromregex dropblank index(string) ///
		indexregex drop(string) dropregex order(string asis) ///
		encoding(string)]

	if `"`replace'"' == "" & `"`save'"' == "" & `"`append'"' == "" {
		di as error "You must specify at least one of the three options replace, save or append."
		exit 498
	}

	if `"`replace'"' != "" & `"`append'"' != "" {
		disp as error "You can not specify both replace and append"
		exit 198
	}

	if `"`from'"' == "" & `"`to'"' != "" {
		di as error "You must specify the substring you want to substitute."
		exit 198
	}

	if `"`index'"' == "" & `"`indexregex'"' != "" {
		di as error "You must specify the option index() if you want to use regular expression to keep lines."
		exit 198
	}

	if `"`drop'"' == "" & `"`dropregex'"' != "" {
		di as error "You must specify the option drop() if you want to use regular expression to keep lines."
		exit 198
	}

	if `"`from'"' == "" & `"`fromregex'"' != "" {
		di as error "You must specify the option from() if you want to use regular expression to substitute strings."
		exit 198
	}

	local filesource `filesource'
	
	if !fileexists(`"`filesource'"') {
		di as error `"File `filesource' could not be found"'
		exit 601
	}

	if "`encoding'" != "" {
		mata: st_local("x", strofreal(isvalidconverter("`encoding'")))
		if `x' == 1 {
			disp as error "`encoding' invalid encoding"
			exit 198
		}
	}
	else {
		local encoding utf8
	}

	if `"`from'"' != "" {
		token `"`from'"'
		mata tokennumber(`"`from'"')
		scalar fromnumber = scalar(tokennumber)
		forvalues num = 1/`=scalar(fromnumber)' {
			local from`num' = `"``num''"'
		}

		if `"`to'"' == "" {
			forvalues num = 1/`=scalar(fromnumber)' {
				local to`num' = ""
			}
		}
		else {
			token `"`to'"'
			mata tokennumber(`"`to'"')
			if scalar(tokennumber) != scalar(fromnumber) {
				disp as error "The number of parts specified in to() is unequal to the number of parts specified in from()"
				exit 198
			}
			else {
				scalar tonumber = scalar(tokennumber)
				forvalues num = 1/`=scalar(tonumber)' {
					local to`num' = `"``num''"'
				}
			}
		}
	}

	if `"`order'"' != "" {
		token `"`order'"'
		mata tokennumber(`"`order'"')
		local ordernumber = scalar(tokennumber)
		forvalues num = 1/`ordernumber' {
			if !inlist(`"``num''"', "index", "drop", "from", "dropblank") {
				disp as error "You can only specify the option order() among index, drop, from or dropblank"
				exit 198
			}
			if `"``num''"' == "" {
				disp as error `"You can not specify ``num'' in order() without specify option `order`num''"'
				exit 198
			}
			if `num' > 1 {
				forvalues i = 1/`=`num'-1' {
					if `"``i''"' == `"``num''"' {
						disp as error `"You can only specify ``num'' once in order()"'
						exit 198
					}
				}
			}
		}
	}
	else local order = "index drop from dropblank"
	local orderitem = ""
	foreach item in `order' index drop from dropblank {
		if !strpos(`"`orderitem'"', `"`item'"') & `"``item''"' != "" local orderitem = `"`orderitem'`item' "'
	}
	token `"`orderitem'"'
	mata tokennumber(`"`orderitem'"')
	scalar orderitemnumber = scalar(tokennumber)
	forvalues i = 1/`=scalar(orderitemnumber)' {
		local order`i' = `"``i''"'
	}
	

	if `"`save'"' == "" local save `"`filesource'"'
	if !strpos(`"`save'"', ".") local save `"`save'.txt"'
	if fileexists(`"`save'"') {
		if "`replace'" == "" & "`append'" == "" {
			di as error `"File `save' have exsited, you need to specify the option replace or append"'
			error 498
		}

		else if `"`save'"' != `"`filesource'"' & "`replace'" != "" {
			cap erase `"`save'"'
			if _rc != 0 {
				! del `"`save'"' /F
			}
		}

		else if `"`save'"' == `"`filesource'"' & "`replace'" != "" {
			tempfile subinfile_temp
			local save `"`subinfile_temp'"'
		}
	}

	qui {
		mata subinfile(`"`filesource'"', `"`encoding'"', `"`save'"')
		if `"`save'"' == `"`subinfile_temp'"' {
			cap erase `"`filesource'"'
			if _rc != 0 {
				! del `"`filesource'"' /F
			}
			copy `"`subinfile_temp'"' `"`filesource'"', replace
		}
	}
end

cap mata mata drop tokennumber()
mata
	function tokennumber(string scalar tokenstring) {
		token = tokens(tokenstring)
		st_numscalar("tokennumber", cols(token))
	}
end

cap mata mata drop subinfile()
mata
	void function subinfile(string scalar filesource, string scalar encoding, string scalar save) {
	
		string matrix rewritefile
		real scalar i
		real scalar j
		real scalar writefile

		rewritefile = cat(filesource)
		rewritefile = ustrfrom(rewritefile, encoding, 1)

		for (i = 1; i <= st_numscalar("orderitemnumber"); i++) {

			if (st_local(sprintf("order%g", i)) == "index") {
				if (st_local("indexregex") == "indexregex") rewritefile = select(rewritefile, ustrregexm(rewritefile, st_local("index")))
				else rewritefile = select(rewritefile, ustrpos(rewritefile, st_local("index")))
			}

			if (st_local(sprintf("order%g", i)) == "drop") {
				if (st_local("dropregex") == "dropregex") rewritefile = select(rewritefile, !ustrregexm(rewritefile, st_local("drop")))
				else rewritefile = select(rewritefile, !ustrpos(rewritefile, st_local("drop")))
			}

			if (st_local(sprintf("order%g", i)) == "from") {
				if (st_local("fromregex") == "fromregex") {
					for (j = 1; j <= st_numscalar("fromnumber"); j++) {
						rewritefile = ustrregexra(rewritefile, st_local(sprintf("from%g", j)), st_local(sprintf("to%g", j)))
					}
				}
				else {
					for (j = 1; j <= st_numscalar("fromnumber"); j++) {
						rewritefile = usubinstr(rewritefile, st_local(sprintf("from%g", j)), st_local(sprintf("to%g", j)), .)
					}
				}
			}

			if (st_local(sprintf("order%g", i)) == "dropblank") rewritefile = select(rewritefile, ustrregexm(rewritefile, "."))
		}
		
		if (st_local("replace") == "" & st_local("append") == "" ) {
			writefile = fopen(save, "w")
			for (i = 1; i <= rows(rewritefile); i++) {
				fwrite(writefile, sprintf("%s\r\n", rewritefile[i]))
			}
			fclose(writefile)
		}

		else if (st_local("replace") == "replace") {
			writefile = fopen(save, "rw")
			for (i = 1; i <= rows(rewritefile); i++) {
				fwrite(writefile, sprintf("%s\r\n", rewritefile[i]))
			}
			fclose(writefile)
		}
		
		else {
			writefile = fopen(save, "a")
			for (i = 1; i <= rows(rewritefile); i++) {
				fwrite(writefile, sprintf("%s\r\n", rewritefile[i]))
			}
			fclose(writefile)
		}
	}
end
