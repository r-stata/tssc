*! itsp_ado  CFBaum 23may2010 
*! create .mo from installed ITSP Mata routines 
prog itsp_ado
version 10.1
loc mataa aggreg aggreg2 avgper 
loc matac calcextrema centerv country compcty compcty2  
loc matai indcorr 
loc matal loadcty 
loc matam myvecstr mypoint m_mycuecrit m_mygmm2s m_mygmmcue m_myomega makevec mf_flipmat mf_nneighbor mm_suregub myvecsub
loc matas shufstr
loc plus `c(sysdir_plus)'
cd "`plus'"
loc alll a c i l m s
foreach l of loc alll {
	foreach w of loc mata`l' {
		do ./`l'/`w'.mata
		mata: mata mosave `w'(), dir(PERSONAL) replace
	}
}
// cd ~
end
