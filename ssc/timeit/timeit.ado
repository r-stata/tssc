*! version 1.1.2 14jan19
* Contact jesse.wursten@kuleuven.be for bug reports/inquiries.
* Many thanks to Daniel Klein for his suggestions and code snippets.

* Changelog
** 14jan2019: Fixed space-before-colon issue
** 27nov2018: Fixed space-in-command issue
** 16apr2018: Fixed some parsing issues, added r-results (this is a pain) and incremental timer results
program define timeit, rclass
	version 11
	
	** Parse syntax
	gettoken beforeColon afterColon : 0, parse(":") quotes
	gettoken theTimer theName: beforeColon, quotes
	gettoken theColon theCommand : afterColon , parse(":")
	
	** Some error checking
	*** User didn't enter a timer
	if "`theTimer'" == ":" {
		local afterColonTrimmed = trim("`afterColon'")
		noisily di as error "You have to enter a timer number.  E.g. timeit 3: `afterColonTrimmed'"
		exit 198
	}
	
	*** User mixed up name and timer position
	local potentialTimer : word 1 of `beforeColon'
	local potentialTimer2 : word 2 of `beforeColon'
	capture assert real("`potentialTimer'") == . & real("`potentialTimer2'") != .
	if _rc == 0 {
		**** And didn't write a colon
		if "`theColon'" != ":" {
			local potentialCommand : list beforeColon - potentialTimer
			local potentialCommand : list potentialCommand - potentialTimer2
			noisily di as error "You have to enter the timer before the name, followed by a colon.  E.g. timeit `potentialTimer2' `potentialTimer': `potentialCommand'"
			exit 198
		}
		
		**** ... did write a colon
		else {
			noisily di as error "You have to enter the timer before the name.  E.g. timeit `potentialTimer2' `potentialTimer': `theCommand'"
			exit 198
		}
	}
		
	*** User didn't enter a colon
	if "`theColon'" != ":" {
		capture assert real("`potentialTimer'") != .
		
		**** And no timer
		if _rc != 0 {
			noisily di as error "You have to enter a timer and a colon.  E.g. timeit 3: `beforeColon'"
			exit 198
		}
		
		else {
			local potentialCommand : list beforeColon - potentialTimer
			noisily di as error "You have to enter a colon.  E.g. timeit `potentialTimer': `potentialCommand'"
			exit 198
		}
	}
	
	*** User didn't enter a command
	if `"`theCommand'"' == "" {
		noisily di as error "You have to enter a command.  E.g. timeit `theTimer': sum someVariable"
		exit 198
	}
	
	** Check whether timer is already running
	*** Store return results in case they were present
	tempname r_results
	_return hold `r_results'
	
	*** Check timer before stopping it
	quietly timer list `theTimer'
	local beforeStop = r(t`theTimer')
	timer off `theTimer'
	
	*** ... and after
	quietly timer list `theTimer'
	local afterStop = r(t`theTimer')
	
	*** Compare
	capture assert `beforeStop' == `afterStop'
	if _rc != 0 noisily di as error "Timer was already running (active)." _newline "You might want to check your code as it will be unclear* what is being timed exactly." _newline "Note that the timer will be stopped after this timeit command." _newline _newline "*Normally, everything from -timer on `theTimer'- until this -timeit- command."
	
	** Return return results
	_return restore `r_results'


	** Time and execute the command
	** The nobreak + capture ... break combination ensures the timer stops when the user manually stops the program
	** The capture noisily ... cmd combination ensures the timer stops when the cmd returns an error. exit _rc then presents the error to the user
	nobreak {
		timer on `theTimer'
		capture noisily break `theCommand'
		timer off `theTimer'
	}
	
	** Store timer
	*** Save existing r_results
	return add
	
	*** Access timer
	tempname timer_value timer_increment fakeReturnHold
	qui timer list
	scalar `timer_value' = r(t`theTimer')
	_return hold `fakeReturnHold'

	*** Calculate increment
	if `afterStop' != .	scalar `timer_increment' = scalar(`timer_value') - `afterStop'
	else 				scalar `timer_increment' = scalar(`timer_value')

	*** Compile return()
	return scalar t`theTimer' = scalar(`timer_value')
	return scalar delta_t`theTimer' = scalar(`timer_increment')
	if trim("`theName'") != "" return scalar `theName' = scalar(`timer_value')
	
	*** Compile r()
	return add
	
	exit _rc
end
