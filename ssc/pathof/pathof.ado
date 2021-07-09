*! pathof version 1.0 2014-11-01 
*! author: Michael Barker mdb96@georgetown.edu

program define pathof , rclass
	version 11
	syntax [anything(id="directory name" name=target)] [, local(name local)]

	* Strip off any outer quotes of target directory
	local target `target'
	* Call getpath mata routine. Store return value in local macro, path.
	mata: st_local("path" , getpath(`"`:pwd'"' , `"`target'"'))

	* If returned path is empty.
	if `"`path'"'=="" {
		display as result "Directory not found in path of current working directory" 
		exit
	}
	
	* If returned path is not empty.
	else {
		return local path `"`path'"'
		if `"`local'"' != "" {
			c_local `local' `"`path'"'
		}
	}
end

version 11
mata:
// Recursive search of the current path to find the target directory. 
string scalar getpath(string scalar path , string scalar target) 
{
	// If the last element of the path matches the target directory, return the current path.
	if (path=="" | pathbasename(path)==target) {
		return(path)
	}
	else {
		// Otherwise, remove last element and check again for a match.
		pathsplit(path, pathlhs , pathrhs) 
		return(getpath(pathlhs , target))
	}
}
end

