/*
*! Ian White # 6apr2018
	improved advice to install network_graphs
version 1.1 # Ian White # 27may2015
19jun2015
    clearer instruction to upgrade networkplot
15may2015
    rewrote parsing using circle and circle2 etc.
12mar2015
    includes vercheck (networkplot appeared not found)
version 1.0 # Ian White # 9Sep2014 
Requires Anna Chaimani's plotter, networkplot
version 0.8 # Ian White # 31jul2014
    added trt labels
    removed my simple plotter
    sensible error code for missing networkplot
version 0.7 # Ian White # 11jul2014
    added graphregion(style(plotregion)) option by default    
    added improve(#) option - improve becomes numeric
version 0.6 # Ian White # 6jun2014
    stop when score=0
    option nodetails to suppress the "=..=."
    row and column names in _network_map_location
    help file updated

Notes
When loc matrix is given, the rows are applied in order to the treatments in the data (or subset)
    and the row names are ignored: thus the following may give different locations:
        network map, loc(M)     
        network map if subset, loc(M)
-networkplot- with if/in and labels() applies the labels 
    to the treatments in the whole data set, not in the subset
*/
prog def network_map

// LOAD SAVED NETWORK PARAMETERS
if mi("`_dta[network_allthings]'") {
	di as error "Data are not in network format"
	exit 459
}
foreach thing in `_dta[network_allthings]' {
    local `thing' : char _dta[network_`thing']
}

// PARSE
syntax [if] [in], [CIRcle2 CIRcle(passthru) SQUare2 SQUare(passthru) ///
    TRIangular2 TRIangular(passthru) RANdom2 RANdom(passthru) ///
    CENtre loc(string) IMProve IMProve2(int 0) noDETails replace LISTloc TRTCodes debug *]
if !mi("`debug'") local dicmd dicmd
local improve = cond(mi("`improve'"),`improve2',10)

// CHECK NETWORKPLOT
cap which networkplot
if _rc {
    di as error `"networkplot is not installed"'
    di as error `"Please install the network_graphs package using {stata "net from http://www.mtm.uoi.gr"}"'
    exit 498
}
cap vercheck networkplot 1.2
local newver = _rc==0
if !`newver' { // old version
    di as error `"You have an old version of networkplot so no network map options are allowed"'
    di as error `"For best results please upgrade networkplot to v1.2 using {stata "net from http://www.mtm.uoi.gr"}"'
    foreach opt in circle square triangular random centre loc listloc trtcodes {
        if !mi("``opt''") di as error "Option `opt' ignored"
        if !mi("``opt'2'") di as error "Option `opt' ignored"
    }
    local improve 0
}


// LINKS: MATRIX LINKS 
preserve
marksample touse
qui keep if `touse'
cap network convert pairs
tempvar pair arm trt
local _trt = substr("`t1'",1,length("`t1'")-1) // common stub for `t1' and `t2'
if "`t2'"!="`_trt'2" { // shouldn't be needed
    tempvar _trt
    rename (`t1' `t2') (`_trt'1 `_trt'2)
}
gen `pair' = _n
qui reshape long `_trt', i(`pair') j(`arm') 
qui levelsof `_trt', local(trtcodelist) clean
local ntrts = wordcount("`trtcodelist'")
if !mi("`debug'") di as input `"`ntrts' treatments: `trtcodelist'"'

sort `pair' `_trt'
qui by `pair': replace `arm'=_n // gets treatments ordered within pairs
encode `_trt', gen(`trt')
qui reshape wide `trt' `_trt', i(`pair') j(`arm') 
sort `trt'1 `trt'2
qui by `trt'1 `trt'2: gen first = _n==1
mkmat `trt'1 `trt'2 if first, mat(links)
drop `pair' first

// LOCATION: MATRIX LOC
cap confirm matrix `loc'
if _rc | !mi("`replace'") { // need to create location matrix
    // NB opt2 has no argument, opt has argument
    local newloc 1
    if !mi("`circle'") local place `circle'
    else if !mi("`square'") local place `square'
    else if !mi("`triangular'") local place `triangular'
    else if !mi("`random'") local place `random'
    else if !mi("`square2'") local place square(`=int(sqrt(`ntrts'))+1') 
    else if !mi("`triangular2'") {
        local n = int(sqrt(`ntrts'))+1
        if `n'^2-int(`n'/2)<`ntrts' local ++n
        local place triangular(`n') 
    }
    else if !mi("`random2'") local place random(`ntrts') 
    else local place circle(`=`ntrts'-!mi("`centre'")') // default
    
    if mi("`loc'") local loc _network_map_location
    `dicmd' makeloc, loc(`loc') `place' ntrts(`ntrts') `centre'
}
else { // use existing location matrix
    local newloc 0
    if rowsof(`loc')<`ntrts' {
        di as error "Location matrix `loc' must have at least `ntrts' rows"
        exit 498
    }
    if !mi("`circle'`square'`triangular'`random'") ///
        di as error "Options ignored: `square' `circle' `triangular' `random'"
}

// TREATMENT NAMES
foreach trtcode in `trtcodelist' {
    local trtnames `"`trtnames' "`trtname`trtcode''""' 
}

// OPTIONAL IMPROVEMENT
if `improve' {
    mata: loc = st_matrix("`loc'")
    mata: xlinks = xlinks(st_matrix("links"))
    mata: score = evaluate(xlinks,loc)
    // IMPROVE
    di as text "Improving locations ..."
    local print = "`details'" != "nodetails"
    mata: newloc = improve(xlinks,loc,`print',`improve') // performs the improvement
    di as text "Evaluating optimal locations ..."
    mata: e = evaluate(xlinks,newloc,9) // prints evaluation
    mata: st_matrix("`loc'",newloc) // returns improved locations in loc
    local newloc 1
}

// ROW AND COL NAMES FOR LOCATION MATRIX
if `newloc' {
    forvalues i=`=`ntrts'+1' / `=rowsof(`loc')' { // name unused rows as "."
        local nullnames `nullnames' "."
    }
    mat colnames `loc' = "x" "y" "labelpos"
    mat rownames `loc' = `trtnames' `nullnames'
}

// FINAL PLOT
if mi("`trtcodes'") local label label(`trtnames')
if `newver' local newoptions loc(`loc') `label' graphregion(style(plotregion)) f9 
`dicmd' networkplot `_trt'1 `_trt'2, `newoptions' `options' 
if !mi("`listloc'") mat list `loc', title(Treatment locations for network map)

end

/*================================================================*/

prog def makeloc
syntax, loc(string) ntrts(int) [circle(int 0) square(int 0) triangular(int 0) random(int 0) centre]
confirm name `loc'
if `square'>0 {
	local trts=`square'^2
    if `trts'<`ntrts' {
        di as error "Argument of square() must be at least sqrt(#treatments)"
        exit 498
    }
	mat `loc' = J(`trts',3,.)
	local i 0
	forvalues x=1/`square' {
	forvalues y=1/`square' {
		local ++i
		mat `loc'[`i',1] = `x'
		mat `loc'[`i',2] = `y'
	}
	}
}
else if `circle'>0 {
    if mi("`centre'") & `circle'<`ntrts' {
        di as error "Argument of circle() must be at least #treatments"
        exit 498
    }
    if !mi("`centre'") & `circle'<`ntrts'-1 {
        di as error "Argument of circle() must be at least #treatments-1"
        exit 498
    }
	mat `loc' = J(`circle',3,.)
	forvalues i=1/`circle' { // start at 3 o'clock and work anti-clockwise
		mat `loc'[`i',1] = cos(2*_pi*(`i'-1)/`circle')  // x
		mat `loc'[`i',2] = sin(2*_pi*(`i'-1)/`circle')  // y
	}
    if !mi("`centre'") mat `loc' = `loc' \ (0,0,12)
}
else if `random'>0 {
    if `random'<`ntrts' {
        di as error "Argument of random() must be at least #treatments"
        exit 498
    }
	mat `loc' = J(`random',3,.)
	forvalues i=1/`random' {
		mat `loc'[`i',1] = runiform()
		mat `loc'[`i',2] = runiform()
	}
}
else if `triangular'>0 { // `triangular' is side of grid
    local spaces = `triangular'^2-floor(`triangular'/2) 
    if `spaces'<`ntrts' {
        di as error "Argument of triangular() is not large enough"
        exit 498
    }
    mat `loc' = J(`spaces',3,.)
    local x 0
    local y 1
    local longrow 1
    forvalues i=1/`spaces' {
			local ++x
			if `x' > `triangular' {
				local y = `y'+sqrt(3)/2
				local longrow = !`longrow'
				local x = cond(`longrow',1,1.5)
			}
			mat `loc'[`i',1]=`x'
			mat `loc'[`i',2]=`y'
		}
}
else {
    di as error "makeloc requires one option of square(), circle(), triangular(), random()"
    exit 198
}

// identify clock positions
* find mean
local rows = rowsof(`loc')
tempname mean loccentred
mat `mean' = J(1,`rows',1/`rows') * `loc'
forvalues i = 1/`rows' {
    local x = `loc'[`i',1] - `mean'[1,1]
    local y = `loc'[`i',2] - `mean'[1,2]
    if `y'>0 local theta = atan(`x'/`y') 
    if `y'<0 local theta = atan(`x'/`y') + _pi 
    if `y'==0 local theta = sign(`x')*_pi/2
    mat `loc'[`i',3] = mod(round(`theta'*6/_pi)-1, 12)+1 
    * also round numbers near 0 to 0
    if abs(`loc'[`i',1])<epsfloat() mat `loc'[`i',1] = 0
    if abs(`loc'[`i',2])<epsfloat() mat `loc'[`i',2] = 0
}
end

/*================================================================*/

* evaluate function
* NB node = treatment
mata :
real matrix evaluate(
	real matrix xlinks // node numbers for all pairs of lines
	, real matrix loc // node locations
    , | real scalar print
	) {
if (args()==2) print = 0
debug=0
if(debug) "evaluate(): xlinks"
if(debug) xlinks
if(debug) "evaluate(): loc"
if(debug) loc
// xlinks = node locations for all pairs of lines
//          and 5th column indicates if node in common
xlocs=J(rows(xlinks),0,.)
for(j=1;j<=4;j++) {
	xlocs = xlocs, loc[xlinks[,j],(1,2)]
}
if(debug) "evaluate(): xlocs"
if(debug) xlocs
// cross = 0 if not crossing, 1 if crossing at a point, 10 if crossing on a line segment
cross=J(rows(xlocs),1,.)
for(i=1;i<=rows(xlocs);i++) {
if(debug) "evaluate(): row " + strofreal(i)
	r1=xlocs[i,1..2]'
	r2=xlocs[i,3..4]'
	r3=xlocs[i,5..6]'
	r4=xlocs[i,7..8]'
	// Lines are r = r1 + x1*(r2-r1)
	// 		 and r = r3 + x2*(r4-r3)
	M=(r2-r1,r3-r4)
	a=(r3-r1)
	if(det(M) != 0) { // not parallel
		if(xlinks[i,5]) cross[i,1]=0 // common node and not parallel is OK
        else {
            x=luinv(M)*a // x1,x2 at intersection
    		cross[i,1] = max(abs(x-J(2,1,0.5)))<=0.5 & 
    					 min(abs(x-J(2,1,0.5)))<0.5 
    		// i.e. are both els of x in [0,1]?
        }
if(debug) xlinks[i,],cross[i,1]
	}
	else { // parallel
		if(det((r2-r1,r3-r1))==0) { // same line 
			// solve r3 = r1 + lambda3*(r2-r1)
			if(r1[1,1]!=r2[1,1]) lambda3 = 
				(r3[1,1]-r1[1,1])/(r2[1,1]-r1[1,1])
			else lambda3 = 
				(r3[2,1]-r1[2,1])/(r2[2,1]-r1[2,1])
			// solve r4 = r1 + lambda4*(r2-r1)
			if(r1[1,1]!=r2[1,1]) lambda4 = 
				(r4[1,1]-r1[1,1])/(r2[1,1]-r1[1,1])
			else lambda4 = 
				(r4[2,1]-r1[2,1])/(r2[2,1]-r1[2,1])
			ok = min((lambda3,lambda4))>1 | max((lambda3,lambda4))<0
if(print==9) printf("Parallel lines at i = %f: ok = %f\n",i,ok)
			cross[i,1] = 10*(1-ok)
		}
		else cross[i,1] = 0
	}
    if(print & cross[i,1]) strofreal(xlinks[i,1])+"-"+strofreal(xlinks[i,2])+" and "+
        strofreal(xlinks[i,3])+"-"+strofreal(xlinks[i,4])+": score "+strofreal(cross[i,1])
}
return(cross)
}
end

/*================================================================*/

* improve function
mata :
real matrix improve(
	real matrix xlinks // node numbers for all pairs of lines
	, real matrix loc // initial node locations
    , real scalar details // 1 to print = and . 
	, | real scalar maxloops // max #loops
    ) {
if (args()==3) maxloops = 10
loc1 = loc
e1 = sum(evaluate(xlinks,loc1))
for(loop=1;loop<=maxloops;loop++) {
    displayas("text")
    if(loop>1) printf("\n")
    printf("loop %f score",loop)
    displayas("result")
    printf(" %f",e1)
    if(details==0) printf("...")
    displayflush()
	estartloop = e1
	for(i=1;i<=rows(loc);i++) {
		for(j=1;j<=rows(loc);j++) {
			loc2=loc1
			loc2[i,]=loc1[j,]
			loc2[j,]=loc1[i,]
			e2 = sum(evaluate(xlinks,loc2))
			if(e2<e1) { // gain!
                if(details==0) printf(" ")
                printf(" %f",e2)
                if(details==0) printf("...")
                displayflush()
				loc1 = loc2
				e1 = e2
			}
			else if(e2==e1) { // switch if no gain!
                if(details==1) printf("=")
				loc1 = loc2
				e1 = e2
			}
			else {
                if(details==1) printf(".")
			}
			if(e1==0) break
		}
		if(e1==0) break
	}
    displayas("text")
    if(e1==0) {
        printf("\nStopping after achieving score of 0\n")
        break
    }
	if(e1==estartloop) {
		printf("\nStopping because loop %f gave no improvement\n", loop)
		break
	}
	if(loop==maxloops) {
        if(loop>1)loopx="loops"
        else loopx="loop"
        printf("\nStopping after completing %f %s\n", loop, loopx)
		break
	}
}
return(loc1)
}
end

/*================================================================*/

//  prog to compute xlinks from links
mata:
real matrix xlinks(real matrix links) {
xlinks=J(0,5,.)
for(i=1;i<=rows(links);i++) {
	for(j=i+1;j<=rows(links);j++) {
        // Is a node in common?
		common = 0
		for(k=1;k<=2;k++) {
			for(l=1;l<=2;l++) {
				if(links[i,k] == links[j,l]) common = 1
			}
		}
		xlinks = xlinks \ (links[i,],links[j,], common)
	}
}
return(xlinks)
}
end

/*================================================================*/



/*======================= auxiliary program: vercheck =======================*/

program define vercheck, sclass
* 11mar2015 - bug fix - didn't search beyond first line
version 9.2
local progname `1'
local vermin `2'
local not_fatal `3'
// If arg `not_fatal' is set to anything, program exits without an error.
if missing("`not_fatal'") local exitcode 498
tempname fh
qui findfile `progname'.ado // exits with error 601 if not found
local filename `r(fn)'
file open `fh' using `"`filename'"', read
local stop 0
while `stop'==0 {
	file read `fh' line
	if r(eof) continue, break
	tokenize `"`line'"'
	if "`1'" != "*!" continue
	while "`1'" != "" {
		mac shift
		if inlist("`1'","version","ver","v") {
			local vernum `2'
			local stop 1
			continue, break
		}
	}
	if "`vernum'"!="" continue, break
}

sreturn local version `vernum'

if "`vermin'" != "" {
	if "`vernum'"=="" local match nover
	else {
		local vermin2 = subinstr("`vermin'","."," ",.)
		local vernum2 = subinstr("`vernum'","."," ",.)
		local words = max(wordcount("`vermin2'"),wordcount("`vernum2'"))
		local match equal
		forvalues i=1/`words' {
			local wordmin = real(word("`vermin2'",`i'))
			local wordnum = real(word("`vernum2'",`i'))
            if `wordmin' == `wordnum' continue
			if `wordmin' > `wordnum' local match old
			if `wordmin' < `wordnum' local match new
			continue, break
		}
	}
	if "`match'"=="old" {
		di as error `"`filename' is version `vernum' which is older than target `vermin'"'
		exit `exitcode'
	}
	if "`match'"=="nover" {
		di as error `"`filename' has no version number found"'
		exit `exitcode'
	}
	if "`match'"=="new" {
		di `"`filename' is version `vernum'"'
	}
}
else {
	if "`vernum'"!="" di as text `"`filename' is version `vernum'"'
	else di as text `"`filename' has no version number found"'
}

end

/*======================= end of vercheck =======================*/

prog def dicmd
noi di as input `"`0'"'
`0'
end
