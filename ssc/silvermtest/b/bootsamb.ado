*version 1.0 25/09/2002
*version 2.0 06/08/2020; 09/08/2020
*for use with Stata command "boot"
*argument `1' = variable; `2' critic bandwidth; `3' sd of variable
version 11.0
program define bootsamb
   gen ck=(1+(`2'/`3')^2)^-0.5
   gen ysm=ck*(`1'+`2'*rnormal())
   drop ck	
end
