pr stgit_summary
	vers 9.2

	syntax, detached(integer) branch(str) sha(str) [clean(integer -1)]

	di
	di as txt "Branch: " _c
	if `detached' ///
		di as txt "(detached HEAD)"
	else ///
		di as res `"`branch'"'
	di as txt "SHA-1 hash of commit: " as res "`sha'"
	if `clean' != -1 ///
		di as txt "The working tree is " cond(`clean', "", "not ") "clean."
end
