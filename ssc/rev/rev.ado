*! version 2.0.5 28aug2012 Daniel Klein

pr rev
	vers 9.2
	
	syntax varlist(num) [if][in] ///
	[ , PREfix(name) Generate(str) SUFfix(str) replace ///
	Label_p(namelist) noLabel modify Mask(str) ///
	Valid(numlist miss min = 2 max = 249) ///
	Reverse(numlist miss min = 2 max = 249) ///
	Swap(numlist miss min = 2 max = 249) ///
	COPYrest ]
	
	loc uservars `varlist'
	loc nvars : word count `uservars'
	
	marksample touse ,nov
	qui cou if `touse'
	if !(r(N)) err 2000 

	// check options
	if ("`label'" != "") & ("`mask'`label_p'" != "") {
		loc opt = cond("`mask'" != "", "mask", "label")
		di as err "nolabel and `opt' not both allowed"
		e 198
	}
	
	if ("`label_p'" != "") {
		loc nlab : word count `label_p'
		if (`nlab' > 1) & (`nvars' != `nlab') {
			di as err "invalid label(): number of" ///
			"names does not match number of variables"
			e 198
		}
	}
	
	if ("`replace'" != "") {
		if (`"`prefix'`generate'`suffix'"' != "") {
			di as err "replace may not be combined " ///
			"with prefix, generate or suffix"
			e 198
		}
	}
	else {
		loc userpre `prefix'
		loc suffix = trim(`"`suffix'"')
		if (`: word count `suffix'' > 1) {
			di as err "invalid suffix(): too many names specified"
			e 103
		}
		if ("`generate'" != "") {
			loc 0 `generate'
			syntax newvarlist
			loc generate `varlist'
			if (`nvars' != `: word count `generate'') {
				di as err "invalid generate(): number of " ///
				"names does not match number of variables"
				e 198
			}
			if (`"`prefix'`suffix'"' == "") {
				foreach g of loc generate {
					conf new v `prefix'`g'`suffix'
					if ("`label'`modify'" == "") {
						cap la li `prefix'`g'`suffix'
						if !(_rc) {
							di as err "label `prefix'`g'`suffix' " ///
							"already defined"
							e 110
						}
					}
				}
			}
		}
		else {
			if (`"`prefix'`suffix'"' == "") loc prefix rv_
			foreach v of loc uservars {
				conf new v `prefix'`v'`suffix'
				if ("`label'`modify'" == "") {
					cap la li `prefix'`v'`suffix'
					if !(_rc) {
						di as err "label `prefix'`v'`suffix' " ///
						"already defined"
						e 110
					}
				}
			}
		}
	}
	
	if (`"`mask'"' != "") {
		loc dmp : subinstr loc mask "#" "" ,c(loc s)
		if (`s' != 1) {
			di as err "option mask should " ///
			"contain 1 substitution char #"
			e 198
		}
		loc mask mask(`"`mask'"')
	}
	
	if ("`reverse'" != "") {
		if ("`valid'" != "") & ("`valid'" != "`reverse'") {
			di as err "reverse and valid differ"
			e 198
		}
		loc valid `reverse'
	}
	
	if ("`swap'" != "") {
		if ("`valid'" != "") {
			di as err "option swap not allowed"
			e 198
		}
		loc nsw : list sizeof swap
		if mod(`nsw', 2) {
			di as err "swap: odd number of values"
			e 198
		}
		token `swap'
		forv j = 1(2)`nsw' {
			loc nxt = `j' + 1
			if (``j'' == ``nxt'') continue
			loc va `va' ``j'' 
			loc lid ``nxt'' `lid'
		}
		loc valid `va' `lid'
	}
	
	loc getvalid = ("`valid'" == "")
	if !(`getvalid') {
		loc dup : list dups valid
		if ("`dup'" != "") {
			di as err "invalid valid(): " ///
			"`dup' mentioned more than once"
			e 198
		}
		loc ls : subinstr loc valid " " ", " ,all
	}
	
	if ("`copyrest'" == "") loc iftouse if `touse' 

	// reminder
	if ("`userpre'`generate'`suffix'`replace'" == "") {
		di as txt "(note: default prefix " /*
		*/ as res "rv_ " as txt "set)"
	}
	
	// reverse value order in variables and value labels
	tempvar tmpv
	loc c 0
	
	foreach var of loc uservars {
		
		loc ++c
		if (`getvalid') qui levelsof `var' ,l(valid)
		
		// reverse values
		loc nvld : list sizeof valid
		qui clonevar `tmpv' = `var' `iftouse'
		cap as `var' == int(`var')
		if !(_rc) & (`getvalid') { // can do fast
			qui {
				su `var' if `touse' ,mean
				replace `tmpv' = (r(min) + r(max)) - `var' if `touse'
				replace `tmpv' = `var' if mi(`var')
			}
		}
		else { // non-integer or -valid- specified
			loc add = cond("`ls'" != "", "& !inlist(`var', `ls')", "")
			loc float = cond("`: t `var''" == "double", "", "float")
			loc stp = ceil(`nvld'/2)
			token `valid'
			forv j = 1/`stp' {
				if (`j' == `nvld') continue ,br // odd number; done
				qui replace `tmpv' = ``j'' ///
				if `var' == `float'(``nvld'') & `touse'
				qui replace `tmpv' = ``nvld'' ///
				if `var' == `float'(``j'') & `touse'
				loc --nvld
			}
			qui replace `tmpv' = `var' if mi(`var') `add'
		}
		
		// new variable name
		if ("`generate'" == "") loc newvar `prefix'`var'`suffix'
		else loc newvar `prefix'`: word `c' of `generate''`suffix'
		
		// make changes final
		if ("`replace'" != "") qui replace `var' = `tmpv'
		else qui clonevar `newvar' = `tmpv'
		drop `tmpv'
		
		// reverse value label
		if ("`label'" != "") {
			la val `newvar'
			continue // nothing to do; next
		}
		
		// check variable has value label
		loc lbl : val l `var'
		if ("`lbl'" == "") {
			di as txt "(note: " as res "`var' " ///
			as txt "has no value label)"
			continue // nothing to do; next
		}
		cap la li `lbl'
		if _rc {
			di as txt "(note: " as res "`lbl' " ///
			as txt "not defined")
			continue // nothing to do; next
		}
		
		// new value label name
		if ("`label_p'" != "") {
			if (`nlab' == 1) & (`c' > 1) {
				la val `newvar' `label_p'
				continue // one label for all vars
			}
			loc newlbl `: word `c' of `label_p''
		}
		else {
			if ("`replace'" != "") loc newlbl `lbl'
			else loc newlbl `newvar'
		}
		
		// check numlabel
		loc addnumlab 0
		qui numlabel `lbl' ,r `mask'
		if ("`: di _rc'" == "0") loc addnumlab 1
		
		// clean valid
		loc nvld : list sizeof valid
		token `valid'
		loc cvalid
		forv j = 1/`nvld' {
			cap as (``j'') == int(``j'')
			if _rc loc `j' .
			loc cvalid `cvalid' ``j''
		}
		
		// reverse label
		m : _mreversevlab("`lbl'", "`newlbl'", "`cvalid'")
		la val `newvar' `newlbl'
			
		// add numlabel
		if (`addnumlab') {
			numlabel `lbl' ,a `mask'
			numlabel `newlbl' ,a `mask'
		}
	}
end

vers 9.2
m :
void _mreversevlab(string scalar oldlbl,
					string scalar newlbl,
					string scalar valid)
{
	real colvector val, rval
	string colvector txt
	real scalar j
	
	st_vlload(oldlbl, val, txt)
	st_vlmodify(newlbl, val, txt)
	
	val = strtoreal(tokens(valid))'
	txt = st_vlmap(newlbl, val)
	j = rows(val)	
	rval = J(1, j, .)'
	for (i = 1; i <= rows(val); ++i) {
		rval[i, 1] = val[j, 1]
		--j
	}
	
	st_vlmodify(newlbl, rval, txt)
	st_vlmodify(newlbl, ., "")
}
end
e

2.0.5	28aug2012	existing value labels no longer overwritten
					new -modify- option
					fix typo, code polish
2.0.4	07feb2012	option copyrest added
					option reverse as synonym for valid
					option swap added
					allow newvarlist in generate
					allow missing values in valid
					fix bug in reminder message
2.0.3	02feb2012	add option suffix
					add version statement to mata code
2.0.2	09dec2011	display reminder once only
2.0.1	02nov2011	mata function reverses labels
					check undefined value labels
					fix bug in option -nolabel-
					display reminder if default prefix is used
2.0.0	21aug2011	change name to rev (was revv)
					internal version is 2.0.0
					downward compatibility with version 9.2
					option -numlabel- replaced with -mask-
					option -define- renamed -label-
					