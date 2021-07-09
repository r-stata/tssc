*! usexmlex v1.0.0 by Sergiy Radyakin, 13aug2014
*! Import xml data into Stata

program define usexmlex
  version 13.0
  
  if (`"`0'"'=="about") {
    mata usexmlex_about()
	exit
  }
  
  if missing(`"`0'"') {
    mata usexmlex_about()
    db usexmlex
  }
  else {
	  syntax using/, [varloadlist(string) clear]

	  mata usexmlex_about()  
	  if (`c(changed)' & missing(`"`clear'"')) error 004
	  clear  // mata version called directly always clears memory
	  mata usexmlex(`"`using'"', `"`varloadlist'"')
  }

end

// end of file
