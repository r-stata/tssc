*! Dan Blanchette 1.2 dan_blanchette@unc.edu 10Jan2012 
** the carolina population center, unc-ch
** Center for Entrepreneurship and Innovation Duke University's Fuqua School of Business
** research computing, unc-ch
* Stata stopped restricting the file size limit of files the do-editor can edit. 
*  So now the file size is only checked if using an earlier version of Stata than Stata 11.
*  Eric Booth suggested option to open the ado-file in whatever software is setup to open 
*   ".ado" file types if the file is too big to open in Stata's do-file editor.
** Dan Blanchette 1.1 dan_blanchette@unc.edu 08Feb2005 
* Stata fixed Linux problem of not being able to edit a file in a directory starting with "~"
* Added "Caution" note when requesting to edit a Stata ado file.
** Dan Blanchette 1.0.3 06 Nov 2003 made it work in Linux
*! NJC 1.0.2 31 Dec 2002 
** CFB 1.0.1 26Dec2002 cloned from adotype
** NJC 1.2.3 14 December 1999 
* NJC 1.2.2 6 December 1999 
* NJC 1.2.1 1 December 1999
program def adoedit, rclass 
        version 8.0

	if "`1'" == "" | "`2'" != "" { 
		di as err "incorrect syntax"
		exit 198 
	}
	args cmd 

	 /* ends with .ado */
	if substr(`"`cmd'"',length(`"`cmd'"')-3,length(`"`cmd'"'))==".ado"  {   
		local filen `"`cmd'"'
	} 
	else {
           	local filen `"`cmd'.ado"'
	} 

	//change to clickable path:
	quietly findfile `filen'
	local file `"`r(fn)'"'
	local wd : environment HOME
 	if strpos(`"`file'"', "~") == 1 & !missing(`"`wd'"') {
 		local file : subinstr local file"~" "`wd'"
        }
 	di as txt `"Click on the file below to open it with whatever software you have setup to open ".ado" file types:"'
 	di as smcl `"{browse `"`file'"' }"'


	// here will exit 601 if `cmd' not found 
	
        local tfile : subinstr local file "\" "/" , all

        if index(`"`tfile'"',"/ado/base")  |  index(`"`tfile'"',"/ado/updates")  {
          di " "
          di as err "Caution, you are requesting to edit an ado file provided by Stata."
          di as err "If this is really what you want, consider first copying the file to {input}`: sysdir PERSONAL' {error}."
          di " "
          more
          di " "
        }

	local size= 100
	if !missing("`c(stata_version)'") {
          if `c(stata_version)' >= 11 {
		di as text _n `"If you get a message saying "Failed to open document." then the file is too large to be do-edited."' 
            	di as txt "Then you must use another text editor to edit this file."  _n
          }
          if `c(stata_version)' < 11 {
	    capture hexdump `"`file'"', analyze
	    local size= r(filesize)
          }
        }
	if `size' < 32000 & `size' > 0 {
          doedit `"`file'"'
          discard
	  return local adofile `"`file'"'
	  exit 0 
        }
        else {
	     	di as txt _n "Sorry, files larger than 32,000 bytes cannot be do-edited."
            	di as txt "You must use another text editor to edit this file." 
            	error 603
    	} 

end


