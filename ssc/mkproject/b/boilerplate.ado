*! version 1.1.0 MLB 
program define boilerplate
	version 10
    syntax anything(id="file name" name=fn), [dta ana noopen]
	
	if "`dta'" != "" & "`ana'" != "" {
		di as err "options dta and ana can not be combined"
		exit 198
	}
	if "`dta'`ana'" == "" local dta "dta"
		
    if strpos(`"`fn'"', ".") == 0 {
		local fn `fn'.do
	}
	
	Parsedirs using `fn'
	local stub `s(stub)'
	local abbrev `s(abbrev)'
	
    tempname do
	file open  `do' using "`fn'", write text
    file write `do' "capture log close"_n
    file write `do' "log using `stub'.txt, replace text"_n
    file write `do' _n
    file write `do' "// What this .do file does"_n
    file write `do' "// Who wrote it"_n
    file write `do' _n
    file write `do' "version `c(stata_version)'"_n
    file write `do' "clear all"_n
    file write `do' "macro drop _all"_n
    file write `do' _n
	if "`dta'" != "" {
		file write `do' "*use ../posted/data/<original_data_file.dta>"_n
		file write `do' _n
		file write `do' "*rename *, lower"_n
		file write `do' "*keep"_n
		file write `do' _n
		file write `do' "// prepare data"_n
		file write `do' _n
		file write `do' "*compress"_n
		file write `do' "*note: `abbrev'##.dta \ <description> \ `stub'.do \ <author> TS "_n
		file write `do' "*label data <description>"_n
		file write `do' "*datasignature set, reset"_n
		file write `do' "*save `abbrev'##.dta, replace"_n
	}
	if "`ana'" != "" {
        file write `do' "*use `abbrev'##.dta"_n
		file write `do' "*datasignature confirm"_n
		file write `do' "*codebook, compact"_n
		file write `do' _n
		file write `do' "// do your analysis"_n
	}
    file write `do' _n
    file write `do' "log close"_n
    file write `do' "exit"_n
    file close `do'
	
	if "`open'" == "" {
		doedit "`fn'"
	}
end

program define Parsedirs, sclass
	version 10
	syntax using/,

	local stub : subinstr local using "\" "/", all
	while `"`stub'"' != "" {
		gettoken path2 stub : stub, parse("/\:")
	}
	local stub `path2'
	gettoken stub suffix : stub, parse(".")
	
	gettoken abbrev rest : stub, parse("_")
	if "`rest'" == "" local abbrev "<abbrev>"	
	
	sreturn local stub `stub'
	sreturn local abbrev `abbrev'
	
end
