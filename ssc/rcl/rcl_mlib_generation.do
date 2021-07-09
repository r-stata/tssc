/*

	rcl_mlib_generation.do
	This do file reproduces for the rcl command the Mata function library lrcl.mlib.
	There is no need to run this file if the rcl command is installed (downloaded),
	as the installation includes the above mentioned file.

*/
	
/* */
/* */
/* */

version 12.1
set more off, perm
mata: mata mlib create lrcl, dir("`c(sysdir_plus)'l\") replace
run "`c(sysdir_plus)'r\rcl_functions_equilibrium.do"
run "`c(sysdir_plus)'r\rcl_functions_marginal_costs.do"
run "`c(sysdir_plus)'r\rcl_functions_merger_simulation.do"
run "`c(sysdir_plus)'r\rcl_functions_elasticities.do"
run "`c(sysdir_plus)'r\rcl_functions_shares.do"
run "`c(sysdir_plus)'r\rcl_functions_ssnip.do"
run "`c(sysdir_plus)'r\rcl_functions_nlogit_eq.do"
run "`c(sysdir_plus)'r\rcl_functions_blp_eq.do"
run "`c(sysdir_plus)'r\rcl_functions.do"
run "`c(sysdir_plus)'r\rcl.ado"
mata: mata mlib index
mata: mata describe using lrcl

/* */
/* */
/* */

