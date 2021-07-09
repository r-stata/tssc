*! autorename 1.0.1 8jul2009 by Julian Reif

* 1.0.1: added nodestring option

program define autorename, nclass
	version 8.2	
	syntax [varlist], [row(int 1) NODrop NOLower VSEParator(string) NODestring VARLABels NORename]
	
	* The following is a list of invalid characters for use in variable names
	local badchars "' ; : # ^ ? < > $ / \ % & * ( ) @ ! + - = ~ . , { } | [ ]"
	
	* Error check the row input value
	qui count
	if `row'<1 | `row'>r(N) {
		di as error "Inputted row value of `row' is invalid"
		exit 198
	}
	
	* Make sure the separator doesn't contain invalid characters
	foreach char of local badchars{
		if index("`vseparator'","`char'")!=0 {
			di as error "`char' is an invalid character for the vseparator option"
			exit 198
		}
	}
	if index("`vseparator'"," ")!=0 {
		di as error "vseparator cannot contain spaces"
		exit 198
	}

	
	* Grab current varnames
	local old_varnames "`varlist'"
	if "`varlist'" == "" unab old_varnames : *
	
	* Begin renaming process
	foreach var of local old_varnames {
		
		* Get the new varname from the data
		local new_varname = `var'[`row']
		
		* Apply labels if specified
		if "`varlabels'" != "" label variable `var' "`new_varname'"
		
		if "`norename'" == "" {
		
			* Remove unuseable characters from it
			foreach char of local badchars{
				local new_varname = subinstr(`"`new_varname'"',"`char'","",.)
			}
	
			* Remove quotes and spaces
			local new_varname = subinstr(`"`new_varname'"',`"""',"",.)
			local new_varname = subinstr("`new_varname'"," ","`vseparator'",.)
	
			* Preface numbers with  an underscore. 
			if inlist(substr("`new_varname'",1,1),"1","2","3","4","5","6","7","8","9") | substr("`new_varname'",1,1)=="0" local new_varname = "_" + "`new_varname'"
	
			* Lower case the name
			if "`nolower'" == "" local new_varname = lower("`new_varname'")
	
			* Truncate if necessary
			if length("`new_varname'") > 32 local new_varname = substr("`new_varname'",1,32)
			capture rename `var' `new_varname'
			if _rc!=0 di in yellow "`var' not renamed"
		}
	}
	
	* Drop row with the varnames
	if "`nodrop'" == "" drop in `row'
	
	* Destring if possible
	if "`nodestring'" == "" qui destring, replace	
end

**EOF
