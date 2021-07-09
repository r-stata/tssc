pr stgit9, rclass
	vers 9.2

	stgit_parse `0'
	foreach param in subcmd git_dir {
		mata: st_local("`param'", st_global("s(`param')"))
	}

	assert "`subcmd'" == "status"

	loc fn "`git_dir'/HEAD"
	cap conf f `"`fn'"'
	if _rc {
		stgit_error retrieve_head
		/*NOTREACHED*/
	}
	tempname fh
	file open `fh' using `"`fn'"', r
	file r `fh' ref
	file r `fh' blank
	loc eof = r(eof)
	file close `fh'
	loc valid = !`:length loc blank' & `eof'
	if `valid' {
		loc detached = !strmatch("`ref'", "ref: refs/heads/*")
		if `detached' ///
			mata: is_sha("ref", "valid")
	}
	if !`valid' {
		stgit_error invalid_head
		/*NOTREACHED*/
	}

	if `detached' {
		loc sha    `ref'
		loc branch `sha'
	}
	else {
		loc ref = subinstr("`ref'", "ref: ", "", 1)
		loc branch = subinstr("`ref'", "refs/heads/", "", 1)

		loc fn "`git_dir'/`ref'"
		cap conf f `"`fn'"'
		if _rc {
			stgit_error invalid_branch
			/*NOTREACHED*/
		}
		file open `fh' using `"`fn'"', r
		file r `fh' sha
		file r `fh' blank
		loc eof = r(eof)
		file close `fh'
		mata: is_sha("sha", "is_sha")
		if !`is_sha' | `:length loc blank' | !`eof' {
			di as err "`ref': invalid reference"
			stgit_error invalid_branch
			/*NOTREACHED*/
		}
	}

	ret loc git_dir "`git_dir'"
	ret sca has_detached_head = `detached'
	ret loc branch "`branch'"
	ret loc sha `sha'

	stgit_summary, detached(`return(has_detached_head)') ///
		branch(`"`return(branch)'"') sha(`return(sha)')
end

vers 9.2

loc SS	string scalar

loc LclNameS	`SS'

mata:
void is_sha(`LclNameS' _sha, `LclNameS' _is_sha)
{
	`SS' sha

	sha = st_local(_sha)
	st_local(_is_sha, strofreal(strlen(sha) == 40 & regexm(sha, "^[0-9a-f]+$")))
}
end
