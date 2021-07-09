*************************************************************
*			getmxdata, version 1.1  1 october 2019			*
* 			by	Miguel Angel González Favila		 		*
* 													 		*
*	version 1.1 							october 1 2019	*
*************************************************************
program define getmxdata
	version 13.0
	syntax anything(name=vars) , [bie banxico key(string) clear]
	if "`bie'"=="" & "`banxico'"==""{
	di as err "error: must especify a dataset to consult"
	exit 498
	}
	if "`key'"==""{
	di as err "error: must provide a token"
	exit 498
	}
	if "`bie'"!="" & "`banxico'"!=""{
	di as err "error: select only one server at a time"
	exit 498
	}
	*
	if "`bie'" != "" & "`banxico'" == "" {
	_getmxdatabie `vars', key(`key')
	unab vlist: v_*
	mata: v=tokens(st_local("vlist"))
	mata: v2=invtokens(v[cols(v)..1])
	mata: st_local("vlist2",v2)
	order Periodo fecha `vlist2'
}	
	if "`bie'" == "" & "`banxico'" != "" {
	_getmxdatabanxico `vars', key(`key')
	order Periodo fecha `vars'
	}
end

