*!condisc version 1.0
*!Written 07Apr2015
*!Written by Mehmet Mehmetoglu
capture program drop condisc
program condisc
version 13.1
  di ""
  di in green "                  Convergent and Discriminant Validity Assessment"
  di as smcl as txt  "{hline 90}"
  di in yellow "{bf:Squared  correlations (SC) among  latent  variables              }"
  di as smcl as txt "{hline 90}"	

  /*extracts the interfactor corr mat*/
  qui estat framework, stand
      mat Phi1=r(Phi)
        //mat list Phi1, format(%12.3f) 
		
	  local ncol=colsof(Phi1) 
      local nrow=rowsof(Phi1) 
		
  /*transforms Phi1 into Phi2 which now represents the
    squared interfactor corr mat*/
  mat Phi2=J(`nrow',`ncol',0) 
       //mat list Phi2
  forvalues i = 1/`nrow' {
      forvalues k = 1/`ncol' {
         mat Phi2[`i', `k'] = Phi1[`i', `k']^2 
            }
          }
	  //mat list Phi2
  
  /*rename the rownames and colnames of the factors of Phi2 which now becomes Phi3*/
  mat Z=J(`nrow',`ncol',0)
  local latent "`e(lxvars)'"
  mat rownames Z = `latent'
  mat colnames Z = `latent'
  //mat list z
  mat Phi3=Phi2+Z
  mat list Phi3, format(%12.3f) noheader  
 
  di ""
  di as smcl as txt "{hline 90}"	
  di in yellow "{bf:Average variance extracted (AVE) by latent variables               }"
  di as smcl as txt "{hline 90}"	
 
  forvalues n=1/`ncol' { 
   mat Phi3[`n',`n']=0
     }
  //mat list Phi3 //Phi3 with zeros in the diagonals
 
 
  /*finding the max value of Phi3*/
  local i=1
  mat M=J(1,1,0)
  forvalues n=1/`nrow' { 
        local j=1
      forvalues m=1/`ncol' {
          mat M[1,1]=max(M[1,1],Phi3[`n',`m'])
		  local ++j
		  }
		local ++i
		  } 
		  //mat list M //lists the maks value of Phi3 matrix
		  tempname maks
		  scalar `maks'=M[1,1] 
		  //di `maks'
		  
  /*takes the average of AVEs for each factor*/
  qui estat framework
     mat L = r(Gamma) //Lambda matrix
     local obsstripes : rowfullnames L
     local latstripes : colfullnames L
     //di "`obsstripes'"
     //di "`latstripes'"
     local nu = wordcount("`e(oyvars)'")
  qui estat eqgof
     mat R = r(eqfit)
     //mat list R
     mat R2 = R[1..`nu', 4]
     //mat list R2
  local latent "`e(lxvars)'" 
  foreach lat of local latent { 
      local sumve = 0
      local i = 0
    foreach obs of local obsstripes {
      if L[rownumb(L, "`obs'"), colnumb(L,"`lat'")] !=0 {
  	  local sumve = `sumve' + R2[rownumb(L,"`obs'"), 1]
  	  local ++i 
      }
    }
	di ""
	  tempname ave
	  scalar `ave' = `sumve'/`i'
	
	
	/*shows the values in a table*/
    if `ave' < `maks' {
       di in red  "" %12s abbrev("AVE_`lat'",12) "{dup 7: }"" "%9.3f `ave' "{dup 9: }""   Problem with discriminant validity""
	      }
	else if `ave' >= `maks' {
       di in green "" %12s abbrev("AVE_`lat'",12) "{dup 7: }"" "%9.3f `ave' "{dup 9: }""   No problem with discriminant validity""
	      }
	   
	   if `ave' < 0.5 {
       di in red  "                                         Problem with convergent validity""
	      }
	else if `ave' >= 0.5 {
       di in green "                                         No problem with convergent validity"
	      }
		  }
	   
	di ""
    di as smcl as txt  "{hline 90}"
	di in yellow "Note: when AVE values >= SC values there is no problem with discriminant validity"
	di in yellow "      when AVE values >= 0.5 there is no problem with convergent validity "
	end



