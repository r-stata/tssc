*!version 1.0.0 MLB MLB 26Sept2018
program lookfor2, rclass
    version 10.1
	syntax anything(name=looklist id="search string" everything), [nonote noVALLab]
	local note   = ( "`note'"   == "" )
	local vallab = ( "`vallab'" == "" )

	mata : lookfor2("looklist", `vallab', `note' )
	if "`res'" != "" {
		desc `res'
		return local varlist `res'
	}
end

mata
void lookfor2(string scalar looklist, real scalar vallab, real scalar note) {
	real   scalar    k, i, j
	string rowvector varlist
	string scalar    res, tosearch
	
	looklist = parse_looklist(looklist)
	k = st_nvar()
	varlist = st_varname((1..k))
	res = ""
	for (i=1 ; i <= k ; i++ ) {
		tosearch = collectinfo(varlist[i], vallab, note)
		for (j=1 ; j <= cols(looklist); j++) {
			if (strpos(tosearch, looklist[j])) {
				res = res + " " + varlist[i]
				break
			}			
		}
	}
	st_local("res",res)
}
string scalar collectinfo(string scalar varname, 
                          real scalar vallab , real scalar note) {
	string       scalar    res, varlab, vallabname, name
	string       rowvector txt
	real         rowvector val
	real         scalar    i
	transmorphic scalar    notes
	
	res = varname
	varlab = st_varlabel(varname)
	if (varlab != "") {
		res = res + " " + varlab
	}
	
	if (vallab) {
		vallabname = st_varvaluelabel(varname)
		if (vallabname != "") {
			st_vlload(vallabname, val=., txt="")
			res = res + " " + invtokens(txt')
		}
	}
	
	if (note) {
		notes =  st_global(varname + "[note0]")
		notes = strtoreal(notes== "" ? "0" : notes)
		for(i=1; i<= notes; i++) {
			name = varname + "[note" + strofreal(i) + "]"
			res = res + " " + st_global(name)
		}
	}
	
	return(strlower(res))
}

string rowvector parse_looklist(string scalar looklist) {
	string       rowvector res
	real         scalar    i
	transmorphic scalar    t  
	
	t = tokeninit()
	tokenset(t, strlower(st_local(looklist)))
	res = tokengetall(t)
    for (i=1; i<=cols(res); i++) {
        if (substr(res[i], 1, 1)==`"""') {
            res[i] = substr(res[i], 2, strlen(res[i])-2)
        }
        else if (substr(res[i], 1, 2)=="`" + `"""') {
            res[i] = substr(res[i], 3, strlen(res[i])-4)
        }
    }
	return(res)
}
end
