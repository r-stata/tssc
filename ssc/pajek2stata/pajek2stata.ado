*! Version 1.0		
* Rense Corten, April 2010


version 11
mata
real matrix function readpajeknet(string scalar fn)
{
	//TODO:
	// Allow for missing vertex numbers --> Ties2Mat may be more appropriate
	// Otherwise: make new function: real matrix function new(x*2 matrix, N vector)
	// Deal with multiple sets of arcs and edges
	
	real scalar N, MatStart, i, j,width
	real matrix M,Mend
	string matrix V
	rowvector thisline
	string scalar ln, line, line2, NetType, pos 
	
	
	//open file
	if(fileexists(fn)) fh = _fopen(fn, "r")
	else{
		errprintf("file "+fn+" not found \n")
		exit(601)
	}

	//read vertices part
		//Read first line in vertices part
	MatStart = 0
	ln = fget(fh)
	if (tokens(ln)[1,1]=="*Vertices")
	{
		N = strtoreal(tokens(ln)[1,2])
		if (N==.)
		{
			errprintf("Invalid Vertices definition \n")
			exit(3498)
		}
	}
	else
	{
		errprintf("Invalid Vertices definition \n")
		exit(3498)
	}
		
	//Find start of network part and determine type of data
	while ((line=fget(fh))!=J(0,0,"") & MatStart==0) {
		if (tokens(line)[1,1] == "*Matrix"){
			MatStart = 1
			NetType = "Matrix"
			pos = ftell(fh)
			M = J(N,N,.)		//M is a square matrix
		}
		else if(tokens(line)[1,1] == "*Arcs"){
			MatStart = 1
			NetType = "Arcs"
			pos = ftell(fh)
		}
		else if(tokens(line)[1,1] == "*Edges"){
			MatStart = 1
			NetType = "Edges"
			pos = ftell(fh)
		}
	}

	if(MatStart==0) {
		errprintf("Error: Network data not found") //If start of network part still not found, something is wrong
		exit(3498)
	}

	st_local("DataFormat",NetType)
	fseek(fh,pos,-1)
	if (NetType=="Arcs" | NetType == "Edges")	{	//create list type of matrix
		// find out how large m should be
		pos = ftell(fh) //remember current position
		j = 0
		while ((line2=fget(fh))!=J(0,0,"")){
			if(j==1) width= cols(tokens(subinstr(line,char(09)," ")))
			j++	 //count remaining lines in file
		}
		M = J(j,width,.)
	}

	//Read Matrix Part
	fseek(fh, pos, -1)	//return to previous position to continue reading the file
	i = 1
	while ((line=fget(fh))!=J(0,0,"")) {
		if (MatStart==1) 
		{
			thisline = strtoreal(tokens(subinstr(line,char(09)," ")))
			if(cols(thisline)!=cols(M)){
				errprintf("Error in line "+strofreal(i)+" of "+ NetType + " specification \n")
				exit(3498)
			}
			else 	M[i,.] = thisline
			i++
		}
 	}
	

	fclose(fh)

	Mend = M
	return(Mend)
}
end


version 11
mata
string matrix function readpajekvars(string scalar fn)
{
	real scalar N, MatStart, i
	string scalar ln
	string matrix V

	
	//open file
	fh = fopen(fn, "r")

	//read vertices part
		//Read first line in vertices part
		MatStart = 0
		ln = fget(fh)
		if (tokens(ln)[1,1]=="*Vertices")
		{
			N = strtoreal(tokens(ln)[1,2])
			if (N==.)
			{
				errprintf("Invalid Vertices definition \n")
				exit(3498)
			}

		}
		else
		{
				errprintf("Invalid Vertices definition \n")
				exit(3498)
		}

		j = 1
		while (MatStart==0 ) {
			line=fget(fh)

			if(j==1) { //set the width of the output matrix based on what we find in the first line
				V = J(N,cols(tokens(subinstr(line,char(09)," "))),"")
			}

			if (substr(strrtrim(tokens(line)[1,1]),1,1) == "*"){
				MatStart = 1
			}
			if (MatStart==0) V[j,.] = tokens(subinstr(line,char(09)," "))
			j++
			
		}
		return(V)
	fclose(fh)
}

end
	

program define pajek2stata
	syntax using/, name(string) [clear replace] 
	version 11
	tempname pvars
	tempname vi
	tempname netmat
	
	//Check if data in memory
	if ("`clear'" == "clear") clear
	qui count
	if `r(N)'	>0 {
		//dis as error "Must start with an empty dataset " 
		error(4)
	}

	//Check if name is not already in use in mata
	
	if("`replace'"==""){
		capt mata: eltype(`name')
		if (_rc!=3499){
			dis as error "`name' already in use"
			exit
		}
	}

	mata: `netmat' = readpajeknet(`"`using'"')
	mata: `pvars' = readpajekvars(`"`using'"')
	mata: st_numscalar("r(numvars)", cols(`pvars'))
	mata: st_numscalar("r(N)",rows(`pvars'))
	mata: `name'= `netmat'
	
	
	qui set obs `r(N)'
	forval x = 1(1)`r(numvars)'{
		mata: `vi'= st_addvar("str"+strofreal(max(strlen(`pvars'[.,`x']))),"var`x'")
		mata: st_sstore(.,("var`x'"),`pvars'[.,`x'])
	}
	label var var1 "Vertices"

	
	mata: st_numscalar("r(mC)",cols(`name'))
	mata: st_numscalar("r(mR)",rows(`name'))
	
	dis "{txt}{hline 50}"
	dis as text "Vertices:", as res "{tab}{tab}{tab}"`r(N)'
	dis as text "Network matrix format:", as res "{tab}{tab}" "`DataFormat'"
	dis as text "Network matrix shape (r x c):", as res "{tab}" `r(mR)' " X " `r(mC)' 
	dis "{txt}{hline 50}"
	mata: mata drop `vi' `pvars' `netmat' //clean up
	

end


