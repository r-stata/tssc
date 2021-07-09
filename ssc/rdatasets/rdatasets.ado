program rdatasets
*! Access R Datasets from GitHub <grodri@princeton.edu> 30nov2017
	version 9
	gettoken subcmd args : 0, parse(" ,")
	if "`subcmd'" == "" {
		local rd {bf} rdatasets
		local pd {it:package dataset}
		display "{txt}syntax: `rd' list [{it:package}] {sf:OR} `rd' doc `pd' {sf:OR} `rd' get `pd'"		
	}
	else if "`subcmd'" == "get" {
		Get `args'
	}
	else if "`subcmd'" == "doc" {
		Doc `args'
	}
	else if "`subcmd'" == "list" {
		List `args'
	}
	else {
		display as error "Subcommand `subcmd' not recognized"
		exit 198
	}
end

program Parse, sclass
 // handle package dataset
	syntax anything
	gettoken package dataset : anything	
	local package  = trim("`package'")
	local dataset     = trim("`dataset'")
	if "`package'" == "" | "`dataset'" == "" {
		display as error "Please specify package and dataset"
		display "{txt}For example: rdatasets get datasets cars"
		exit 198
	}
	sreturn local package `package'
	sreturn local dataset `dataset'
end

program Get
	syntax anything [, clear]
	Parse `anything'
	local url https://raw.githubusercontent.com/vincentarelbundock/Rdatasets/master
	if "`clear'" == "clear" local optclear ", clear"
	local cmd insheet using `url'/csv/`s(package)'/`s(dataset)'.csv  `optclear'
	`cmd'
end

program Doc
	syntax anything
	Parse `anything'
    local url https://raw.githubusercontent.com/vincentarelbundock/Rdatasets/master
	local filename _rdatasets_doc_.html
	capture erase "`filename'"
	copy `url'/doc/`s(package)'/`s(dataset)'.html `filename'
	view browse `filename'
end	

program List
	syntax [anything] [, clear]
	local datalabel : data label
	if "`datalabel'" != "R Datasets List" {
		display "downloading database..."
		local url https://vincentarelbundock.github.io/Rdatasets/
		insheet using `url'/datasets.csv, clear
		label data "R Datasets List"
		drop doc csv
		egen tag = tag(package)
	}
	local anything = trim("`anything'")
	if "`anything'" == "" {
		mata: listPackages()
	}
	else {
		mata: listPackage("`anything'")
	}
end
	
// -----------------------------------------------------------------------

mata:	
	void listPackages() {
	 // list packages with link to list datasets in package
		packages = st_sdata(., "package", "tag")
		s = order(ustrlower(packages), 1)
		packages = packages[s]
		n = length(packages)		
		nc = 4
		nr = floor((n + nc - 1)/nc)
		m = J(nr, nc, "")
		w = 20		
		printf("\n%s\n", "{col 4}R Datasets packages")
		printf("%s\n", "{col 4}{hline 72}")
		for(i = 1; i <= nr; i++) {
			cmd = ""
			for (j = 1; j <= nc; j++) {
				k = (j - 1) * nr + i
				if (k > n) continue
				pkg = packages[k]
				skip = "{col " + strofreal(5 + (j-1)*w) + "}"
				cmd = cmd + skip + `"{stata rdatasets list "' + pkg + ":" + pkg + "}"
			}
			printf("%s\n", cmd)
		}
		printf("%s\n", "{col 4}{hline 72}")
	}
	void listPackage(string scalar package) {
	 // list datasets in a given package with link to description
		packages = st_sdata(., "package", "tag")
		matches = select(packages, packages :== package)
		if(length(matches) < 1) {
			errprintf("Package %s not found in R Datasets list\n", package)
			exit(198)
		}
		tempname = st_tempname()
		stata("quietly gen " + tempname + `" = package == ""' + package + `"""')
		ds = st_sdata(., ("item", "title"), tempname)
		itemWidth = max(strlen(ds[,1])) + 4
		skip = "{col " + strofreal(4 + itemWidth) + "}"
		hrule = "{col 4}{hline " + strofreal(itemWidth + 60) + "}"
		
		printf("\n%s\n","{col 4}R Datasets in package " + package)
		printf("%s\n", hrule)
		fmt = "{stata rdatasets doc %s %s:%s}"
		for(i = 1; i <= rows(ds); i++) {
		    link = sprintf(fmt, package, ds[i,1], ds[i,1])
			title = splitTitle(ds[i,2])
			printf("%s\n", "{col 4}{txt}" + link + skip + title[1])
			for(j = 2; j <= length(title); j++) {
				printf("%s\n", skip + title[j])
			}
		}
		printf("%s\n", hrule)	
	}
	string vector splitTitle(string scalar title) {
	  // split a title into lines of <= 54 characters
		maxw = 60
		if (strlen(title) <= maxw) return(title)
		pos = maxw
		while(pos > 0) {
			ch = substr(title, pos, 1)
			if(ch == " ") break
			pos--
		}
		left = substr(title, 1, pos - 1)
		rest = substr(title, pos + 1, .)
		return( left\splitTitle(rest) )
	}
end		
exit
