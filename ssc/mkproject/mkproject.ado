*! version 1.1.0 MLB
program define mkproject
        version 10
        syntax name(id="project abbreviation" name=abbrev), ///
               [DIRectory(string)]

		if "`directory'" == "" local directory = c(pwd)
			   
        qui cd `"`directory'"'
        if `"`: dir . dirs "`abbrev'"'"' != "" {
            di as err "directory " as result `"`abbrev'"' as err " already exists in " as result `"`directory'"'
                exit 693
        }
        mkdir `abbrev'
        mkdir `abbrev'/docu
        mkdir `abbrev'/admin
        mkdir `abbrev'/posted
        mkdir `abbrev'/posted/data
        mkdir `abbrev'/work
        
        qui cd `abbrev'/work
        write_main `abbrev'
        boilerplate `abbrev'_dta01.do, dta noopen
		boilerplate `abbrev'_ana01.do, ana noopen
        qui cd ../docu
        write_log 
        cd ../work
		if c(stata_version)>=13{
			projmanager ../`abbrev'.stpr
		}
		else{
			doedit `abbrev'_main.do	
		}
         
end

program define write_main
	version 10
    syntax name(id="project abbreviation" name=abbrev)
    
    local fn = "`abbrev'_main.do"
    tempname main
    file open `main' using `fn', write text
    file write `main' "clear all"_n
    file write `main' "macro drop _all"_n
    file write `main' `"cd "`c(pwd)'""'_n
    file write `main' _n
    file write `main' "do `abbrev'_dta01.do // some comment"_n
    file write `main' "do `abbrev'_ana01.do // some comment"_n
    file write `main' _n
    file write `main' "exit"_n
    file close `main'
end

program define write_log
    version 10
	local fn = "research_log.txt"
    tempname log
    file open  `log' using `fn', write text
    file write `log' "============================"_n
    file write `log' "Research log: <Project name>"_n
    file write `log' "============================"_n
    file write `log' _n _n
    file write `log' "`c(current_date)': Preliminaries"_n
    file write `log' "=========================="_n
    file write `log' _n
    file write `log' "Author(s):"_n
    file write `log' "----------"_n
    file write `log' "Authors with affiliation and email"_n
    file write `log' _n _n
    file write `log' "Preliminary research question:"_n
    file write `log' "------------------------------"_n
    file write `log' _n _n
    file write `log' "Data:"_n
    file write `log' "-----"_n
    file write `log' "data, where and how to get it, when we got it, version"_n
    file write `log' _n _n
    file write `log' "Intended conference:"_n
    file write `log' "--------------------"_n
    file write `log' "conference, deadline"_n
    file write `log' _n _n
    file write `log' "Intended journal:"_n
    file write `log' "-----------------"_n
    file write `log' "journal, requirements, e.g. max word count"_n
end
