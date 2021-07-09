pr st2openbugs 
	vers 13
	
	syntax, /// 
		Model(string) ///
		Data(string) ///
		Nchains(numlist) ///
		Inits(string) ///
		Savepars(string) ///
		[	///
			Wdpath(string) ///
			NBurn(numlist) ///
			NUpdate(numlist) ///
			Prefix(string) ///
			SCriptname(string) ///
			DElcodafiles ///
		]
	// chequear coincidencia nc y long in
	loc linits: word count `inits'
	if `nchains' != `linits'{
		di as err "nchains and inits options are not consistent"
		exit 198
	}
        if "`wdpath'" != "" loc wdpath = "`wdpath'/"
	if "`nburn'" == "" loc nburn = "5000"
	if "`nupdate'" == "" loc nupdate = "20000"	
	if "`scriptname'" == "" loc scriptname = "`prefix'script.txt"
// add 'deviance' node
	loc savepars `savepars' deviance
// write script
	mata: writescript("`scriptname'", "`wdpath'", "`model'", "`data'", "`inits'", "`nchains'", "`nburn'", "`nupdate'", "`savepars'", "`prefix'")
// run OpenBUGS
	loc pathscr "`wdpath'`scriptname'"
	loc pathlog "`wdpath'`prefix'log.log"
	sh OpenBUGS `pathscr' | tee `pathlog'
	qui log query
	if "`r(status)'" == "on" qui log close
	qui log using "`wdpath'log2", replace
	local pathcodaindex `wdpath'`prefix'CODAindex.txt
	if "`delcodafiles'" == "" di "file `wdpath'`prefix'CODAindex.txt saved"
	local patcodachainall ""
	forv chain = 1/`nchains' {
		loc pathcodachain `wdpath'`prefix'CODAchain`chain'.txt
		loc pathcodachainall `pathcodachainall' `wdpath'`prefix'CODAchain`chain'.txt		
		if "`delcodafiles'" == "" di "file `wdpath'`prefix'CODAchain`chain'.txt saved"
	}	
// CODA processing	
	forv chain = `nchains'(-1)1 {
		loc pathcodachain "`wdpath'`prefix'CODAchain`chain'.txt"
		qui inf iteration var using `pathcodachain', clear
		egen j = seq(), b(`nupdate')
		gen chain = `chain'
		qui reshape wide var, i(iteration) j(j)
		if `chain' < `nchains' ap using "`wdpath'`prefix'CODA"
		if `chain' >  1 qui sa "`wdpath'`prefix'CODA", replace
	}
	// rename variables with parameter names (using `prefix'CODAindex.txt)
	mata: parsenamepars("`pathcodaindex'")
	sa "`wdpath'`prefix'CODA", replace 
	qui log close 
	qui translate "`wdpath'log2.smcl" "`wdpath'log2.log", replace
	qui sh cat `wdpath'log2.log >> `wdpath'`prefix'log.log
	qui sh rm `wdpath'log2.log `wdpath'log2.smcl
 	// remove OpenBUGS auxiliary files
	if "`delcodafiles'" != "" qui sh rm `pathcodaindex' `pathcodachainall'
end

vers 13
mata:

function writescript(scriptname, wdpath, model, data, inits, nchains, nburn, nupdate, savepars, prefix) {
	vinits = tokens(inits)
	vsavepars = tokens(savepars)
	path1 = pathjoin(wdpath, scriptname)
	unlink(path1)
	fhscript = fopen(path1, "w")
	fput(fhscript, invtokens(("modelSetWD(", `"""', wdpath, `"""', ")"), ""))
	fput(fhscript, invtokens("modelGetWD()", ""))
	fput(fhscript, invtokens(("modelCheck(", model, ")"), ""))
	fput(fhscript, invtokens(("modelData(", data, ")"), ""))
	fput(fhscript, invtokens(("modelCompile(", nchains, ")"), ""))
	for (i = 1; i <= length(vinits); i++) {
		fput(fhscript, invtokens(("modelInits(", vinits[i], ", ", strofreal(i),")"), ""))
	}
	fput(fhscript, invtokens("modelGenInits()", ""))
	fput(fhscript, invtokens(("modelUpdate(", nburn, ")"), ""))
	fput(fhscript, "dicSet()")			
	for (i = 1; i <= length(vsavepars); i++) {
		fput(fhscript, invtokens(("samplesSet(", vsavepars[i], ")"), ""))		
	}
	fput(fhscript, invtokens(("modelUpdate(", nupdate, ")"), ""))
	fput(fhscript, "dicStats()")			
	fput(fhscript, invtokens((`"samplesCoda("*", ""', prefix, `"")"'), ""))
	fclose(fhscript)
}

function parsenamepars(pathcodaindex) {	
	fhcodaind = fopen(pathcodaindex, "r")
	// count line number
	lcodaind = fget(fhcodaind)
	nlcodaind = 0
	while (lcodaind != J(0,0,"")) {
		lcodaind = fget(fhcodaind)	
	   nlcodaind = nlcodaind + 1
	}
	// read names and change them if they don't stick to Stata's naming conventions
	string rowvector namepars
	namepars = J(1, nlcodaind, "")
	fseek(fhcodaind, 0, -1)
	for (i = 1; i <= nlcodaind; i++) {
		lcodaind = fget(fhcodaind)
		vlcodaind = tokens(lcodaind, char(9))
		namepars[i] = vlcodaind[1]
	}
	fclose(fhcodaind)
	namepars = subinstr(namepars, ".", "_")
	namepars = subinstr(namepars, "[", "_")
	namepars = subinstr(namepars, "]", "")
	for (i = 1; i <= nlcodaind; i++) {
		st_varrename(invtokens(("var", strofreal(i)), ""), namepars[i])
	}
}

end
