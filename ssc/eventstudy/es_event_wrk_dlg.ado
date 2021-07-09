/*----------------------------------------------------

es_event_wrk_dlg.ado
*!version 1.0.2       07mar2013
*/

capture program drop es_event_wrk_dlg
program es_event_wrk_dlg
	version 12
	syntax using,clsname(string)
	capture describe `using',varlist
	if _rc{
		.es_event_dlg.event_des_error.settrue
	}
	else{
		local dlg .`clsname'
		foreach item in id date firmid control{
			local cblist_name ///
				`"``dlg'.event.cb_event`item'.contents'"'
			local i=1
			foreach var in `r(varlist)'{
				`dlg'.`cblist_name'[`i']= "`var'"
				local ++i
			}
		}
	}
end

