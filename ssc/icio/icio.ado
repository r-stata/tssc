
*! version 1.2.7  27may2020
*! authors: Federico Belotti, Michele Mancini, Alessandro Borin
*! see end of file for version comments

program define icio, rclass
    syntax, [EXPorter(string) IMPorter(string) ORIGin(string) DESTination(string) Flow(string) Perspective(string) Approach(string) ///
	   noDISPlay OUTput(string) SECTor(string) GRoups(string asis) INFO SAVE(string) REPLACE ]

/* fede -> todo: put replace into save() option */

** we need version 14 due to the option save(), but we can try to find a workaround
** version 11
version 14

*** This is for us: Set this to 0 for distributed version
loc working_version 0

if "`0'"=="" {
	di as error "At least one of the following options must be specified:"
	di as error "exporter(), importer(), origin() or destination()."
	di as error "See {help icio:help icio} for details."
	error 198
}

loc noi

/* Get working info from _icio_in_ */
m _icio_useful_info(_icio_in_)

if "`iciotable'"=="" {
	di as error "-icio_load- must be used to load a icio table before using the -icio- command."
	exit 198
}

if "`info'" != "" {
	di
	icio_countries, iciotable(`iciotable') working_version(`working_version')
	di
	icio_sectors, iciotable(`iciotable') working_version(`working_version')
	di
	di as result "Summary:"
	di as text "{hline 32}"
	if "`iciotable'"!="user" di as result "ICIO table: " _col(22) as text "`iciotable'"
	else di as result "ICIO table: " _col(22) as text "`iciotable'"
	di as result "Version: " _col(22) as text "`_iotab_rel'"
	di as result "Year: " _col(22) as text "`year'"
	di as result "Number of countries: " _col(22) as text "`_ncountries'"
	if "`_nsectors'"!= "" di as result "Number of sectors: " _col(22) as text "`_nsectors'"

	exit
}


/* Check if groups has been specified and turn the switch on */
if "`groups'"!="" loc groupsyes 1
else loc groupsyes 0

local parsecmd ParseICIOCountry
local parsecmds ParseICIOSector
*** Parsing out
ParseICIOout detail : `"`output'"'

if `groupsyes'==1 {

	local error_groups `"`groups'"'
	local error_groups: subinstr local error_groups " ," ",", all
	local error_groups: subinstr local error_groups ", " ",", all
	local error_groups: subinstr local error_groups `"""' `" " "',all
	local nerror_groups: word count `error_groups'

	*** Checks if the user correctly specifies the groups() argument
	if mod(`nerror_groups',2) == 1 {
		noi di as error "The argument of option -groups()- must contain an even number of elements."
		noi di as error "Each user-defined code must be specified with its own recoding rule."
		error 198
		exit
	}

	*** Compute numbers for option groups arguments
	local nr = `nerror_groups'/2

	*** Initialize rules
	forvalues i = 1/`nr' {
		local user_rule_`i' ""
	}
	local nr_counter = 1
	*** Checks the compulsory presence of double quotes for user-defined groups
	forvalues i = 1/`nerror_groups' {
		gettoken user_rule_component`i' error_groups: error_groups, qed(check_quotes)
			if mod(`i',2) != 1 {
				if `check_quotes'!=1  {
					noi di as error "-groups()- option: user-defined codes must be specified within double quotes."
					error 198
					exit
				}
			}
			local user_rule_`nr_counter' "`user_rule_`nr_counter'' `user_rule_component`i''"
			if mod(`i',2) != 1 {
				local nr_counter= `nr_counter'+1
			}
	}


// WARNING: VERY IMPORTANT
/* when new vinatages of tiva or similar tables are added the groups must be defined also in the loop below and not only into the _icio_main() mata function */


	m _su = J(`nr',1,_icio())
	*m liststruct(_su)
	*** Fix rules specified by the user
	local user_rules ""
	local _group_names_for_parsing ""
		forvalues ur=1/`nr' {
			gettoken upd_user_rules user_rule_`ur': user_rule_`ur'
			local check_upd_user_rules = subinstr("`upd_user_rules'", ",", " ",.)
				foreach cont of local check_upd_user_rules {

					loc lower_countrylist = lower("`countrylist'")

					loc check "regexm("`lower_countrylist'", "`cont'")==0"

					if `check' {
		    			noi di as error "Country " in yellow "`cont'" as error " is not included in the `iciotable' table."
		    			error 198
		    			exit
					}
					if "`cont'"=="chn" & "`iciotable'"=="tiva" & "`_iotab_rel'"=="2016" loc user_groups_`ur' `"`user_groups_`ur'' "`cont'" "cn1" "cn2" "cn3" "cn4""'
					else if "`cont'"=="mex" & "`iciotable'"=="tiva" & "`_iotab_rel'"=="2016" loc user_groups_`ur' `"`user_groups_`ur'' "`cont'" "mx1" "mx2" "mx3""'
          else if "`cont'"=="chn" & "`iciotable'"=="tiva" & "`_iotab_rel'"=="2018" loc user_groups_`ur' `"`user_groups_`ur'' "`cont'" "cn1" "cn2""'
					else if "`cont'"=="mex" & "`iciotable'"=="tiva" & "`_iotab_rel'"=="2018" loc user_groups_`ur' `"`user_groups_`ur'' "`cont'" "mx1" "mx2""'
					else loc user_groups_`ur' `"`user_groups_`ur'' "`cont'""'
					loc check_for_parsing = regexr("`check_for_parsing'","`cont'","")
					loc _group_list_for_parsing "`_group_list_for_parsing' `cont'"

				}
				*loc user_groups_`ur' = regexr(`"`user_groups_`ur''"',",$","")
				local user_groupname_`ur' = trim("`user_rule_`ur''")

				** Define string vectors containing user-defined groups

				m _su = _icio_get_groups(`ur', "`user_groupname_`ur''", `"`user_groups_`ur''"', _su)
				loc _group_names_for_parsing "`_group_names_for_parsing' `user_groupname_`ur''"

		}
}
else  m _su = J(0,1,_icio())


*** Parsing exporter
gettoken exporter exp_sector: exporter, parse(",")
local exp_sector = rtrim(ltrim("`exp_sector'"))
loc exp_sector = regexr(`"`exp_sector'"',"^,","")

if "`exp_sector'"!="" {
	*** Parsing sector code
	`parsecmds' sect_e : `"`exp_sector'"' `_nsectors'
}
else local sect_e 999

*** Parsing importer
gettoken importer imp_sector: importer, parse(",")
local imp_sector = rtrim(ltrim("`imp_sector'"))
loc imp_sector = regexr(`"`imp_sector'"',"^,","")

if "`imp_sector'"!="" {
	*** Parsing sector code
	`parsecmds' sect_i : `"`imp_sector'"' `_nsectors'
}
else local sect_i 999


/* Check if only importer. If yes, set default out to va and origin to all */
if "`exporter'"=="" & "`importer'"!="" {
	if "`output'"=="" {
		*** Set default out in this case
		local detail "gtrade"
	}
}

*** Parsing flow (indirect)
if "`exporter'"!="" & "`importer'"!="" local flow "bilateral"
else if "`exporter'"!="" & "`importer'"=="" local flow "total"
else if "`exporter'"=="" & "`importer'"=="" local flow "vby"
else if "`exporter'"=="" & "`importer'"!="" local flow "totalimp"
if "`exporter'"=="" & "`importer'"!="" & `sect_i'!=999  local flow "sectimp"
if "`flow'"=="vby" local detail "vby"


if "`flow'" != "vby" {

	if "`exporter'" != "" `noi' `parsecmd' export : `"`exporter'"' "exporter" "`countrylist'" "`_group_names_for_parsing'"

	/*
	loc rc = _rc
	if `rc'==198 {
		di "{err}Country/group {res}`exporter' {err}not found"
		exit `rc'
	}
	else if `rc'==100001 {
		di as error "exporter() incorrectly specified. Only one country/group can be specified as exporter."
		exit 198
	}
	else if `rc'==100002 {
		di as error "At least one exporter country/group must be specified."
		exit 198
	}
	*/

	*** Parsing importer (note that importer never needs a sector)
	if "`importer'" != "" {
		`noi' `parsecmd' import : `"`importer'"' "importer" "`countrylist'" "`_group_names_for_parsing'"
		loc rc = _rc
		if `rc'==198 {
			di "{err}Country/group {res}`importer' {err}not found"
			exit `rc'
		}
		else if `rc'==100001 {
			di as error "importer() incorrectly specified. Only one country/group can be specified as importer."
			exit 198
		}
	}
	else local import ""

} /* close flow != vby */

if ("`importer'"== "`exporter'") & ("`importer'"!= "" & "`exporter'"!= "")  {
	di as error "exporter() and importer() must be different."
	exit 198
}

/*
if `sect_e'!=999 & "`import'"=="" {
	di as error "importer() must be specified when a sector is specified in exporter()."
	exit 198
}
*/


*** Parsing origin() and destination() sector
if "`origin'"!="" {
	gettoken origin ori_sector: origin, parse(",")
	local ori_sector = rtrim(ltrim("`ori_sector'"))
	loc ori_sector = regexr(`"`ori_sector'"',"^,","")

	if "`ori_sector'"!="" {
		*** Parsing sector code
		`parsecmds' sect_o : `"`ori_sector'"' `_nsectors'
	}
	else local sect_o 999

	*** Parsing origin
	cap `noi' `parsecmd' ori : `"`origin'"' "origin" "`countrylist'" "`_group_names_for_parsing'"
	loc rc = _rc
	if `rc'==198 {
		di "{err}Country/group {res}`origin' {err}not found"
		exit `rc'
	}
	else if `rc'==100001 {
		di as error "origin() incorrectly specified. Only one country/group can be specified as origin."
		exit 198
	}

}
else {
	local ori ""
	loc sect_o 999
}

if "`destination'"!="" {
	gettoken destination dest_sector: destination, parse(",")
	local dest_sector = rtrim(ltrim("`dest_sector'"))
	loc dest_sector = regexr(`"`dest_sector'"',"^,","")

	if "`dest_sector'"!="" {
		*** Parsing sector code
		`parsecmds' sect_d : `"`dest_sector'"' `_nsectors'
	}
	else local sect_d 999

	cap `noi' `parsecmd' dest : `"`destination'"' "destination" "`countrylist'" "`_group_names_for_parsing'"
	loc rc = _rc
	if `rc'==198 {
		di "{err}Country/group {res}`destination' {err}not found"
		exit `rc'
	}
	else if `rc'==100001 {
		di as error "destination() incorrectly specified. Only one country/group can be specified as destination."
		exit 198
	}

}
else {
	local dest ""
	loc sect_d 999
}



*** Check if origin or destination are countries included in groups
if `groupsyes'==1 {
	loc init_groups_change = 0
	foreach c of local _group_list_for_parsing {
		loc C = upper("`c'")
		if "`C'"=="`ori'" {
			di "{err}Country {res}`c' {err}already included in a group."
			exit 198
		}
		if "`C'"=="`dest'" {
			di "{err}Country {res}`c' {err}already included in a group."
			exit 198
		}
		if "`C'"=="CHN" local init_groups_change = `init_groups_change' + 1
		if "`C'"=="MEX" local init_groups_change = `init_groups_change' + 2
	}
}
else local init_groups_change = 0

*** Check if exporter, importer, origin or destination are countries included in groups
if `groupsyes'==1 {
	loc init_groups_change = 0
	foreach c of local _group_list_for_parsing {
		loc C = upper("`c'")
		if "`C'"=="`export'" {
			di "{err}Country {res}`c' {err}already included in a group."
			exit 198
		}
		if "`C'"=="`import'" {
			di "{err}Country {res}`c' {err}already included in a group."
			exit 198
		}
		if "`C'"=="`ori'" {
			di "{err}Country {res}`c' {err}already included in a group."
			exit 198
		}
		if "`C'"=="`dest'" {
			di "{err}Country {res}`c' {err}already included in a group."
			exit 198
		}
		if "`C'"=="CHN" local init_groups_change = `init_groups_change' + 1
		if "`C'"=="MEX" local init_groups_change = `init_groups_change' + 2
	}
}
else local init_groups_change = 0


*********************************************************
**************** Parsing perspective ********************
*********************************************************
if inlist("`flow'","totalimp","sectimp")==0   {
ParseICIOpersp persp : `"`perspective'"' `"`import'"'
}
else if "`flow'"=="totalimp"  {
if   "`perspective'"!="importer" &  "`perspective'"!=""  {
		di as text "Warning: only perspective(importer) is allowed in total aggregate imports decomposition. -importer- is now imposed."
}
	local persp "importer"
}
else if "`flow'"=="sectimp"  {
if  "`perspective'"!="sectimp"  &  "`perspective'"!="" {
		di as text "Warning: only perspective(sectimp) is allowed in total sectoral imports decomposition. -sectimp- is now imposed."
}
	local persp "sectimp"
}

*********************************************************
******************* Parsing approach ********************
********************************************************




if   inlist("`flow'","sectimp")==1 & ("`sect_i'"=="99999") {
		di as error "A sector of import must be specified when perspective(sectimp)."
		exit 198
}

if "`approach'"!="" & "`flow'"=="total" & "`persp'"!="world" & `sect_e'==999 {
		di as text "Warning: approach() is redundant in total export decomposition with exporter perspective."
		local approach
}
if "`approach'"!="" & "`flow'"=="bilateral" & ("`persp'"=="bilateral" | "`persp'"=="sectbil") {
		di as text "Warning: approach() is redundant in bilateral export decomposition without exporter perspective."
		local approach
}


if (("`detail'"=="detailed" | "`detail'"=="dc" | "`detail'"=="fc" | "`detail'"=="dva" | "`detail'"=="fva") & inlist("`flow'","sectimp","totalimp")==1) {
	 di as text "Warning: only -gtrade- and -va- are allowed with gross imports decomposition."
	 di as text "output(gtrade) set as default output."
	 loc detail "gtrade"
}

if ("`detail'"=="gvc" | "`detail'"=="gvcf" | "`detail'"=="gvcb")  {
	if "`persp'"!="exporter" {
		if inlist("`flow'","sectimp","totalimp")==1 {
		di as error "-gvc-, -gvcb- and -gvcf- can be computed only with a decomposition of gross exports."
		exit 198
		}
		if inlist("`flow'","sectimp","totalimp")==0 {
		di as text "-gvc-, -gvcb- and -gvcf- can be computed only with a -exporter- perspective."
		di as text "perspective(exporter) is now imposed."
		local persp "exporter"
	}
	}
}


local source_is_needed 1
if "`flow'"=="total" & "`persp'"!="world" & `sect_e'==999 local source_is_needed 0
if "`flow'"=="bilateral" & ("`persp'"=="bilateral" | "`persp'"=="sectbil") local source_is_needed 0
if "`flow'"=="vby" local source_is_needed 0
if "`flow'"=="totalimp" local source_is_needed 0
if "`flow'"=="sectimp" local source_is_needed 0

*******
if `source_is_needed'==1 ParseICIOapproach approach : `"`approach'"'
*******

if `sect_e'!=999 & "`flow'"=="bilateral" & "`persp'"=="bilateral" {
		di as text "Warning: perspective(bilateral) is not meaningful when a sector is specified in exporter()."
		di as text "         perspective(sectbil) has been forced."
		local persp "sectbil"
}
if (`sect_e'==999 | `sect_e'==99999) & "`persp'"=="sectbil" {
		di as error "A sector of export must be specified when perspective(sectbil)."
		exit 198
}
if (`sect_e'==999 | `sect_e'==99999) & "`persp'"=="sectexp" {
		di as error "A sector of export must be specified when perspective(sectexp)."
		exit 198
}
if (`sect_e'!=999) & "`persp'"=="world" {
		di as error "perspective(world) cannot be selected when a sector of export is specified."
		exit 198
}

*** Check if options are correctly specified (for bilateral decomposition)
if "`detail'"=="dva" {
	if "`ori'"!="" & ("`ori'"!="`export'")  {
		di as text "Warning: -dva- option requires that the exporter country is also the origin of VA."
		di in text "`export' set as origin of VA"
		loc ori "`export'"
	}
	else if "`ori'"=="" local ori "`export'"
}
if "`detail'"=="fva" {
	if "`export'" == "`ori'" {
		di as error "-fva- option requires a different country for -exporter()- and -origin()-."
		exit 198
	}
}
if "`detail'"=="dc" {
	if "`ori'"!="" & ("`ori'"!="`export'")  {
		di as text "Warning: -dc- option requires that the exporter country is also the origin of VA."
		di in text "`export' set as origin of VA"
		loc ori "`export'"
	}
	else if "`ori'"=="" local ori "`export'"
}
if "`detail'"=="fc" {
	if "`ori'"!="" & ("`export'" == "`ori'") {
		di as error "-fc- option requires a different country for -exporter()- and -origin()-."
		exit 198
	}
}
if "`detail'"=="detailed" {
	if  ("`ori'"!="" & inlist("`flow'","sectimp","totalimp")==0) | "`dest'"!="" {
		di as text _col(1) "Warning: Detailed output cannot be obtained if origin() and/or destination() has/have been specified."
		di as text _col(1) "output(gtrade) is now imposed."
		di as text _col(1) "Other possible selections for output() are: va, dva, fva, dc, fc, gvc, gvcb, gvcf."
		loc detail "gtrade"
	}
}
if ("`detail'"=="gvc" | "`detail'"=="gvcf" | "`detail'"=="gvcb")  {
	if "`approach'"=="sink" {
		di as text "-gvc-, -gvcb- and -gvcf- can be computed only with -source- decomposition.
		di as text "approach(source) is now imposed."
		local approach "source"
	}
}

if (`sect_o'!=999 | `sect_d'!=999) & "`detail'"=="detailed" {
		di as error "Detailed output cannot be obtained if sector of origin and/or destination has/have been specified."
		exit 198
}


if `sect_e'==99999 &  ("`ori'"=="ALL" | "`dest'"=="ALL") {
		di as error "A single sector of export must be specified when origin(ALL) or destination(ALL)."
		exit 198
}


if ("`ori'"=="ALL" & `sect_o'==99999) {
		di as error "origin(all,all) cannot be specified. Specify a single sector - origin(all,num) - or a single country - origin(string,all)."
		exit 198
}

if ("`dest'"=="ALL" & `sect_d'==99999) {
		di as error "destination(all,all) cannot be specified. Specify a single sector - destination(all,num) - or a single country - destination(string,all)."
		exit 198
}
if "`flow'"=="bilateral" & "`persp'"!="sectbil" & `sect_e'<999 & (`sect_o'!=999 | `sect_d'!=999) {
		di as text "Warning: Perspective must be sectoral-bilateral when exporting sector and origin/destination sector are selected."
		di as text "perspective(sectbil) is now imposed."
		loc persp "sectbil"
}
if "`flow'"=="total" & "`persp'"!="sectexp" & `sect_e'<999 & (`sect_o'!=999 | `sect_d'!=999) {
		di as text "Warning: Perspective must be sectoral-exporter when exporting sector and origin/destination sector are selected."
		di as text "perspective(sectexp) is now imposed."
		loc persp "sectexp"
}

if "`flow'"=="bilateral" & `sect_e'==99999 & (`sect_o'!=999 | `sect_d'!=999) {
		di as error "A single sector of export must be specified when a sector of origin and/or destination is selected."
		exit 198
}
if "`flow'"=="total" & `sect_e'==99999 & (`sect_o'!=999 | `sect_d'!=999) {
		di as error "A single sector of export must be specified when a sector of origin and/or destination is selected."
		exit 198
}

if "`flow'"=="vby" & "`detail'"!="" & "`detail'"!="vby" {
		di as text "Warning: the only output available is Value-Added when exporter and importer are not selected."
		loc detail "vby"
}


////////////////////////////////////////////////////////////////
//////////////// HERE IS THE ENGINE OF ICIO ////////////////////
////////////////////////////////////////////////////////////////
di ""

/// Define external variable to be used without declaring them as argument in a function or subfunction
m _icio_nr_pae = _icio_in_.nr_pae
m _icio_nr_sett = _icio_in_.nr_sett

m out = _icio_main("`iciotable'", `sect_e', `sect_o', `sect_d', `sect_i', "`export'", "`import'", ///
				   "`flow'", "`persp'", "`approach'", "`detail'", `groupsyes', "`ori'", "`dest'", _su, _icio_in_)


/* ----------------------------------------------------------------- */
/* ---------- Prepare _out for final display or return ------------- */
/* ----------------------------------------------------------------- */

** Get sector colnames
loc sector_names
forv _s = 1/`_nsectors' {
	loc sector_names `"`sector_names' "sector`_s'","'
}
loc sector_names = regexr(`"`sector_names'"',",$","")
m sector_names = `sector_names'

m _get_out(out, "`detail'", "`ori'", "`dest'", _icio_nr_sett, sector_names)

* Remember sect=99999 means all sectors
*** Attach names to rows and columns
if "`detail'"=="detailed" {
	get_rownames, flow(`flow') persp(`persp') approach(`approach') sect_e(`sect_e')
	mat rownames _out = `r(_rownames)'
	loc _rspec_ "`r(_rspec)'"
	loc _note_ "`r(_note)'"
	loc fmtrowname "%`r(_fmt)'s"
}
else if "`detail'"!="detailed" {

	if rowsof(_out)==1 {
		if "`detail'"=="va" loc nodet_rowname "Value-Added"
		if "`detail'"=="dva" loc nodet_rowname "Domestic VA"
		if "`detail'"=="fva" loc nodet_rowname "Foreign VA"
		if "`detail'"=="dc" loc nodet_rowname "Domestic content"
		if "`detail'"=="fc" loc nodet_rowname "Foreign content"
		if "`detail'"=="gvc" loc nodet_rowname "GVC"
		if "`detail'"=="gvcb" loc nodet_rowname "GVC backward"
		if "`detail'"=="gvcf" loc nodet_rowname "GVC forward"
		if "`detail'"=="gtrade" loc nodet_rowname "Gross exports"
		if "`detail'"=="gtrade" & ("`flow'"=="totalimp" | "`flow'"=="sectimp") loc nodet_rowname "Gross imports"
		if "`detail'"=="vby" loc nodet_rowname "Value-Added"

		loc len_nodet_rowname = length("`nodet_rowname'")+1
		loc fmtrowname "%`len_nodet_rowname's"
		mat rownames _out = "`nodet_rowname'"
		loc _rspec_ "---"
	}
	else {
		if rowsof(_out)==_out_nr_c {
			loc fmtrowname "%4s"
			loc _rspec_ "--"
			forv mm = 1/`=_out_nr_c-1' {
				loc _rspec_ "`_rspec_'&"
			}
			loc _rspec_ "`_rspec_'-"
		}
		if rowsof(_out)==_out_nr_s {
			loc fmtrowname "%9s"
			loc _rspec_ "--"
			forv mm = 1/`=_out_nr_s-1' {
				loc _rspec_ "`_rspec_'&"
			}
			loc _rspec_ "`_rspec_'-"
		}

	}
}
if colsof(_out)==2     mat colnames _out = "Millions of $" "% of export"
if colsof(_out)==2 &  ("`flow'"=="totalimp"  | "`flow'"=="sectimp")  mat colnames _out = "Millions of $" "% of import"
if colsof(_out)==2 &  "`detail'"=="vby"   mat colnames _out = "Millions of $" "% of total"

/* ----------------------------------------------------------------- */
/* ------------------------- Display _out -------------------------- */
/* ----------------------------------------------------------------- */

if "`display'"=="" & `_display_'==1 {
	if "`detail'"=="detailed" {
		matlist _out, underscore cspec(& `fmtrowname' | %14.2f | i %12.2f |) rspec(`_rspec_')
		di as text "`_note_'"
	}
	else matlist _out, underscore cspec(& `fmtrowname' | %14.2f | i %12.2f |) rspec(`_rspec_')
}
if `_display_'==0 {
	di
	di in yel "Output is not displayed but saved in r(`detail')."
}

***** Here save() option in action
if "`save'"!="" {
	di ""
	gettoken savename replace: save, parse(",")
	local savename = subinstr("`savename'", " ", "", .)
	local replace = subinstr("`replace'", ",", "", .)
	local replace = strtrim("`replace'")
	m _icio_out_export("`savename'", "`replace'")
}

* Common post
ret local cmd "icio"
if inlist("`iciotable'","wiod","tiva","eora") ret local version "`_iotab_rel'"
ret local table "`iciotable'"
ret local year "`year'"
if "`ori'"!="" ret local origin "`ori'"
if "`dest'"!="" ret local destination "`dest'"
ret local approach "`approach'"
ret local exporter "`export'"
ret local perspective "`persp'"
if "`import'"!="" ret local importer "`import'"
ret local output "`detail'"

* POST final vectors or matrices to r()
ret matrix `detail' = _out

/// Destructors
loc scalist orig_ncode dest_ncode exp_ncode imp_ncode _out_nr_c _out_nr_s
foreach sc of local scalist {
	cap sca drop `sc'
}

loc structlist _su out _icio_nr_pae _icio_nr_sett sector_names
foreach st of local structlist {
	cap m mata drop `st'
}



end


/* ----------------------------------------------------------------- */
/* --------------------  Ancillary programs ------------------------ */
/* ----------------------------------------------------------------- */

program define get_rownames, rclass
	syntax, flow(string) persp(string) [ approach(string) sect_e(string) ]

	if "`flow'"=="total" & "`persp'"=="exporter" & "`sect_e'"=="999" {

		/* template
		Gross exports (GEXP)
			Domestic content (DC)
				Domestic Value-Added (DVA)
					VAX -> DVA absorbed abroad
					Reflection
				Domestic double counting
			Foreign content (FC)
				Foreign Value-Added (FVA)
				Foreign double counting
		GVC-related trade (GVC)
			GVC-backward (GVCB)
			GVC-forward (GVCF)
		*/

		#d ;
		local total_names `" "Gross exports (GEXP)"
							 "Domestic content (DC)"
							 "Domestic Value-Added (DVA)"
							 "VAX -> DVA absorbed abroad"
							 "Reflection"
							 "Domestic double counting"
							 "Foreign content (FC)"
							 "Foreign Value-Added (FVA)"
							 "Foreign double counting"
							 "GVC-related trade (GVC)"
							 "GVC-backward (GVCB)"
							 "GVC-forward (GVCF)"
							 "';
		#d cr

		loc counter 1
		loc _rownames
		foreach name in EXP DC DVA VAX REF DDC FC FVA FDC GVC GVCB GVCF {
			loc namelong: word `counter' of `total_names'
			if inlist("`name'", "EXP", "GVC") {
				local upd "`namelong'"
				loc l_name = length("`upd'")
				forv i = 1/`=32-`l_name'' {
					local upd "`upd'_"
				}
			}
			if inlist("`name'", "DC","FC","GVCB","GVCF") {
				local upd "__`namelong'"
				loc l_name = length("`upd'")
				forv i = 1/`=32-`l_name'' {
					local upd "`upd'_"
				}
			}
			if inlist("`name'", "DVA","DDC","FVA","FDC") {
				local upd "____`namelong'"
				loc l_name = length("`upd'")
				forv i = 1/`=32-`l_name'' {
					local upd "`upd'_"
				}
			}
			if inlist("`name'", "VAX","REF") {
				local upd "______`namelong'"
				loc l_name = length("`upd'")
				forv i = 1/`=32-`l_name'' {
					local upd "`upd'_"
				}
			}
			loc _rownames `"`_rownames' "`upd'""'

		loc counter = `counter'+1
		}
		local _rspec_ "--&&&&&&&&-&&-"
		local _fmt_ "33"
	}
	else if "`flow'"=="total" & "`persp'"=="world" {

		/* template
		Gross exports (GEXP)
        	Domestic content (DC)
                Domestic Value-Added (DVA)
                    VAX -> DVA absorbed abroad
                    Reflection
                Domestic double counting
            Foreign content (FC)
                Foreign Value-Added (FVA)
                Foreign double counting
		*/

		#d ;
		local total_names `" "Gross exports (GEXP)"
							 "Domestic content (DC)"
							 "Domestic Value-Added (DVA)"
							 "VAX -> DVA absorbed abroad"
							 "Reflection"
							 "Domestic double counting"
							 "Foreign content (FC)"
							 "Foreign Value-Added (FVA)"
							 "Foreign double counting"
							 "';
		#d cr

		loc counter 1
		loc _rownames
		foreach name in EXP DC DVA VAX REF DDC FC FVA FDC {
			loc namelong: word `counter' of `total_names'
			if inlist("`name'", "EXP") {
				local upd "`namelong'"
				loc l_name = length("`upd'")
				forv i = 1/`=32-`l_name'' {
					local upd "`upd'_"
				}
			}
			if inlist("`name'", "DC","FC") {
				local upd "__`namelong'"
				loc l_name = length("`upd'")
				forv i = 1/`=32-`l_name'' {
					local upd "`upd'_"
				}
			}
			if inlist("`name'", "DVA","DDC","FVA","FDC") {
				local upd "____`namelong'"
				loc l_name = length("`upd'")
				forv i = 1/`=32-`l_name'' {
					local upd "`upd'_"
				}
			}
			if inlist("`name'", "VAX","REF") {
				local upd "______`namelong'"
				loc l_name = length("`upd'")
				forv i = 1/`=32-`l_name'' {
					local upd "`upd'_"
				}
			}
			loc _rownames `"`_rownames' "`upd'""'

		loc counter = `counter'+1
		}
		local _rspec_ "--&&&&&&&&-"
		local _fmt_ "33"
	}
	else if  "`flow'"=="bilateral" & "`persp'"=="exporter" & "`approach'"=="sink" {

		/* template
	    Gross exports (GEXP)
          Domestic content (DC)
            Domestic Value-Added (DVA)
              VAX -> DVA absorbed abroad
                VAXIM
              Reflection
            Domestic double counting
          Foreign content (FC)
            Foreign Value-Added (FVA)
            Foreign double counting

		(VAXIM: Value-Added absorbed by the importer)
		*/

		#d ;
		local total_names `" "Gross exports (GEXP)"
							 "Domestic content (DC)"
							 "Domestic Value-Added (DVA)"
							 "VAX -> DVA absorbed abroad"
							 "VAXIM"
							 "Reflection"
							 "Domestic double counting"
							 "Foreign content (FC)"
							 "Foreign Value-Added (FVA)"
							 "Foreign double counting"
							 "';
		#d cr

		loc counter 1
		loc _rownames
		foreach name in EXP DC DVA VAX VAXIM REF DDC FC FVA FDC {
			loc namelong: word `counter' of `total_names'
			if inlist("`name'", "EXP") {
				local upd "`namelong'"
				loc l_name = length("`upd'")
				forv i = 1/`=32-`l_name'' {
					local upd "`upd'_"
				}
			}
			if inlist("`name'", "DC","FC") {
				local upd "__`namelong'"
				loc l_name = length("`upd'")
				forv i = 1/`=32-`l_name'' {
					local upd "`upd'_"
				}
			}
			if inlist("`name'", "DVA","DDC","FVA","FDC") {
				local upd "____`namelong'"
				loc l_name = length("`upd'")
				forv i = 1/`=32-`l_name'' {
					local upd "`upd'_"
				}
			}
			if inlist("`name'", "VAX","REF") {
				local upd "______`namelong'"
				loc l_name = length("`upd'")
				forv i = 1/`=32-`l_name'' {
					local upd "`upd'_"
				}
			}
			if inlist("`name'", "VAXIM") {
				local upd "________`namelong'"
				loc l_name = length("`upd'")
				forv i = 1/`=32-`l_name'' {
					local upd "`upd'_"
				}
			}
			loc _rownames `"`_rownames' "`upd'""'

		loc counter = `counter'+1
		}
		local _rspec_ "--&&&&&&&&&-"
		local _fmt_ "33"
		local _note_ "VAXIM: Value-Added absorbed by the importer"
	}

	else if   "`flow'"=="total" & "`sect_e'"!="999"     & "`persp'"=="exporter" & "`approach'"=="sink" {

		/* template
	    Gross exports (GEXP)
          Domestic content (DC)
            Domestic Value-Added (DVA)
              VAX -> DVA absorbed abroad
              Reflection
            Domestic double counting
          Foreign content (FC)
            Foreign Value-Added (FVA)
            Foreign double counting

		*/

		#d ;
		local total_names `" "Gross exports (GEXP)"
							 "Domestic content (DC)"
							 "Domestic Value-Added (DVA)"
							 "VAX -> DVA absorbed abroad"
							 "Reflection"
							 "Domestic double counting"
							 "Foreign content (FC)"
							 "Foreign Value-Added (FVA)"
							 "Foreign double counting"
							 "';
		#d cr

		loc counter 1
		loc _rownames
		foreach name in EXP DC DVA VAX REF DDC FC FVA FDC {
			loc namelong: word `counter' of `total_names'
			if inlist("`name'", "EXP") {
				local upd "`namelong'"
				loc l_name = length("`upd'")
				forv i = 1/`=32-`l_name'' {
					local upd "`upd'_"
				}
			}
			if inlist("`name'", "DC","FC") {
				local upd "__`namelong'"
				loc l_name = length("`upd'")
				forv i = 1/`=32-`l_name'' {
					local upd "`upd'_"
				}
			}
			if inlist("`name'", "DVA","DDC","FVA","FDC") {
				local upd "____`namelong'"
				loc l_name = length("`upd'")
				forv i = 1/`=32-`l_name'' {
					local upd "`upd'_"
				}
			}
			if inlist("`name'", "VAX","REF") {
				local upd "______`namelong'"
				loc l_name = length("`upd'")
				forv i = 1/`=32-`l_name'' {
					local upd "`upd'_"
				}
			}

			loc _rownames `"`_rownames' "`upd'""'

		loc counter = `counter'+1
		}
		local _rspec_ "--&&&&&&&&-"
		local _fmt_ "33"
	}
	else if ("`flow'"=="bilateral"   | ( "`flow'"=="total" & "`sect_e'"!="999" )) & "`persp'"=="exporter" & "`approach'"=="source" {

		/* template
	    Gross exports (GEXP)
          Domestic content (DC)
            Domestic Value-Added (DVA)
              VAX -> DVA absorbed abroad
                DAVAX
              Reflection
            Domestic double counting
          Foreign content (FC)
            Foreign Value-Added (FVA)
            Foreign double counting
		GVC-related trade (GVC)
		  GVC-backward (GVCB)
		  GVC-forward (GVCF)
		(DAVAX: Value-Added directly absorbed by the importer)
		*/

		#d ;
		local total_names `" "Gross exports (GEXP)"
							 "Domestic content (DC)"
							 "Domestic Value-Added (DVA)"
							 "VAX -> DVA absorbed abroad"
							 "DAVAX"
							 "Reflection"
							 "Domestic double counting"
							 "Foreign content (FC)"
							 "Foreign Value-Added (FVA)"
							 "Foreign double counting"
							 "GVC-related trade (GVC)"
							 "GVC-backward (GVCB)"
							 "GVC-forward (GVCF)"
							 "';
		#d cr

		loc counter 1
		loc _rownames
		foreach name in EXP DC DVA VAX DAVAX REF DDC FC FVA FDC GVC GVCB GVCF {
			loc namelong: word `counter' of `total_names'
			if inlist("`name'", "EXP", "GVC") {
				local upd "`namelong'"
				loc l_name = length("`upd'")
				forv i = 1/`=32-`l_name'' {
					local upd "`upd'_"
				}
			}
			if inlist("`name'", "DC","FC","GVCB","GVCF") {
				local upd "__`namelong'"
				loc l_name = length("`upd'")
				forv i = 1/`=32-`l_name'' {
					local upd "`upd'_"
				}
			}
			if inlist("`name'", "DVA","DDC","FVA","FDC") {
				local upd "____`namelong'"
				loc l_name = length("`upd'")
				forv i = 1/`=32-`l_name'' {
					local upd "`upd'_"
				}
			}
			if inlist("`name'", "VAX","REF") {
				local upd "______`namelong'"
				loc l_name = length("`upd'")
				forv i = 1/`=32-`l_name'' {
					local upd "`upd'_"
				}
			}
			if inlist("`name'", "DAVAX") {
				local upd "________`namelong'"
				loc l_name = length("`upd'")
				forv i = 1/`=32-`l_name'' {
					local upd "`upd'_"
				}
			}
			loc _rownames `"`_rownames' "`upd'""'

		loc counter = `counter'+1
		}
		local _rspec_ "--&&&&&&&&&-&&-"
		local _fmt_ "33"
		local _note_ "DAVAX: Value-Added directly absorbed by the importer"
	}
	else if ("`flow'"=="bilateral" & ("`persp'"=="sectbil" | "`persp'"=="bilateral")) |   ("`flow'"=="total" & "`persp'"=="sectexp") {

		/* template
	    Gross exports (GEXP)
          Domestic content (DC)
            Domestic Value-Added (DVA)
              VAX -> DVA absorbed abroad
              Reflection
            Domestic double counting
          Foreign content (FC)
            Foreign Value-Added (FVA)
            Foreign double counting
		*/

		#d ;
		local total_names `" "Gross exports (GEXP)"
							 "Domestic content (DC)"
							 "Domestic Value-Added (DVA)"
							 "VAX -> DVA absorbed abroad"
							 "Reflection"
							 "Domestic double counting"
							 "Foreign content (FC)"
							 "Foreign Value-Added (FVA)"
							 "Foreign double counting"
							 "';
		#d cr

		loc counter 1
		loc _rownames
		foreach name in EXP DC DVA VAX REF DDC FC FVA FDC {
			loc namelong: word `counter' of `total_names'
			if inlist("`name'", "EXP") {
				local upd "`namelong'"
				loc l_name = length("`upd'")
				forv i = 1/`=32-`l_name'' {
					local upd "`upd'_"
				}
			}
			if inlist("`name'", "DC","FC") {
				local upd "__`namelong'"
				loc l_name = length("`upd'")
				forv i = 1/`=32-`l_name'' {
					local upd "`upd'_"
				}
			}
			if inlist("`name'", "DVA","DDC","FVA","FDC") {
				local upd "____`namelong'"
				loc l_name = length("`upd'")
				forv i = 1/`=32-`l_name'' {
					local upd "`upd'_"
				}
			}
			if inlist("`name'", "VAX","REF") {
				local upd "______`namelong'"
				loc l_name = length("`upd'")
				forv i = 1/`=32-`l_name'' {
					local upd "`upd'_"
				}
			}
			/*
			if inlist("`name'", "DAVAX") {
				local upd "________`namelong'"
				loc l_name = length("`upd'")
				forv i = 1/`=32-`l_name'' {
					local upd "`upd'_"
				}
			}
			*/
			loc _rownames `"`_rownames' "`upd'""'

		loc counter = `counter'+1
		}
		local _rspec_ "--&&&&&&&&-"
		local _fmt_ "33"
		*local _note_ "DAVAX: Value-Added directly absorbed by the importer"
	}

	*** return the rownames
	ret loc _rownames = `"`_rownames'"'
	ret loc _rspec = "`_rspec_'"
	ret loc _note = "`_note_'"
	ret loc _fmt = "`_fmt_'"


end

/* ----------------------------------------------------------------- */

program define ParseICIOCountry
	args returmac colon o type countrylist groupnames

	loc o = lower("`o'")

	if "`type'" == "exporter" | "`type'" == "importer" | "`type'" == "origin" | "`type'" == "destination" local allcountries ALL

	// unfortunately we need to check manually for eora - too many countries
	loc check_c 0
	loc countries_to_check "`countrylist' `allcountries' `groupnames'"
	loc ncountries_to_check: word count `countries_to_check'
	loc c 1
	while (`check_c'!=1) {
		if lower("`:word `c' of `countries_to_check''")=="`o'" loc check_c 1
		loc c = `c'+1
		if `c'>`ncountries_to_check' continue, break
	}
	if `check_c' == 0 {
		di as error "Country `o' not allowed."
		exit 198
	}
	loc `o' "`o'"

	/* old code not usable due to too many countries in eora
	 I have decided to adapt the new code above for all cases
	local 0 ", `o'"
	syntax [, `countrylist' `allcountries' `groupnames']
	*/

	loc alll  = lower("`countrylist' `allcountries' `groupnames'")

	foreach a of loc alll {
		loc toret "`toret' ``a''"
	}

	local wc : word count `toret'

	if `wc' > 1 {
		di as error "`type'() incorrectly specified. Only one country/group can be specified as `type'."
		exit 198
	}
	if `wc' == 0 & "`type'" == "exporter" {
		di as error "At least one exporter country/group must be specified."
		exit 198
	}
	else {
		loc ret = upper("`toret'")
		c_local `returmac' `ret'
	}

end


/* ----------------------------------------------------------------- */


program define ParseICIOSector
	args returmac colon s nrsect

	local 0 ", sector(`s')"
	syntax, sector(string)


	cap confirm integer number `sector'
	if _rc!=0 {
		if lower("`sector'")!="all" {
			di as error "The specified sector must be an integer number or the string " in yel "all."
			exit 198
		}
	}
	else {
		if (`sector' > `nrsect' | `sector'<0) & `sector'!=. {
			di as error "sector code must be within 1-`nrsect'."
			exit 198
		}
	}

	if lower("`sector'")=="all" local sector 99999
	c_local `returmac' `sector'

end

/* ----------------------------------------------------------------- */


program define ParseICIOapproach
	args returmac colon appro

	local 0 ", `appro'"
	syntax [, sink source ]

	local wc : word count `sink' `source'

	if `wc' > 1 {
		di as error "approach() invalid. It may be -sink- or -source-."
		exit 198
	}
	if `wc' == 0 {
		c_local `returmac' source
	}
	else {
		c_local `returmac' `sink' `source'
	}

end

/* ----------------------------------------------------------------- */


/* ----------------------------------------------------------------- */

program define ParseICIOout
	args returmac colon out

	local 0 ", `out'"
	syntax [, DETailed VA DVA FVA DC FC GVC GVCB GVCF GTrade]

	local wc : word count `detailed' `va' `dva' `fva' `dc' `fc'  `gvc' `gvcb' `gvcf' `gtrade'

	if `wc' > 1 {
		di as error "output() invalid. It may be -detailed-, -gtrade-, -va-, -dva-, -fva-, -dc-, -fc-, -gvc-, -gvcb- or -gvcf-."
		exit 198
	}
	else if `wc' == 0 {
		 c_local `returmac' detailed
	}
	else {
		loc ret = lower("`detailed'`va'`dva'`fva'`dc'`fc'`gvc'`gvcb'`gvcf'`gtrade'")
		c_local `returmac' `ret'
	}

end

/* ----------------------------------------------------------------- */


program define ParseICIOpersp
	args returmac colon perspo importo

	local 0 ", `perspo'"
	if "`importo'"!="" syntax [, EXPorter Bilateral SECTBIL]
	else syntax [, EXPorter World SECTEXP]

	local wc : word count `bilateral' `world' `exporter' `sectbil'  `sectexp'
	*`imp'

	if `wc' > 1 {
		if "`importo'"!="" di as error "perspective() invalid. It can be -exporter-, -bilateral-, -sectbil-."
		else di as error "perspective() invalid. It can be -exporter-,-sectexp-, -world-."
		exit 198
	}
	if `wc' == 0 {
		c_local `returmac' exporter
	}
	else {
		loc ret = lower("`bilateral'`world'`exporter'`sectbil'`sectexp'")
		*`imp'
		c_local `returmac' `ret'
	}

end

/* ----------------------------------------------------------------- */


program define icio_countries, sclass
    syntax , ICIOTable(string) [ working_version(integer 0) ]

version 11

m _icio_useful_info(_icio_in_)

*** Get the right sysdir
loc sysdir_plus `"`c(sysdir_plus)'i/"'

/// NOTICE THAT `c(adopath)' has to be substituted with `c(sysdir_plus)' when the command will be distributed
*** Load country list
preserve
if inlist("`iciotable'","wiod") {
	loc wiod_rel "`_iotab_rel'"

	if "`iciotable'"=="wiod" & "`wiod_rel'"=="2013" loc folder wiodo
	if "`iciotable'"=="wiod" & "`wiod_rel'"=="2016" loc folder wiodn

	cap findfile wiod_`wiod_rel'_countrylist.csv, path(`".;`c(adopath)';`"`sysdir_plus'"'"') nodescend
	if _rc {
		// Download the file from http://www.tradeconomics.com/icio/data/wiod
		qui insheet using "http://www.tradeconomics.com/icio/data/`folder'/wiod_`wiod_rel'_countrylist.csv", c clear
		if "`working_version'"=="1" {
			local path4save `"`c(adopath)'"'
			gettoken path4save butta: path4save, parse(";")
		}
		else {
			loc path4save `"`sysdir_plus'"'
		}
		loc path4save = regexr("`path4save'", "/$", "")
		qui outsheet using `"`path4save'/wiod_`wiod_rel'_countrylist.csv"', c nonames noquote
	}
	else {
		qui insheet using `"`r(fn)'"', c clear
	}

	loc n = 1
	loc j = 2
	loc k = 3
	loc m = 4
	di as res "WIOD country list:"
	di
	forv i = 1/`=round(`_ncountries'/4)' {

 		di in gr _col(2) v1[`n'] _col(6) v1[`j'] _col(10) v1[`k'] _col(14) v1[`m']
		loc n = `n'+4
		loc j = `j'+4
		loc k = `k'+4
		loc m = `m'+4
	}
}
if "`iciotable'"=="tiva" {
	loc tiva_rel "`_iotab_rel'"

	if "`iciotable'"=="tiva" & "`tiva_rel'"=="2016" loc folder tivao
	if "`iciotable'"=="tiva" & "`tiva_rel'"=="2018" loc folder tivan

	cap findfile tiva_`tiva_rel'_countrylist.csv, path(`".;`c(adopath)';`"`sysdir_plus'"'"') nodescend
		if _rc {
		// Download the file from http://www.tradeconomics.com/icio/data/tiva
		qui insheet using "http://www.tradeconomics.com/icio/data/`folder'/tiva_`tiva_rel'_countrylist.csv", c clear
		if "`working_version'"=="1" {
			local path4save `"`c(adopath)'"'
			gettoken path4save butta: path4save, parse(";")
		}
		else {
			loc path4save `"`sysdir_plus'"'
		}
		loc path4save = regexr("`path4save'", "/$", "")
		qui outsheet using "`path4save'/tiva_`tiva_rel'_countrylist.csv", c nonames noquote
	}
	else {
		qui insheet using `"`r(fn)'"', c clear
	}

	di as res "TIVA country list:"
	di
	di as res _col(2) "Country" _col(12) "Country group"
	forv i = 1/`_ncountries' {
 		di in gr _col(2) v1[`i'] _col(12) v2[`i']

	}
}
if "`iciotable'"=="eora" {
	cap findfile eora_countrylist.csv, path(`".;`c(adopath)';`"`sysdir_plus'"'"') nodescend
		if _rc {
		// Download the file from http://www.tradeconomics.com/icio/data/eora
		qui insheet using "http://www.tradeconomics.com/icio/data/eora/eora_countrylist.csv", c clear
		if "`working_version'"=="1" {
			local path4save `"`c(adopath)'"'
			gettoken path4save butta: path4save, parse(";")
		}
		else {
			loc path4save `"`sysdir_plus'"'
		}
		loc path4save = regexr("`path4save'", "/$", "")
		qui outsheet using "`path4save'/eora_countrylist.csv", c nonames noquote
	}
	else {
		qui insheet using `"`r(fn)'"', c clear
	}

	loc n = 1
	loc j = 2
	loc k = 3
	loc m = 4
	di as res "EORA country list:"
	di
	forv i = 1/`=round(`_ncountries'/4)' {

 		di in gr _col(2) v1[`n'] _col(6) v1[`j'] _col(10) v1[`k'] _col(14) v1[`m']
		loc n = `n'+4
		loc j = `j'+4
		loc k = `k'+4
		loc m = `m'+4
	}
}
if "`iciotable'"=="adb" {
	cap findfile adb_countrylist.csv, path(`".;`c(adopath)';`"`sysdir_plus'"'"') nodescend
		if _rc {
		// Download the file from http://www.tradeconomics.com/icio/data/adb
		qui insheet using "http://www.tradeconomics.com/icio/data/adb/adb_countrylist.csv", c clear
		if "`working_version'"=="1" {
			local path4save `"`c(adopath)'"'
			gettoken path4save butta: path4save, parse(";")
		}
		else {
			loc path4save `"`sysdir_plus'"'
		}
		loc path4save = regexr("`path4save'", "/$", "")
		qui outsheet using "`path4save'/adb_countrylist.csv", c nonames noquote
	}
	else {
		qui insheet using `"`r(fn)'"', c clear
	}

	loc n = 1
	loc j = 2
	loc k = 3
	loc m = 4
	di as res "ADB country list:"
	di
	forv i = 1/`=round(`_ncountries'/4)' {

 		di in gr _col(2) v1[`n'] _col(6) v1[`j'] _col(10) v1[`k'] _col(14) v1[`m']
		loc n = `n'+4
		loc j = `j'+4
		loc k = `k'+4
		loc m = `m'+4
	}
}
if "`iciotable'"=="user" {

	qui insheet using `"`iotable_user_clist'"', c clear

	loc n = 1
	loc j = 2
	loc k = 3
	loc m = 4
	di as res "User-provided country list:"
	di
	forv i = 1/`=round(`_ncountries'/4)' {

 		di in gr _col(2) v1[`n'] _col(6) v1[`j'] _col(10) v1[`k'] _col(14) v1[`m']
		loc n = `n'+4
		loc j = `j'+4
		loc k = `k'+4
		loc m = `m'+4
	}
}
restore

end

/* ----------------------------------------------------------------- */

program define icio_sectors, sclass
    syntax , ICIOTable(string) [ working_version(integer 0) ]

version 11

m _icio_useful_info(_icio_in_)

*** Get the right sysdir
loc sysdir_plus `"`c(sysdir_plus)'i/"'

*** Load sector list
preserve
if inlist("`iciotable'","wiod") {
	loc wiod_rel "`_iotab_rel'"

	if "`iciotable'"=="wiod" & "`wiod_rel'"=="2013" loc folder wiodo
	if "`iciotable'"=="wiod" & "`wiod_rel'"=="2016" loc folder wiodn

	cap findfile wiod_`wiod_rel'_sectorlist.csv, path(`".;`c(adopath)';`"`sysdir_plus'"'"') nodescend
	if _rc {
		// Download the file from http://www.tradeconomics.com/icio/data/wiod
		qui insheet using "http://www.tradeconomics.com/icio/data/`folder'/wiod_`wiod_rel'_sectorlist.csv", delimit(";") nonames clear
		if "`working_version'"=="1" {
			local path4save `"`c(adopath)'"'
			gettoken path4save butta: path4save, parse(";")
		}
		else {
			loc path4save `"`sysdir_plus'"'
		}
		loc path4save = regexr("`path4save'", "/$", "")
		qui outsheet using `"`path4save'/wiod_`wiod_rel'_sectorlist.csv"', delimit(";") nonames
	}
	else {
		qui insheet using `"`r(fn)'"', delimit(";") clear nonames
	}

	di as res "WIOD sector list:"
	di
	di as res _col(2) "Sector code" _col(16) "Sector description"
	forv i = 1/`_nsectors' {
 		di in gr _col(2) v1[`i'] _col(16) v2[`i']

	}
}
if "`iciotable'"=="tiva" {
	loc tiva_rel "`_iotab_rel'"

	if "`iciotable'"=="tiva" & "`tiva_rel'"=="2016" loc folder tivao
	if "`iciotable'"=="tiva" & "`tiva_rel'"=="2018" loc folder tivan

	cap findfile tiva_`tiva_rel'_sectorlist.csv, path(`".;`c(adopath)';`"`sysdir_plus'"'"') nodescend
		if _rc {
		// Download the file from http://www.tradeconomics.com/icio/data/tiva
		qui insheet using "http://www.tradeconomics.com/icio/data/`folder'/tiva_`tiva_rel'_sectorlist.csv", delimit(";") clear nonames
		if "`working_version'"=="1" {
			local path4save `"`c(adopath)'"'
			gettoken path4save butta: path4save, parse(";")
		}
		else {
			loc path4save `"`sysdir_plus'"'
		}
		loc path4save = regexr("`path4save'", "/$", "")
		qui outsheet using "`path4save'/tiva_`tiva_rel'_sectorlist.csv", delimit(";") nonames
	}
	else {
		qui insheet using `"`r(fn)'"', delimit(";") clear nonames
	}

	di as res "TIVA sector list:"
	di
	di as res _col(2) "Sector code" _col(16) "Sector description"
	forv i = 1/`_nsectors' {
 		di in gr _col(2) v1[`i'] _col(16) v2[`i']

	}
}
if inlist("`iciotable'","eora") {
	cap findfile eora_sectorlist.csv, path(`".;`c(adopath)';`"`sysdir_plus'"'"') nodescend
	if _rc {
		// Download the file from http://www.tradeconomics.com/icio/data/eora
		qui insheet using "http://www.tradeconomics.com/icio/data/eora/eora_sectorlist.csv", delimit(";") clear nonames
		if "`working_version'"=="1" {
			local path4save `"`c(adopath)'"'
			gettoken path4save butta: path4save, parse(";")
		}
		else {
			loc path4save `"`sysdir_plus'"'
		}
		loc path4save = regexr("`path4save'", "/$", "")
		qui outsheet using `"`path4save'/eora_sectorlist.csv"', delimit(";") nonames
	}
	else {
		qui insheet using `"`r(fn)'"', delimit(";") clear nonames
	}

	di as res "EORA sector list:"
	di
	di as res _col(2) "Sector code" _col(16) "Sector description"
	forv i = 1/`_nsectors' {
 		di in gr _col(2) v1[`i'] _col(16) v2[`i']

	}
}
if inlist("`iciotable'","adb") {
	cap findfile adb_sectorlist.csv, path(`".;`c(adopath)';`"`sysdir_plus'"'"') nodescend
	if _rc {
		// Download the file from http://www.tradeconomics.com/icio/data/adb
		qui insheet using "http://www.tradeconomics.com/icio/data/adb/adb_sectorlist.csv", delimit(";") clear nonames
		if "`working_version'"=="1" {
			local path4save `"`c(adopath)'"'
			gettoken path4save butta: path4save, parse(";")
		}
		else {
			loc path4save `"`sysdir_plus'"'
		}
		loc path4save = regexr("`path4save'", "/$", "")
		qui outsheet using `"`path4save'/adb_sectorlist.csv"', delimit(";") nonames
	}
	else {
		qui insheet using `"`r(fn)'"', delimit(";") clear nonames
	}

	di as res "ADB sector list:"
	di
	di as res _col(2) "Sector code" _col(16) "Sector description"
	forv i = 1/`_nsectors' {
 		di in gr _col(2) v1[`i'] _col(16) v2[`i']

	}
}
restore

end

exit

/**** Versioning

* version 1.0.0  25mar2016 - First version
* version 1.0.1  16feb2017 - Added origin and destination options
* version 1.0.2  25may2017 - Added icio_load and created a icio_dlg.ado to be call only through DIALOG (see icio.dlg).
							- This allows for flexibility and efficiency when the main command is included
							- in a user-defined loop.
* version 1.0.3  9jun2017 - Added -kww- and -output()- options
* version 1.0.4  10jul2017 - Added -sector()- option for sectoral kww and bilateral decomposition
* version 1.1 6oct2017 - Added -groups()- option to specify user-defined countries' groups
* version 1.1.1 13oct2017 - Added -gvc- as output option for source decomposition
* version 1.1.2 17oct2017 - Added -vby- as alternative to kww and bilateral
* version 1.1.3 23oct2017 - Country list is now endogenized and is loaded by the ado to parse the origin() destination() exporter() and importer() options
* version 1.1.4 21nov2017 - Added -info- option an corrected small bugs
* version 1.1.5 16jan2018 - Corrected small bugs in -icio, info-
* version 1.1.6 25jul2018 - Added save() and replace options to export the output in xls. In mata, all source-related mata functions have been optimized
* version 1.1.7 3aug2018  - icio_load.ado now handles partially the data-preparation step. Parsing subcommands have been extended and generalized solving a bunch of bugs
* version 1.1.8 11sep2018 - Some bug fixes on output post
* version 1.1.9 15jan2019 - icio restyling to fit the new BM (2019) paper
* version 1.2.0 30jan2019 - The output procedures have been completely rewritten to fit the new outlet.
* version 1.2.1 23feb2019 - Fixed a bug preventing the loading of user-provided tables
* version 1.2.2 20jun2019 - Added several functions in line with World Bank WP (2019): VA analysis, total sectoral exports, sectexp perspective. Now only totalimp and sectimp perspectives are missing. totalimp already coded and linked. output(va) to be added to all functions (not non totalimp, already done).
* version 1.2.3 1aug2019 - According to the new icio_load (1.2.0), this version allows for two different releases of "wiod" and "tiva" and add "eora" as a new preloaded iotable in icio
* version 1.2.4 10sep2019 - Fixed groups for tiva (new release). The icio_load "_in" structure now contains the release of the table.
* version 1.2.5 11sep2019 - Now the option save() works properly using the syntax save(filename [, replace]) where filename is a standard filename or include the full or relative path to the file including the name (optionally the .xls prefix), i.e. "/Users/federico/Desktop/file.xls". Also, now mm_which by Ben Jann has been included in _icio_functions.mata (no need to install moremata anymore).
* version 1.2.6 5feb2020 - Fixed an annoying bug preventing the use of china and mexico inside groups()
* version 1.2.7 27may2020 - Added the new table ADB

*/
