*! 1.0.0  26 Sept 2001  NJC
program define labvarch 
 	version 7
	syntax [varlist] , [ Upper Lower PREFix(str) POSTFix(str) /*
	 */ SUFFix(str) PRESub(str asis) POSTSub(str asis) SUBst(str asis)  /*
	 */ PREDrop(str) POSTDrop(str) Trim(str) /*
	 */ Map(str asis) SYmbol(str) TEST Display /* 
	 */ BEFore(str) AFTer(str) to(str) FRom(str) ]

	if `"`symbol'"' == "" {
		local symbol "@"
	}
	if `"`map'"' != "" & !index(`"`map'"',`"`symbol'"') {
		di as err `"map( ) does not contain `symbol'"'
		exit 198
	}

	* suffix is a synonym for postfix; issuing both
	* is not an error, so long as they agree
	if `"`suffix'"' != "" {
		if `"`postfix'"' != "" & `"`postfix'"' != `"`suffix'"' {
			di as err "postfix( ) and suffix( ) differ"
			exit 198
		}
		local postfix `"`suffix'"'
		local suffix
	}

	local nopt : word count `upper' `lower' /*
        */  `predrop' `postdrop' `trim'
	#delimit ; 
	local nopt = `nopt' + (`"`prefix'"' != "") + (`"`postfix'"' != "") 
	+ (`"`suffix'"' != "") + (`"`map'"' != "") + (`"`presub'"' != "") 
	+ (`"`postsub'"' != "") + (`"`subst'"' != "") + (`"`before'"' != "") +
	(`"`after'"' != "") + (`"`to'"' != "") + (`"`from'"' != ""); 
	#delimit cr 
 	if `nopt' != 1 {
 		di as err /*
		 */ "exactly one transformation option should be specified"
		exit 198
	}

	if `"`subst'"' != "" {
		local srch : word 1 of `subst'
		local repl : word 2 of `subst'
	}
	if `"`presub'"' != "" {
		local srch : word 1 of `presub'
		local repl : word 2 of `presub'
		local nsrch = length(`"`srch'"')
	}
	if `"`postsub'"' != "" {
		local srch : word 1 of `postsub'
		local repl : word 2 of `postsub'
		local nsrch = length(`"`srch'"')
	}
	
	foreach v of varlist `varlist' {
		local label : variable label `v' 
 		if "`upper'" != "" {
 			local label = upper(`"`label'"')
 		}
 		else if "`lower'" != "" {
 			local label = lower(`"`label'"')
 		}
 		else if `"`prefix'"' != "" {
 			local label `"`prefix'`label'"'
 		}
 		else if `"`postfix'"'  != "" {
 			local label `"`label'`postfix'"'
 		}
 		else if `"`subst'"' != "" {
 			local label : /*
 			 */ subinstr local label `"`srch'"' `"`repl'"', all
 		}
 		else if `"`presub'"' != "" {
 			if `"`srch'"' == substr(`"`label'"',1,`nsrch') {
				local label = /*
  			 */ `"`repl'"' + substr(`"`label'"',`nsrch'+1,.)
 			}
 		}
 		else if `"`postsub'"' != "" {
 			if `"`srch'"' == substr(`"`label'"',-`nsrch',.) {
 				local label = /*
	 */ substr(`"`label'"',1,length(`"`label'"')-`nsrch') + `"`repl'"'
			}
 		}
 		else if `"`predrop'"' != "" {
 			confirm integer number `predrop'
 			local label = substr(`"`label'"', 1+`predrop', .)
 		}
 		else if `"`postdrop'"' != "" {
 			confirm integer number `postdrop'
 			local label = /*
		 */ substr(`"`label'"', 1, length(`"`label'"')-`postdrop')
 		}
 		else if `"`trim'"' != "" {
 			confirm integer number `trim'
 			local label = substr(`"`label'"', 1, `trim')
 		}
		else if `"`before'"' != "" {
			local where = index(`"`label'"', `"`before'"')
			if `where' { 
				local label = /* 
				*/ substr(`"`label'"', 1, `where' - 1) 
			} 	
		}
		else if `"`to'"' != "" { 
			local where = index(`"`label'"', `"`to'"') 
			if `where' { 
				local len = length(`"`to'"') 
				local label = /* 
				*/ substr(`"`label'"', 1, `where' + `len' - 1) 
			} 	
		} 
		else if `"`after'"' != "" { 
			local where = index(`"`label'"', `"`after'"') 
			if `where' { 
				local len = length(`"`after'"') 
				local label = /* 
				*/ substr(`"`label'"',`where' + `len', .) 
			} 	
		} 	
		else if `"`from'"' != "" { 
			local where = index(`"`label'"', `"`from'"') 
			if `where' { 
				local label = /* 
				*/ substr(`"`label'"',`where', .) 
			} 	
		} 	
 		else if `"`map'"' != "" {
			local label : /*
			 */ subinstr local map "`symbol'" "`v'", all
			if _rc {
				di as err "inappropriate map?"
				exit _rc
			}
		}
	
		if "`test'" != "" {
			local abbrev = abbrev("`v'",18) 
			di as res "`abbrev'" _col(21) `"`label'"' 
		}	
 		else label var `v' `"`label'"' 
		
 	} /* end of syntax for transformation */

	if "`display'" != "" { 
		describe `varlist' 
	}
end
