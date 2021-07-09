/*

es_trade_wrk_dlg.ado

!version 1.0.2   08mar2013

*/

capture program drop es_trade_wrk_dlg
program es_trade_wrk_dlg
	version 12
	syntax using,clsname(string)
	capture describe `using',varlist
	if _rc{
		.es_trade_dlg.trade_des_error.settrue
	}
	else{
		local dlg .`clsname'
		foreach item in firmid date rit rmt{
			local cblist_name ///
				`"``dlg'.trade.cb_trade`item'.contents'"'
			local i=1
			foreach var in `r(varlist)'{
				`dlg'.`cblist_name'[`i']= "`var'"
				local ++i
			}
		}
	}
end
