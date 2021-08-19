/*** DO NOT EDIT THIS LINE -----------------------------------------------------
Version: 1.0.0
Title: html
Description: writes the given text on the {help Weaver} log
----------------------------------------------------- DO NOT EDIT THIS LINE ***/

/***

Author
======

__E. F. Haghish__     
Center for Medical Biometry and Medical Informatics     
University of Freiburg, Germany     
_and_        
Department of Mathematics and Computer Science       
University of Southern Denmark     
haghish@imbi.uni-freiburg.de     
      
[Weaver Homepage](www.haghish.com/weaver)         
Package Updates on [Twitter](http://www.twitter.com/Haghish)     

- - -

_This help file was dynamically produced by[MarkDoc Literate Programming package](http://www.haghish.com/markdoc/)_ 
***/

	

program define html
        version 11
        
        //if "$weaver" != "" confirm file `"$weaver"'

        tempname canvas
        cap file open `canvas' using `"$weaverFullPath"', write text append         
		cap file write `canvas' `"`macval(0)'"' _n
		
		// Make sure the weaver html log is open
		/*
		if "$weaver" == "" {
			
			di as txt _n(2) "{hline}"
			di as error "{bf:Warning}" 
			di as txt "{help weaver} log file is off!" 
			di as txt "{hline}{smcl}"	_n
			
		}  
		*/
		
end

// DYNAMIC HELP FILE
// ===================================

*markdoc html.ado, export(sthlp) replace
	

