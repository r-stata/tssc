*! version 1.0.0 March 5, 2014 @ 20:25:38
*! splits file names into base and extension, allowing default extensions
program define parsefilename, sclass
   version 11.2
   syntax using/ [, defext(str)]
   mata: st_local("usingext",pathsuffix(st_local("using")))
   if `"`usingext'"'!="" {
      mata: st_local("using",pathrmsuffix(st_local("using")))
      }
   else {
      if `"`defext'"'!="" {
         local usingext ".`defext'"
         }
      }
   sreturn local sbase `"`using'"'
   sreturn local sext `"`usingext'"'
end
