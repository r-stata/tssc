capture program drop reshape3
program define reshape3, rclass 
	version 9.0
	syntax anything, i(varlist) j(namelist) [STRING]
	
	local k=0
	gettoken tp 0:0,p("( ),")
	
	
	if !(strmatch("`tp'","wide") | strmatch("`tp'","long") ){
		disp as red "You omitted the word wide or long after typing reshape3"
		disp _n as red "You should have typed"
		disp _n as red "        .reshape3 long (varlist)....(varlist),..."
		disp _n as red "      or"
		disp _n as red "        .reshape3 long varlist,..."
		disp _n as red "      or"
		disp _n as red "        .reshape3 wide (varlist)....(varlist),..."
		disp _n as red "      or"
		disp _n as red "        .reshape3 wide varlist,..."
	    exit 198
	
	}
	
	
	gettoken word 0:0,p("( ),")
	
	while !("`word'"==","| "`word'"=="") {
	    
	
		if !("`word'"=="("|"`word'"==")"){
	
			local varlist `varlist' `word'
			gettoken word 0:0,p("( ),")
			//disp "`varlist'"
		
		}
		else{
			gettoken word 0: 0,p("( ),")
			local k=`k'+1
			while !("`word'"==")"| "`word'"=="") {
					local com`k' `com`k'' `word'
			        gettoken word 0:0,p("( ),")
			
			}
			gettoken word 0:0,p("( ),")
		}
				
		
   }
	

	
	if strmatch("`tp'","long"){
	
		if !("`varlist'"==""|"`com1'"==""){
			disp as red "reshape long should be used as"
			disp as red "                  reshape long varlist, ...."
			disp as red "               or                            "
			disp as red "                  reshape long (varlist1)...(varlist2),..."
			exit 198
		
		}
		
		if !("`varlist'"==""){
			local nj: word count `j'
			local vlist `varlist'
			if `nj'>1 {
				disp as yellow  `"     WARNING: "For multi-level data, reshape long varlist, ...." can ONLY be used for simple cases"'
				disp as yellow "               e.g., variable names are VNAMEijk, 0<=i,j,k<=9, "
				disp as yellow "                                       or, i,j,k belong to {a,...,z,A,...,Z}"
			}
			forvalues q=1/`nj'{
				gettoken x j: j
				qui ds 
				local alist=r(varlist)
				//disp "`x'"
				//disp "`vlist'"
				reshape long `vlist', i(`i') j(`x') `string'
				local i `i' `x'
				qui ds 
				local blist=r(varlist)
				local alist `alist' `x'
				local vlist: list blist-alist
				local nv: word count `vlist'
				local nvlist
				forvalues p=1/`nv' {
					gettoken varw vlist: vlist
					local varw=substr("`varw'",1,strlen("`varw'")-1)
					if !strpos("`nvlist'","`varw'"){
						local nvlist `nvlist' `varw'
					}
				}
				local vlist `nvlist'
				
				}
				
		}
		
	
		
		if !("`com1'"==""){
			local nj: word count `j'
			if `nj'!=`k' {
				disp as red "The # of items specified in j() is not consistent with the # of varibale groups for reshaping!"
				exit 198
			}
			forvalues q=1/`nj' {
				gettoken newvar j: j  
				//disp "`com`q''"
				reshape long `com`q'', i(`i') j(`newvar') `string'
				local i `i' `newvar'
			}
		 
		
     }
	}
	
	if strmatch("`tp'","wide"){
		if !("`varlist'"==""|"`com1'"==""){
			disp as red "reshape wide should be used as"
			disp as red "                  reshape wide varlist, ...."
			disp as red "               or                            "
			disp as red "                  reshape wide (varlist1)...(varlist2),..."
			exit 198
		
		 }
		
		if !("`varlist'"==""){
		
			local nj: word count `j'
			local vlist `varlist'
			forvalues q=1/`nj'{
				gettoken x j: j
				qui ds 
				local alist=r(varlist)
				reshape wide `vlist', i(`i' `j') j(`x') `string'
				qui ds 
				local blist=r(varlist)
				local vlist: list blist-alist	
			}
		}
		
		if !("`com1'"==""){
			local nj: word count `j'
			if `nj'!=`k' {
				disp as red "The # of items specified in j() is not consistent with the # of varibale groups for reshaping!"
				exit 198
			}
			
			forvalues q=1/`nj' {
				gettoken newvar j: j  
				//disp "`com`q''"
				reshape wide `com`q'', i(`i' `j') j(`newvar') `string'
			}			
		
		}
		
	}
	
	
	
	
	
	
	//return local newvar `vlist'
	end
