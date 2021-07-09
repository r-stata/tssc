*! version 1.0.0, Ben Jann, 6sep2004
program define fview
	version 8.2
	syntax anything(id="filename") [ , asis path(passthru) ]
	qui findfile `anything', `path'
	if "`asis'"!="" local asis ", asis"
	view `"`r(fn)'"' `asis'
end
