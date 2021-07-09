program define autolog 

*! 1.0 Ian Watson 18 Dec 2002

macro drop DB* 
capture program drop autolog

  version 7.0
  syntax using/ [,sm path(string)]

  if "`sm'" ~=""{        
    local ext=""
    }
    else{
    local ext=".log"
    }
  if "`path'"~=""{
    local mydir="`path'\"
    }
    else{
    local mydir=""
    }

global DB_fname=""
global DB_filename "Enter log file name:"
window control static DB_filename 10 10 100 10
window control edit 10 20 175 8 DB_fname
window control button "OK" 10 40 50 10 DB_ok default
window control button "Cancel" 70 40 50 10 DB_can escape
global DB_ok "exit 3001"
global DB_can "exit 3000"

* change the 400 400 co-ordinates to centre the dialog box on your own screen

capture noisily window dialog "Log file details"  400 400 200 70
if _rc==3001 {
  global DB_fname="$DB_fname"+"`ext'"
  }
  else
if _rc==3000 {
    global DB_fname="`using'"+"`ext'"
  }  
global lfile="`mydir'"+"$DB_fname"

log using $lfile, append

end


