program affiliationexposure
version 10
syntax varlist(numeric min=1), ATTRIBute(varlist min=1 max=1) RESult(name)

capture matrix drop AE
*load the data
mkmat `varlist' `attribute', matrix(AE)
*Cleanup missing values --> 0
mata: m=editmissing(st_matrix("AE"),0); 
mata: Y=m[.,(cols(m))]; A=m[.,1..(cols(m)-1)];   
*calculate Affinity Exposure
mata: C=A*A';
mata: _diag(C,0);
mata: rs=rowsum(C);
mata: ev = (C*Y) :/ rs;
*save to workspace
capture drop RES_AE* `result'
mata: st_matrix("RES_AE",ev)
svmat RES_AE
rename RES_AE `result'
*cleanup memory
matrix drop AE
end
