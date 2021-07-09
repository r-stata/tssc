*! version 1.1  Oct2006
*! Author: Le Dang Trung
#delimit;
program define tabform, rclass byable(recall) sort;
	version 9.0;

   syntax varlist(numeric) using [if] [in] [aw fw] [ , 
   		 By(varname) SD SE CI Level(cilevel) noTotal BDec(numlist int >=0 <=11) 
   		 SDBracket CIBrace MTest MTProb MTSe MTBdec(numlist int >=0 <=11) VERtical ];

	* sample selection;
	marksample touse, novar;
	
	if "`by'" != ""  
		{;
		markout `touse' `by' , strok;
      };
	qui count if `touse';
   local ntouse = r(N);
   
   if `ntouse' == 0 
   	{;
      error 2000;
      };
   
   if `"`weight'"' != "" 
   	{;
      local wght `"[`weight'`exp']"';
      };   
     
   if "`level'" == "" 
   	{;
     	local level = 95;				// Set default confidence level 95%
     	};
     
   if "`bdec'"=="" 
   	{;
     	local bdec = 2;
      };
   if "`mtbdec'"==""
   	{;
   	local mtbdec = 2;
   	};
     
	tempfile outtab;
	tokenize "`varlist'";
	local nvars : word count `varlist';
   forvalues i = 1/`nvars' 
   	{;
   	local var`i' ``i'';
   	tempname tempvar`i';
   	quiet gen `tempvar`i'' = "";
   	capture local labtempvar`i': var label ``i'';
   	};
   tempname varlab;
   quiet gen `varlab' = "";
   capture local labby: var lavel `by';
	tempname bycate;
	
* Compute mean, sd, se, ci, median, n for each of varlist and each of categories of by;
	local i = 1;
	if "`by'" != "" 
		{;
		* conditional statistics are saved in local macro m`ij', sd`ij', lb`ij', un`ij';
		* where i indicates categories of by and j indicates the order of variables in varlist;
		* This part is mainly adopted from tabstat;
      qui replace `touse' = - `touse';
      sort `touse' `by';
      local bytype : type `by';
      local by2 0;
      local iby 1;
      local i = 1;
      while `by2' < `ntouse'  
      	{;
      	* range `iby1'/`iby2' refer to obs in the current by-group;
      	local by1 = `by2' + 1;
      	qui count if (`by'==`by'[`by1']) & (`touse');
      	local by2 = `by1' + r(N) - 1;
      	quiet gen `bycate' = 1 in `by1'/`by2';
      	quiet recode `bycate' . = 0;
      	
      	* loop over all variables;
      	forvalues k = 1/`nvars' 
      		{;
      		qui summ `var`k'' in `by1'/`by2' `wght';
      		local m`i'`k' = r(mean);
      		local sd`i'`k' = r(sd);
      		if "`se'" != "" 
      			{;
      			local sd`i'`k' = r(sd)/sqrt(r(N));
      			};
      		* Compute confidence interval;
      		ret scalar N = r(N);
      		ret scalar mean = r(mean);
      		ret scalar se = sqrt(r(Var)/r(N));
      		
      		local invt = invttail(r(N)-1, (100-`level')/200);
      		local lb`i'`k' = r(mean) - `invt'*return(se);
      		local ub`i'`k' = r(mean) + `invt'*return(se);
      		
      		* Mean comparison test;
      		quiet reg `var`k'' `bycate' if `touse' `wght';
      		local tstat = abs(_b[`bycate']/_se[`bycate']);
      		local df_r = e(df_r);
      		if `df_r'==. 
      			{;
      			local mprob = 2*(1-normprob(`tstat'));
      			};
      		else 
      			{;
      			local mprob = tprob(`df_r', `tstat');
      			};
      		local mse = _se[`bycate'];

      		if `mprob'<=0.10 & `mprob'!=. 
      			{;
      			local astrix`i'`k' = "*";
      			};
      		if `mprob'<=0.05 & `mprob'!=. 
      			{;
      			local astrix`i'`k' = "**";
      			};
      		if `mprob'<=0.01 & `mprob'!=. 
      			{;
      			local astrix`i'`k' = "***";
      			};
      		if "`mtprob'"!=""
      			{;
      			local astrix`i'`k' = "(" + string(`mprob', "%12.`mtbdec'f") + ")";
      			};
      		if "`mtse'"!=""
      			{;
      			local astrix`i'`k' = "(" + string(`mse', "%12.`mtbdec'f") + ")";
      			};
      		if "`mtest'"=="" 
      			{;
      			local astrix`i'`k' = "";
      			};
      		};
      		quiet drop `bycate';
      		
      	* save label for groups in lab1, lab2 etc;
      	if substr("`bytype'",1,3) != "str" 
      		{;
      		local iby1 = `by'[`by1'];
      		local lab`iby' : label (`by') `iby1';
      		};
      	else 
      		{;
      		local lab`iby' = `by'[`by1'];
      		};
      	
      	local iby = `iby' + 1;
      	local i = `i' + 1;
      	};
      
      local nby = `iby' - 1;
      local i = `i' - 1;
      };
      
   else 
   	{;
   	local nby 0;
   	local i = 0;
   	};
   	
	if "`total'" == "" 
		{;
		* unconditional (Total) statistics are stored in Stat`nby+1';
		local iby = `nby' + 1;
		local i = `i' + 1;
		
		* Loop over varlist;
		forvalues k = 1/`nvars' 
			{;
			qui summ `var`k'' if `touse' `wght';
			local m`i'`k' = r(mean);
			local sd`i'`k' = r(sd);
			if "`se'" != "" 
      		{;
      		local sd`i'`k' = r(sd)/sqrt(r(N));
      		};
			* Compute confidence interval;
			ret scalar N = r(N);
			ret scalar mean = r(mean);
			ret scalar se = sqrt(r(Var)/r(N));
			local invt = invttail(r(N)-1, (100-`level')/100);
			local lb`i'`k' = r(mean) - `invt'*return(se);
			local ub`i'`k' = r(mean) + `invt'*return(se);
			local astrix`i'`k' = "";
			};
		local lab`i' "Total";
		};
     
   * Display the table;
   * -----------------;
   if "`sdbracket'" != ""
   	{;
   	local lparen = "[";
   	local rparen = "]";
   	local sdparen = "brackets";
   	};
   else
   	{;
   	local lparen = "(";
   	local rparen = ")";
   	local sdparen = "parentheses";
   	};
   	
   if "`cibrace'" != ""
   	{;
   	local lbrack = "{";
   	local rbrack = "}";
   	local cibrack = "braces";
   	};
   else
   	{;
   	local lbrack = "[";
   	local rbrack = "]";
   	local cibrack = "brackets";
   	};
   local smcomma = ";";
	
   * Case 0: Reports only means when sd and ci are not both specified;
   if "`sd'"=="" & "`se'"=="" & "`ci'"=="" 
   	{;
   	* loop over the categories of -by- (1..nby) and -total- (nby+1> );
   	local nbyt = `nby' + ("`total'" == "");
		forvalues k = 1/`nvars' 
			{;
     		if "`labby'"!="" 
     			{;
     			quiet replace `varlab' = "`labby'" in 1;
     			};
     		else 
     			{;
     			quiet replace `varlab' = "`by'" in 1;
     			};
     			
     		if "`labtempvar`k''"!="" 
     			{;
     			quiet replace `tempvar`k'' = "`labtempvar`k''" in 1;
     			};
     		else 
     			{;
     			quiet replace `tempvar`k'' = "`var`k''" in 1;
     			};
     			
     		forvalues j = 1/`nbyt' 
     			{;
     			local y = `j' + 1;
     			quiet replace `tempvar`k'' = string(`m`j'`k'', "%12.`bdec'f") + "`astrix`j'`k''" in `y';
     			quiet replace `varlab' = "`lab`j''" in `y';
     			};
     		};
     	local N = `nbyt' + 1;
     
     	if "`mtest'"!="" 
   		{;
   		local N = `N' + 1;
   		if "`mtprob'"!=""
   			{;
   			quiet replace `varlab' = "P-values for mean-difference test in brackets after means" in `N';
   			};
   		if "`mtse'"!=""
   			{;
   			quiet replace `varlab' = "SE for mean-difference test in brackets after means" in `N';
   			};
   		if "`mtprob'"==""&"`mtse'"==""
   			{;
   			quiet replace `varlab' = "* significant at 10%; ** significant at 5%; *** significant at 1%" in `N';
   			};
   		};
   	if "`vertical'" == ""
   		{;
     		outsheet `varlab' `tempvar1' - `tempvar`nvars'' `using' in 1/`N', nonames replace;
     		};
     	else 
     		{;
     		local V = 1;
     		foreach Vvar of varlist `varlab' `tempvar1' - `tempvar`nvars''
     			{;
     			tempvar Tempvar`V';
     			quiet gen `Tempvar`V'' = `Vvar';
     			local V = `V' + 1;
     			};

     		local V = `V' - 1;
     		local nvarsvertical = `V';					/// # of columns
     		local Nver = `V' + 1;
     		if "`mtest'"!="" 
     			{;
     			local nobsvertical = `N' - 1;				/// Don't process observation containing the note
     			};
     		else 
     			{;
     			local nobsvertical = `N';
     			};
     		quiet forval v = 1/`nobsvertical' 
     			{;
     			tempvar tempvarvertical`v';
     			gen `tempvarvertical`v'' = "";
     			local U = 1;
     			foreach u of varlist `Tempvar1' - `Tempvar`V'' 
     				{;
     				replace `tempvarvertical`v'' = `u'[`v'] in `U';
     				local U = `U' + 1;
     				};
     			};
     			
     		if "`mtest'" != "" 
     			{;
     			local note = `varlab'[`N'];
     			quiet replace `tempvarvertical1' = "`note'" in `Nver';
     			};
    		
     		outsheet `tempvarvertical1' - `tempvarvertical`nobsvertical'' `using' in 1/`Nver', nonames replace;
     		};
 		};

   * Case 1: Only SD specified;
   if ("`sd'"!="" | "`se'"!="") & "`ci'"=="" 
   	{;
   	* loop over the categories of -by- (1..nby) and -total- (nby+1> );
   	local nbyt = `nby' + ("`total'" == "");
      forvalues k = 1/`nvars' 
      	{;
      	if "`labby'"!="" 
      		{;
      		quiet replace `varlab' = "`labby'" in 1;
      		};
      		
     		else 
     			{;
     			quiet replace `varlab' = "`by'" in 1;
     			};
     			
     		if "`labtempvar`k''"!="" 
     			{;
     			quiet replace `tempvar`k'' = "`labtempvar`k''" in 1;
     			};
     		else 
     			{;
     			quiet replace `tempvar`k'' = "`var`k''" in 1;
     			};
     			
     		forvalues j = 1/`nbyt' 
     			{;
     			local x = 0;
     			local y = 2*`j'-`x';
     			while `x' >=-1 
     				{;
     				quiet replace `tempvar`k'' = string(`m`j'`k'', "%12.`bdec'f") + "`astrix`j'`k''" in `y';
     				quiet replace `varlab' = "`lab`j''" in `y';
     				local x = `x' - 1;
     				local y = `y'+1;
     				quiet replace `tempvar`k'' = "`lparen'" + string(`sd`j'`k'', "%12.`bdec'f") + "`rparen'" in `y';
     				local x = `x' - 1;
     				};
     			};
     		};
     	local N = 2*`nbyt' + 2;
     	local lastrow = `N' - 1;

     	if "`se'"=="" 
     		{;
     		quiet replace `varlab' = "Standard deviations in `sdparen'" in `N';
     		};
     	else 
     		{;
     		quiet replace `varlab' = "Standard errors of means in `sdparen'" in `N';
     		};
     	if "`mtest'"!="" 
   		{;
   		local N = `N' + 1;
   		if "`mtprob'"!=""
   			{;
   			quiet replace `varlab' = "P-values for mean-difference test in brackets after means" in `N';
   			};
   		if "`mtse'"!=""
   			{;
   			quiet replace `varlab' = "SE for mean-difference test in brackets after means" in `N';
   			};
   		if "`mtprob'"==""&"`mtse'"==""
   			{;
   			quiet replace `varlab' = "* significant at 10%; ** significant at 5%; *** significant at 1%" in `N';
   			};
   		};
   	if "`vertical'" == ""
   		{;
     		outsheet `varlab' `tempvar1' - `tempvar`nvars'' `using' in 1/`N', nonames replace;
     		};
     	else 
     		{;
     		local V = 1;
     		foreach Vvar of varlist `varlab' `tempvar1' - `tempvar`nvars''
     			{;
     			tempvar Tempvar`V';
     			quiet gen `Tempvar`V'' = `Vvar';
     			local V = `V' + 1;
     			};
			
     		local V = `V' - 1;
			
     		local nvarsvertical = `V';					/// # of columns
     		local Nver = `V' + 1;
     		local nobsvertical = `lastrow';
     		* Expose observations and variables;
     		quiet forval v = 1/`nobsvertical' 
     			{;
     			tempvar tempvarvertical`v';
     			gen `tempvarvertical`v'' = "";
     			local U = 1;
     			foreach u of varlist `Tempvar1' - `Tempvar`V'' 
     				{;
     				replace `tempvarvertical`v'' = `u'[`v'] in `U';
     				local U = `U' + 1;
     				};
     			};
     		local V = `nobsvertical' - 1;				// New last column	
			local lastrow1 = `lastrow' + 1;
			local note1 = `varlab'[`lastrow1'];
     		if "`mtest'" != "" 
     			{;
     			local lastrow2 = `lastrow' + 2;
     			local note2 = `varlab'[`lastrow2'];
     			};

     		* Duplicate the observations which will be exported to process the table;
     		preserve;
     		tempvar id;
     		gen `id' = _n;
     		quiet expand 2 in 1/`nvarsvertical';
     		sort `id';
			quiet drop in 2;
			local newlastrow = 2*`nvarsvertical' - 1;
			local newlastrow1 = `newlastrow' + 1;
			local newlastrow2 = `newlastrow' + 2;
			
			local J = 2;					// Start to process `tempvarvertical2'
			while `J'<`lastrow' 
				{;
				local K = `J' + 1;
				local I = 3;				// Starting row to process
				while `I'<=`newlastrow' 
					{;
					quiet replace `tempvarvertical`J'' = `tempvarvertical`K''[`I'] in `I';
					quiet replace `tempvarvertical1' = "" in `I';
					local I = `I' + 2;
					};
				local J = `J' + 2;
				};

			* Drop unused variables;
			local varsdrop;
			forvalues X = 1/`lastrow'
				{;
				if `tempvarvertical`X''[1]==""
					{;
					local varsdrop "`varsdrop' `X'";
					};
				};    

			foreach Y of local varsdrop
				{;
				drop `tempvarvertical`Y'';
				};
			* Add notes;	
			quiet replace `tempvarvertical1' = "`note1'" in `newlastrow1';
     		if "`mtest'" != "" 
     			{;
   			quiet replace `tempvarvertical1' = "`note2'" in `newlastrow2';
     			};

     		outsheet `tempvarvertical1' - `tempvarvertical`V'' `using' in 1/`newlastrow2', nonames replace;     		
     		};

     	};
   * Case 2: Only CI specified;
   if ("`sd'"=="" & "`se'"=="") & "`ci'"!="" 
    	{;
     	* loop over the categories of -by- (1..nby) and -total- (nby+1> );
     	local nbyt = `nby' + ("`total'" == "");
     	
     	forvalues k = 1/`nvars' 
     		{;
     		if "`labby'"!="" 
     			{;
     			quiet replace `varlab' = "`labby'" in 1;
     			};
     		else 
     			{;
     			quiet replace `varlab' = "`by'" in 1;
     			};
     			     			
     		if "`labtempvar`k''"!="" 
     			{;
     			quiet replace `tempvar`k'' = "`labtempvar`k''" in 1;
     			};
     		else 
     			{;
     			quiet replace `tempvar`k'' = "`var`k''" in 1;
     			};
     			     		
     		forvalues j = 1/`nbyt' 
     			{;
     			local x = 0;
     			local y = 2*`j'-`x';
     			while `x' >=-1 
     				{;
     				quiet replace `tempvar`k'' = string(`m`j'`k'', "%12.`bdec'f") + "`astrix`j'`k''" in `y';
     				quiet replace `varlab' = "`lab`j''" in `y';
     				local x = `x' - 1;
     				local y = `y'+1;
     				quiet replace `tempvar`k'' = "`lbrack'" + string(`lb`j'`k'', "%12.`bdec'f") + "`smcomma'"
     														 + string(`ub`j'`k'', "%12.`bdec'f") + "`rbrack'" in `y';
     				local x = `x' - 1;
     				};
     			};
     		};
     	local N = 2*`nbyt' + 2;
     	local lastrow = `N' - 1;
     	
     	quiet replace `varlab' = "`level'% Confidence intervals in `cibrack'" in `N';
     	if "`mtest'"!="" 
   		{;
   		local N = `N' + 1;
   		if "`mtprob'"!=""
   			{;
   			quiet replace `varlab' = "P-values for mean-difference test in brackets after means" in `N';
   			};
   		if "`mtse'"!=""
   			{;
   			quiet replace `varlab' = "SE for mean-difference test in brackets after means" in `N';
   			};
   		if "`mtprob'"==""&"`mtse'"==""
   			{;
   			quiet replace `varlab' = "* significant at 10%; ** significant at 5%; *** significant at 1%" in `N';
   			};
   		};
   	if "`vertical'" == ""
   		{;
	     	outsheet `varlab' `tempvar1' - `tempvar`nvars'' `using' in 1/`N', nonames replace;
	     	};
	   else 
	   	{;
     		local V = 1;
     		foreach Vvar of varlist `varlab' `tempvar1' - `tempvar`nvars''
     			{;
     			tempvar Tempvar`V';
     			quiet gen `Tempvar`V'' = `Vvar';
     			local V = `V' + 1;
     			};
			
     		local V = `V' - 1;
			
     		local nvarsvertical = `V';					/// # of columns
     		local Nver = `V' + 1;
     		local nobsvertical = `lastrow';
     		* Expose observations and variables;
     		quiet forval v = 1/`nobsvertical' 
     			{;
     			tempvar tempvarvertical`v';
     			gen `tempvarvertical`v'' = "";
     			local U = 1;
     			foreach u of varlist `Tempvar1' - `Tempvar`V'' 
     				{;
     				replace `tempvarvertical`v'' = `u'[`v'] in `U';
     				local U = `U' + 1;
     				};
     			};
     		local V = `nobsvertical' - 1;				// New last column	
			local lastrow1 = `lastrow' + 1;
			local note1 = `varlab'[`lastrow1'];
     		if "`mtest'" != "" 
     			{;
     			local lastrow2 = `lastrow' + 2;
     			local note2 = `varlab'[`lastrow2'];
     			};

     		* Duplicate the observations which will be exported to process the table;
     		preserve;
     		tempvar id;
     		gen `id' = _n;
     		quiet expand 2 in 1/`nvarsvertical';
     		sort `id';
			quiet drop in 2;
			local newlastrow = 2*`nvarsvertical' - 1;
			local newlastrow1 = `newlastrow' + 1;
			local newlastrow2 = `newlastrow' + 2;
			
			local J = 2;					// Start to process `tempvarvertical2'
			while `J'<`lastrow' 
				{;
				local K = `J' + 1;
				local I = 3;				// Starting row to process
				while `I'<=`newlastrow' 
					{;
					quiet replace `tempvarvertical`J'' = `tempvarvertical`K''[`I'] in `I';
					quiet replace `tempvarvertical1' = "" in `I';
					local I = `I' + 2;
					};
				local J = `J' + 2;
				};

			* Drop unused variables;
			local varsdrop;
			forvalues X = 1/`lastrow'
				{;
				if `tempvarvertical`X''[1]==""
					{;
					local varsdrop "`varsdrop' `X'";
					};
				};    

			foreach Y of local varsdrop
				{;
				drop `tempvarvertical`Y'';
				};
			* Add notes;	
			quiet replace `tempvarvertical1' = "`note1'" in `newlastrow1';
     		if "`mtest'" != "" 
     			{;
   			quiet replace `tempvarvertical1' = "`note2'" in `newlastrow2';
     			};

     		outsheet `tempvarvertical1' - `tempvarvertical`V'' `using' in 1/`newlastrow2', nonames replace;     		
	   	};
     	};
     	
   * Case 3: Both SD and CI specified;
 	if ("`sd'"!="" | "`se'"!="") & "`ci'"!="" 
 		{;
 		* loop over the categories of -by- (1..nby) and -total- (nby+1> );
 		local nbyt = `nby' + ("`total'" == "");
 		forvalues k = 1/`nvars' 
 			{;
 			if "`labby'"!="" 
 				{;
 				quiet replace `varlab' = "`labby'" in 1;
 				};
 			else 
 				{;
 				quiet replace `varlab' = "`by'" in 1;
 				};
 				 				
     		if "`labtempvar`k''"!="" 
     			{;
     			quiet replace `tempvar`k'' = "`labtempvar`k''" in 1;
     			};
     		else 
     			{;
     			quiet replace `tempvar`k'' = "`var`k''" in 1;
     			};
     		     		
     	forvalues j = 1/`nbyt' 
     		{;
     		local x = 1;
     		local y = 3*`j'-`x';
     		while `x' >=-1 
     			{;
     			quiet replace `tempvar`k'' = string(`m`j'`k'', "%12.`bdec'f") + "`astrix`j'`k''" in `y';
     			local x = `x' - 1;
     			local y = `y'+1;
     			quiet replace `tempvar`k'' = "`lparen'" + string(`sd`j'`k'', "%12.`bdec'f") + "`rparen'" in `y';
     			quiet replace `varlab' = "`lab`j''" in `y';
     			local x = `x' - 1;
     			local y = `y'+1;
     			quiet replace `tempvar`k'' = "`lbrack'" + string(`lb`j'`k'', "%12.`bdec'f") + "`smcomma'" 
     													+ string(`ub`j'`k'', "%12.`bdec'f") + "`rbrack'" in `y';
     			local x = `x' - 1;
     			};
   		};
   	};
   local N = 3*`nbyt' + 2;
   local lastrow = `N' - 1;

   if "`se'"=="" 
     		{;
     		quiet replace `varlab' = "Standard deviations in `sdparen'" in `N';
     		};
     	else 
     		{;
     		quiet replace `varlab' = "Standard errors of means in `sdparen'" in `N';
     		};
   local N = `N' + 1;
   quiet replace `varlab' = "`level'% Confidence intervals in `cibrack'" in `N';
   if "`mtest'"!="" 
   	{;
   	local N = `N' + 1;
   		if "`mtprob'"!=""
   			{;
   			quiet replace `varlab' = "P-values for mean-difference test in brackets after means" in `N';
   			};
   		if "`mtse'"!=""
   			{;
   			quiet replace `varlab' = "SE for mean-difference test in brackets after means" in `N';
   			};
   		if "`mtprob'"==""&"`mtse'"==""
   			{;
   			quiet replace `varlab' = "* significant at 10%; ** significant at 5%; *** significant at 1%" in `N';
   			};
   	};
   if "`vertical'" == "" 
   	{;
   	outsheet `varlab' `tempvar1' - `tempvar`nvars'' `using' in 1/`N', nonames replace;
   	};
   else 
   	{;
     		local V = 1;
     		foreach Vvar of varlist `varlab' `tempvar1' - `tempvar`nvars''
     			{;
     			tempvar Tempvar`V';
     			quiet gen `Tempvar`V'' = `Vvar';
     			local V = `V' + 1;
     			};
			
     		local V = `V' - 1;
			
     		local nvarsvertical = `V';					/// # of columns
     		local Nver = `V' + 1;
     		local nobsvertical = `lastrow';
     		* Expose observations and variables;
     		quiet forval v = 1/`nobsvertical' 
     			{;
     			tempvar tempvarvertical`v';
     			gen `tempvarvertical`v'' = "";
     			local U = 1;
     			foreach u of varlist `Tempvar1' - `Tempvar`V'' 
     				{;
     				replace `tempvarvertical`v'' = `u'[`v'] in `U';
     				local U = `U' + 1;
     				};
     			};
     		local V = `nobsvertical' - 2;				// New last column	
			local lastrow1 = `lastrow' + 1;
			local note1 = `varlab'[`lastrow1'];
			local lastrow2 = `lastrow' + 2;
			local note2 = `varlab'[`lastrow2'];
     		if "`mtest'" != "" 
     			{;
     			local lastrow3 = `lastrow' + 3;
     			local note3 = `varlab'[`lastrow3'];
     			};

     		* Duplicate the observations which will be exported to process the table;
     		preserve;
     		tempvar id;
     		gen `id' = _n;
     		quiet expand 3 in 1/`nvarsvertical';
     		sort `id';
			quiet drop in 2/3;
			local newlastrow = 3*`nvarsvertical' - 2;
			local newlastrow1 = `newlastrow' + 1;
			local newlastrow2 = `newlastrow' + 2;
			local newlastrow3 = `newlastrow' + 3;
			
			local J = 2;					// Start to process `tempvarvertical2'
			while `J'<`lastrow' 
				{;
				local K = `J' + 1;
				local L = `J' + 2;
				local I = 3;				// Starting row to process
				quiet replace `tempvarvertical`J'' = `tempvarvertical`K''[1] in 1;
				quiet replace `tempvarvertical`K'' = "" in 1;
				
				while `I'<=`newlastrow' 
					{;
					local M = `I' + 1;
					local N = `I' - 1;
					quiet replace `tempvarvertical`J'' = `tempvarvertical`K''[`I'] in `I';
					quiet replace `tempvarvertical`J'' = `tempvarvertical`L''[`M'] in `M';
					quiet replace `tempvarvertical1' = "" in `N';
					quiet replace `tempvarvertical1' = "" in `M';
					local I = `I' + 3;
					};
				local J = `J' + 3;
				};

			* Drop unused variables;
			local varsdrop;
			forvalues X = 1/`lastrow'
				{;
				if `tempvarvertical`X''[1]==""
					{;
					local varsdrop "`varsdrop' `X'";
					};
				};    

			foreach Y of local varsdrop
				{;
				drop `tempvarvertical`Y'';
				};
			* Add notes;	
			quiet replace `tempvarvertical1' = "`note1'" in `newlastrow1';
			quiet replace `tempvarvertical1' = "`note2'" in `newlastrow2';
     		if "`mtest'" != "" 
     			{;
   			quiet replace `tempvarvertical1' = "`note3'" in `newlastrow3';
     			};
     		outsheet `tempvarvertical1' - `tempvarvertical`V'' `using' in 1/`newlastrow3', nonames replace;     		
   	};
   };
   
end;
exit;

