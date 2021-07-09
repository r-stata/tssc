* This program takes random draws of the estimated parameters and recomputes WTP measures
*! Author PWJ 
program wtpkrinsky, rclass
	version 9.2
     	syntax varlist, Bname(name) Vname(name) MODel(string) [MYMean(name) EXPOnential]	
	tempname z
   	mata: takedraw()  
      
	* Now use the new parameter vector z to compute WTP measures
 	wtpmeasure `varlist', bvec(`z') mod(`model') mym(`mymean') `exponential' 		
	if "`exponential'"=="" ret sca meanwtp=r(meanwtp)
	else {
		ret sca medianwtp=r(medianwtp)		
		ret sca meanwtp=r(meanwtp)		
	} 
end
version 9.2
mata: 
void takedraw()
{
	real matrix b, v, Z	
	b = st_matrix(st_local("bname"))
	v = st_matrix(st_local("vname"))
	Z = (b' :+ cholesky(v)*invnormal(uniform(cols(b),1)))'  // Take a random draw from multivariate normal distribution
	st_matrix(st_local("z"),Z)
}
end

