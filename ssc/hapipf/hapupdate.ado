prog def hapupdate
version 7.0
local push=`1'

local i 1
tokenize $Qvar
while "`1'"~="" {
  local ii = `i'+1
  global statloc`ii' ""
  if "`2'"~="" { global statloc`i' "Locus `i' (`1',`2')"}
  else {
    global statloc`i' "ERROR at locus `i'"
    local ii = `i'+1
    global statloc`ii' "need PAIRED variables"
  }
  if `i'==1 {
    global Qipf "l1"
    global Qmod1 "l1"
    global Qmod2 "l1"
    global Qmod3 "l1"
    global Qmod4 "l1"
  }
  else {
    global Qipf "$Qipf*l`i'"
    global Qmod1 "$Qmod1*l`i'"
    global Qmod2 "$Qmod2+l`i'"
    global Qmod3 "$Qmod3*l`i'"
    global Qmod4 "$Qmod4*l`i'"
   
  }
  local i = `i'+1
  mac shift 2
}

if "$Qtvar"~="" {
  global infoqt1 "Disease"
  global infoqt "$Qtvar"
  global Qmod3 "$Qmod3*$Qtvar"
  global Qmod4 "$Qmod4+$Qtvar"
}
else {
   global Qmod3 "no disease variable"
   global Qmod4 "no disease variable"
}

local mod = "Qmod$Qrad"
global Qipf "$`mod'"

global Qcommand "hapipf $Qvar, ipf($Qipf)"
if "`push'"=="1" { window push $Qcommand }

global Qdis "Command:"

window dialog update
end
