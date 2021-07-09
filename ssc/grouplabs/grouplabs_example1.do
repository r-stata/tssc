clear all

sysuse nlsw88
replace occupation=. in 1/20
egen gg=group(married race collgrad occupation) , miss

grouplabs married race collgrad occupation , groupvar(gg) sep(",") values

label variable gg "Worker profile"
tabulate gg, miss
