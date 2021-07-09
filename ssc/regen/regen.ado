*! version 1.0.1 19jun2014 Daniel Klein

pr regen ,sclass by(o)
	vers 9.2
	
	gettoken ty_fmt_varn_lbls 0 : 0 ,p("=")
	
	syntax anything(id = "=exp" equalok) [if] [in] ///
	[ ,REPLACE NOPromote NOFIX ELSE(str asis) EGEN FORCE * ]
	
	gettoken eqs anything : anything ,p("=")
	if ("`eqs'" != "=") err 102
	
	gettoken ty_fmt_varn lbls : ty_fmt_varn_lbls ,p(`":`""'"')
	
	loc n : word count `ty_fmt_varn'
	if (`n' > 3) err 103
	loc varn : word `n' of `ty_fmt_varn'
	cap n conf name `varn'
	if (_rc) e 198
	if (`n' == 2) {
		gettoken 1st : ty_fmt_varn
		if (substr("`1st'", 1, 1) == "%") loc fmt `1st'
		else loc ty `1st'
	}
	else if (`n' == 3) {
		loc ty : word 1 of `ty_fmt_varn'
		loc fmt : word 2 of `ty_fmt_varn'
	}
	
	loc nlbl : word count `lbls'
	if (`nlbl') {
		if (`nlbl' > 3) err 103
		gettoken dmp : lbls ,p(`"`""'"') qed(q)
		if (`q') gettoken varl lbls : lbls
		else {
			gettoken col lbls : lbls ,p(":")
			gettoken vall lbls : lbls ,qed(q)
			if mi(`"`vall'"') | (`q') err 198
			loc nlbl : word count `lbls'	
			gettoken varl lbls : lbls
		}
		if (strtrim(`"`macval(lbls)'"') != "") err 103
	}
	
	loc cmd `egen'
	if mi("`cmd'") {
		gettoken fcn : anything ,p("(")
		if (`"`macval(fcn)'"' == "group") loc cmd egen
	}
	if mi("`cmd'") {
		loc cmd generate
		cap loc expr = `anything'
		if (_rc == 133) loc cmd egen
		else if (_rc == 198) {
			cap findfile _g`fcn'.ado
			if !(_rc) loc cmd egen
		}
	}
	loc expr `"= `anything'"'
		
	if mi(`"`macval(if)'`in'"') loc iselse 0
	else loc iselse : word count `else'
	if (`iselse') {
		tempvar aux
		qui g byte `aux' = 1 `if' `in'
		loc qui qui
	}
	
	if (`"`options'"' != "") loc options , `options'
	if (_by()) loc byc by `_byvars' `byrc0' :
	
	m : st_global("s(else)", strtrim(st_local("else")))
	m : st_global("s(in)", strtrim(st_local("in")))
	m : st_global("s(if)", strtrim(st_local("if")))
	m : st_global("s(expr)", strtrim(st_local("anything")))
	m : st_global("s(cmd)", strtrim(st_local("cmd")))
	m : st_global("s(by)", strtrim(st_local("byc")))

	cap conf new v `varn'
	if !(_rc) {
		`qui' `byc' `cmd' `ty' `varn' `expr' `if' `in' `options'
		if (`iselse') {
			cap replace `varn' = `else' if mi(`aux')
			if (_rc) {
				drop `varn'
				err _rc
			}
		}
	}
	else {
		if mi("`replace'") conf new v `varn'
		if ("`cmd'" == "egen") | (`iselse') {
			tempvar tmp
			qui `byc' `cmd' `tmp' `expr' `if' `in' `options'
			if (`iselse') qui replace `tmp' = `else' if mi(`aux')
			foreach x in options if in {
				loc `x'
			}
			loc expr "= `tmp'"
		}
		`byc' replace `varn' `expr' `if' `in' ,`nopromote' `options'
	}
	
	if !inlist("`ty'", "", "`: t `varn''") {
		recast `ty' `varn' ,`force'
	}
	
	if (`"`fmt'"' != "") {
		cap form `varn' `fmt'
		if (_rc) di as txt `"(ignored invalid format `fmt')"'
	}
	
	if (`"`vall'"' != "") {
		cap la val `varn' `vall' ,`nofix'
		if (_rc == 181) di as txt "(may not label strings)" 
		else if (_rc) di as txt `"(ignored invalid label `vall')"'
	}
	
	if (`"`macval(varl)'"' != "") | (`nlbl') {
		m : st_varlabel("`varn'", st_macroexpand("`" + "varl" + "'"))
	}
end
e

1.0.1	19jun2014	fix bug with undocumented -group()- function
					new option -egen- (undocumented)
1.0.0	16jun2014	sent to SSC
