*! version 1.0.3  08Jul2015
// On 08Jul2015 changed http to https per change made by St. Louis Fed.
program define _fredweb

	version 9.0 

	syntax anything(name=slist id="series list") , 		///
		[						///
		clear						///
		]


	gettoken sname slist:slist , quotes
	mata: _fredcleanname("sname", 0)

	tempname fname
	local fname "`fname'.txt"
	capture noi confirm new file `fname'
	if _rc {
		di as err "{p 2 4 2}file with temporary name already exits"
		di as err "{p 2 4 2}rename files that begin with {cmd:__}"
		exit 498
	}

	capture noi _FredWeb , sname(`sname') fname(`fname') 	///
		slist(`slist') `clear'

	erase `fname'
end

program define _FredWeb

	syntax , sname(string asis) fname(string asis) 		///
		[ slist(string asis) clear ]

	tempfile current

	local fbase "https://research.stlouisfed.org/fred2/series"
	capture noi copy `fbase'/`sname'/downloaddata/`sname'.txt `fname'
	if _rc {
		di as err "{p 2 4 2}cannot copy `sname' from " ///
			"`fbase'/`sname'/downloaddata/`sname'.txt" 
		exit 498
	}

	_freduse2 using `fname' , `clear'

	gettoken next :slist, quotes

	sort daten
	while `"`next'"' != "" {
		qui save `"`current'"' , replace


		gettoken sname slist:slist , quotes
		mata: _fredcleanname("sname", 0)

		capture noi copy `fbase'/`sname'/downloaddata/`sname'.txt /// 
			`fname' , replace
		if _rc {
			di as err `"{p 2 4 2}cannot copy `sname' from "' ///
				`"`fbase'/`sname'/downloaddata/`sname'.txt"' 
			exit 498
		}


		_freduse2 using `fname', clear
	
		sort daten
			
		merge daten using `"`current'"'
		qui drop _merge
		sort daten

		gettoken next :slist, quotes
	}

end
