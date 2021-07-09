*! hlp2pdf 1.0.1 CFBaum 11apr2008
* 1.0.1 allowed for OS dependencies, replace option
prog def hlp2pdf, rclass
  version 9.0
  syntax anything [,REPLACE]
  set more off
  help `anything'

  local ext = cond("$S_OS" == "MacOSX", "pdf", "ps")
  if "`replace'" == "replace" {
  	  capture erase `anything'.`ext'
  }      
  translate @Viewer `anything'.`ext'
  local printfile "`c(pwd)'`c(dirsep)'`anything'.`ext'"
  display as txt _n "Help for " as res "`anything'" ///
  as txt " written to `printfile'"
  return local printfile "`printfile'"
  set more on
 end
 
