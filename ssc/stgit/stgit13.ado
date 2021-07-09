pr stgit13, rclass
	vers 13.1

	stgit_parse `0'
	ret loc git_dir "`s(git_dir)'"
	javacall org.matthewjwhite.stata.git.StGit javacall, ///
		args(`s(subcmd)' `"`s(git_dir)'"' error_code error_message)
	if "`error_code'" != "" {
		stgit_error `error_code', java(`"`error_message'"')
		/*NOTREACHED*/
	}
	foreach res in has_detached_head is_clean has_uncommitted_changes {
		ret sca `res' = ``res''
	}
	foreach res in branch sha added changed conflicting ignored_not_in_index ///
		missing modified removed uncommitted_changes untracked ///
		untracked_folders {
		ret loc `res' "``res''"
	}

	stgit_summary, detached(`return(has_detached_head)') ///
		branch(`"`return(branch)'"') sha(`return(sha)') ///
		clean(`return(is_clean)')
end
