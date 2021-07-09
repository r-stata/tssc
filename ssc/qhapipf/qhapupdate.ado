*! Date    : 25 Sep 2001
*! Version : 1.1
*! Author  : Adrian Mander
*! Email   : adrian.mander@mrc-bsu.cam.ac.uk

prog def qhapupdate
version 7.0
local push=`1'

global Qmod1 "1"
global statloc1 "ERROR no loci specified"
global Qhapint ""
local i 1
tokenize $Qvar
while "`1'"~="" {
  if "`2'"~="" {
    qui tab `1',matrow(winrow)
    local first = winrow[1,1]
    if "$Qhapint"=="" { global Qhapint "`first'" }
    else { global Qhapint "$Qhapint.`first'" }
    global statloc`i' "Locus `i' (`1',`2')"
  }
  else {
    global statloc`i' "ERROR at locus `i'"
    local ii = `i'+1
    global statloc`ii' "need PAIRED variables"
  }
  if `i'==1 {
    global Qipf "l1"
    global Qmod2 "[l1+l1]"
    global Qmod3 "[l1+l1]"
    global Qmod4 "[l1*l1]"
    global Qmod5 "[l1a*l1b]"
  }
  else {
    global Qipf "$Qipf*l`i'"
    global Qmod2 "$Qmod2+[l`i'+l`i']"
    global Qmod3 "$Qmod3*[l`i'+l`i']"
    global Qmod4 "$Qmod4*[l`i'*l`i']"
    global Qmod5 "$Qmod5*[l`i'a*l`i'b]"
   
  }
  
  local i = `i'+1
  mac shift 2
}
if "$Qhi_rad"=="2" { global Qhapint "all" }
if "$Qhapint"==""  { global Qhapint "<specify haplotype>" }

local mod = "Qmod$Qrad"
global Qadd "$`mod'"

if "$Qtvar"~="" {
  global infoqt1 "Quantitative Trait"
  global infoqt "$Qtvar"
}
if "$Qtvar"=="" {
  global infoqt1 "ERROR - specify the"
  global infoqt "Quantitative Trait"
}

global Qcommand "qhapipf $Qvar, qt($Qtvar) ipf($Qipf) reg($Qadd) hap($Qhapint)"
if "`push'"=="1" { window push $Qcommand }

global Qdis "Syntax is:"

window dialog update
end
