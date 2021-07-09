program usespss
   version 9.2

   if (c(os)=="Windows") & (strpos(`"`c(machine_type)'"',"64-bit")==0) {
     _usespss `0'
     capture program drop _usespss
   }
   else {
     display as error "This command works only in 32-bit Stata for Windows"
     display as text  "Your operating system is: " as result c(os)
     display as text  "Your machine type is: " as result c(machine_type)
   }

end

// END OF FILE
