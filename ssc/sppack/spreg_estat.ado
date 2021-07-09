*! version 1.0.1  03jun2010
program spreg_estat, rclass

	version 11.1

	if "`e(cmd)'" != "spreg" & "`e(cmd)'" != "spivreg" {
		error 301
	}
	
	gettoken key rest : 0, parse(", ")
	local lkey = length(`"`key'"')
	if `"`key'"' == substr("gof",1,max(3,`lkey')) {
		
		di "{err}gof not available after `e(cmd)'"
		exit 198
		
		//spreg_gof `rest'
	}
	else estat_default `0'
	
	return add
	
end
