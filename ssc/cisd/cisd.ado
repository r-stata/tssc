*! cisd ver 1.1 15 jan2014
*! Postestimation command to -regress-
*! calculates confidence interval for SD(error)
*! Authors: Morten Frydenberg, Svend Juul , Dept. of Public Health, Aarhus University

program cisd
version 11
syntax [, Level(cilevel)]

if e(cmd) != "regress" & e(cmd) != "anova" {
   display as error "The last estimation should be -regress- or -anova-"
   exit
}

if "`level'" == "" {
   local level = c(level)
}

local SD = e(rmse)
local DF = e(df_r)
local LOW  = `SD'*sqrt(`DF'/invchi2(`DF',(100+`level')/200))
local HIGH = `SD'*sqrt(`DF'/invchi2(`DF',(100-`level')/200))

display
display as res "SD(error): " `SD'
display as res "`level'% CI: ( " `LOW' " ; " `HIGH' " ) "
end
		
