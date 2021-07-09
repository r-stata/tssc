*! version 1.0.5 20aug2012 Daniel Klein

pr uselab ,rclass
	vers 9.2

	syntax [anything(name = namelist)] [, VARiables Current]
	
	// multilingual value labels
	qui la lang
	loc k `r(k)'
	if (`k' > 1) & ("`current'" == "") {
		loc lgs `r(languages)'
		loc clan `r(language)'
	}
	else loc lgs `r(language)'

	
	// get lblnamelist
	loc ok 0
	if ("`namelist'" == "") loc namelist _all
	if ("`variables'" != "") {
		foreach lan of loc lgs {
			qui la lang `lan'
			foreach v of varlist `namelist' {
				loc lblnamelist `lblnamelist' `: val l `v''
			}
		}
		if (`k' > 1) qui la lang `clan'
	}
	else {
		if (`: list posof "_all" in namelist') {
			qui la di
			loc lblnamelist `r(names)'
			loc ok 1
		}
		else {
			cap la li `namelist'
			if !(_rc) {
				loc lblnamelist `namelist'
				loc ok 1
			}
			else {
				m : st_local("hasd", ///
				strofreal(strpos(st_local("namelist"), "-")))
				if (`hasd') {
					loc namelist : subinstr loc namelist "- " "-" ,all
					loc namelist : subinstr loc namelist " - " "-" ,all
					loc namelist : subinstr loc namelist " -" "-" ,all
				}
				while (`"`namelist'"' != "") {
					gettoken tok namelist : namelist
					cap la li `tok'
					if !(_rc) loc lblnamelist `lblnamelist' `tok'
					else loc varlist `varlist' `tok'
				}
				foreach lan of loc lgs {
					qui la lang `lan'		
					foreach v of varlist `varlist' {
						loc lblnamelist `lblnamelist' `: val l `v''
					}
				}
				if (`k' > 1) qui la lang `clan'
			}
		}
	}
	loc lblnamelist : list uniq lblnamelist
	if !(`ok') qui la li `lblnamelist'
	
	// get varlists for labels
	foreach lan of loc lgs {
		qui la lang `lan'
		foreach var of varlist _all {
			loc lbl : val l `var'
			if ("`lbl'" == "") | !(`: list lbl in lblnamelist') continue
			loc `lbl' ``lbl'' `var'
			if !(`: list lbl in lbllist') loc lbllist `lbllist' `lbl'
		}
	}
	if (`k' > 1) qui la lang `clan'
	
	if ("`lbllist'" == "") {
		di as txt "no value labels found"
		e 0 // done
	}
	if (`k' > 1) ret loc languages `lgs'
	foreach lbl of loc lbllist {
		di as txt %12s "`lbl': " " " as res "``lbl''"
		ret loc `lbl' ``lbl''
	}
end
e

1.0.5	20aug2012	fix bug
					code polish
1.0.4	07jan2012	namelist may conatin variable names
					support multilingual datasets
1.0.3	12aug2011	minor changes to intial checks
					part of -labutil2- package
1.0.2	25jun2011	namelist may now contain wildcards (anything)
					minor changes in error checking/messages
					version 9.2 compatibility
1.0.1	06apr2011	capture error in label list
					add sub-routine _nolabs
					only version 11.1 supported
