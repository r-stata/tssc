
capture program drop mobs
program mobs, rclass
syntax varlist [if] [in]  [, Level(real 1) Noshow ]
marksample touse, strok novarlist
tokenize `varlist'
local vnum: word count `varlist'
capture drop obs
capture drop obst
capture mat drop A0
capture mat drop A1
capture mat drop B0
capture mat drop B1

sort `varlist'
if `level'==1 {
	by `1' : gen obs=_n
    by `1' : gen obst=_N
	tab1 obs, matrow(A0) matcell(A1) 
	tab1 obst, matrow(B0) matcell(B1)

}



if `level'==2 {
    if `vnum'<2 {
	    display as error "While level=2, you must specify at least two variables"
	}
	by `1' `2' : gen obs=_n
    by `1' `2' : gen obst=_N
	tab1 obs, matrow(A0) matcell(A1) 
	tab1 obst, matrow(B0) matcell(B1)
}

if `level'==3 {
        if `vnum'<3 {
	    display as error "While level=3, you must specify at least three variables"
	}
	by `1' `2' `3': gen obs=_n
    by `1' `2' `3': gen obst=_N

	tab1 obs, matrow(A0) matcell(A1) 
	tab1 obst, matrow(B0) matcell(B1)

}


if `level'==4 {
        if `vnum'<4 {
	    display as error "While level=4, you must specify at least four variables"
	}
	by `1' `2' `3' `4': gen obs=_n
    by `1' `2' `3' `4': gen obst=_N

	tab1 obs, matrow(A0) matcell(A1) 
	tab1 obst, matrow(B0) matcell(B1)

}
*
mat A=A0,A1
mat B=B0,B1
return mat obs=A
return mat obst=B

end
