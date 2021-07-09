*! version 1.0.3  19sep2005
program define _freduse

	version 9.0 

	syntax anything(name=flist id="file list") , 		///
		[						///
		clear						///
		]

	gettoken fname flist:flist , quotes
	local fname `fname'				// clear any quotes

	mata: _fredcleanname("fname", 1)

	_freduse2 using `"`fname'"' , `clear'

	gettoken next :flist, quotes

	tempfile current 
	while `"`next'"' != "" {
		sort daten
		qui save `current' , replace

		gettoken fname flist:flist , quotes
		local fname `fname'
		mata: _fredcleanname("fname", 1)

		_freduse2 using `"`fname'"' , `clear'
	
		sort daten
			
		merge daten using `current'
		qui drop _merge

		gettoken next :flist, quotes
	}

end
