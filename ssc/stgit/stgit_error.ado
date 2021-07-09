pr stgit_error
	vers 9.2

	syntax name(name=code id=code), [java(str)]

	loc rc 198
	if "`code'" == "invalid_repository" {
		di as err "invalid repository"
	}
	else if "`code'" == "retrieve_head" {
		di as err "cannot retrieve HEAD"
		di as err "check path of GIT_DIR"
	}
	else if "`code'" == "invalid_head" {
		di as err "invalid HEAD"
	}
	else if "`code'" == "invalid_branch" {
		di as err "invalid branch"
	}
	else if "`code'" == "java" {
		* Display Java exception message only.
		loc rc 5100
	}
	else {
		di as err "invalid stgit_error code"
	}

	if "`java'" != "" {
		di as err "Java error message:"
		di as err "`java'"
	}

	conf n `rc'
	ex `rc'
end
