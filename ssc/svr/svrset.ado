*! version 3.0.1  05sep2002 NJGW

program define svrset
	version 7

	gettoken cmd 0 : 0

	if inlist("`cmd'","clear","list") & `"`0'"'=="" {
		local 0 meth pw rw dof fay psun
	}

	if "`cmd'"=="list" {
		list_key `0'
		exit
	}
	if "`cmd'"=="clear" {
		clear_key `0'
		exit
	}
	if "`cmd'"=="set" {
		set_key `0'
		exit
	}
	if "`cmd'"=="" {	/* help for beginners */
		di
		di "{txt}Syntax:  {cmd:svrset} set    {it:key value} [ {it:key value...} ]"
		di "         {cmd:svrset} list  [{it:key value} [ {it:key value...} ] ]"
		di "         {cmd:svrset} clear [{it:key value} [ {it:key value...} ] ]"
		di
		exit
	}
	di as error "Unrecognized svrset subcommand"
	exit 198

end

program define clear_key

	foreach key of local 0 {
		if !(inlist("`key'","meth","pw","rw") | inlist("`key'","dof","fay","psun")) {
			di as error "illegal key `key'"
			exit 198
		}
		char _dta[svr`key']
	}


end

program define list_key

	foreach key of local 0 {
		if !(inlist("`key'","meth","pw","rw") | inlist("`key'","dof","fay","psun")) {
			di as error "illegal key `key'"
			exit 198
		}
		local val : char _dta[svr`key']
		if `"`val'"'=="" {
			local val "{txt}<not set>"
		}
		local sp = 7-length("`1'")
		di `"{p 0 8}{txt}{space `sp'}`key'  {res}`val'{p_end}"'
		mac shift
	}
	di
end



program define set_key

	while `"`0'"'!="" {
		gettoken key 0 : 0
		gettoken val 0 : 0
		if `"`val'"'=="" {
			di as error "must specify a value for each key to be set"
			exit 198
		}
		if `"`key'"'=="meth" {
			if !inlist(`"`val'"',"brr","jk1","jk2","jkn") {
				di as error `"illegal method `val'"'
				exit 198
			}
			if "`val'"!="brr" {
				set_key fay 0
			}
		}
		else if "`key'"=="pw" {
			unab val : `val' , min(1) max(1) name("pw")
			confirm numeric variable `val'
		}
		else if "`key'"=="rw" {
			unab val : `val' , min(2) name("rw")
			confirm numeric variable `val'
		}
		else if "`key'"=="dof" {
			confirm number `val'
		}
		else if "`key'"=="fay" {
			local type : char _dta[svrmeth]
			if "`type'"!="brr" & "`val'"!="0" {
				di as error "cannot set fay constant"
				di as error "before setting method to BRR"
				exit 198
			}
			confirm number `val'
			if `val'>=1 | `val'<0 {
				di as error "fay constant must be between 0 and 1"
				exit 198
			}
		}
		else if "`key'"=="psun" {
			local type : char _dta[svrmeth]
			local nrep : char _dta[svrrw]
			local nrep : word count `nrep'
			if `nrep'==0 | "`type'"!="jkn" {
				di as error "cannot set number of psus per stratum"
				di as error `"before setting method to "jkn", and "'
				di as error "setting the replicate weights"
				exit 198
			}
			local npsun : word count `val'
			if `nrep' != `npsun' {
				di as error "`npsun' PSU counts does not match `nrep' replicates"
				exit 198
			}
		}
		else {
			di as error "illegal key `key'"
			exit 198
		}
		char _dta[svr`key'] `val'
	}

end


