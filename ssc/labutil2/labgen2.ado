*! version 1.0.0 01dec2011 Daniel Klein

pr labgen2 ,by(o)
	vers 9.2
	
	* split user
	gettoken bef 0 : 0 ,p(=)
	loc nb : word count `bef'
	syntax anything(equalok everything) /*
	*/ [ , DEFinition EQualsign noBY ]
	
	* check options
	if ("`definition'" == "") {
		if ("`equalsign'`by'" != "") {
			di as err "option definition required"
			e 198
		}
	}
	if ("`equalsign'" != "") loc eq "="
	
	* get by
	if _by() loc byc by `_byvars' `byrc0' :
	
	* get varlabel
	if ("`definition'" != "") {
		loc varl : subinstr loc anything "=" "`eq'"
		loc varl = strtrim(`"`varl'"')
		if _by() & ("`by'" == "") loc varl `"`varl' (by `_byvars')"'
	}
	else {
		loc varl : word `nb' of `bef'
		loc --nb
		tokenize `"`bef'"'
		loc bef
		forv j = 1/`nb' {
			loc bef `bef' ``j''
		}
	}
	
	* get varname
	if (strpos(`"`bef'"', ":")) {
		gettoken varn : bef ,p(:)
		loc varn : word `: word count `varn'' of `varn'
	}
	else loc varn : word `nb' of `bef'
	
	* generate and label new variable
	`byc' g `bef' `anything'
	
	if ("`definitions'" != "") & (strlen(`"`varl'"') > 80) {
		notes `varn' : `varl'
		loc varl "(definition in notes)"
	}
	la var `varn' `"`varl'"'
end
