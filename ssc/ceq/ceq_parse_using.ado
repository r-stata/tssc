/***
	Title
	=====

	ceq_parse_using -- Parse the "using" argument for various ceq programs

	Syntax
	======

	ceq_parse_using [using] filename, cmd(cmdname) open(macname)

	where:

	cmdname is a command (e.g. "ceqdom") in the CEQStataPackage.
	macname is a local macro (e.g. "open") in calling environment.

	Description
	===========

	ceq_parse_using parse the "using" argument for various ceq programs:

	- Return error 198 if `"`using'"' doesn't have xls or xlsx extension.
	- Return error 601 if `"`using'"' doesn't exist.
	- Update `open' to nothing if `"`using'"' has " " characters.
	- Clear the information set by "putexcel set" if no error is found.
*/
capture : program drop ceq_parse_using
program define ceq_parse_using, nclass
{
	// Set syntax
	version 13.0
	syntax [using/], cmd(string) [open(string)]

	// Print a warning if `using' is empty
	if (`"`using'"' == "") {
		display as text in smcl ///
			"Warning: No file specified with {bf:using}; " ///
			"results saved in {bf:return list} but " ///
			"not exported to Output Tables"
	}
	else {
		// Return error 198 if `using' doesn't have the appropiate extension
		if !regexm(`"`using'"', "(\.xls(x)?)$") {
			display as error in smcl ///
				"File extension must be .xls or .xlsx to write " ///
				"to an existing CEQ Master Workbook " ///
				"(requires Stata 13 or newer)"
			exit 198
		}

		// Return error 601 if `using' doesn't exist
		confirm file `"`using'"'

		// Update `open' to "" if `using' has " " characters
		if (regexm(`"`using'"', " ") & ("`open'" != "")) {
			// Update the `open' macro in the calling environment
			c_local `open' = ""
			// Print a warning about the update of `open'
			display as text in smcl ///
				`"Warning: `"`using'"' contains spaces; {bf:open} "' ///
				`"option will not be executed. File can be "' ///
				`"opened manually after `cmd' runs."'
		}		

		// Clear the file information set by putexcel set
		capture : putexcel clear
	}
}
end 
// endof(ceq_parse_input.ado)

