program runmlwin_qshell,
	version 9.0
	syntax [anything(equalok everything)] [, *]
	if `"`anything'"' == "" {
		capture plugin call runmlwin_quietshell, `"cmd"'
		if c(rc) == 199 {
			shell `cmd'
		}
	}
	else {
		capture plugin call runmlwin_quietshell, `"`anything'"'
		if c(rc) == 199 {
			shell `anything'
		}
	}
end

capture program runmlwin_quietshell, plugin using("runmlwin_quietshell.plugin")
