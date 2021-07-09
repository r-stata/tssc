*! version 1.2  25Nov2017
*! written by Kerry Du, kerrydu@sdu.edu.cn

cap program drop labone
program define labone
        version 12.1
        syntax [varlist], [Nrow(numlist) noSpace Concat(str asis)]

        if _N == 0 {
                error 2000
        }

	 if "`nrow'"=="" {
		 local nrow=1
		 }
		
  
   
        local numrow: word count `nrow'
        local numconcat: word count `concat'
        if `numconcat'>=`numrow' {
        
                disp as red "Warning: #(concatenating sysboms) is greater than #(rows)-1."
                disp "In this case:"
                disp "         # of concatenating sysboms is `numconcat'."
                disp "         # of located rows is `numrow'."
                disp "         Only the first `=`numrow'-1' concatenating sysboms is used."
                
        }
        
    local nvar: word count `varlist'
        if `nvar'==0 {
                qui ds
                local varlist=r(varlist)
        }
   
        
        local vlabel=""
        foreach k in `varlist' {
                local vlabel=""
                local first=1
                local allp `"`concat'"'
                foreach j in `nrow' {
                local vl`j'=`k'[`j']
                if `first'==1{
                        local vlabel=`"`vl`j''"'
                        local first=0
                        continue
                }
                gettoken onep allp:allp
                if "`onep'"==`""'& "`space'"!="nospace"{
                        local onep `" "'
                }
                local vlabel=`"`vlabel'"'+`"`onep'"'+`"`vl`j''"'
                }
                
                
                label var `k' `"`vlabel'"'
        }
*/
        end
        
