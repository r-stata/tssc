*! getfilename2
*! version 1.3
*! 09Dec2005
*! by Jeff Arnold, jeffrey DOT arnold AT ny DOT frb DOT org
* 
* tweak of the official command _getfilename
*

program define getfilename2, rclass
	version 8

        // check that it is one word
	gettoken pathfile rest : 0
	if `"`rest'"' != "" {
		exit 198
	}

	// get last word in pathfile, with separators \, /, :
	gettoken filename rest : pathfile, parse("\/:")
	while `"`rest'"' != "" {
                local path : di `"`path'"' `"`token'"'
                local token `"`filename'"'
		gettoken filename rest : rest, parse("\/:")
	}
	if inlist(`"`filename'"', "\", "/", ":") {
		di as err `"incomplete path-filename; ends in separator `word'"'
		exit 198
	}
        * make sure absolute paths are correct if specified
        if ("`path'" == "" & "`token'" == "/") local path "/"
        if (substr("`path'",-1,1) == ":") local path `"`path'`token'"'
        
        // get etension of path file, with separators "."
        // if file has no "." or begins in "." then no extension
        local anyext = index("`filename'",".")
        if `anyext' > 1 { 
            gettoken ext rest : filename, parse(".")
            while `"`rest'"' != "" {
                    gettoken ext rest : rest, parse(".")
            }
            if inlist(`"`ext'"', ".") {
                    di as err `"incomplete filename; ends in separator `ext'"'
                    exit 198
            }
            // get root of file by removing extension
            local l1 = length(`"`filename'"')
            local l2 = length(`"`ext'"')
            local root = substr(`"`filename'"',1,(`l1'-`l2'-1))
        }
        else {
            local ext ""
            local root `"`filename'"'
        }

        return local path `"`path'"'
        return local ext `"`ext'"'
        return local root `"`root'"'
	return local filename `"`filename'"'
end

