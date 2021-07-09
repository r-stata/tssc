*! Returns number of running Stata instances
*! Jan Ditzen 2019
*! initally coded for multishell
program define stataid , rclass
syntax anything [, exename(string) list mata id(string) ] 
		version 14
        qui {
                if "`anything'" == "list" {
					tempfile StataListe
					preserve
						if "`exename'" == "" {
							if `c(SE)' == 1 & `c(MP)' == 0 {
									local type "SE"
							}
							else if `c(SE)' == 0 & `c(MP)' == 1 {
									local type "MP"
							}
							else {
									local type "IC"
							}
							local exename "Stata`type'-`c(bit)'.exe"

						}
						
						noi disp "Obtaining number of Stata instances running under `exename'."
						
						shell tasklist > "`StataListe'" /fo "CSV" /FI "imagename eq `exename'" /V
						import delimited  "`StataListe'" ,  clear rowr(2:)
						
						noi disp "`=_N' Stata instance(s) running."
						
						if "`list'" != "" {
							noi list
						}
						if "`mata'" != "" {
							tostring * , replace force
							des *, varl
							putmata stataid = (`r(varlist)' ), replace 
							noi disp in smcl "Results saved in mata matrix {stata mata stataid:stataid}."
						}
						
						return scalar instances = _N				   
					restore
					
			}
			else if "`anything'" == "kill" {
				if "`id'" == "" {
					noi disp "CPU process id needs to be defined."
				}
				else {
					noi disp "CPU process id `id' going to be closed."
					winexec taskkill /f /t /pid `id'
				}
			}
			else {
				noi disp in smcl "Only {cmd:kill} or {cmd:list} allowed with {cmd:stataid}."
			}
		}
end
