*! version 1.2
*! Rense Corten, Utrecht University, Aug 2010

* Version history:
* 1.1 (June 2010): 
*		- Removed obsolete code for Labels(string) and associated error message
*		- Removed unnecessary dropping of functions
*		- Added declarations
*		- Removed obsolete declarations
*		- Improved error messages
*	1.2 (August 2010)
*		- Corrected problem with drawing of arrows. New function: NumElist()
*		- Removed obsolete function mat2elist()


program define netplot
	version 10
	syntax varlist( max=2 min=2 ) [if] [in] [, ///
		Type(string) Label Arrows Iterations(integer 1000)]

	tokenize `varlist'
	local n1 `1'
	local n2 `2'
	
	marksample touse, novarlist
	qui replace `touse' = -`touse' 
	sort `touse' 
	qui count if `touse' 
	local nobs = r(N) // number of cases to process
	if `nobs' == 0 {
		exit 2000
	}

	qui count if missing(`n1')
	local miss1 = r(N)
	qui count if missing(`n2')
	local miss2 = r(N)

	if (`miss1'==`nobs' & `miss2'==`nobs'){ // If only missings on both vars 
		dis as err "no vertices"
		exit 2000
	}
	

	if("`type'"=="") {
		local plottype "mds"
	}	
	else {
		local plottype `"`type'"'
		local len = strlen(`"`plottype'"') 
		if `"`plottype'"' == substr("mds", 1, `len') {
			local plottype "mds" 
		}
		else if `"`plottype'"' == substr("circle", 1, `len') {
			local plottype "circle"
		}
		else {		
			dis as error "invalid layout type() '`plottype'"
			exit 198
		}
	}	
	
	local dolabel  = ("`label'" !="")
	local doarrows = ("`arrows'"!="")
	mata: netplot("`n1'","`n2'",`nobs', "`plottype'",`dolabel',`doarrows',`iterations')
end


mata:
void function DrawLayout(
	real matrix Coord, real matrix List ,| transmorphic colvector vLabel, real scalar Arrows)
{
	real matrix 	TC
	real scalar 	i , nadd
	string scalar 	vAdded, nx, ny, sx, sy, ex, ey,labels,labelopt, arrowopt,plottype
	
	//generate tie coordinates
	TC = J(rows(List),4,.)
	for(i=1;i<=rows(TC);i++){
		TC[i,1]= Coord[List[i,1],1] //start x of tie i
		TC[i,2] = Coord[List[i,1],2] //start y of tie i
		TC[i,3] = Coord[List[i,2],1] //end x of tie i
		TC[i,4] = Coord[List[i,2],2] //end y of tie i
	}

	//save temp variables in stata dataset

	//add obs if necessary
	nadd=max((rows(TC), rows(Coord)))-st_nobs()
	if (nadd>0) {
		st_addobs(nadd)
		//add added-identifier for cleaning up afterwards
		(void) st_addvar("double", vAdded=st_tempname())
		stata("qui replace "+vAdded+" = _n> "+strofreal(st_nobs()-nadd))
	}
			

	//node coordinates (2 vars)
	(void) st_addvar("double", nx=st_tempname())
	(void) st_addvar("double", ny=st_tempname())
	st_store((1::rows(Coord)),(nx, ny),Coord[.,.])

	//tie coordinates (4 vars)
	(void) st_addvar("double", sx=st_tempname())
	(void) st_addvar("double", sy=st_tempname())
	(void) st_addvar("double", ex=st_tempname())
	(void) st_addvar("double", ey=st_tempname())
			
	if (rows(TC)>0) {
		st_store((1::rows(TC)),(sx, sy,ex,ey),TC[.,.])
	}
		
	labels = ""
	if (rows(vLabel)>0) {
		if (eltype(vLabel)=="real") {
			(void) st_addvar("double", labels=st_tempname())
			st_store((1::rows(vLabel)),(labels),vLabel[.])
		}
		else if (eltype(vLabel)=="string") {
			(void) st_addvar("str"+strofreal(max(strlen(vLabel))), labels=st_tempname())
			st_sstore((1::rows(vLabel)),(labels),vLabel[.])
		}
		else {
			errprintf("Label vector cannot be " + eltype(vLabel))
			exit()
		}
			
		labelopt = "mlabel(" + labels + ")"
	}

	if (Arrows==1) {
		plottype = "arrow"	
		arrowopt = " , barbsize(1) "
	}
	else {
		plottype = "spike"	
		arrowopt = ""
	}

	// graph command

	stata(  "twoway pc" + 
		plottype + " " +
		sy + " " + 
		sx + " " +
		ey + " " +  
		ex + arrowopt + " || " + 
		" scatter " + 
		ny + " " + nx + 
		", aspect(1) legend(off)  ylabel(, nogrid)  yscale(off) xscale(off)" + 
		labelopt )

	//clean up
	
	//delete variables (needed if temvars used?)
	if(nadd>0) {
		//delete added obs
		stata(	"qui drop if " + vAdded)
		stata(	"qui drop " + 
			vAdded + " " + " " + 
			nx + " " + 
			ny + " " + 
			sx + " " + 
			sy + " " + 
			ex + " " + 
			ey + " " + 
			labels) 
	}
}	
end


//distance()
//Calculates the distance matrix in a discrete graph
//Distances between unconnecte nodes are indicated by "0"
mata:
real matrix function distance(real matrix Net, | real scalar MaxDist)
{
	real scalar 	ready,counter, maxcounter
	real matrix 	N1,Dist,Ntemp
	
	if (args()==2) 
		maxcounter = MaxDist
	else 
		maxcounter = rows(Net)-1
	
	N1 = Net
	Dist = Net	//Distance 1 matrix
	counter = 1
	ready = 0
	while (ready==0 & counter<maxcounter) {
		counter = counter + 1
		N1=(N1*Net)
		Ntemp = (Dist:==0):*(N1:>0):*counter
		if (sum(Ntemp)==0) ready = 1
		Dist = Dist:+Ntemp
	}
	return(Dist)
}
end

mata:
real matrix function circlelayout(real scalar N)
{
	real colvector 	V
	real matrix 	Coord
	real scalar 	xmax, ymax

	xmax = 100
	ymax = 100
	V= (1::N)
	Coord=J(N,2,.)

	Coord[.,1] = 0.5*xmax :+ 0.5:*xmax:*cos(V[.]:*(2*pi()/N))	
	Coord[.,2] = 0.5*ymax :+ 0.5:*ymax:*sin(V[.]:*(2*pi()/N))

	return(Coord)
}
end


mata:
real matrix function mmdslayout(real matrix G, real scalar MaxIt)
{
	real matrix 	D, sCoord, Coord
	string scalar 	dMat, sMat
	real scalar ScaleFactor, rc 
	
	Coord  =  J(rows(G),2,.)
	sCoord = jumble(circlelayout(rows(G))) //circle coordinates as starting positions for mds

	D = distance(G) //compute distances
	_diag(D,0)
	
	st_matrix(dMat=st_tempname(),D) 	//Distance mat to stata under tempname
	st_matrix(sMat=st_tempname(),sCoord) 	//Distance mat to stata under tempname

	// compute MDS coordinates in stata
	rc = _stata(  "qui mdsmat " + 
		dMat + 
		", noplot method(modern) initialize(from(" + 
		sMat + 
		")) iterate("+strofreal(MaxIt)+")" )
 	
	if (rc!=0) {
		errprintf("mds computation failed \n")
		exit(rc)
	}

	Coord = st_matrix("e(Y)") 	//pull coordinates back into mata
	
	// put isolates back on their circle coordinate
	
	ScaleFactor = max(abs(Coord))/50
	Coord[.,1] = (rowsum(G):==0):*((sCoord[.,1]:-50):*ScaleFactor) + (rowsum(G):!=0):*Coord[.,1]
	Coord[.,2] = (rowsum(G):==0):*((sCoord[.,2]:-50):*ScaleFactor) + (rowsum(G):!=0):*Coord[.,2]

	return(Coord)
}
end


mata
transmorphic matrix function getdata(
	string scalar 	var1, 
	string scalar 	var2, 
	real scalar 	N)
{
	transmorphic matrix D

	if (st_isstrvar(var1)!=st_isstrvar(var2)) {
		errprintf("Network variables must be of the same type \n")
		exit(error(3250))
	}
	if(st_isnumvar(var1)){
		D = st_data((1,N), (var1,var2)) 
	}
	if(st_isstrvar(var1)){
		D = st_sdata((1,N), (var1,var2)) 
	}
	return(D)
	
}
end


//Looks up a unique value
//NOTE: code copied from mm_which() by Ben Jann
mata
real matrix whichone(real vector I)
{
        if (cols(I)!=1) 
		return(select(1..cols(I), I))
        else 
		return(select(1::rows(I), I))
}
end

mata
//NumElist()
//Creates a numeric version of an Elist with sorted numbers, without missings
real matrix NumElist(matrix L){
	vector 		NodeList
	real scalar Nties,i
	real matrix Out
	matrix L2
	//create a list with unique names of nodes, excluding missings
	NodeList = uniqrows(L[.,1]\L[.,2]) 
	if(eltype(NodeList)=="real" ) {
		NodeList = select(NodeList,NodeList:!=.)
	}	
	if (eltype(NodeList)=="string") {
		NodeList = select(NodeList,(NodeList:!=""))
	}	

	// setup return matrix
	if(eltype(L)=="real" ){
		L2 = select(L,rowmissing(L):==0) // L without rows with missings (num)
	}

	if(eltype(L)=="string" ){
		L2 = select(L,rowsum(L:==""):==0) // L without rows with missings (num)

	}
	Nties = rows(L2) 
	Out = J(Nties,2,.)	



	//fill return matrix
	for(i=1;i<=rows(Out);i++){
		Out[i,1]=whichone(NodeList:==L2[i,1])
		Out[i,2]=whichone(NodeList:==L2[i,2])
	}
	return(Out)
}

end



mata
//Elist2Mat()
//Converts a list of ties into an adjacency matrix 
real matrix function Elist2Mat(matrix Data)
{
	vector 		NodeList
	real scalar 	NTies, N, N1, N2, i
	real matrix 	NetMatrix
	scalar 		Node1
	scalar 		Node2
	
	if(cols(Data)!=2){  // Check if this is really a tieslist
		errprintf("Error: Tielist must consist of two columns \n")
		exit(error(3498))
	}

	//create a list with unique names of nodes, excluding missings
	NodeList = uniqrows(Data[.,1]\Data[.,2]) 
	if(eltype(NodeList)=="real" ) {
		NodeList = select(NodeList,NodeList:!=.)
	}	
	if (eltype(NodeList)=="string") {
		NodeList = select(NodeList,(NodeList:!=""))
	}	

	NTies = rows(Data)		//# of ties
	N = rows(NodeList)		//# of Nodes

	NetMatrix = J(N,N,0)
	for(i=1;i<=NTies;i++){		//Create Adj matrix
		Node1 = Data[i,1]
		Node2 = Data[i,2]
		N1 = whichone(NodeList:==Node1)
		N2 = whichone(NodeList:==Node2)
		if (rows(N1)!=0  & rows(N2)!=0){
			//TODO: account for missings!
			NetMatrix[N1,N2] = 1
			NetMatrix[N2,N1] = 1
		}
	}
	return(NetMatrix)
}
end




mata
void function netplot(
	string scalar 	var1, 
	string scalar 	var2, 
	real scalar 	N, 
	string scalar 	ptype, 
	real scalar 	label,
	real scalar 	arrows,
	real scalar MaxIt
	)
	
{
	real matrix 	Data,M,Coord
	transmorphic 	matrix labels
	
	Data = getdata(var1,var2,N)
	M = Elist2Mat(Data)
	printf("{text:Calculating coordinates...}\n")
	displayflush()
	
	if (ptype=="circle") Coord = circlelayout(rows(M))
	if (ptype=="mds"   ) Coord = mmdslayout(M,MaxIt)
	
	if(label==0) labels = J(0,1,0)
	if (label==1) {
		labels = uniqrows(Data[.,1]\Data[.,2])
		if(eltype(labels)=="real"  ) labels = select(labels,labels:!=.)
		if(eltype(labels)=="string") labels = select(labels,(labels:!=""))
	}
	printf("{text:Drawing layout...}\n")
	displayflush()
	DrawLayout(Coord,NumElist(Data),labels,arrows)
	
}
end



