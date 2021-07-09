program define mcq2long

version 8.0

syntax varlist(min=27 max=27), id(string)

keep `id' `varlist'

local i=0

foreach x of varlist `varlist' {

qui local i=`i'+1

qui rename `x' choice`i'

}


qui reshape long choice, i(`id') j(qnum)

qui gen near=.
qui gen far=.
qui gen time=.

qui replace near=54 if qnum==1
qui replace near=55 if qnum==2
qui replace near=19 if qnum==3
qui replace near=31 if qnum==4
qui replace near=14 if qnum==5
qui replace near=47 if qnum==6
qui replace near=15 if qnum==7
qui replace near=25 if qnum==8
qui replace near=78 if qnum==9
qui replace near=40 if qnum==10
qui replace near=11 if qnum==11
qui replace near=67 if qnum==12
qui replace near=34 if qnum==13
qui replace near=27 if qnum==14
qui replace near=69 if qnum==15
qui replace near=49 if qnum==16
qui replace near=80 if qnum==17
qui replace near=24 if qnum==18
qui replace near=33 if qnum==19
qui replace near=28 if qnum==20
qui replace near=34 if qnum==21
qui replace near=25 if qnum==22
qui replace near=41 if qnum==23
qui replace near=54 if qnum==24
qui replace near=54 if qnum==25
qui replace near=22 if qnum==26
qui replace near=20 if qnum==27

qui replace far=55 if qnum==1
qui replace far=75 if qnum==2
qui replace far=25 if qnum==3
qui replace far=85 if qnum==4
qui replace far=25 if qnum==5
qui replace far=50 if qnum==6
qui replace far=35 if qnum==7
qui replace far=60 if qnum==8
qui replace far=80 if qnum==9
qui replace far=55 if qnum==10
qui replace far=30 if qnum==11
qui replace far=75 if qnum==12
qui replace far=35 if qnum==13
qui replace far=50 if qnum==14
qui replace far=85 if qnum==15
qui replace far=60 if qnum==16
qui replace far=85 if qnum==17
qui replace far=35 if qnum==18
qui replace far=80 if qnum==19
qui replace far=30 if qnum==20
qui replace far=50 if qnum==21
qui replace far=30 if qnum==22
qui replace far=75 if qnum==23
qui replace far=60 if qnum==24
qui replace far=80 if qnum==25
qui replace far=25 if qnum==26
qui replace far=55 if qnum==27

qui replace time=117 if qnum==1
qui replace time=61 if qnum==2
qui replace time=53 if qnum==3
qui replace time=7 if qnum==4
qui replace time=19 if qnum==5
qui replace time=160 if qnum==6
qui replace time=13 if qnum==7
qui replace time=14 if qnum==8
qui replace time=162 if qnum==9
qui replace time=62 if qnum==10
qui replace time=7 if qnum==11
qui replace time=119 if qnum==12
qui replace time=186 if qnum==13
qui replace time=21 if qnum==14
qui replace time=91 if qnum==15
qui replace time=89 if qnum==16
qui replace time=157 if qnum==17
qui replace time=29 if qnum==18
qui replace time=14 if qnum==19
qui replace time=179 if qnum==20
qui replace time=30 if qnum==21
qui replace time=80 if qnum==22
qui replace time=20 if qnum==23
qui replace time=111 if qnum==24
qui replace time=30 if qnum==25
qui replace time=136 if qnum==26
qui replace time=7 if qnum==27

gen ip1=-far/near+1
end


