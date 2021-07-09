*! version 1.0.2 July 18, 2018 @ 16:53:25
*! either cd's and pushes the previous directory to the directory stack or just pushes the current directory on the stack
* 1.0.2 - gave the directory a name in -syntax-, so that errors would make sense
* 1.0.1 - changed version back to 9; no need for newer stuff
program define pushd
version 9
	syntax [anything(id="directory" name=dirname)]
   local wherami `"`c(pwd)'"'
   if `"`dirname'"'!="" {
      capture cd `"`dirname'"'
      if _rc {
         capture cd `dirname'
         if _rc {
            display as error "Could not change directory to " as text `"`dirname'"'
            exit 170
            }
         }
      pwd
      }
   if `"$S_DIRSTACK"'=="" {
      global S_DIRSTACK `""`wherami'""'
      }
   else {   
      global S_DIRSTACK `""`wherami'" $S_DIRSTACK"'
      }
end
