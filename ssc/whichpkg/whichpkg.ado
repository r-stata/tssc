*! whichpkg 1.02 19Feb2015
*! author mes
* 1.00           16Feb2015  First working version.
* 1.01           18Feb2015  "cap noi" tweak so that if a file isn't found, report this and continues.
* 1.02           19Feb2015  OS-specific delimiter fix by CFB
*                           Renamed whichpkg; changed default filetype to .pkg; set min Stata to version 9

program whichpkg
	version 9
	
	args pkg

// is argument pkg specified with no file extension?
// if so, add default extension ".pkg"
	local default	= ~strpos("`pkg'",".")
	if `default' {
		local pkg "`pkg'.pkg"
	}

// is pkg specified with file extension ".pkg"?
// if so, it's a package
	local ispkg		= strpos("`pkg'",".pkg")

	if `ispkg' {									//  call code to list pkg contents
		local fn `c(sysdir_plus)'stata.trk
		local ds = cond(c(os)=="Windows", "\", "/")
		di as text "All instances on search path of components of package `pkg':"
		mata: m_whichpkg("`pkg'", "`fn'", "`ds'")
	}
	else {											//  call Stata -which- with -all- option
		which `pkg', all
	}

end			//  end whichpkg.ado

//////////////// Format of stata.trk file ///////////////////
// Header: lines starting with *, *! or blank.
// Then blocks for each package composed of
// lines starting with letter followed by:
// S, URL
// N, name of package including .pkg extension
// D, date installed
// U, number of package (?)
// d [multiple lines], text describing package, can be blank
// f, subfolder of PLUS + filename.ext
// e, nothing [end of entry]
/////////////////////////////////////////////////////////////

version 9
mata:
void m_whichpkg(string scalar pkg, string scalar filename, string scalar ds)
	{
// set flag for whether package was ever found
		foundpkg = 0
		fh = fopen(filename, "r")
		while ((line=fget(fh))!=J(0,0,"")) {							//  outer loop
			tstring = tokens(line)
			if (cols(tstring)>1) {										//  line has more than one token
				if ((tstring[1,1]=="N") & (tstring[1,2]==pkg)) {		//  line has name of package in position 2
					foundpkg = 1										//  we've hit the package, so set flag
					while (tokens(line=fget(fh))[1,1]!="f") {			//  read lines until file names encountered
					}
// now we've hit the list of file names
// process first file name and call Stata -which- routine
					pfname = tokens(line, ds)
					stcmd = "cap noi which " + pfname[1,cols(pfname)] + ", all"
					stata(stcmd)
// repeat for rest of file names
					while (tokens(line=fget(fh))[1,1]=="f") {			//  inner loop
						pfname = tokens(line, ds)
						stcmd = "cap noi which " + pfname[1,cols(pfname)] + ", all"
						stata(stcmd)
					}		//  end inner loop
				}
			}
		}			// end outer loop
		fclose(fh)

// check to see if package was ever found; if not, exit with error
		if (!foundpkg) {
errprintf("package %s not found as installed pkg\n", pkg)
			exit(111)
		}

	}		//  end m_whichpkg()

end		//  end mata block
