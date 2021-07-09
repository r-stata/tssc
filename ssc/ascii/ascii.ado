*! Date    : 15 May 2009
*! Version : 1.2
*! Author  : Adrian Mander
*! Email   : adrian.mander@mrc-bsu.cam.ac.uk

*! Display all the ascii characters

/* 
2Nov2006  v 1.1 added the start option to avoid printing the first 32 characters that can cause problems in unix 
15May2009 v 1.2 changed email
*/

pr ascii
version 9.2
syntax [,Start(int 33)]

local yourls = c(linesize)

local col 1
forv i=`start'/255 {
  local ncol = `col'+4
  di in smcl _continue _col(`col') "`i'" _col(`ncol') `"{c `i'}"'
  if `col'<`yourls'-10 local col = `col'+6
  else { 
     di 
    local col 1
  }
}

end
