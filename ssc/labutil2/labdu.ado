*! version 1.0.3 05jan2012 Daniel Klein

pr labdu ,rclass
	vers 9.2
	
	syntax [namelist] [, DELete Keep Dryrun Report Current]
	
	* check options
	if ("`dryrun'" != "") loc report report
	if ("`keep'" != "") {
		if ("`dryrun'" != "") {
			di as err "keep may not be combined with dryrun"
			e 198
		}
		if ("`delete'" == "") {
			di as err "keep may only be specified with delete"
			e 198
		}
	}
	
	* get labelnames
	if ("`namelist'" == "") loc namelist _all
	if (`: list posof "_all" in namelist') {
		qui la di
		loc namelist `r(names)'
		if ("`namelist'" == "") {
			di as err "no value labels found"
			e 111
		}
	}
	else qui la li `namelist'
	
	* get varlists into labelnames
	qui la lang
	loc curl `r(language)'
	if ("`current'" != "") {
		loc languages `r(language)'
		loc k 1
	}
	else {
		loc languages `r(languages)'
		loc k `r(k)'
	}
	foreach lan of loc languages {
		if (`k' > 1) qui la lang `lan'
		foreach v of varlist * {
			loc lbl : val l `v'
			if ("`lbl'" == "") | !(`: list lbl in namelist') continue
			qui la li `lbl'
			if !r(k) continue
			loc `lbl' ``lbl'', `v'
			if !(`: list lbl in lbllist') loc lbllist `lbllist' `lbl'
		}
	}
	if (`k' > 1) qui la lang `curl'
	
	* output
	if ("`report'" != "") di as txt "unused value labels:"
	
	* drop value labels
	loc found 0
	foreach lab of loc namelist {
		if ("``lab''" == "") {
			loc found 1
			if ("`report'" != "") {
				di as res _col(22) "`lab'"
				if ("`dryrun'" != "") {
					loc unused `unused' `lab'
					continue
				}
			}
			if ("`keep'" != "") continue
			la drop `lab'
			loc dropped `dropped' `lab'
		}
	}
	if ("`report'" != "") & !(`found') di as txt _col(22) "none"
	ret loc unused `unused'
	ret loc dropped `dropped'
	if ("`delete'" == "") e 0 // done
	
	* output
	if ("`report'" != "") di as txt _n "values not in the dataset:"
	
	* delete labels
	tempname val
	loc found 0
	foreach lab of loc lbllist {
		if (`: list lab in dropped') continue
		loc def
		loc todel
		mata : st_vlload("`lab'", v = ., t =.)
		mata : st_matrix("`val'", v)
		forv j = 1/`= rowsof(`val')' {
			loc v = `val'[`j', 1]
			qui cou if inlist(`v'``lab'')
			if (r(N) == 0) {
				loc found 1
				loc def `def' `v' ""
				loc todel `todel' `v'
			}
		}
		if ("`report'" != "") & ("`todel'" != "") {
			di as res _col(28) "`lab': `todel'"
			if ("`dryrun'" != "") continue
		}
		if ("`def'" == "") continue 
		la de `lab' `def' ,modify
	}
	if ("`report'" != "") & !(`found') di as txt _col(28) "none"
end
e

1.0.3	05jan2012	-invtokens- no longer used (Stata 9.2 compatible)
					fix bug with label language
1.0.2	02nov2011	new option -dryrun- (implies report)
					change deletion of integer to text mappings
					macros "values" and "labels" no longer returned
1.0.1	14sep2011	respect label languages
1.0.0	14aug2011	first version on SSC (part of labutil2)
