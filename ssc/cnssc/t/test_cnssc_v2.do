
*- to Prof. Baum

* Yujun Lian, 
* v1 2021.5.27  copy ssc.ado and mirar modify
* v2 2021.6.13  add cnsscget to download ancillary files
*               provide more information after cnssc install
*                                              cnssc describe
*               two servers: SSC and lianxh.cn

*------------------
*- Test cnssc.ado
*------------------

cap global p "D:\Github\pubcmds\cnssc"  // modify folder 
cap global p "D:\Github\pubcmds\_submit_ssc\cnssc"
cap global p "D:\Github\pubcmds\_submit_ssc\_Lian_SSC_15June2021\cnssc"

adopath + "$p"
cd $p
cap mkdir testPlus  // save plus files
net set ado "$p/testPlus"
adopath + "$p/testPlus"

cd $p
cap mkdir data
cd "$p/data"

/*
cd $p/_update
clear 
input update
20210614
20210520
end
save "cnssc_update.dta", replace 
*/


*-basic
  which cnssc
  help  cnssc 
  cnssc new        // = ssc new
  cnssc hot, n(20) // = ssc hot, n(20)
  cnssc hot, n(40) author(Baum)
  cnssc hot, n(20) author(Yujun)
  
*-describe
  cnssc des a
  cnssc des _
  cnssc des x
  cnssc des winsor
  cnssc des ivreg2
  cnssc des ihelp    //lianxh.cn pkg
  cnssc des wwwc     //error
  cnssc des 

*-install
  cnssc install ivreg2
  cnssc install ivreg2, all
  cnssc install ivreg2, replace 
  cnssc install ihelp 
  cnssc install ihelp, replace
  cnssc install          //error
  cnssc install abc      //error
  
*-uninstall 
  cnssc uninstall ivreg2
/*
  package not found
  r(111);
*/


*-install packages in [lianxh.cn], not in SSC
  cnssc install rdbalance
/*
cnssc install: "rdbalance" not found at SSC, now turn to lianxh.cn server ...
checking rdbalance consistency and verifying not already installed...
installing into D:\Github\pubcmds\_submit_ssc\cnssc/testPlus\...
installation complete.
*/
  which ihelp 
  cnssc install ihelp 
  which ihelp 

*-type
  cnssc des  firthlogit
  cnssc type asseryanis.do
  
  cnssc des  ivreg2
  cnssc type cs_ivreg29.do
  cnssc type cs_ivreg2_4.1.11.do
  
*-copy
  cnssc copy cs_ivreg29.do
  cnssc copy cs_ivreg29.do, replace 
  
  
*-get - NEW
  
  program drop _all 
  which cnssc 
  
  *- SSC packages
  cnssc des firthlogit
  cnssc get firthlogit, replace
  cnssc get firthlogit, replace force 
  * no ancillary files
  cnssc des xtbalance
  cnssc get xtbalance
  *- lianxh.cn packages
  cnssc des rdbalance
  cnssc get rdbalance, replace       
  cnssc get rdbalance, replace force   
  
  *-test cnget_FileList.ado
  cnget_FileList firthlogit
  
  *-test Chinese
  cnssc get testget
  cnssc des testget

  
*-cnssc install, lianxh // lianxh option  
  
  program drop _all 
  which cnssc 
  
  cnssc install winsor2
  set trace on
  cnssc install rdbalance, li
  
  cnssc install imusic
  cnssc install imusic, li replace
  cnssc install imusic2
  
  cnssc install ivreg2, li
  
  cnssc get rdbalance  
  cnssc get rdbalance, li
  
  cnssc get ivreg2
  cnssc get ivreg2, li
  cnssc get ivreg3, li  // error
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
