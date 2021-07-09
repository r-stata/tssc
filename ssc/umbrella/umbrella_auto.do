log using auto.log, replace
*  auto.log
*
*  Demonstrate the umbrella program for performing O'Brien's Umbrella test.
*  See O'Brien PC. Biometrics 1984;40:1079-1087.
*
sysuse auto
by foreign: summarize mpg weight length
umbrella mpg weight length, by(foreign) highlow(L H H)
umbrella mpg weight length, by(foreign) highlow(L H H) ranktable id(make)
umbrella mpg weight length, by(foreign) highlow(H L L) ranktable id(make)
umbrella mpg weight length, by(foreign) highlow(H H H) ranktable id(make)
umbrella mpg weight length, by(foreign) 
log close


