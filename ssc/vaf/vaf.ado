*!vaf version 1.0
*!Written 05Dec2015
*!Written by Mehmet Mehmetoglu
capture program drop vaf
        program vaf   
        version 14.1
  local ecmd "e(cmd)"
if `ecmd' != "sem" {
        di in red "works only with -sem-"
        exit
        }   
  di ""  		
  //local usersem = e(cmdline)
  //qui `usersem'
  //qui ereturn list

  local colfullname:colfullnames e(b)
  //mat list e(b)
  local latenty = e(lyvars)
  local latentx = e(lxvars)
  local latent `latenty' `latentx'
  local lxy = 0
  foreach x of local colfullname {
        gettoken equation col: x, parse(:)
        gettoken coma col: col, parse(:)

        if (regexm("`latent'", "`equation' ") | regexm("`latent'", " `equation' ") ///
           | regexm("`latent'", " `equation'") | ("`latent'"=="`equation'")) & ///
            (regexm("`latent'", "`col' ") | regexm("`latent'", " `col' ") ///
           | regexm("`latent'", " `col'") | ("`latent'" == "`col'")) {
                local ++lxy
        }
      }
  //di `lxy'
  
  tempname lxn
  scalar `lxn' = wordcount("`e(lxvars)'")
  //di `lxn'
  tempname lyn
  scalar `lyn' = wordcount("`e(lyvars)'")
  //di `lyn'
  
  qui estat teffects, stand nototal nodirect
  qui return list
  	
  mat ind=r(indirect_std)
  //mat list ind
  local lsn=colsof(ind)
  //di `lsn'
  tempname coln
  scalar `coln' =`lsn' - `lxy' + 1
  mat ind2=ind[1...,`coln'...] 
  
  local cols2 = colsof(ind2)
  forvalues ii = 1/`cols2' {
	if (ind2[1, `ii'] ==0) mat ind2[1, `ii'] = .
  }
  matrix rownames ind2 = "INDIRECT ="
  //mat list ind2, noheader format(%10.2f)
  
  mat ind3 = J(1,`lxy',0)
  //mat list ind3
  local i=1
	forvalues j = 1/`lxy' {
		 matrix ind3[`i',`j']= ind2[`i',`j']^2  
	}
  //mat list ind3
  mat ind4 = J(1,`lxy',0)
  //mat list ind4
  local i=1
	forvalues j = 1/`lxy' {
		 matrix ind4[`i',`j']= sqrt(ind3[`i',`j'])  
	}
  //mat list ind4

  local cname1 : colfullnames ind2
  matrix colnames ind4 = `cname1'
  //mat list ind4, noheader format(%10.2f) 

  mat dirc=r(direct_std)
  local ldn3=colsof(dirc)
  tempname coln1
  scalar `coln1' =`lsn' - `lxy' + 1  
  mat dirc2=dirc[1...,`coln1'...]
  //mat list dirc2
  mat dirc3 = J(1,`lxy',0)
  //mat list dirc3
  local i=1
	forvalues j = 1/`lxy' {
		 matrix dirc3[`i',`j']= dirc2[`i',`j']^2  
	}
  //mat list dirc3
   mat dirc4 = J(1,`lxy',0)
  //mat list dirc4
  local i=1
	forvalues j = 1/`lxy' {
		 matrix dirc4[`i',`j']= sqrt(dirc3[`i',`j'])  
	}
  //mat list dirc4

  local cname2 : colfullnames dirc2
  matrix colnames dirc4 = `cname2'
  //mat list dirc4
  
  mat tot = J(1,`lxy',0)
  //mat list tot
  local i=1
	forvalues j = 1/`lxy' {
		 matrix tot[`i',`j']= ind4[`i',`j'] + dirc4[`i',`j']   
	}
   
  local cname2 : colfullnames dirc2
  matrix colnames tot = `cname2'
  //mat list tot	
	
  //qui estat teffects,stand	
  mat tot2=r(total_std)
  //mat list tot2
  local lsn2=colsof(tot2)
  //di `lsn2'
  tempname coln2
  scalar `coln2' =`lsn2' - `lxy' + 1
  mat tot2=tot2[1...,`coln2'...] 
  
  local cols22 = colsof(tot2)
  forvalues ii = 1/`cols22' {
	if (tot2[1, `ii'] ==0) mat tot2[1, `ii'] = .
  }
  matrix rownames tot2 ="TOTAL ="
  //mat list tot2, noheader format(%10.2f)
  
	
  /*to obtain the vaf values, we need to divide the indirect 
  effects by the total effects*/
  mat vaf = J(1,`lxy',0)
  //mat list vaf
  local i=1
	forvalues j = 1/`lxy' {
	matrix vaf[`i',`j']= (ind4[`i',`j']/tot[`i',`j'])*100   
	}	
  //mat list vaf

  local cname3 : colfullnames ind4
  matrix colnames vaf = `cname3'
  matrix rownames vaf ="VAF(%) =" 
  //mat list vaf, noheader format(%10.1f) 
  
  local cols = colsof(vaf)
  forvalues ii = 1/`cols' {
	if (vaf[1, `ii'] ==0) mat vaf[1, `ii'] = .
}
  di in green as text "{bf}    VAF = (indirect effects/total effects)*100"
  matlist vaf, noheader showcoleq(each) format(%10.1f) lines(columns) border(top left right)
  matlist ind2, noheader showcoleq(each) names(row) format(%10.3f) lines(columns) border(left right)
  matlist tot2, noheader names(row) format(%10.3f) lines(columns) border(left bottom right)        
  
end 







