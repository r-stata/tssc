program desspss
   version 8.2

   if (c(os)=="Windows") & (strpos(`"`c(machine_type)'"',"64-bit")==0) {
     _desspss `0'
     capture program drop _desspss
   }
   else {
     display as error "This command works only in 32-bit Stata for Windows"
     display as text  "Your Stata version is: " as result c(version)
     display as text  "Your operating system is: " as result c(os)
     display as text  "Your machine type is: " as result c(machine_type)
   }

end

// END OF FILE
