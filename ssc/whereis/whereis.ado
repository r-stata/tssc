program whereis, rclass
*! v1.4 mantains a directory of external files or folders 10sep2016 rev 17feb2020
	version 14
	args name location
	// why am i storing this is in a macro?
	mata whereis(`"`name'"', `"`location'"') // stores location in local location
	if `"`name'"' != "" {
		display as text `"`location'"' 
		return local `name' `location'
	}
end

mata:
	void whereis(string scalar name, string scalar location) {		
		real scalar pos, col, fh, retrieve, i
		string scalar dirpath, adopath, entry
		string vector dir	
		dir = J(0, 1, "")
		
		// get or create whereis directory
		dirpath = findfile("whereis.dir")
		if(dirpath != "") {
			dir = cat(dirpath)
		}
		else {
			adopath = findfile("whereis.ado")
			dirpath = usubinstr(adopath, ".ado", ".dir", 1)
		}			
		
		// list all resources
		name = ustrtrim(name) //!
		if (name == "") {
			if (length(dir) < 1) {
				printf("{text}No resource locations have been stored with {bf}whereis{sf}\n")
			}
			else {
				//printf("{text}File locations saved with with {bf}whereis{sf}:\n")
				listf(dirpath)
			}
			return
		}
		
		// retrieve location
		pos = lsearch(dir, name)
		retrieve = location == ""
		if(retrieve) { 
			if(pos < 1) {
				errprintf("{txt}location of %s has not been stored with {cmd:whereis}\n", name)
				errprintf("{txt}type {cmd:help whereis} or click {help whereis} for instructions\n")
				exit(601)
			}
			col = ustrpos(dir[pos], " ")
			location = usubstr(dir[pos], col + 1, .)
		}
		
		// check location
		if(!fileexists(location) & !direxists(location)) {
			errprintf(`"file or folder "%s" not found\n"', location)
			exit(601)
		}
		st_local("location", location)

		// store location
		if(!retrieve) {
			entry = name + " " + location
			if(pos < 0) {
				dir = dir \ entry
			}
			else {
				dir[pos] = entry
			}
			if(fileexists(dirpath)) unlink(dirpath)
			fh = fopen(dirpath, "w")
			for(i = 1; i <= length(dir); i++) {
				fput(fh, dir[i])
			}
			fclose(fh)
		}
	}
	// linear search in whereis directory
	real scalar lsearch(string vector lines, string scalar target) {		
		real scalar i, m
		string scalar key
		for(i = 1; i <= length(lines); i++) {
			m = ustrpos(lines[i], " ") 
			key = m > 1 ? usubstr(lines[i], 1, m-1) : lines[i]
			if(key == target) return(i)
		}
		return(-1)
	}
	// list contents of text file
	void listf(string scalar filename) {
		string vector lines
		real scalar i
		lines = cat(filename)
		for(i = 1; i <= length(lines); i++) {
			printf("{text}%s\n", lines[i])
		}	
	}
end     
       
exit
