*! version 1.0.1 14Mar2010 MLB
program define obsofint_ex
        Msg preserve
        preserve
		if `1' == 1 {
			Xeq sysuse auto, clear
			Xeq obsofint , idlist(make)
		}
		if `1' == 2 {
			Xeq sysuse auto, clear
			Xeq obsofint price - foreign, loud idlist(make) sum
		}
		if `1' == 3 {
			Xeq sysuse auto, clear
			Xeq obsofint price - foreign, idlist(make) tukey
		}
        Msg restore 
        restore
end

program Msg
        di as txt
        di as txt "-> " as res `"`0'"'
end

program Xeq, rclass
        di as txt
        di as txt `"-> "' as res `"`0'"'
        `0'
end
