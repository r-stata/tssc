*! INORM Version 1
*! inormpi.ado version 1.0.2 JCG 04jan2007
* Note: read INORM ado files with tab set equal to 6 spaces
*--------------------------------------------------------------------------------------------------------
* program inormpi
* syntax:
*	inormpi cmd cmdline,
*
* where cmd is load or call.
*--------------------------------------------------------------------------------------------------------
program define inormpi
	version 9
	set more off							/* shall remain off for all commands */
	gettoken cmd cmdline : 0					/* extract command */

	if "`cmd'"=="load" {
		cap program inormdll, plugin using(inormpi.dll)	/* load plugin, if it exists */
		local rc=_rc
		if _rc!=601 {
			local rc=0
		}
		exit `rc'
	}
	else if "`cmd'"=="call" {
		plugin call inormdll `cmdline'
		exit 0
	}
	else {
		display as error "subcommand load or call expected"
		exit 198
	}
end
