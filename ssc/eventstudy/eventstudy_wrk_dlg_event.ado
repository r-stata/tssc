/*-----------------------eventstudy_wrk_dlg.ado-----------------------------
*!----version 1.0.1
*!----programmer: Chuntao Li, Xin Xu
*!----date 04mar2013
*/
capture program drop eventstudy_wrk_dlg_event
program eventstudy_wrk_dlg_event
	version 12
	syntax using, dialog(string)
	capture describe `using',varlist
	if _rc{
		.eventstudy_dlg.event_des_error.setvalue 1
	}
	else{
		foreach item in id date firmid control{
			local cblist_name ///
				`"`.eventstudy_dlg.`dialog'.cb_event`item'.contents'"'
			local i=1
			foreach var in `r(varlist)'{
				.eventstudy_dlg.`cblist_name'[`i']= "`var'"
				local ++i
			}
		}
	}
end
	
