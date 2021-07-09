*! version 1.0, 22nd July 2012
*Program to display calandar
*Created by Chamara Anuranga, Institute for Health Policy, Sri Lanka
version 8.0
capture program drop cal
		program define cal
		syntax [,y(integer 5)  REPLACE]
*If year does not specify
		if  index("`0'","y")==0 {
			local y= real(substr(c(current_date),-4,.))
			}

		if `y'<99 | `y'>9999 {
		display as result "Current time is `c(current_time)' on  `c(current_date)'"
		display as error "Year should be bwtween 100 to 9999"
			exit
		}
		
		if ("`replace'"=="") {
			preserve		
		}
			qui { 
				clear all
				set obs 372
				gen year=`y'
				egen mon=fill(1/12 1/12)
				sort mon
				egen date=fill(1/31 1/31)
				gen date1=mdy(mon, date,year)
				format date1 %td
				gen temp=dow(date1)
				sort date1
				egen nummonth=fill(1 1 1 1 1 1 1  2 2 2 2 2 2 )
				label define day 0 "Sun" 1 "Mon" 2 "Tue" 3 "Wed" 4 "Thu" 5 "Fri" 6 "Sat"
				label val temp day
				drop if date1==.
				gen wt=1 if temp==0
				bys mon (date1): gen wt1=sum(wt)
				replace wt1=wt1+1
				bys mon: egen min=min(wt1)
				replace wt1=wt1-1 if min==2
				rename wt1 wkt
				*recode wkt 6=1
			 }
			label define mon 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
			label val mon mon			
			label var wkt "  `y' (weeks)"
			label var mon "Jan"
			label var temp "Feb"
			table wkt temp mon,c(mean date),if mon<3
			label var mon "Mar"
			label var temp "Apr"
			table wkt temp mon,c(mean date),if mon>=3 & mon<=4
			label var mon "May"
			label var temp "Jun"
			table wkt temp mon,c(mean date),if mon>=5 & mon<=6			
			label var mon "Jul"
			label var temp "Aug"
			table wkt temp mon,c(mean date),if mon>=7 & mon<=8			
			label var mon "Sep"
			label var temp "Oct"
			table wkt temp mon,c(mean date),if mon>=9 & mon<=10			
			label var mon "Nov"
			label var temp "Dec"
			table wkt temp mon,c(mean date),if mon>10
			qui {
				drop nummonth wt wkt min
				rename date day1
				rename date1 date
				rename mon month
				rename temp day2
				order year month day1 day2 date
				label var year "Year"
				label var month "Month"
				label var day1 "Day (1-31)"
				label var day2 "Day (Sun, Mon, Tue, Wed, Thu, Fri, Sat)"
				label var date "Date"
				
			}
		if ("`replace'"=="") {			
		restore
		}
		dis "Current time is `c(current_time)' on  `c(current_date)'"
		end

 
