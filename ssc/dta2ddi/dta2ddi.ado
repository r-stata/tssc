*! version 0.02 28May2014 Minh Cong Nguyen

* Need to add options on character variables (if more than 100, donot list).

cap program drop dta2ddi
program define dta2ddi, rclass
	version 13, missing
    local version : di "version " string(_caller()) ", missing:"   

	syntax, [using(string) save(string) replace append(string) id(string) ///
	stats(string) xxx(string) yyy(string) zzz(string) aaa(string) bbb(string) ///
	ccc(string) ddd(string) eee(string) fff(string) ggg(string) ///
	hhh(string) iii(string) jjj(string) kkk(string) lll(string) ///
	mmm(string) nnn(string) ooo(string) ppp(string) qqq(string) ///
	rrr(string) sss(string) ttt(string) uuu(string) vvv(string)]
	
	**xxx yyy zzz aaa bbb ccc ddd eee fff ggg hhh iii jjj kkk lll mmm nnn ooo ppp qqq rrr sss ttt uuu vvv
	// Check syntax
	// stats: mean stdev, default is min max
	local cmdline: copy local 0
	if "`id'"=="" local id `using'
	
	tempfile outdata
	tempname outfile
	file open  `outfile' using "`outdata'", read write text
	file write `outfile' `"<?xml version='1.0' encoding='UTF-8'?>"' _n
	file write `outfile' `"<codeBook version="1.2.2" ID="`id'" xml-lang="en" xmlns="http://www.icpsr.umich.edu/DDI" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.icpsr.umich.edu/DDI http://www.icpsr.umich.edu/DDI/Version1-2-2.xsd">"' _n
	
	// Check for appending study description
	if "`append'"~="" {
		tempfile longfile
		tempname note docDscr stdyDscr mystr
		qui gen strL `note' = fileread("`append'")
		//search for syntax - <docDscr> and </docDscr>
		local pos1 = strpos(`note', "<docDscr>")
		local pos2 = strpos(`note', "</docDscr>")
		if `pos1'>0 & `pos2'>0 & `pos2'>`pos1' {
			qui gen strL `docDscr' = substr(`note', `pos1'+9, `pos2'-`pos1'-9)
			// replace with other options
			local addlist xxx yyy zzz aaa bbb ccc ddd eee fff ggg hhh iii jjj kkk lll mmm nnn ooo ppp qqq rrr sss ttt uuu vvv
			foreach v of local addlist {	
				if "``v''"~="" {
					qui replace `docDscr' = subinstr(`docDscr', ";`=upper("`v'")';", "``v''",.)
				}
			}
			scalar `mystr' = `docDscr'[1]
			file write `outfile' _col(4) "<docDscr>" _n
			file write `outfile' `"`=`mystr''"' _n
			file write `outfile' _col(4) "</docDscr>" _n			
			// Add title			
			// Add IDNo
		}
		//search for syntax - <stdyDscr> and </stdyDscr>
		local pos1 = strpos(`note', "<stdyDscr>")
		local pos2 = strpos(`note', "</stdyDscr>")
		if `pos1'>0 & `pos2'>0 & `pos2'>`pos1' {
			qui gen strL `stdyDscr' = substr(`note', `pos1'+10, `pos2'-`pos1'-10)
			// replace with other options
			local addlist xxx yyy zzz aaa bbb ccc ddd eee fff ggg hhh iii jjj kkk lll mmm nnn ooo ppp qqq rrr sss ttt uuu vvv
			foreach v of local addlist {	
				if "``v''"~="" {
					qui replace `stdyDscr' = subinstr(`stdyDscr', ";`=upper("`v'")';", "``v''",.)
				}
			}
			scalar `mystr' = `stdyDscr'[1]
			file write `outfile' _col(4) "<stdyDscr>" _n
			file write `outfile' `"`=`mystr''"' _n
			file write `outfile' _col(4) "</stdyDscr>" _n
			// Add IDNo
		}
	}
	// Check using is a file or folder
	if "`using'"=="" {
		cap des,sh
		if _rc==0 {
			tempfile curdta
			qui save `curdta', replace
			local list1 `curdta'
			local folder = 0
		}
	}
	else {
		cap use `using', clear
		if _rc==0 {
			local list1 `using'
			local folder = 0
		}
		else {
			local list1 : dir "`using'" files "*.dta", nofail respectcase	
			dis `"`list1'"'
			local folder = 1
		}
	}
	
	// loop for file description
	local F = 1
	foreach file of local list1 {
		if `folder' == 0 {
			use `list1', clear
		}
		if `folder' == 1 {
			use "`using'/`file'", clear
		}		
		local filedes : data label
		local filedes = proper("`filedes'")		
		local file1 `=substr("`file'",1,length("`file'")-4)'				
		file write `outfile' `"<fileDscr ID="F`F'" URI="`id'.Nesstar?Index=`=`F'-1'&amp;Name=`file1'">"' _n
		file write `outfile' _col(6) "<fileTxt>" _n
		file write `outfile' _col(8) "<fileName>" _n
		file write `outfile' _col(10) "`file1'.NSDstat" _n
		file write `outfile' _col(8) "</fileName>" _n
		file write `outfile' _col(8) "<fileCont>" _n
		file write `outfile' _col(10) "`filedes'" _n
		file write `outfile' _col(8) "</fileCont>" _n
		file write `outfile' _col(8) "<dimensns>" _n
		file write `outfile' _col(8) "<caseQnty>" _n
		qui des, varl
		file write `outfile' _col(10) "`r(N)'" _n
		file write `outfile' _col(8) "</caseQnty>" _n
		file write `outfile' _col(8) "<varQnty>" _n
		file write `outfile' _col(10) "`r(k)'" _n
		file write `outfile' _col(8) "</varQnty>" _n		
		file write `outfile' _col(8) "</dimensns>" _n
		file write `outfile' _col(8) "<fileType>" _n
		file write `outfile' _col(10) "Nesstar 200801" _n
		file write `outfile' _col(8) "</fileType>" _n
		file write `outfile' _col(6) "</fileTxt>" _n
		file write `outfile' _col(6) "<notes>" _n
		*file write `outfile' _col(8) "`r(varlist)'" _n
		// should get the data note here?
		file write `outfile' _col(6) "</notes>" _n
		file write `outfile' "</fileDscr>" _n
		local F = `F' + 1	
	}
	
	// loop for each file for variable description
	file write `outfile' "<dataDscr>" _n
	local F = 1
	local V = 1
	foreach file of local list1 {
		if `folder' == 0 {
			use `list1', clear
		}
		if `folder' == 1 {
			use "`using'/`file'", clear
		}
		tempfile oridata
		qui save `oridata', replace
		
		des, replace
		local end = _N
		tempfile lbldata
		qui save `lbldata', replace
		
		local pos = 1
		forv i=1(1)`end' {
			qui _xmlvar, use("`oridata'") fwrite("`outfile'") id(`V') name(`=name[`i']') files("F`F'") dcml("0") startpos(`pos') stats(`stats')	
			local V = `V' + 1
			local pos = r(endpos)
		}
		local F = `F' + 1		
	}
	file write `outfile' "</dataDscr>" _n
	file write `outfile' "</codeBook>"
	file close `outfile'
	
	qui capture copy "`outdata'" "`save'", replace
	if _rc {
		display as error "file can not be saved at this location"
		exit 603
	}

end

** Subfunctions to get the information
cap program drop _xmlvar
program define _xmlvar, rclass
	syntax, use(string) fwrite(string) id(string) name(string) files(string) dcml(string) startpos(integer) [stats(string)]	
	*** Check variable type
	preserve
	use `name' using `use', clear	
	local varlab : variable label `name'
	if "`varlab'"~="" {
		_ddifix, localfix("`varlab'")
		local varlab = r(localfix)
	}
	capture confirm numeric variable `name'
	if _rc==0 {
		local type : type `name'
		if "`type'"=="float" | "`type'"=="double" {
			//real
			local intrvl contin
			local types = 1
			local format = "numeric"
		}
		else {
			//integer
			local intrvl discrete
			local types = 2
			local lbllist : value label `name'
			//integer with label
			if "`lbllist'"~="" local types = 3	
			local format = "numeric"
		}
		
		su `name'
		local mean = r(mean)
		local stdev = r(sd)
		local min = r(min)
		local max = r(max)
		local rn = r(N)
		count if `name'==.
		local rmiss = r(N)
		if `types' == 1 {
			local mean = trim("`: dis %23.3f `mean''")
			local stdev = trim("`: dis %23.3f `stdev''")
			local min = trim("`: dis %23.3f `min''")
			local max = trim("`: dis %23.3f `max''")
		}
		local width = `=length("`max'")'
		local endpos = `startpos'+`width'-1
		local dcml `"dcml="`dcml'""'
	}
	else {
		count if `name'~=""
		local rn = r(N)
		local type : type `name'
		local width = real(substr("`type'",4,`=length("`type'")-3'))				
		local endpos = `startpos'+`width'-1		
		local intrvl discrete
		local format = "character"
		local dcml 
		local types = 3	
		count if `name'==""
		local rmiss = r(N)
	}
				
	local lbllist : value label `name'
	
	*** Write information
	file write `fwrite' _col(4) `" <var ID="V`id'" name="`name'" files="`files'" `dcml' intrvl="`intrvl'">"' _n
	file write `fwrite' _col(6) `"<location StartPos="`startpos'" EndPos="`endpos'" width="`width'" RecSegNo="1"/>"' _n
	
	file write `fwrite' _col(6) "<labl>" _n	
	*local varlab : subinstr local varlab "&" "&amp;", all
	file write `fwrite' _col(6) "<![CDATA[" _n	
	file write `fwrite' _col(8) "`varlab'" _n
	file write `fwrite' _col(6) "]]>" _n	
	file write `fwrite' _col(6) "</labl>" _n
	
	if `types' == 1 | `types' == 2 {
		file write `fwrite' _col(6) "<valrng>" _n
		file write `fwrite' _col(8) `"<range UNITS="REAL" min="`min'" max="`max'"/>"' _n
		file write `fwrite' _col(6) "</valrng>" _n
	}
	if `types' == 3 {
		if "`lbllist'"~="" cap la list `lbllist'
			if _rc==0 {
				file write `fwrite' _col(6) "<valrng>" _n
				file write `fwrite' _col(8) `"<range min="`= min(r(min), `min')'" max="`= max(r(max), `max')'"/>"' _n
				file write `fwrite' _col(6) "</valrng>" _n
			}
	}
	
	file write `fwrite' _col(6) `"<sumStat type="vald">"' _n
	file write `fwrite' _col(8) "`rn'" _n
	file write `fwrite' _col(6) "</sumStat>" _n
	file write `fwrite' _col(6) `"<sumStat type="invd">"' _n
	file write `fwrite' _col(8) "`rmiss'" _n
	file write `fwrite' _col(6) "</sumStat>" _n
	
	//if `types' == 1 | `types' == 2 {
	if "`format'" ~= "character" {
		file write `fwrite' _col(6) `"<sumStat type="min">"' _n
		file write `fwrite' _col(8) "`min'" _n
		file write `fwrite' _col(6) "</sumStat>" _n
		file write `fwrite' _col(6) `"<sumStat type="max">"' _n
		file write `fwrite' _col(8) "`max'" _n
		file write `fwrite' _col(6) "</sumStat>" _n
		if "`stats'"~="" {
			foreach st in `stats' {
				file write `fwrite' _col(6) `"<sumStat type="`st'">"' _n
				file write `fwrite' _col(8) "``st''" _n
				file write `fwrite' _col(6) "</sumStat>" _n
			}
		}
	}
	
	if `types' == 3 {
		//Get the list of label values
		qui cap levelsof `name', local(lvlx)
		if "`lbllist'"~="" {
			qui cap labelval, varlbl(`name')
			//qui cap labelsof2 `name'
			local rl `r(lbllist)'
			local lvlx : list lvlx | rl
			qui cap localsort, sortlocal("`lvlx'")
			local lvlx `r(sorted)'
		}
		
		foreach lbl of local lvlx {
			file write `fwrite' _col(6) "<catgry>" _n
			file write `fwrite' _col(8) "<catValu>" _n
			file write `fwrite' _col(8) "`lbl'" _n
			file write `fwrite' _col(6) "</catValu>" _n
			
			if "`lbllist'"~="" {
				local lblname :  label (`name') `lbl', strict
				if "`lblname'"~="" {
					_ddifix, localfix("`lblname'")
					local lblname = r(localfix)
				}
				file write `fwrite' _col(6) "<labl>" _n
				file write `fwrite' _col(6) "<![CDATA[" _n	
				file write `fwrite' _col(8) "`lblname'" _n
				file write `fwrite' _col(6) "]]>" _n
				file write `fwrite' _col(6) "</labl>" _n
			}
			cap confirm numeric variable `name'
			if _rc==0 {
				count if `name'==`lbl'
			}
			else {
				count if `name'=="`lbl'"
			}
			local val2 = r(N)
			file write `fwrite' _col(6) `"<catStat type="freq">"' _n
			file write `fwrite' _col(8) "`val2'" _n
			file write `fwrite' _col(6) "</catStat>" _n
			file write `fwrite' _col(6) "</catgry>" _n
		}
		//missing information
		if `rmiss' > 0 {
			file write `fwrite' _col(6) `"<catgry missing="Y">"' _n
			file write `fwrite' _col(8) "<catValu>" _n
			file write `fwrite' _col(8) "Sysmiss" _n
			file write `fwrite' _col(6) "</catValu>" _n
			file write `fwrite' _col(6) `"<catStat type="freq">"' _n
			file write `fwrite' _col(8) "`rmiss'" _n
			file write `fwrite' _col(6) "</catStat>" _n
			file write `fwrite' _col(6) "</catgry>" _n
		}
		
	}
	file write `fwrite' _col(6) `"<varFormat type="`format'" schema="other"/>"' _n
	file write `fwrite' _col(4) "</var>   " _n  
	
	return local endpos = `endpos'
	restore
end

cap program drop _ddifix
program define _ddifix, rclass
	syntax, localfix(string)
	local localfix1 `localfix'
	*local localfix1 : subinstr local localfix1 "<" "less", all
	*local localfix1 : subinstr local localfix1 ">" "more", all
	*local localfix1 : subinstr local localfix1 "&" "&amp;", all
	*local localfix1 : subinstr local localfix1 "`=char(38)'" "&amp;", all
	local localfix1 : subinstr local localfix1 "`=char(189)'" "1/2", all
	*local localfix1 : subinstr local localfix1 "`=char(189)'" "&frac12;", all	
	local localfix1 : subinstr local localfix1 "`=char(151)'" "-", all 
	local localfix1 : subinstr local localfix1 "`=char(150)'" "-", all 
	local localfix1 : subinstr local localfix1 "`=char(173)'" "-", all 
	local localfix1 : subinstr local localfix1 "`=char(147)'" " ", all
	local localfix1 : subinstr local localfix1 "`=char(148)'" " ", all
	/* Check this “selected respondent” */
	/*
	local localfix1 : subinstr local localfix1 "`=char(147)'" "&ldquo;", all
	local localfix1 : subinstr local localfix1 "`=char(148)'" "&rdquo;", all
	*local localfix1 : subinstr local localfix1 "`"`=char(34)'"'" "&quot;", all 
	local localfix1 : subinstr local localfix1 "`=char(151)'" "&mdash;", all 
	local localfix1 : subinstr local localfix1 "`=char(126)'" "&tilde;", all 
	local localfix1 : subinstr local localfix1 "`=char(130)'" "&sbquo;", all 
	local localfix1 : subinstr local localfix1 "`=char(132)'" "&dbquo;", all 
	local localfix1 : subinstr local localfix1 "`=char(134)'" "&dagger;", all 
	local localfix1 : subinstr local localfix1 "`=char(135)'" "&Dagger;", all 
	local localfix1 : subinstr local localfix1 "`=char(139)'" "&lsaquo;", all 
	local localfix1 : subinstr local localfix1 "`=char(145)'" "&lsquo;", all 
	local localfix1 : subinstr local localfix1 "`=char(146)'" "&rsquo;", all
	local localfix1 : subinstr local localfix1 "`=char(150)'" "&ndash;", all
	local localfix1 : subinstr local localfix1 "`=char(153)'" "&trade;", all
	local localfix1 : subinstr local localfix1 "`=char(153)'" "&trade;", all
	local localfix1 : subinstr local localfix1 "`=char(155)'" "&rsaquo;", all
	local localfix1 : subinstr local localfix1 "`=char(161)'" "&iexcl;", all
	local localfix1 : subinstr local localfix1 "`=char(166)'" "&brvbar;", all
	local localfix1 : subinstr local localfix1 "`=char(169)'" "&copy;", all
	local localfix1 : subinstr local localfix1 "`=char(170)'" "&ordf;", all
	local localfix1 : subinstr local localfix1 "`=char(171)'" "&laquo;", all
	local localfix1 : subinstr local localfix1 "`=char(172)'" "&not;", all
	local localfix1 : subinstr local localfix1 "`=char(174)'" "&reg;", all
	local localfix1 : subinstr local localfix1 "`=char(176)'" "&deg;", all
	local localfix1 : subinstr local localfix1 "`=char(178)'" "&sup2;", all
	local localfix1 : subinstr local localfix1 "`=char(179)'" "&sup3;", all
	local localfix1 : subinstr local localfix1 "`=char(181)'" "&micro;", all
	local localfix1 : subinstr local localfix1 "`=char(182)'" "&para;", all
	local localfix1 : subinstr local localfix1 "`=char(183)'" "&middot;", all
	local localfix1 : subinstr local localfix1 "`=char(185)'" "&sup1;", all
	local localfix1 : subinstr local localfix1 "`=char(186)'" "&ordm;", all
	local localfix1 : subinstr local localfix1 "`=char(187)'" "&raquo;", all
	local localfix1 : subinstr local localfix1 "`=char(191)'" "&iquest;", all
	local localfix1 : subinstr local localfix1 "`=char(167)'" "&sect;", all
	*/
	return local localfix `localfix1'
end

*! version 1.0.0, Minh Cong Nguyen, 12jul2014
cap program drop labelval
prog labelval, rclass
        version 10
        syntax, varlbl(string)
		local lbllist : value label `varlbl'
		if "`lbllist'" ~= "" {
			mata: st_vlload("`lbllist'", v = ., t = "")
			mata : st_local("rows", strofreal(rows(v)))
			if `rows' >0 {
				local lbllist
				forv s = 1(1)`rows' {
					mata : st_local("val0", strofreal(v[strtoreal(st_local("s")),1]))
					local lbllist "`lbllist' `val0'"	
				}
				local lbllist = trim("`lbllist'")
				ret local lbllist "`lbllist'"
			}
		}
end

*! version 1.0.0, Minh Cong Nguyen, 12jul2014
cap program drop localsort
prog localsort, rclass
	version 10
    syntax, sortlocal(string)
	local localsort `sortlocal'
	mata: x = J(`: list sizeof localsort',1,.)
	local i = 1
	foreach lbl of local localsort {
		mata: x[`i',1] = strtoreal(st_local("lbl"))
		local i = `i' + 1
	}
	mata: y = sort(x,1)
	local sorted
	forv s = 1(1)`=`i'-1' {
		mata : st_local("val0", strofreal(y[strtoreal(st_local("s")),1]))
		local sorted "`sorted' `val0'"	
	}
	local sorted = trim("`=subinstr("`sorted'","."," ",.)'")
	ret local sorted "`sorted'"
end
