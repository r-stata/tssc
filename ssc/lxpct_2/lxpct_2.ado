*This program produces life expectancies
*If you are using it when it is not after mprobs you need to set matrix b1, b2... etc. and global i and k=i-1

program define lxpct_2
     version 7.0
  syntax [, i(real 1) d(real 1) ]
  global i=`i'
  global k=`i'-`d'	 
  forvalues r=1(1)$k{
	matrix define b`r'_=`r'1
	forvalues s=2(1)$i{
		matrix define b`r'`s'=`r'`s'
		matrix define b`r'_=b`r'_,b`r'`s'
		}
	matrix b`r'=b`r'_'
	}


*Step 1: Make Matrix"
*This creates all the possible probabilities from variables prob11 prob12... into matrix p1; prob22 prob 23... into matrix p2, etc.
forvalues a=1(1)$i {
	forvalues b=1(1)$i {
		gen prob`a'`b'=0
		replace prob`a'`b'=1 if `b'==$i & `a'==$i
		}
	mkmat prob`a'*, matrix(p`a')
	}
*This substitutes those probabilities for which there are estimates for the 0s from above
forvalues a=1(1)$k {
	local b=rowsof(b`a')
	forvalues c=1(1)`b' {
		local d=el(b`a',`c',1)
		local e=string(`d')
		local f=substr("`e'",2,.)
		mkmat p`a'`f', matrix(p`a'`f')
		matrix substitute p`a'[1,`f']=p`a'`f'
		}
	}
*Step 2: Transposing the matrices so that they can be joined by age"
sort age
local agei=age[_n]
local agef=age[_N]
quietly ta age , matrow(age)
quietly ta age if age<`agef', matrow(age2)
forvalues a=1(1)$i {
	matrix p`a't=p`a''
	svmat p`a't
	}
drop if p1t1==.
local d=`agef'-`agei' +1
*This produces the matrices of the probabilites from each state at each age
forvalues b=1(1)`d' {
	local z=`agei'+`b'-1
	forvalues a=1(1)$i {
		mkmat p`a't`b', matrix(p`a'age`z')
		}
	}
*Step 3: This accumulates the probabilities from each state by age"
forvalues b=1(1)`d' {
	*Begins with the first
	local z=`agei' + `b' -1
	matrix p_age`z'=p1age`z'
	*And then accumulates all additional
	forvalues c=2(1)$i {
		matrix p_age`z'=p_age`z', p`c'age`z'
		}
	matrix p_age`z'_=p_age`z''
	}
* I now have matrices entitled p_age18_ - p_age`lastage'_ which have all of the transition probabilities

*Step 4: obtain the lx"
*The first survivorship function is easy:
matrix l_`agei'=J(1,$i,0)
matrix substitute l_`agei'[1,1]=100000
display "*All of the rest are a little more tricky:"
local c=`d'-1
forvalues a=1(1)`c' {
	local b=`agei'+`a'-1
	local e=`agei'+`a'
	matrix l_`e'=l_`b'*p_age`b'_
	}
* "Step 5: obtain the person-years"
forvalues a=1(1)`c' {
	local f=`agei'+`a'-1
	local g=`agei'+`a'
	matrix L_`f'=.5*(l_`f'+l_`g')
	}
local y=`agef'-1
matrix T_`y'=L_`y'
local f=`c'-1
*`f' counts one fewer than the total number btwn initial and the last
forvalues a=1(1)`f' {
	local k=`y'-`a'
	*so k, the first here, is the second to last-1
	local m=`k'+1
	matrix T_`k' = T_`m'+ L_`k'
	}
*Step 6: obtain life expectancies*"
*Divide by l(x)which in this case is always 100,000
forvalues a=1(1)`c'{
	local f = `agei'+`a'-1
	matrix e_`f'= T_`f'/100000
	}
*This accumulates the l(x); L(x,n); T(x,n) and e(x) from each state by age
*Begins with the first
matrix l_x=l_`agei'
matrix L_x=L_`agei'
matrix T_x=T_`agei'
matrix e_x=e_`agei'
*And then accumulates all additional
local f=`agef'-`agei'-1
local top= "age"
*survivor; l(x)
forvalues s=1(1)$i {
	local top= "`top' l_`s'"
	}
forvalues r=1(1)`f' {
	local r=`r'+`agei'
	matrix ltemp = l_`r'
	matrix l_x= l_x\ltemp
	}
matrix l_x=age2, l_x
matrix  colnames l_x=`top'
*person-years; L(x)
local top= "age"
forvalues s=1(1)$i {
	local top= "`top' L_`s'"
	}
forvalues r=1(1)`f' {
	local r=`r'+`agei'
	matrix Ltemp = L_`r'
	matrix L_x= L_x\Ltemp
	}
matrix L_x=age2, L_x
matrix  colnames L_x=`top'
*summed; T(x)
local top= "age"
forvalues s=1(1)$i {
	local top= "`top' T_`s'"
	}
forvalues t=1(1)`f' {
	local t=`t'+`agei'
	matrix Ttemp = T_`t'
	matrix T_x= T_x\Ttemp
	}
matrix T_x=age2, T_x
matrix  colnames T_x=`top'
*life expect; e(x)
local top= "age"
forvalues s=1(1)$i {
	local top= "`top' e_`s'"
	}
forvalues v=1(1)`f' {
	local v=`v'+`agei'
	matrix etemp = e_`v'
	matrix e_x= e_x\ etemp
	}
matrix e_x=age2, e_x
matrix  colnames e_x=`top'
drop age* p*

display"*Output"
matrix list l_x
matrix list L_x
matrix list T_x
matrix list e_x
end
