program linequate, rclass
        version 11.1
        args anchor testX testY

*changelog  
*version 11.1 (3/29/2011) removed use of matrices to use only local scalars and return results in r()




*------------------------------------------------------------- calculate summary statistics

quietly summ `testY' if `anchor'!=.
local  sya=r(sd)
local nya=r(N)


local  mya=r(mean)

quietly summ `testX' if `anchor'!=.
local  sxa=r(sd)
local  mxa=r(mean)
local nxa=r(N)


quietly summ `anchor'
local  sae=r(sd)
local  ma=r(mean)
local na=r(N)


quietly summ `anchor' if `testY'!=.
local  say=r(sd)
local  may=r(mean)

quietly summ `anchor' if `testX'!=.
local  sax=r(sd)
local  max=r(mean)


quietly corr `anchor' `testX', cov
local  cax=r(cov_12) 
quietly corr `anchor' `testY', cov
local  cay=r(cov_12) 


*------------------------------------------------------------- calculate equating constants

local  tae= (sqrt(`sya'^2+((`cay'^2)*(`sae'^2-`say'^2))/`say'^4))/(sqrt(`sxa'^2+((`cax'^2)*(`sae'^2-`sax'^2))/`sax'^4))


local  tb= `mya'+`cay'*(`ma'-`say'^2-`tae'*`mxa'-(`tae'*`cax'*(`ma'-`max')))/`sax'^2


local  an11=((`sxa'^2)*(`sax'^2)-`cax'^2)/(`sax'^2+`cax')
local  an22=((`sya'^2)*(`say'^2)-`cay'^2)/(`say'^2+`cay')
local  an31=((`sxa'^2)*(`sax'^2)-`cax'^2)/(`sxa'^2+`cax')
local  an32=((`sya'^2)*(`say'^2)-`cay'^2)/(`sya'^2+`cay')

local  holder011=((`sya'^2-`an22'^2)*(`sae'^2-`say'^2))/(`say'^2-`an32'^2)
local  holder021=((`sxa'^2-`an11'^2)*(`sae'^2-`sax'^2))/(`sax'^2-`an31'^2)
local  holder031=`sya'^2
local  holder041=`sax'^2

local  LevEa=sqrt(`holder031'+`holder011')/sqrt(`holder041'+`holder021')
local  holder111=sqrt((`sya'^2-`an22'^2)/(`say'^2-`an32'^2))
local  holder121=sqrt((`sxa'^2-`an11'^2)/(`sax'^2-`an31'^2))
local  LevEb=`mya'+(`max'-`may')*`holder111'-`LevEa'*`mxa'-`LevEa'*(`ma'-`max')*`holder121'


local  LevUa=(sqrt(((`sya'^2)-(`an22'^2))/((`say'^2)-(`an32'^2))))/(sqrt(((`sxa'^2)-(`an11'^2))/((`sax'^2)-(`an31'^2))))
local  holder211=(sqrt(((`sya'^2)-(`an22'^2))/((`say'^2)-(`an32'^2))))
local  LevUb=`mya'+(`max'-`may')*`holder211'-`LevUa'*`mxa'




*------------------------------------------------------------- return results


	return scalar tae = `tae'
	return scalar tb = `tb'
	return scalar La=`LevEa'
	return scalar Lb=`LevEb'	
	return scalar LUa=`LevUa'	
	return scalar LUb=`LevUb'	

*-------------------------------------------------------------------- output

display as text "(Nya=" `nya' as text ", Nxa=" `nxa' as text ", Na=" `na' as text ")"
display as text "                              "
display as text "Tucker Equating Constant A = " as result `tae'
display as text "Tucker Equating Constant B = " as result `tb'
display as text "                              "
display as text "Levine's Equal Variances Equating Constant A  = " as result `LevEa'
display as text "Levine's Equal Variances  Equating Constant B  = " as result `LevEb'
display as text "                              "
display as text "Levine's Unequal Variances  Equating Constant A = " as result `LevUa'	
display as text "Levine's Unequal Variances  Equating Constant B  = " as result `LevUb'	

	
	

* --------------------------------------------------------------------

end
