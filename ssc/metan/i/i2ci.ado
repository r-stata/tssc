*! Author: Ross Harris
*! Date: 1 August 2008

* Confidence interval for I-sq, to be run after metan

version 8.0
program i2ci

local k = r(df)+1
local q = r(het)

if `q' > `k'{
        local selogH = 0.5 * ( ln(`q') - ln(`k'-1) ) / ( sqrt(2*`q') - sqrt(2*`k'-3) )
}
else{
        local selogH = sqrt(  (1/(2*(`k'-2))) * (1- (1/(3*(`k'-2)^2)))  )
}

local H = sqrt(`q'/(`k'-1))
local Hlow = exp(ln(`H')-1.96*`selogH')
local Hupp = exp(ln(`H')+1.96*`selogH')

local I2 = string( r(i_sq) , "%5.1f")
local I2low = string( max( 100* ( (`Hlow'^2-1) / `Hlow'^2 ) , 0) , "%5.1f")
local I2upp = string( max( 100* ( (`Hupp'^2-1) / `Hupp'^2 ) , 0) , "%5.1f")

di in ye "I-sq= `I2'%, 95% CI: `I2low'% to `I2upp'%"
di in whi "CI based on Higgins & Thompson, Statist. Med. 2002; 21:1539–1558,
di in whi "Appendix A2: Intervals based on the statistical significance of Q."

end
