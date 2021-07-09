*! version 1.3.0 Patrick McNeal 13sep2016
pr veracrypt
	vers 9

	if !inlist(c(os), "Windows", "MacOSX") {
		di as err "Stata for Windows or Mac required"
		ex 198
	}

	syntax [anything(name=volume)], [Mount DISmount truecryptvolume DRive(str) PROGdir(str)]

	***Check syntax***

	* Check strings.
	loc volume `volume'
	loc temp : subinstr loc volume `"""' "", count(loc dq)
	if `dq' {
		di as err `"filename cannot contain ""'
		ex 198
	}
	foreach option in drive progdir {
		loc temp : subinstr loc `option' `"""' "", count(loc dq)
		if `dq' {
			di as err `"option `option'() cannot contain ""'
			ex 198
		}
	}

	* -mount-, -dismount-
	if "`mount'`dismount'" == "" loc mount mount
	else if "`mount'" != "" & "`dismount'" != "" {
		di as err "options mount and dismount are mutually exclusive"
		ex 198
	}

	* -mount-
	if "`mount'" != "" {
		* `volume'
		conf f "`volume'"

		* Make `volume' a clean absolute reference.
		* VeraCrypt can't handle absolute references that are unclean
		* (understood by Stata but not the OS) or relative references up the
		* directory tree (containing ..).
		mata: st_local("file", pathbasename("`volume'"))
		mata: st_local("path", strreverse(subinstr(strreverse("`volume'"), strreverse("`file'"), "", 1)))
		nobreak {
			loc curdir = c(pwd)
			* -cd ""- in Stata for Mac changes the working directory to the home
			* directory.
			if "`path'" != "" qui cd "`path'"
			loc path = c(pwd)
			qui cd "`curdir'"
		}
		loc volume `path'`=cond(c(os) == "Windows", "\", "/")'`file'
	}
	* -dismount-
	else {
		* `volume'
		if "`volume'" != "" {
			di as err "option dismount: filename not allowed"
			ex 198
		}

		* -drive()-
		if "`drive'" == "" {
			di as err "option dismount must be specified with option drive()"
			ex 198
		}
	}

	* -drive()-
	if "`drive'" != "" {
		if !regexm("`drive'", "^[A-Za-z]:?$") {
			di as err "option drive(): invalid drive"
			ex 198
		}

		loc driveletter = regexr("`drive'", ":$", "")
		if c(os) == "Windows" ///
			loc drive `driveletter':
		else ///
			loc drive = "~/`driveletter'colon"

		* Check that the drive is available if -mount- or is mounted if -dismount-.
		mata: st_local("mounted", strofreal(direxists("`drive'")))
		if "`mount'" != "" & `mounted' {
			di as err "option mount: drive letter `driveletter' not available"
			ex 198
		}
		else if "`dismount'" != "" & !`mounted' {
			di as err "option dismount: no volume specified by drive letter `driveletter'"
			ex 198
		}
	}
	else if "`mount'" != "" & c(os) == "MacOSX" {
		* If -mount- is specified and -drive()- is not, we want VeraCrypt to use
		* the first free drive letter. On Windows, VeraCrypt will do this
		* automatically if not specified a drive letter, but on Mac, it will
		* select something other than a drive letter as the mount directory. So
		* if -VeraCrypt- is run on Stata for Mac, we'll have Stata determine the
		* first free drive letter, then pass it to VeraCrypt.

		foreach letter in `c(ALPHA)' {
			loc drive ~/`letter'colon
			mata: st_local("mounted", strofreal(direxists("`drive'")))
			if !`mounted' continue, break
		}

		if `mounted' {
			di as err "option mount: no drive letter available"
			ex 198
		}
	}

	* -progdir()-
	if "`progdir'" == "" {
		if c(os) == "Windows" ///
			loc progdir C:\Program Files\VeraCrypt
		else ///
			loc progdir /Applications/VeraCrypt.app/Contents/MacOS
	}
	else if c(os) == "MacOSX" ///
		loc progdir `progdir'/VeraCrypt.app/Contents/MacOS
	conf f "`progdir'/VeraCrypt`=cond(c(os) == "Windows", ".exe", "")'"
	***End***

	if c(os) == "Windows" {
		* -mount-
		if "`mount'" != "" ///
			sh "`progdir'\VeraCrypt.exe" `=cond("`truecryptvolume'" != "", "/truecrypt", "")' /v "`volume'" `=cond("`drive'" != "", "/l `drive'", "")' /q
		* -dismount-
		else ///
			sh "`progdir'\VeraCrypt.exe" /d `drive' /q
	}
	else {
		if "`mount'" != "" ///
			sh "`progdir'/VeraCrypt" `=cond("`truecryptvolume'" != "", "--truecrypt", "")' "`volume'" `drive'
		else ///
			sh "`progdir'/VeraCrypt" -d `drive'
	}
end

* Changes history
* version 1.0.0  21feb2012
* version 1.1.0  14mar2012
*	-progdir()- is optional
*	Syntax checks added
* version 1.2.0  03jul2012
*	Compatible with Mac OS X
*	All references to the TrueCrypt volume accepted
* version 1.3.0 13sep2016
* replace all code references to TrueCrypt with VeraCrypt
