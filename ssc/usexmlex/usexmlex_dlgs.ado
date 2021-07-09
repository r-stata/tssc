*! usexmlex_dlgs is part of the -usexmlex- package by Sergiy Radyakin.
*! Type: which usexmlex
*! to obtain version and date information

program define usexmlex_dlgs

  version 13.0

  mata st_local("usexmlex_version", _usexmlex_getversion())
  mata st_local("usexmlex_date", _usexmlex_getdate())

  capture .usexmlex_dlg.about.tx_vrsn.setlabel ///
    "This is -usexmlex- version `usexmlex_version' compiled on `usexmlex_date'"

end
//eof