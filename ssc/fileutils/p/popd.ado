*! version 1.0.2 December 16, 2015 @ 11:07:12
*! goes to the directory at the front of $S_DIRSTACK, then pulls it off the list
* v1.0.2: added -keep- option to keep invalid directory if pop fails
* v1.0.1: changed back to version 9, because nothing needs a newer version
program define popd
version 9
   syntax [, keep]
	if `"$S_DIRSTACK"'=="" {
      display as text "Nowhere to pop to"
      }
   else {
      local dirstack `"$S_DIRSTACK"'
      gettoken newdir dirstack : dirstack
      capture cd `"`newdir'"'
      if _rc {
         display as error "Could not cd to " as text `"`newdir'"'
         if "`keep'"=="" {
            display as error "  but S_DIRSTACK shortened anyway"
            global S_DIRSTACK `"`dirstack'"'
            exit 170
            }
         else {
            display as error "  S_DIRSTACK unchanged"
            }
         }
      pwd
      global S_DIRSTACK `"`dirstack'"'
      }
end
