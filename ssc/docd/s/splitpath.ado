*! version 1.0.1  06jul2021  hendri.adriaens@centerdata.nl
// based on function project_pathname from the project package
program define splitpath, rclass

	args path
	
	// to avoid macro expansion problems
	local path: subinstr local path "\" "/", all
	
	// navigate and build the directory until we reach the filename
	gettoken part rest : path, parse("/:")
	while "`rest'" != "" {
		local directory "`directory'`part'"
		gettoken part rest : rest, parse("/:")
	}
	if inlist("`part'", "/", ":") {
		display as error `"Was expecting a filename: "`path'""'
		exit 198
	}
	else {
		local filename "`part'"
	}
	
	return local directory "`directory'"
	return local filename "`filename'"

end
