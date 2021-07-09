use mylist.dta ,clear
keep if myid==`1'
egen count = count(myid)
save output\myid`1' , replace
