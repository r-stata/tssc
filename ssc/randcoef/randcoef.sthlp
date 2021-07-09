{smcl}
{* *! version 1.0 06DEC2016}{...}

{hline}
help for {hi:randcoef}{right:Barriga Cabanillas, Michler, Michuda, Tjernström}
{hline}

{title:Title}

{phang}
{bf:randcoef} {hline 2} Estimates CRE and CRC models following 
{browse "http://onlinelibrary.wiley.com/doi/10.3982/ECTA7749/abstract" : Tavneet Suri's paper: "Selection and Comparative Advantage in Technology Adoption," Econometrica, Vol. 79, No. 1 (January, 2011), 159-209.} 

{marker syntax}{...}
{title:Syntax}

{pstd}
Basic syntax

{p 8 14 2}
{cmdab:randcoef:}
{cmd:(}depvar1 depvar2 depvar3...{cmd:)} [{it:if}] 
{cmd:,} {it:choice(indepvar1 indepvar2 indepvar3 ...)}
[{it:options}]

{pstd}

{marker desc}{...}
{title:Description}
{p 40 20 2} {p_end}

{pstd}
{cmd:randcoef}
estimates both the CRE (Correlated Random Effects) {it:(default)} and the CRC (Correlated Random Coefficients) models allowing several weighting matrices for 
the latter. The command uses the number of dependent variables to know how many years the CRE 
or CRC model contains and use the appropriate restriction matrix.
The command's syntax requires the order of both the outcome and choice variables to be set chronologically. This is important since the order in the regressions must match the restriction 
matrices pre-wired in the command. This is true, except for the CRE model where the user can specify it {it:{help randcoef##rest:Restrictions}}. 
The set up of the CRC model requieres interactions between the choice variables. These interactions are automatically created by the command.
For a more thorough overview of the theory behind the estimation, please read {browse "http://onlinelibrary.wiley.com/doi/10.3982/ECTA7749/abstract" :Suri (2011)}. 

{p2colreset}{...}
{p 4 6 2}
{cmd:by} is not allowed.{p_end}
{p 4 6 2}
{cmd:fweights} are not allowed

{synoptline}
{marker options}{...}
{title:Options}

{synoptset 26 tabbed}{...}
{dlgtab:Required options}

{synopt:{opt choice: (varlist)}} It must contain the variable of interest organized in chronological order. In the case of the CRC model, interactions SHOULD NOT be included since they are created 
automatically by the program. These variables must defined as dummies.{p_end}

{synoptset 26 tabbed}{...}
{dlgtab:General options}

{synopt:{opt met:hod(CRE, CRC)}}Determines the method to be used: CRE {it:(default)} or CRC. {p_end}
{synopt:{opt controls: (varlist)}}Allows adding controls to the underlying SUR regression.{p_end}
{synopt:{opt showreg: }}By default the program does not show the SUR regression's output for faster computation and to avoid displaying innecesary information.
 This option allows the user to see the SUREG output. {p_end}


{synoptset 26 tabbed}{...}
{dlgtab:CRE model options}

{pstd}

{synopt:{opt mat:rix}} A matrix containing the problem's restrictions can be specified in case the 
user wants to input the restriction matrix manually (perhaps for changing the order of coefficients). Note that the 
{ul:restriction's order is important since it must match the order} in which the parameters of interest 
are inputted in the SUR regressions.{p_end}

{dlgtab:CRC model options}

{pstd} For this model the matrix option is not allowed. The restriction matrices are preprogrammed for up to five year panels and 
are automatically chosen depending on the number of dependent variables. Additionally, the CRC model involves the creation of interactions 
between the adoption variables, these interactions  are created automatically within the program. {it:{help randcoef##examples:See examples}}.
{p_end}

{synopt:{opt endo:genous(varlist)}}Allows for endogenous variables to be added to the 
CRC estimation. This must be a dummy variable. The interactions needed between the choice variables and the endogenous variables are
automatically created.{p_end}

{synopt:{opt keep: }} During the estimation of the CRC model the interactions needed for the choice variables, as well as the endogenous variables 
(if specified) are deleted after the program is run. This option allows preserving those interactions after the estimation. 
Note that if specified, running the command several times requires dropping those variables{p_end}

{synopt:{opt weight:ing(string)}}Chooses the weighting matrix to be used. 

{pmore}
{cmd:OMD} {it:(default)} Optimal Minumum Distance: the inverse of the variance-covariance matrix of the reduced form
estimates. {p_end}
{pmore}
{cmd:EWMD} Equally Weighted Minimum Distance: Uses the identity matrix. {p_end}
{pmore}
{cmd:DWMD} Diagonally Weighted Minimum Distance: Uses the optimal matrix, but with zeroes
on the off-diagonals. {p_end}

{synoptline}

{marker examples}{...}
{title:Examples}

{p 8 12}{stata "randcoef_examples example_01" :. randcoef lny2008 lny2010 , choice(h_2008 h_2010) meth(CRE) (click to run)}{p_end}
{p 8 12}Estimates the CRE model for a two year panel.{p_end}
{p 10 10} Note that the magnitudes of the parameters of the "structural" parameters are: {bf:beta} = 2, {bf:lambda_1} = 4, {bf:lambda_2} = 3


{p 8 12}{stata "randcoef_examples example_02" :. randcoef lny2008 lny2010, choice(h_2008 h_2010) meth(CRC)  weighting(DWMD) (click to run)}{p_end}
{p 8 12} Estimates the CRC model for a two year panel. In this case, the interactions for the choice variable 
are automatically created. Given that {opt keep} is not used, these interactions are not available after the estimation. The  weighting of the OMD used 
the Diagonally Weighted Minimum Distance. 
Note that the magnitudes of the parameters of the "structural" parameters are: {bf:beta} = 2, {bf:lambda_1} = 4, {bf:lambda_2} = 3, {bf:lambda_3} = 2, {bf:phi} = 2

{p 8 12}{stata "randcoef_examples example_03" :. randcoef lny2008 lny2010, choice(h_2008 h_2010) endogenous(e_2008 e_2010) meth(CRC) (click to run)}{p_end}
{p 8 12} Estimates the CRC model for a two year panel and an extra endogenous variable. The weighting of the OMD used the inverse of the variance-covariance
matrix of the reduced form estimates.
Note that the magnitudes of the parameters of the "structural" parameters are: {bf:beta} = 2, {bf:lambda_1} = 4, {bf:lambda_2} = 3,
{bf:lambda_3} = 2, {bf:lambda_3} = 2, {bf:lambda_3} = 2, {bf:lambda_3} = 2, {bf:lambda_3} = 2, {bf:lambda_3} = 2, 
{bf:lambda_4} = 6, {bf:lambda_5} = 7, {bf:lambda_6} = 8, {bf:lambda_7} = 9, {bf:lambda_8} = 11, {bf:lambda_9} = 12, {bf:lambda_10} = 13, {bf:lambda_11} = 14, 
{bf:phi} = 2 and {bf:rho} = 1

{marker rest}{...}
{title:Restrictions}

{phang}The following represents an example of the restrictions the CRC model uses on the Optimal Minimun Distance estimation. This is performed in mata. It is extremely important that the names of the 
functions: {it:(derivat33)} and {it:(myeval)}; as well as the  name of the vectors:  {it:(gtheta)} ,  {it:(theta)}  and  {it:(derivat33)} are not changed. However, their dimensions 
can be adapted to the needs of the model estimated. In this case, the command uses a DWMD weighting matrix, and we have chosen to keep the generated interactions after
estimation.{p_end}

//-------------------------------- Mata code ------------------------
	
version 10
mata:

	mata clear
	mata drop *()
	mata set matalnum off
	mata set mataoptimize on
	mata set matafavor speed

	// Explicitly set dimensions for the number of colums on 
	// the INITIAL VALUES ON THE theta_0 vector for the maximization
	// Line 341 randcoef do file
	
	n_col = 5

	
	// Defines the funtion to take derivatices from. Notice that it
	// is the same as in the previous function
	
	void myeval(todo, theta , param , V,  omd , S , H)
	{
		real colvector  diff

		gtheta=J(1,n_col_gtheta,1)
		
		gtheta[1]=theta[1]*(1+theta[5])+theta[4]+theta[5]*(-0.7827869*theta[1]-0.8970037*theta[2]-0.7494407*theta[3])
		gtheta[2]=theta[2]
		gtheta[3]=theta[3]*(1+theta[5])+(theta[5]*theta[2])
		gtheta[4]=theta[1]
		gtheta[5]=theta[2]*(1+theta[5])+theta[4]+theta[5]*(-0.7827869*theta[1,1]-0.8970037*theta[2]-0.7494407*theta[3])
		gtheta[6]=theta[3]*(1+theta[5])+(theta[5]*theta[1])
		
		diff = param-gtheta'
		omd= (diff)'*V*(diff)		
	
	}
	
	void derivat33( theta , gtheta )
	{
		gtheta = J(1,n_col_gtheta,.)
		
		gtheta[1]=theta[1]*(1+theta[5])+theta[4]+theta[5]*(-0.7827869*theta[1]-0.8970037*theta[2]-0.7494407*theta[3])
		gtheta[2]=theta[2]
		gtheta[3]=theta[3]*(1+theta[5])+(theta[5]*theta[2])
		gtheta[4]=theta[1]
		gtheta[5]=theta[2]*(1+theta[5])+theta[4]+theta[5]*(-0.7827869*theta[1,1]-0.8970037*theta[2]-0.7494407*theta[3])
		gtheta[6]=theta[3]*(1+theta[5])+(theta[5]*theta[1])
		
	}	

end		

// -------------------------------- end Mata code ------------------------

{p 8 12} (Go up to {it:{help randcoef##syntax:Syntax}} )


{title:Authors}

{p 5}Oscar Barriga Cabanillas{p_end}
{p 5}obarriga@ucdavis.edu{p_end}
{p 5}Jeffrey D. Michler{p_end}
{p 5}jmichler@illinois.edu{p_end}
{p 5}Aleksandr Michuda {p_end}
{p 5}amichuda@ucdavis.edu{p_end}
{p 5}Emilia Tjernström{p_end}
{p 5}tjernstroem@wisc.edu{p_end}
