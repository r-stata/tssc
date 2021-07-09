*! version 1.0.0 Matthew White 30dec2014
pr stgit, rclass
	vers 9.2

	loc command = cond(_caller() >= 13, "stgit13", "stgit9")
	vers `=_caller()': `command' `0'
	ret add
end
