*! version 1.0.2 31jan2019
*! checkipaddresses: program to check IP addresses against IPHub database
*! Nicholas J. G. Winter

program checkipaddresses
	version 15
	//	http://v2.api.iphub.info/ip/8.8.8.8?key=<<key>>
	// {"ip":"8.8.8.8","countryCode":"US","countryName":"United States","asn":15169,"isp":"GOOGLE","block":1,"hostname":"8.8.8.8"}

	syntax varname using/ [if] [in] , xkey(string) [ replace NOIsily noCOMPress STub(string) ]
	marksample touse, strok

	local keys     countryCode countryName asn isp block hostname
	local strKeys  countryCode countryName     isp       hostname
	// IPv6 can be up to 39 chars
	// ip returned first by parsing routine
	local postlist str39 `varlist' str2 `stub'countryCode str50 `stub'countryName long `stub'asn str150 `stub'isp byte `stub'block str150 `stub'hostname
	local iphub    http://v2.api.iphub.info/ip
	mata : st_local("xkeyUrlEnc", urlencode(`"`xkey'"'))

	tempname hdlRead hdlWrite

	// unique list of IPs
	// ta `touse' 
	qui levelsof `varlist' if `touse' , local(ips)
	di `"Checking `: word count `ips'' IP addresses:"' _c

	postfile `hdlWrite' `postlist' using `using' , `replace'

	foreach ip of local ips {
		quietly: `noisily' di
		quietly: `noisily' di "IP: `ip' .." _c
		di "." _c
		quietly: `noisily' di
		capture file open `hdlRead' using `"`iphub'/`ip'?key=`xkeyUrlEnc'"', text read
		if _rc {
			if _rc==679 {
				di 
				di as error "Server refused (too many requests)"
				di as error "Have you hit the daily limit for your API Key?"
				exit 672
			}
			if _rc==672 {
				di 
				di as error "Error contacting server"
				di as error "Could be bad API key or problem with internet connection or proxy"
				exit 672
			}
			di 
			di as error "Error encountered accessing ipHub:"
			di as error `"`iphub'/`ip'?key=`xkeyUrlEnc'"'
			exit _rc
		}
		file read `hdlRead' line
		file close `hdlRead'

		parseJSON `"`line'"' , keys(`keys') strkeys(`strKeys') local(postline) 
		quietly: `noisily' ret list
		quietly: `noisily' di `"postline: [`postline']"'
		post `hdlWrite' `postline'
	}

	postclose `hdlWrite'
	if "`compress'"!="nocompress" {
		preserve
		drop _all
		qui {
			use `using'
			compress
			save, replace
		}
		restore
	}
	di
	di "{txt}iphub info saved; merge results into dataset with this command:"
	di `"{stata `"merge m:1 `varlist' using `using'"':merge m:1 `varlist' using `using'}"'

end

program parseJSON
	syntax anything(name=json) , keys(string) local(string) strkeys(string)

	// eliminate quotation marks around it
	local json `json'

	// strip curly braces
	if substr(`"`json'"',1,1)=="{" {
		local json = substr(`"`json'"',2,.)
	}
	if substr(`"`json'"',-1,1)=="}" {
		local json = substr(`"`json'"',1,length(`"`json'"')-1)
	}

	tokenize `"`json'"', parse(",:")
	while `"`1'"'!="" {
		if `"`2'"'!=":" {
			di as error `"{p}problem parsing `1' within `json'{p_end}"'
			exit 198
		}
		// `1' is key; `3' is value, so next line sets local `key' to value
		local `1' `3'
		if !inlist(`"`4'"',",","") {
			di as error `"{p}problem parsing `1' within `json'{p_end}"'
			exit 198
		}
		mac shift 4
	}

	local line `"("`ip'")"' // return IP address first
	foreach key of local keys {
		local qt = cond(`"`: list key & strkeys'"'=="","",`"""')
		// double-quotes mean that ``key'' is the *value* for this key
		local line `"`line' (`qt'``key''`qt')"'
	}
	c_local `local' `"`line'"'

end

