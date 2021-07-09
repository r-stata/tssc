*! version 1.0.0 26jun2011 Daniel Klein

pr hlpedit
	vers 9.2
	if (`"`1'"' == "") | (`"`2'"' != "") err 198
	gettoken cmd ext : 1 ,p(.)
	cap unabcmd `cmd'
	if !(_rc) loc cmd `r(cmd)'
	if (`"`ext'"' == "") loc ext .hlp
	cap findfile `cmd'`ext'
	if (_rc == 601) {
		if ("`ext'" == ".hlp") cap findfile `cmd'.sthlp
		if ("`ext'" == ".sthlp") cap findfile `cmd'.hlp		
		if (_rc) err `= _rc' 
	}
	di as txt `"`r(fn)'"'
	doedit `"`r(fn)'"'
end
