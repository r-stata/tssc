
**************************************************
//
**************************************************
capture program drop evalue
program evalue, rclass
version 14.2
syntax [anything] , Measurement(numlist max=1) [Lowlimit(numlist max=1) Uplimit(numlist max=1) Rareoutcome(real 1)]
**************************************************
//
**************************************************
tokenize `anything'


local lownum: word count `lowlimit'
local upnum: word count `uplimit'

**************************************************
//
**************************************************
if `rareoutcome'!=1 & `measurement'==1 {
display as error "When specifying measurement as 1, which means risk ratio. The rare outcome assumption is not relevant, please remove the option rareoutcome"
exit
}
**************************************************
//
**************************************************
if `measurement'==1 {
local mm "risk ratio"
local MM "Risk ratio"
}
*
if `measurement'==2 {
local mm "odd ratio"
local MM "Odd ratio"
}
*
if `measurement'==3 {
local mm "hazard ratio"
local MM "Hazard ratio"
}
*
if `measurement'==4 {
local mm "risk difference"
local MM "Risk difference"
}
*
if `measurement'==5 {
local mm "rate ratio"
local MM "Rate ratio"
}
*
if `measurement'==6 {
local mm "difference in continuous outcomes"
local MM "Difference in continuous outcomes"
}
*
**************************************************
//
**************************************************
/*
local prevalencenum: word count `prevalence'
if `prevalencenum'==0 {
    local rare=3
	}
*	
if `prevalencenum'==1 {
    if `prevalence'<=0.15 {
	local rare=1
	}
*		
	 if `prevalence'>0.15 {
	local rare=0
	}
*		
}
*
*display "rare = " `rare'
*/
**************************************************
//Effect measurement
**************************************************
//RR
if `1'>=1  & `rareoutcome'==1  {
             local effectmeasure=`1'
			 }
*
  if `1'<1  & `rareoutcome'==1    {
             local effectmeasure=1/`1'
			 }
*
//OR common  
if `1'>=1  & `measurement'==2  & `rareoutcome'==0 {
             local approximation= sqrt(`1')
             local effectmeasure=`approximation'
}
*
if `1'<1  & `measurement'==2 & `rareoutcome'==0 {
             local approximation= sqrt(`1')
             local effectmeasure=1/`approximation'
			 
}
*
//HR common
if `1'>=1  & `measurement'==3 & `rareoutcome'==0 {
             local approximation=(1 - 0.5^sqrt(`1'))/(1 - 0.5^sqrt(1/`1'))
             local effectmeasure=`approximation'
}
*
if `1'<1  & `measurement'==3 & `rareoutcome'==0 {
             local approximation=(1 - 0.5^sqrt(`1'))/(1 - 0.5^sqrt(1/`1'))
             local effectmeasure=1/`approximation'
}
*
**************************************************
//Limit values
**************************************************
if `lownum'==1 {
				local llvalue=`lowlimit'
				*display as error "llvalue = " `llvalue'
				}
*
if `upnum'==1 {
				local ulvalue=`uplimit'
				*display as error "ulvalue = " `ulvalue'
				}
*

**************************************************
//
**************************************************
//RR
if `1'>=1 & `rareoutcome'==1  {
            if `lownum'==1 {
						   if `llvalue'<=1 {
									local eValueLow=1
									}
							else {
									local ll=`llvalue'
									local eValueLow=`ll' + sqrt(`ll' * (`ll' - 1))
									}
				}
*
             if `upnum'==1 {
				           local ul=`ulvalue'
						   local eValueUp=`ul' + sqrt(`ul' * (`ul' - 1))
				}
*
			 }
*
  if `1'<1 & `rareoutcome'==1    {
			 if `lownum'==1 {
				             local ll=1/`llvalue'
							 local eValueLow=`ll' + sqrt(`ll' * (`ll' - 1))
				}
*
              if `upnum'==1 {
						   if `ulvalue'>=1 {
									local eValueUp=1
									}
						   else {
						            *display "ulvalue = " `ulvalue'
									local ul=1/`ulvalue'
									*display "ul = " `ul'
									local eValueUp=`ul' + sqrt(`ul' * (`ul' - 1))
									*display "eValueUp = " `eValueUp'
									}
				             }
*
			 }
*	   

//OR common  
if `1'>=1  & `measurement'==2 & `rareoutcome'==0 {
            if `lownum'==1 {
							if `llvalue'<=1 {
								   local eValueLow=1
										}
							else {
								   local approximationLow= sqrt(`llvalue')
								   local ll=`approximationLow'
								   local eValueLow=`ll' + sqrt(`ll' * (`ll' - 1))
								 }
							}
            if `upnum'==1 {
                           local approximationUp= sqrt(`ulvalue')
                           local ul=`approximationUp'
						   local eValueUp=`ul' + sqrt(`ul' * (`ul' - 1))
						   }						   
}
*
if `1'<1  & `measurement'==2 & `rareoutcome'==0 {
            if `lownum'==1 {
                           local approximationLow= sqrt(`llvalue')
                           local ll=1/`approximationLow'
						   local eValueLow=`ll' + sqrt(`ll' * (`ll' - 1))
						   }
            if `upnum'==1 {
			               if `ulvalue'>=1 {
						       local eValueUp=1
							   }
						   else {
								   local approximationUp= sqrt(`ulvalue')
								   local ul=1/`approximationUp'
								   local eValueUp=`ul' + sqrt(`ul' * (`ul' - 1))
						        }
			    }
			 
}
*
//HR common
if `1'>=1  & `measurement'==3 & `rareoutcome'==0 {
            if `lownum'==1 {
							if `llvalue'<=1 {
								   local eValueLow=1
										}
							else {
								   local approximationLow= (1 - 0.5^sqrt(`llvalue'))/(1 - 0.5^sqrt(1/`llvalue'))
								   local ll=`approximationLow'
								   local eValueLow=`ll' + sqrt(`ll' * (`ll' - 1))
								   }
							   }
            if `upnum'==1 {
                           local approximationUp= (1 - 0.5^sqrt(`ulvalue'))/(1 - 0.5^sqrt(1/`ulvalue'))
                           local ul=`approximationUp'
						   local eValueUp=`ul' + sqrt(`ul' * (`ul' - 1))						   
						   }	
}
*
if `1'<1  & `measurement'==3 & `rareoutcome'==0 {
            if `lownum'==1 {
                           local approximationLow= (1 - 0.5^sqrt(`llvalue'))/(1 - 0.5^sqrt(1/`llvalue'))
                           local ll=1/`approximationLow'
						   local eValueLow=`ll' + sqrt(`ll' * (`ll' - 1))
						   }
            if `upnum'==1 {
			               if `ulvalue'>=1 {
						       local eValueUp=1
							   }
						   else {
								   local approximationUp= (1 - 0.5^sqrt(`ulvalue'))/(1 - 0.5^sqrt(1/`ulvalue'))
								   local ul=1/`approximationUp'
								   local eValueUp=`ul' + sqrt(`ul' * (`ul' - 1))
						        }
						   }	
}
*
*/
**************************************************
//
**************************************************

local eValue=`effectmeasure' + sqrt(`effectmeasure' * (`effectmeasure' - 1))

**************************************************
//
**************************************************

if `measurement'==1  {
   display "For the observed `mm' (`1'), E value = " %6.2f `eValue'
   return scalar e_value=`eValue'
   
   if `lownum'==1 {
					display "For the observed low limit (`llvalue') of 95%CI for `mm', E value = " %6.2f `eValueLow'
					return scalar ll_E_value=`eValueLow'
							}
   if `upnum'==1 {

					display "For the observed up limit (`ulvalue') of 95%CI for `mm', E value = " %6.2f `eValueUp'
					return scalar ul_E_value=`eValueUp'
							}
}
*


if (`measurement'==2  |  `measurement'==3)   {
   local eValue=`effectmeasure' + sqrt(`effectmeasure' * (`effectmeasure' - 1))


     if `rareoutcome'==1 {
                             display "When the outcome is relatively rare (prevalence <= 0.15):"
							 display "For the observed `mm' (`1'), E value = " %6.2f `eValue'
							}
	 if `rareoutcome'==0 {
                             display "When the outcome is not relatively rare (prevalence= > 0.15):"
							 display "For the observed `mm' (`1'), the approximated E value = " %6.2f `eValue'
							}


   return scalar e_value=`eValue'
   
   if `rareoutcome'==1 {  
   if `lownum'==1 {
					
					display "For the observed low limit (`llvalue') of 95%CI for `mm', E value = " %6.2f `eValueLow'
					return scalar ll_E_value=`eValueLow'
							}
   if `upnum'==1 {
					
					display "For the observed up limit (`ulvalue') of 95%CI for `mm', E value = " %6.2f `eValueUp'
					return scalar ul_E_value=`eValueUp'
							}
							}
							
	   if `rareoutcome'==0 {  
   if `lownum'==1 {
					
					display "For the observed low limit (`llvalue') of 95%CI for `mm', the approximated E value = " %6.2f `eValueLow'
					return scalar ll_E_value=`eValueLow'
							}
   if `upnum'==1 {
					
					display "For the observed up limit (`ulvalue') of 95%CI for `mm', the approximated E value = " %6.2f `eValueUp'
					return scalar ul_E_value=`eValueUp'
							}
							}						
}
*

end
