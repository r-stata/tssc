* Parses the -stgit- command line.
pr stgit_parse, sclass
	vers 9.2

	syntax [anything], *

	if !`:length loc anything' ///
		loc anything status

	gettoken first 0 : anything
	if `:length loc options' ///
		loc 0 "`0', `options'"
	if "`first'" == "status" ///
		syntax, *
	else {
		/*
		Deprecated syntax:

		stgit directory_name

		where directory_name is the path of the root of the repository.
		*/

		syntax

		mata: st_local("git_dir", pathjoin(st_local("first"), ".git"))
		stgit_parse status, git_dir(`"`git_dir'"')
		ex
	}

	syntax, [git_dir(str)]

	if !`:length loc git_dir' ///
		mata: find_git_dir("git_dir")
	else {
		mata: st_local("exists", strofreal(direxists(st_local("git_dir"))))
		if !`exists' {
			di as err `"directory `git_dir' not found"'
			ex 601
		}

		* Make `git_dir' a clean absolute reference.
		nobreak {
			mata: st_local("curdir", pwd())
			* -cd ""- in Stata for Mac/Unix changes the working directory to
			* the home directory, hence this test.
			if `:length loc git_dir' ///
				qui cd `"`git_dir'"'
			* Using -c("pwd")- rather than -pwd()- because the latter ends in
			* a directory separator while the former does not. We want to be
			* consistent with -find_git_dir()-, which does not end with one.
			mata: st_local("git_dir", c("pwd"))
			mata: chdir(st_local("curdir"))
			* -chdir()- does not update the working directory bar in the GUI.
			qui cd .
		}

		* JGit seems to need `git_dir' to have a parent directory.
		mata: if (parent_dir("git_dir") == "") ///
			st_local("git_dir", pathjoin(".", st_local("git_dir")));;
	}

	sret loc git_dir "`git_dir'"
	sret loc subcmd  "`first'"
end

vers 9.2

loc SS	string scalar

loc LclNameS	`SS'

mata:

void function find_git_dir(`LclNameS' _git_dir)
{
	`SS' dir, git_dir

	dir = pwd()
	while (dir != "" & !direxists(git_dir = pathjoin(dir, ".git")))
		pathsplit(dir, dir, "")

	if (dir == "") {
		errprintf("Git repository not found\n")
		exit(601)
	}

	st_local(_git_dir, git_dir)
}

`SS' parent_dir(`LclNameS' _dir)
{
	`SS' parent

	pragma unset parent
	pathsplit(st_local(_dir), parent, "")
	return(parent)
}

end
