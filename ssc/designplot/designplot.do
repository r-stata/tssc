set scheme s1color

sysuse auto, clear

designplot mpg foreign rep78

more 

designplot mpg foreign rep78 if !missing(foreign,rep78), stat(count) recast(hbar) blabel(total) ///
yla(none) t1title("frequencies") variablelabels ytitle("") ysc(r(0 72))

more 

designplot mpg foreign rep78, stat(min p25 median mean p75 max) maxway(1) legend(row(1))

more 

infix class 1-9 adult 10-18 male 19-27 survived 28-36 using http://www.amstat.org/publications/jse/datasets/titanic.dat.txt, clear
label def class 0 crew 1 first 2 second 3 third
label def adult 1 adult 0 child
label def male 1 male 0 female
label def survived 1 yes 2 no
foreach v in class adult male survived {
    label val `v' `v'
}

designplot survived class adult male, max(2) ysize(7)

