*! version 1.0.0 Matthew White 13feb2015
pr dtanotes
	vers 10.1

	gettoken subcmd rest : 0

	define_globals

	if `"`subcmd'"' == "drop" {
		drop_notes `rest'
	}
	else {
		add_notes `0'
	}

	drop_globals
end

pr define_globals
	syntax
	gl DTANOTES_VERSION 1.0.0
end

pr drop_globals
	syntax
	foreach suffix in VERSION {
		gl DTANOTES_`suffix'
	}
end

pr add_note
	note: {* dtanotes $DTANOTES_VERSION}`0'
end

pr add_notes
	syntax, creator(str) [NOGIT]

	drop_notes

	lab data "See notes."

	loc creator "`"`creator'"'"
	loc creator : list clean creator
	add_note Dataset created by `creator'.
	loc date : di %td date(c(current_date), "DMY")
	add_note Dataset created on `date' at `c(current_time)'.
	loc computer : environment computername
	if "`computer'" == "" ///
		loc computer (unknown)
	add_note Dataset created on computer `computer' by user `c(username)'.

	qui datasig set, reset
	add_note Data signature: `r(datasignature)'

	if "`nogit'" == "" {
		vers `c(stata_version)': qui stgit
		loc sha `r(sha)'
		if c(stata_version) >= 13 {
			loc status = cond(r(is_clean), "", "not ") + "clean"
			loc uncommitted "`r(untracked)' `r(untracked_folders)' `r(uncommitted_changes)'"
			loc uncommitted : list sort uncommitted
		}
		else {
			loc status      unknown
			loc uncommitted unknown
		}

		add_note Git SHA of current commit: `sha'
		add_note Git working tree status: `status'
		add_note Git uncommitted changes: `uncommitted'
	}

	varabbrev_on note _dta
end

pr drop_notes
	syntax

	lab data

	loc n : char _dta[note0]
	cap conf n `n'
	if _rc ///
		ex
	forv i = 1/`n' {
		mata: st_local("is_dtanote", ///
			strofreal(regexm(st_global("_dta[note`i']"), "^{\* dtanotes .*}")))
		if `is_dtanote' ///
			qui varabbrev_on note drop _dta in `i'
	}
end

* -notes _dta- requires variable abbreviation in Stata 10,
* which also does not have the -varabbrev- prefix.
pr varabbrev_on
	loc varabbrev `c(varabbrev)'
	set varabbrev on
	`macval(0)'
	set varabbrev `varabbrev'
end
