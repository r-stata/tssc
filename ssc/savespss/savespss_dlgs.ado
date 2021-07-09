*! savespss_dlgs is part of the -savespss- package by Sergiy Radyakin.
*! Type: which savespss
*! to obtain version and date information

program define savespss_dlgs

  version 10.0

  syntax ,dlg(string)

  mata st_local("savespss_version", _savespss_getversion())
  mata st_local("savespss_date", _savespss_getdate())

  capture `dlg'.about.tx_vrsn.setlabel "This is -savespss- version `savespss_version' compiled on `savespss_date'"

  if (`c(stata_version)'<13) {
    capture `dlg'.advanced.tx_strlmax.disable
    capture `dlg'.advanced.sp_strlmax.disable
  }

end
//eof