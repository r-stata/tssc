*! xtbalance2
*! v. 1.0 - 29.01.2021
*! Jan Ditzen - jan.ditzen@unibz.it - www.jan.ditzen.net


capture program drop xtbalance2
program define xtbalance2, rclass
	syntax [varlist(ts)] [if] [in] , GENerate(string) [Optimisation(string)]
		qui {
			version 14

			local newvar "`generate'"

			tempvar touse
			marksample touse , strok

/*
			if "`varlist'" == "" {
				gen `touse' = 1
				markout touse * 
			}			
			else {
				marksample touse 
			}
*/
			if "`optimisation'" == "T" | "`optimisation'"=="" {
				local max = 0
			}
			else if "`optimisation'" == "N" {
				local max = 1
			}
			else if "`optimisation'" == "NT" {
				local max = -1
			}
			else {
				local max = 0
			}

			tempname varnum idvar tvar

			_xt
			egen `idvar' = group(`r(ivar)')  if `touse'
			_xt
			egen `tvar' = group(`r(tvar)')  if `touse'

			if `max' > -1 {
				mata BalancePanel("`idvar' `tvar'","`touse'","`newvar'",`max',`varnum'=.)
			}
			else {
				tempname times units
				mata BalancePanel("`idvar' `tvar'","`touse'","`times'",0,`varnum'=.)
				sum `times'
				local TT = r(sum)

				mata BalancePanel("`idvar' `tvar'","`touse'","`units'",1,`varnum'=.)
				sum `units'
				local NN = r(sum)

				if `NN' >= `TT' {
					rename (`units'*) (`newvar'*)
				}
				else {
					rename (`times'*) (`newvar'*)
				}

			}

			foreach var of varlist `newvar'* {
				replace `var' = 0 if `var' == .
			}
			
			mata st_numscalar("NumMax",`varnum')
			return scalar NumMax = NumMax
		}


end


cap mata mata  drop BalancePanel()
mata:
	function BalancePanel(	string scalar idtname, 			///
						string scalar tousename, 		///
						string scalar tousenewname,		/// name of new variable
						real scalar max,				/// which dimension to maximasize, zero for T (default), one for id 
						real scalar varNum)
	{

		idt = st_data(.,idtname,tousename)

		///idt_s = idt

		ID_uniq = uniqrows(idt[.,1])
		t_uniq = uniqrows(idt[.,2]) 

		N = rows(ID_uniq)
		T = rows(t_uniq)

		(N,T)
		mat = J(T,N,0)

		/// creates matrix with 1 and 0s for observations
		i = 1
		while (i<=N) {
			i
			idt[selectindex(idt[.,1]:==ID_uniq[i]),2]
			tsel = idt[selectindex(idt[.,1]:==ID_uniq[i]),2]
			mat[tsel,i] = J(rows(tsel),1,1)
			i++
		}
	 	
		if (max == 1) {
			mat = mat'
			N = cols(mat)
			T = rows(mat)
		}

	 	mat = mm_colrunsum(mat):*(mat:==1)
	 	
	 	/// mat now has number of observations for each column. next step is to identify
	 	/// number which occurs most in each row
	 	runsum = 0
	 	freq_m1 = 0

	 	/// matrix freq is: element, freq, runnsum, touse
	 	freq = J(T,3,0)
	 	i = 1
	 	while (i<=T) {

	 		rowi = mat[i,.]'
	 		freqi = rowi,mm_freq2(rowi)
	 		maxi = max(freqi[.,2])	 		
	 		
	 		eli = freqi[selectindex(freqi[.,2]:==maxi),1]
	 		
	 		/// only use first element
	 		eli = eli[1,1]
	 		
	 		if (maxi >= freq_m1 ) {
	 			runsum = runsum + maxi 			
	 		}
	 		else {
	 			/// case freqi < freq_m1, restart runsum
	 			runsum = maxi 			
	 		}

	 		freq_m1 = maxi
	 		freq[i,.] = eli,maxi,runsum

	 		i++
	 	}
	 	
	 	/// now loop back from start element and set touse column to one
	 	maxs = selectindex(freq[.,3]:==max(freq[.,3]))
	 	freq = J(1,3,0) \ freq
	 		 	
	 	varNum = rows(maxs)
	 	s = 1
	 	while (s<=varNum) {
	 		returnMat = SelectMat(freq,mat,N,T,maxs[s]+1)
		 	"return mat"
			returnMat
		 	namei = tousenewname
		 	if (s>1) {
		 		namei = tousenewname:+"_":+strofreal(s)
		 	}	
		 	GenTouse(idt,tousename,namei,returnMat,max,N,T)
		 	s++
		 }
	}	
end

cap mata mata drop SelectMat()
mata:
	function SelectMat(real matrix freq, real matrix mat, real scalar N , real scalar T,real scalar i)
	{
		returnMat = J(T,N,0)
		rowl = J(1,N,1)
		while ( i>1 ) {
			i--			
			rowi = (mat[i,.]:==freq[i+1,1])			
			rowi = rowl :*rowi
			rowl = rowi
			returnMat[i,.]=rowi
		}
		return(returnMat)
	}

end

cap mata mata  drop GenTouse()
mata:
	function GenTouse(	real matrix idt,	 			///
						string scalar tousename,		///
						string scalar tousenewname,		///
						real matrix returnMat,			///
						real scalar max,				///
						real scalar N,					///
						real scalar T 					///
						)	
	{
	
		/// return data to new touse variable
	 	idx = st_addvar("double",tousenewname)

	 	real matrix tousenew	
	 	real matrix tousei 	
		st_view(tousenew,.,idx,tousename)

		index = panelsetup(idt,1)
		
		/// loop over columns
		if (max==0) {
			i = 1
			while (i<=N) {
				coli = returnMat[.,i]
				if (sum(coli) > 0) {
					coli = selectindex(coli:==1)
					panelsubview(tousei,tousenew,i,index)
					ti = panelsubmatrix(idt[.,2],i,index)
					coli2 = xtbalance_which2f(coli,ti)
					coli2 = coli2[selectindex(coli2:!=0)]
					tousei[coli2,1] = J(rows(coli2),1,1)
				
				}
				i++
			}
		}
		else {
			/// loop over rows (might have bug when!)
			i = 1
			while (i<=T) {
				coli = returnMat[i,.]
				if (sum(coli) > 0) {
					coli = selectindex(coli:==1)'
					panelsubview(tousei,tousenew,i,index)
					ti = panelsubmatrix(idt[.,2],i,index)
					coli2 = xtbalance_which2f(coli,ti)
					coli2 = coli2[selectindex(coli2:!=0)]
					tousei[coli2,1] = J(rows(coli2),1,1)
				
				}
				i++
			}
		}

	}
end


capture mata mata drop xtbalance_which2f()
mata:
	function xtbalance_which2f(source,search )
	{		
		real matrix output
		search_N = rows(search)
		output = J(search_N,1,0)
		source_N = rows(source)
	
		i = 1
		
		while (i<=search_N) {
			new_elvec = source:==search[i]	
			if (anyof(new_elvec,1)) {
				output[i]= xtbalance2_selectindex(new_elvec)
			}
			i++
		}
		return(output)
	}
end

capture mata mata drop xtbalance2_selectindex()
mata: 
	function xtbalance2_selectindex(a)
	{
		
			row = rows(a)
			col = cols(a)
			if (row==1) {
				output = J(1,0,.)
				j = 1
				while (j<=col) {
					if (a[1,j] != 0) {
						output = (output , j)
					}
					j++
				}		
			}
			if (col==1) {
				output = J(0,1,.)
				j = 1
				while (j<=row) {
					if (a[j,1] != 0) {
						output = (output \ j)
					}
					j++
				}		
			}

		return(output)
	}
end

