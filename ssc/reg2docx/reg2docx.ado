* Authors:
* Chuntao Li, Ph.D. , China Stata Club(爬虫俱乐部)(chtl@hust.edu.cn)
* Yuan Xue, China Stata Club(爬虫俱乐部)(xueyuan@hust.edu.cn)
* July 13rd, 2017
* Updated on December 27th, 2018
* Program written by Dr. Chuntao Li and Yuan Xue
* Report regression table to formatted table in DOCX file.
* Can only be used in Stata version 15.0 or above

program define reg2docx
	
	if _caller() < 15.0 {
		disp as error "this is version `=_caller()' of Stata; it cannot run version 15.0 programs"
		exit 9
	}

	syntax anything using/, [append replace b Bfmt(string) t Tfmt(string) z ///
		Zfmt(string) p Pfmt(string) se SEfmt(string) scalars(string asis) NOCONstant ///
		NOSTAr STAR STAR2(string asis) staraux title(string) mtitles MTITLES2(string asis) ///
		noMTITLE DEPvars order(string asis) indicate(string asis) drop(string asis) ///
		NOPArentheses PArentheses BRackets noOBS note(string) pagesize(string) ///
		font(string) landscape]

	if "`append'" != "" & "`replace'" != "" {
		disp as error "you could not specify both append and replace"
		exit 198
	}
	
	if ("`t'" != "" | "`tfmt'" != "") + ("`z'" != "" | "`zfmt'" != "") + ///
	("`p'" != "" | "`pfmt'" != "") + ("`se'" != "" | "`sefmt'" != "") >= 2 {
		disp as error "you could only specify one of t|z|p|se[(fmt)]"
		exit 198
	}

	if "`obs'" != "" & ustrregexm(`"`scalars'"', "\bN\b") {
		disp as error "you could not specify both noobs and obslast or N in scalar()"
		exit 198
	}

	if `"`scalars'"' == "" & "`obs'" == "" local scalars = "N"

	if ("`nostar'" != "") & ("`star'" != "" | "`star2'" != "" | "`staraux'" != "") {
		disp as error "you could not specify both nostar and star[()]|staraux"
		exit 198
	}
	
	if "`mtitle'" != "" & ("`mtitles'" != "" | `"`mtitles2'"' != "" | "`depvars'" != "") {
		disp as error "you could not specify both nomtitle and mtitles|depvars"
		exit 198
	}

	if `"`mtitles2'"' != "" & "`depvars'" != "" {
		disp as error "you could not specify both mtitles() and depvars"
		exit 198
	}
	
	if ("`parentheses'" != "") & ("`noparentheses'" != "" | "`brackets'" != "") {
		disp as error "you could not specify both parentheses and noparentheses|brackets"
		exit 198
	}
	
	local tleft "(" 
	local tright ")"
	
	if "`noparentheses'" != "" {
		local tleft ""
		local tright ""
	}
	
	if "`brackets'" != "" {
		local tleft "["
		local tright "]"
	}

	local star_error = 0
	mata def_star(`"`star2'"')
	if `star_error' == 1 {
		disp as error "you specify the option star() incorrectly"
		exit 198
	}
	local siglevel_`=`levelnum'+1' = 0

	mata get_stats_name(`"`scalars'"')
	if `stats_number' != 0 {
		mat blank_scalar = J(`stats_number', 1, .)
		mat scalar_mat = blank_scalar
	}

	local modelnum = 0
	qui {
		foreach mdl in `anything' {
			local modelnum = `modelnum' + 1
			est stat `mdl'
			mat ictable = r(S)
			cap est replay `mdl'
			_est unhold `mdl'

			if `stats_number' != 0 {
				if `modelnum' != 1 mat scalar_mat = scalar_mat, blank_scalar
				forvalues sti = 1/`stats_number' {
					if "`stat_`sti''" == "N" mat scalar_mat[`sti', `modelnum'] = e(N)
					else if "`stat_`sti''" == "aic" mat scalar_mat[`sti', `modelnum'] = scalar(ictable[1, 5])
					else if "`stat_`sti''" == "bic" mat scalar_mat[`sti', `modelnum'] = scalar(ictable[1, 6])
					else mat scalar_mat[`sti', `modelnum'] = e(`stat_`sti'')
				}
			}

			local df = e(df_r)   //自由度
			local depvar = word(`"`=e(depvar)'"', 1)

			local indicate_error = ""
			if has_eprop(b) & has_eprop(V) {
				local bV = 1
				mat b = e(b)'
				mat V = e(V)
				mata calculate_all("b", "V", "", `df', `"`drop'"', `"`indicate'"', `"`noconstant'"', `modelnum')
			}
			else {
				local bV = 0
				mat regtable = r(table)'
				mata calculate_all("", "", "regtable", `df', `"`drop'"', `"`indicate'"', `"`noconstant'"', `modelnum')
			}
			if `"`indicate'"' != "" {
				if "`indicate_error'" == "error" {
					disp as error "you specify the option indicate() incorrectly"
					exit 198
				}
				if `modelnum' == 1 {
					mat indicate_mat = indicateornot
				}
				else mat indicate_mat = indicate_mat, indicateornot
			}
		}

		if `"`drop'"' != "" {
			local droperror = ""
			mata testdrop(`"`indepvar'"', `"`drop'"')
			if `"`droperror'"' == "error" {
				disp as error "the `drop_item' in option indicate() could not match any independent variables"
				exit 198
			}
		}

		if `"`mtitles2'"' != "" {
			mata mtitles(`"`mtitles2'"')
			if `mtitles_num' != `modelnum' {
				disp as error "the number of mtitles is not equal to the number of models"
				exit 198
			}
		}
		else {
			forvalues i = 1/`modelnum' {
				local mtitle_`i' `depvar1_`i''
			}
		}

		local sig = "tz"
		if "`bfmt'" == "" local bfmt %9.3f
		if "`tfmt'" != "" local tzfmt `tfmt'
		else if "`zfmt'" != "" local tzfmt `zfmt'
		else local tzfmt `bfmt'
		if "`se'" != "" | "`sefmt'" != "" {
			local sig = "se"
			if "`sefmt'" == "" local sefmt `bfmt'
		}
		if "`p'" != "" | "`pfmt'" != "" {
			local sig = "p"
			if "`pfmt'" == "" local pfmt `bfmt'
		}

		local ordererror = ""
		mata combinetable1(`modelnum', `"`order'"')
		if `"`ordererror'"' == "error" {
			disp as error "the `order_item' in option order() could not match any independent variables"
			exit 198
		}

		forvalues num_i = 1/`modelnum' {
			if `depvarnum_`num_i'' > 1 {
				forvalues dv_i = 2/`depvarnum_`num_i'' {
					if !ustrregexm(`"`otherdpv'"', "(^`depvar`dv_i'_`num_i'' )|( `depvar`dv_i'_`num_i'' )") local otherdpv = "`otherdpv'`depvar`dv_i'_`num_i'' "
				}
			}
		}
		local otherdpv = trim(`"`otherdpv'"')

		local othernum = 0
		if `"`otherdpv'"' != "" {
			mata getothertable(`"`otherdpv'"', `"`order'"', `modelnum')
		}

		local colsnum = 1 + `modelnum'
		local rowsnum = 2 + `indepvar1num'*2 + `stats_number'
		if `othernum' != 0 {
			forvalues ot_id = 1/`othernum' {
				local rowsnum = `rowsnum' + 1 + `indepvar`=`ot_id'+1'num' * 2
			}
		}
		local top = 2
		if "`mtitle'" != "" {
			local rowsnum = `rowsnum' - 1
			local top = 1
		}
		if `"`indicate'"' != "" local rowsnum = `rowsnum' + `indicate_num'

		if `"`pagesize'"' == "" local pagesize = "A4"
		if `"`font'"' == "" local font = "Times New Roman"
		putdocx clear
		putdocx begin, pagesize(`pagesize') font(`font') `landscape'
		putdocx paragraph, spacing(after, 0) halign(center)
		if `"`title'"' == "" local title = "Regression Table"
		putdocx text (`"`title'"')

		if `"`note'"' != "" {
			putdocx table regtbl = (`rowsnum', `colsnum'), border(all, nil) border(top) halign(center) note(`"`note'"')
			putdocx table regtbl(`rowsnum', .), border(bottom)
		}
		else {
			putdocx table regtbl = (`rowsnum', `colsnum'), border(all, nil) border(top) border(bottom) halign(center)
		}

		putdocx table regtbl(`top', 1), border(bottom)
		forvalues col = 1/`modelnum' {
			if `top' == 1 {
				putdocx table regtbl(1, `=`col'+1') = ("(`col')"), border(bottom) halign(center)
			}
			else {
				putdocx table regtbl(1, `=`col'+1') = ("(`col')"), halign(center)
				putdocx table regtbl(2, `=`col'+1') = ("`mtitle_`col''"), border(bottom) halign(center)
			}
		}
		local row = `top' + 1
		foreach var in `orderindepvar1' {
			putdocx table regtbl(`row', 1) = ("`var'"), halign(center)
			local row = `row' + 2
		}
		putdocx table regtbl(`=`row'-1', .), border(bottom)

		if `othernum' != 0 {
			forvalues ot_id = 1/`othernum' {
				putdocx table regtbl(`row', 1) = (`"`other_`ot_id'':"'), halign(left)
				local row = `row' + 1
				foreach var in `orderindepvar`=`ot_id' + 1'' {
					putdocx table regtbl(`row', 1) = (`"`var'"'), halign(center)
					local row = `row' + 2
				}
				putdocx table regtbl(`=`row'-1', .), border(bottom)
			}
		}

		if `"`indicate'"' != "" {
			foreach name in `indicate_name' {
				putdocx table regtbl(`row', 1) = ("`name'"), halign(center)
				local row = `row' + 1
			}
			putdocx table regtbl(`=`row'-1', .), border(bottom)
		}
		
		if `stats_number' != 0 {
			foreach name in `scalar_list' {
				putdocx table regtbl(`row', 1) = ("`name'"), halign(center)
				local row = `row' + 1
			}
		}

		local sigfmt ``sig'fmt'
		local row = `top' + 1

		forvalues vi = 1/`indepvar1num' {
			forvalues mi = 1/`modelnum' {
				local b = b1[`vi', `mi']
				local tz = tz1[`vi', `mi']
				local se = se1[`vi', `mi']
				local p = p1[`vi', `mi']
				if `b' < . {
					local staroutput = ""
					local bstar = ""
					local tstar = ""
					forvalues si = 1/`levelnum' {
						if `p' < `siglevel_`si'' & `p' >= `siglevel_`=`si'+1'' {
							local staroutput `star_`si''
						}
					}
					if "`staraux'" == "" {
						local bstar `staroutput'
					}
					else {
						local tstar `staroutput'
					}
					if "`nostar'" != "" {
						local bstar = ""
						local tstar = "" 
					}
					putdocx table regtbl(`row', `=`mi' + 1') = (`"`=subinstr("`: disp `bfmt' `b''", " ", "", .)'`bstar'"'), halign(center)
					putdocx table regtbl(`=`row' + 1', `=`mi' + 1') = (`"`tleft'`=subinstr("`: disp `sigfmt' ``sig'''", " ", "", .)'`tright'`tstar'"'), halign(center)
				}
			}
			local row = `row' + 2
		}

		if `othernum' != 0 {
			forvalues ot_id = 1/`othernum' {
				local row = `row' + 1
				forvalues vi = 1/`indepvar`= `ot_id' + 1'num' {
					forvalues mi = 1/`modelnum' {
						local b = b`= `ot_id' + 1'[`vi', `mi']
						local tz = tz`= `ot_id' + 1'[`vi', `mi']
						local se = se`= `ot_id' + 1'[`vi', `mi']
						local p = p`= `ot_id' + 1'[`vi', `mi']
						if `b' < . {
							local staroutput = ""
							local bstar = ""
							local tstar = ""
							forvalues si = 1/`levelnum' {
								if `p' < `siglevel_`si'' & `p' >= `siglevel_`=`si'+1'' {
									local staroutput `star_`si''
								}
							}
							if "`staraux'" == "" {
								local bstar `staroutput'
							}
							else {
								local tstar `staroutput'
							}
							if "`nostar'" != "" {
								local bstar = ""
								local tstar = "" 
							}
							putdocx table regtbl(`row', `=`mi' + 1') = (`"`=subinstr("`: disp `bfmt' `b''", " ", "", .)'`bstar'"'), halign(center)
							putdocx table regtbl(`=`row' + 1', `=`mi' + 1') = (`"`tleft'`=subinstr("`: disp `sigfmt' ``sig'''", " ", "", .)'`tright'`tstar'"'), halign(center)
						}
					}
					local row = `row' + 2
				}
			}
		}

		if `"`indicate'"' != "" {
			forvalues indi = 1/`indicate_num' {
				forvalues mi = 1/`modelnum' {
					local yon = indicate_mat[`indi', `mi']
					if `yon' == 1 {
						putdocx table regtbl(`row', `=`mi' + 1') = ("Yes"), halign(center)
					}
					else {
						putdocx table regtbl(`row', `=`mi' + 1') = ("No"), halign(center)
					}
				}
				local row = `row' + 1
			}
		}

		if `stats_number' != 0 {
			forvalues si = 1/`stats_number' {
				forvalues mi = 1/`modelnum' {
					local scl = scalar_mat[`si', `mi']
					if `scl' < . {
						if "`stat_`si'_yn'" == "Y" putdocx table regtbl(`row', `=`mi' + 1') = (`"`=subinstr("`: disp `stat_`si'_fmt' `scl''", " ", "", .)'"'), halign(center)
						else if int(`scl') != `scl' putdocx table regtbl(`row', `=`mi' + 1') = (`"`=subinstr("`: disp `stat_`si'_fmt' `scl''", " ", "", .)'"'), halign(center)
						else putdocx table regtbl(`row', `=`mi' + 1') = ("`scl'"), halign(center)
					}
				}
				local row = `row' + 1
			}
		}

		if "`replace'" == "" & "`append'" == "" {
			putdocx save `using'
		}
		else {
			putdocx save `using', `replace'`append'
		}
	}
	di as txt `"regression table have been written to file {browse "`using'"}"'
end

mata
	void function def_star(string scalar star2) {
		string rowvector star_token
		real scalar col_i

		if (star2 != "") {
			star_token = tokens(star2)
			if (mod(cols(star_token), 2) == 1) {
				st_local("star_error", "1")
			}
			else {
				st_local("levelnum", strofreal(cols(star_token)/2))
				for (col_i = 1; col_i <= cols(star_token)/2; col_i++) {
					st_local(sprintf("star_%g", col_i), star_token[1, 2*col_i-1])
					st_local(sprintf("siglevel_%g", col_i), star_token[1, 2*col_i])
				}
			}
		}
		else {
			st_local("levelnum", "3")
			for (col_i = 1; col_i <= 3; col_i++) {
				st_local(sprintf("star_%g", col_i), "*"*col_i)
				if (col_i != 3) st_local(sprintf("siglevel_%g", col_i), strofreal(0.1/col_i))
				else st_local(sprintf("siglevel_%g", col_i), "0.01")
			}
		}
	}

	void function get_stats_name(string scalar stats) {
		
		string rowvector stats_token
		real scalar stats_i

		stats_token = tokens(stats)
		st_local("stats_number", strofreal(cols(stats_token)))

		for (stats_i = 1; stats_i <= cols(stats_token); stats_i++) {
			if (strpos(stats_token[1, stats_i], "(") != 0) {
				st_local(sprintf("stat_%g", stats_i), substr(stats_token[1, stats_i], 1, strpos(stats_token[1, stats_i], "(") - 1))
				st_local(sprintf("stat_%g_fmt", stats_i), substr(stats_token[1, stats_i], strpos(stats_token[1, stats_i], "(") + 1, strpos(stats_token[1, stats_i], ")") - strpos(stats_token[1, stats_i], "(") - 1))
				st_local(sprintf("stat_%g_yn", stats_i), "Y")
			}
			else {
				st_local(sprintf("stat_%g", stats_i), stats_token[1, stats_i])
				st_local(sprintf("stat_%g_fmt", stats_i), "%9.3f")
				st_local(sprintf("stat_%g_yn", stats_i), "N")
			}
			if (stats_i == 1) st_local("scalar_list", st_local(sprintf("stat_%g", stats_i)))
			else st_local("scalar_list", st_local("scalar_list") + " " + st_local(sprintf("stat_%g", stats_i)))
		}
	}

	void function calculate_all(string scalar b, string scalar V, string scalar regtable, real scalar df, string scalar drop, string scalar indicate, string scalar constant, real scalar modelnum) {
		
		string colvector depvar
		string colvector indepvar
		string colvector total_indepvar
		real matrix expandmat
		real matrix summat
		real colvector selectvec
		real colvector coef
		real matrix Var
		real colvector se
		real colvector tz
		real colvector pvalue
		real matrix allvalue
		string rowvector drop_token
		real colvector droprow
		real colvector consrow
		string colvector indicate_vec
		string matrix indicate_name
		real rowvector indicateornot
		string rowvector indicatetoken
		real colvector indicaterow
		string colvector selectdepvar
		real rowvector omitvar

		if (b != "") {
			depvar = st_matrixrowstripe(b)[., 1]
			indepvar = st_matrixrowstripe(b)[., 2]
		}
		else {
			depvar = st_matrixrowstripe(regtable)[., 1]
			indepvar = st_matrixrowstripe(regtable)[., 2]
		}
		
		total_indepvar = tokens(st_local("indepvar"))'\indepvar
		expandmat = total_indepvar :== (total_indepvar' :* J(rows(total_indepvar), rows(total_indepvar), 1))
		for (i = 1; i <= rows(expandmat); i++) {
			if (i == 1) summat = runningsum(expandmat[., i])
			else summat = summat, runningsum(expandmat[., i])
		}
		selectvec = rowsum(summat :* I(rows(expandmat))) :== 1
		st_local("indepvar", invtokens(select(total_indepvar, selectvec)', " "))

		if (b != "") {
			coef = st_matrix(b)
			Var = st_matrix(V)
			se = J(rows(coef), 1, .)
			for (i = 1; i <= rows(coef); i++) {
				se[i, 1] = sqrt(Var[i, i])
			}
			tz = coef :/ se
			if (df < .) pvalue = 2 :* ttail(df, abs(tz))
			else pvalue = 2 :* (1 :- normal(abs(tz)))

			allvalue = coef, se, tz, pvalue
		}
		else {
			allvalue = st_matrix(regtable)[., 1..4]
		}
		
		omitvar = ustrregexm(indepvar, "^o\.")
		for (i = 1; i <= rows(indepvar); i++) {
			if (omitvar[i, 1] == 1 & allvalue[i, 3] >= .) {
				indepvar[i, 1] = subinstr(indepvar[i, 1], "o.", "", 1)
			}
		}
		
		drop_token = tokens(drop)
		if (cols(drop_token) != 0) {
			droprow = J(rows(indepvar), 1, 0)
			for (i = 1; i <= cols(drop_token); i++) {
				droprow = droprow + strmatch(indepvar, drop_token[1, i])
			}
			depvar = select(depvar, !droprow)
			indepvar = select(indepvar, !droprow)
			allvalue = select(allvalue, !droprow)
		}

		if (constant != "") {
			consrow = indepvar :== "_cons"
			depvar = select(depvar, !consrow)
			indepvar = select(indepvar, !consrow)
			allvalue = select(allvalue, !consrow)
		}
		
		indicate_vec = tokens(indicate)'
		if (rows(indicate_vec) != 0) {
			if ((strpos(indicate_vec, "=") :== 0) != J(rows(indicate_vec), 1, 0)) {
				st_local("indicate_error", "error")
			}
			st_local("indicate_num", strofreal(rows(indicate_vec)))
			indicateornot = J(rows(indicate_vec), 1, 0)
			for (i = 1; i <= rows(indicate_vec); i++) {
				indicatetoken = strtrim(tokens(indicate_vec[i, 1], "="))
				if (i == 1) indicate_name = indicatetoken[1, 1]
				else indicate_name = indicate_name \ indicatetoken[1, 1]
				indicaterow = strmatch(indepvar, indicatetoken[1, 3])
				if (indicaterow != J(rows(indicaterow), 1, 0)) indicateornot[i, 1] = 1
				depvar = select(depvar, !indicaterow)
				indepvar = select(indepvar, !indicaterow)
				allvalue = select(allvalue, !indicaterow)
			}
			st_matrix("indicateornot", indicateornot)
			indicate_name = (`"""' :+ indicate_name :+ `"""')
			st_local("indicate_name", invtokens(indicate_name', " "))
		}
		
		if (depvar == J(rows(depvar), 1, "")) {
			st_local(sprintf("depvarnum_%g", modelnum), "1")
			st_local(sprintf("depvar1_%g", modelnum), st_local("depvar"))
			st_matrix(sprintf("value1_%g", modelnum), allvalue)
			st_local(sprintf("indepvar1_%g", modelnum), invtokens(indepvar', " "))
		}
		else {
			expandmat = depvar :== (depvar' :* J(rows(depvar), rows(depvar), 1))
			for (i = 1; i <= rows(expandmat); i++) {
				if (i == 1) summat = runningsum(expandmat[., i])
				else summat = summat, runningsum(expandmat[., i])
			}
			selectvec = rowsum(summat :* I(rows(expandmat))) :== 1
			selectdepvar = select(depvar, selectvec)
			st_local(sprintf("depvarnum_%g", modelnum), strofreal(rows(selectdepvar)))
			for (i = 1; i <= rows(selectdepvar); i++) {
				st_local(sprintf("depvar%g_%g", i, modelnum), selectdepvar[i, 1])
				selectvec = depvar :== selectdepvar[i, 1]
				st_matrix(sprintf("value%g_%g", i, modelnum), select(allvalue, selectvec))
				st_local(sprintf("indepvar%g_%g", i, modelnum), invtokens(select(indepvar, selectvec)', " "))
			}
		}
	}

	void function testdrop(string scalar indepvar, string scalar drop) {

		string rowvector indepvar_token
		string rowvector drop_token
		real rowvector validdrop

		indepvar_token = tokens(indepvar)
		drop_token = tokens(drop)
		validdrop = colsum(strmatch(indepvar_token' :* J(rows(indepvar_token'), cols(drop_token), 1), drop_token))
		for (i = 1; i <= cols(validdrop); i++) {
			if (validdrop[1, i] == 0) {
				st_local("droperror", "error")
				st_local("drop_item", drop_token[1, i])
			}
		}
	}

	void function mtitles(string scalar mtitles_string) {

		string rowvector token
		real scalar mt_id

		token = tokens(mtitles_string)
		st_local("mtitles_num", sprintf("%g", cols(token)))
		for (mt_id = 1; mt_id <= cols(token); mt_id++) {
			st_local(sprintf("mtitle_%g", mt_id), token[1, mt_id])
		}
	}

	void function combinetable1(real scalar modelnum, string scalar order) {
		
		string rowvector indepvar_token
		string rowvector order_token
		real rowvector validorder
		string rowvector orderindepvar
		real matrix expandmat
		real matrix summat
		real colvector selectvec
		real matrix orderb
		real matrix orderse
		real matrix ordertz
		real matrix orderp
		real matrix value
		string colvector varname
		real matrix ordermatrix
		real colvector timemiss
		real rowvector misst
		
		for (i = 1; i <= modelnum; i++) {
			if (i == 1) indepvar_token = tokens(st_local(sprintf("indepvar1_%g", i)))
			else indepvar_token = indepvar_token, tokens(st_local(sprintf("indepvar1_%g", i)))
		}
		
		order_token = tokens(order)
		if (cols(order_token) != 0) {
			validorder = colsum((indepvar_token' :* J(rows(indepvar_token'), cols(order_token), 1)) :== order_token)
			for (i = 1; i <= cols(validorder); i++) {
				if (validorder[1, i] == 0) {
					st_local("ordererror", "error")
					st_local("order_item", order_token[1, i])
				}
			}
		}
		
		orderindepvar = order_token, indepvar_token
		expandmat = orderindepvar' :== (orderindepvar :* J(rows(orderindepvar'), rows(orderindepvar'), 1))
		for (i = 1; i <= rows(expandmat); i++) {
			if (i == 1) summat = runningsum(expandmat[., i])
			else summat = summat, runningsum(expandmat[., i])
		}
		
		selectvec = rowsum(summat :* I(rows(expandmat))) :== 1
		orderindepvar = select(orderindepvar, selectvec')
		if ((orderindepvar :== "_cons") == J(1, cols(orderindepvar), 1)) orderindepvar = "_cons"
		else if ((orderindepvar :== "_cons") != J(1, cols(orderindepvar), 0)) orderindepvar = select(orderindepvar, (orderindepvar :!= "_cons")), "_cons"
		st_local("indepvar1num", strofreal(cols(orderindepvar)))
		st_local("orderindepvar1", invtokens(orderindepvar, " "))

		for (i = 1; i <= modelnum; i++) {
			value = st_matrix(sprintf("value1_%g", i))
			varname = tokens(st_local(sprintf("indepvar1_%g", i)))'
			ordermatrix = ((orderindepvar :* J(rows(varname), cols(orderindepvar), 1)) :== varname)'
			timemiss = rowsum(ordermatrix)
			for (j = 1; j <= rows(timemiss); j++) {
				if (timemiss[j, 1] == 0) timemiss[j, 1] = .
			}
			
			misst = value[., 3] :>= .
			if (misst != J(rows(value), 1, 0)) {
				for (n = 1; n <= rows(value); n++) {
					if (misst[n, 1] == 1) {
						value[n, 3] = 0
						value[n, 4] = 0
					}
				}
			}
			value = (ordermatrix * value) :* timemiss
			misst = (ordermatrix * misst) :* timemiss
			if (misst != J(rows(value), 1, 0)) {
				for (n = 1; n <= rows(value); n++) {
					if (misst[n, 1] == 1) {
						misst[n, 1] = .
					}
				}
			}
			if (i == 1) {
				orderb = value[., 1]
				orderse = value[., 2]
				ordertz = value[., 3] + misst
				orderp = value[., 4] + misst
			}
			else {
				orderb = orderb, value[., 1]
				orderse = orderse, value[., 2]
				ordertz = ordertz, value[., 3] + misst
				orderp = orderp, value[., 4] + misst
			}
		}
		st_matrix("b1", orderb)
		st_matrix("se1", orderse)
		st_matrix("tz1", ordertz)
		st_matrix("p1", orderp)
	}

	void function getothertable(string scalar otherdpv, string scalar order, real scalar modelnum) {

		string rowvector othertoken
		string rowvector indepvar_token
		string rowvector ordertoken
		string rowvector selectorder
		string rowvector orderindepvar
		real matrix expandmat
		real matrix summat
		real colvector selectvec
		real matrix orderb
		real matrix orderse
		real matrix ordertz
		real matrix orderp
		real matrix value
		string colvector varname
		real matrix ordermatrix
		real colvector timemiss
		real rowvector misst
		
		othertoken = tokens(otherdpv)
		ordertoken = tokens(order)

		st_local("othernum", strofreal(cols(othertoken)))
		for (i = 1; i <= cols(othertoken); i++) {
			
			st_local(sprintf("other_%g", i), othertoken[1, i])
			for (j = 1; j <= modelnum; j++) {
				if (strtoreal(st_local(sprintf("depvarnum_%g", j))) > 1) {
					for (x = 2; x <= strtoreal(st_local(sprintf("depvarnum_%g", j))); x++) {
						if (st_local(sprintf("depvar%g_%g", x, j)) == othertoken[1, i]) {
							if (j == 1) indepvar_token = tokens(st_local(sprintf("indepvar%g_%g", x, j)))
							else indepvar_token = indepvar_token, tokens(st_local(sprintf("indepvar%g_%g", x, j)))
						}
					}
				}
			}
			for (j = 1; j<= cols(ordertoken); j++) {
				if ((indepvar_token :== ordertoken[1, j]) != J(1, cols(indepvar_token), 0)) {
					if (j == 1) selectorder = ordertoken[1, j]
					else selectorder = selectorder, ordertoken[1, j]
				}
			}
			orderindepvar = selectorder, indepvar_token
			expandmat = orderindepvar' :== (orderindepvar :* J(rows(orderindepvar'), rows(orderindepvar'), 1))
			for (j = 1; j <= rows(expandmat); j++) {
				if (j == 1) summat = runningsum(expandmat[., j])
				else summat = summat, runningsum(expandmat[., j])
			}
			selectvec = rowsum(summat :* I(rows(expandmat))) :== 1
			orderindepvar = select(orderindepvar, selectvec')
			if ((orderindepvar :== "_cons") == J(1, cols(orderindepvar), 1)) orderindepvar = "_cons"
			else if ((orderindepvar :== "_cons") != J(1, cols(orderindepvar), 0)) orderindepvar = select(orderindepvar, (orderindepvar :!= "_cons")), "_cons"
			st_local(sprintf("indepvar%gnum", i + 1), strofreal(cols(orderindepvar)))
			st_local(sprintf("orderindepvar%g", i + 1), invtokens(orderindepvar, " "))
			for (j = 1; j <= modelnum; j++) {
				if (strtoreal(st_local(sprintf("depvarnum_%g", j))) > 1) {
					for (x = 2; x <= strtoreal(st_local(sprintf("depvarnum_%g", j))); x++) {
						if (st_local(sprintf("depvar%g_%g", x, j)) == othertoken[1, i]) {
							value = st_matrix(sprintf("value%g_%g", x, j))
							varname = tokens(st_local(sprintf("indepvar%g_%g", x, j)))'
							ordermatrix = ((orderindepvar :* J(rows(varname), cols(orderindepvar), 1)) :== varname)'
							timemiss = rowsum(ordermatrix)
							for (y = 1; y <= rows(timemiss); y++) {
								if (timemiss[y, 1] == 0) timemiss[y, 1] = .
							}
							misst = value[., 3] :>= .
							if (misst != J(rows(value), 1, 0)) {
								for (n = 1; n <= rows(value); n++) {
									if (misst[n, 1] == 1) {
										value[n, 3] = 0
										value[n, 4] = 0
									}
								}
							}
							value = (ordermatrix * value) :* timemiss
							misst = (ordermatrix * misst) :* timemiss
							if (misst != J(rows(value), 1, 0)) {
								for (n = 1; n <= rows(value); n++) {
									if (misst[n, 1] == 1) {
										misst[n, 1] = .
									}
								}
							}
							if (j == 1) {
								orderb = value[., 1]
								orderse = value[., 2]
								ordertz = value[., 3] + misst
								orderp = value[., 4] + misst
							}
							else {
								orderb = orderb, value[., 1]
								orderse = orderse, value[., 2]
								ordertz = ordertz, value[., 3] + misst
								orderp = orderp, value[., 4] + misst
							}
							break
						}
						else if (x == strtoreal(st_local(sprintf("depvarnum_%g", j)))) {
							if (j == 1) {
								orderb = J(cols(orderindepvar), 1, .)
								orderse = J(cols(orderindepvar), 1, .)
								ordertz = J(cols(orderindepvar), 1, .)
								orderp = J(cols(orderindepvar), 1, .)
							}
							else {
								orderb = orderb, J(cols(orderindepvar), 1, .)
								orderse = orderse, J(cols(orderindepvar), 1, .)
								ordertz = ordertz, J(cols(orderindepvar), 1, .)
								orderp = orderp, J(cols(orderindepvar), 1, .)
							}
						}
					}
				}
				else {
					if (j == 1) {
						orderb = J(cols(orderindepvar), 1, .)
						orderse = J(cols(orderindepvar), 1, .)
						ordertz = J(cols(orderindepvar), 1, .)
						orderp = J(cols(orderindepvar), 1, .)
					}
					else {
						orderb = orderb, J(cols(orderindepvar), 1, .)
						orderse = orderse, J(cols(orderindepvar), 1, .)
						ordertz = ordertz, J(cols(orderindepvar), 1, .)
						orderp = orderp, J(cols(orderindepvar), 1, .)
					}
				}
			}
			st_matrix(sprintf("b%g", i + 1), orderb)
			st_matrix(sprintf("se%g", i + 1), orderse)
			st_matrix(sprintf("tz%g", i + 1), ordertz)
			st_matrix(sprintf("p%g", i + 1), orderp)
		}
	}
end
