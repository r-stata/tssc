capture program drop _subsim_vers
program define       _subsim_vers

local  inst_ver   3.03
local  inst_dat  "27January2015"

dis _n
qui include http://www.subsim.org/modules/subsim3/Installer/version
dis _col(5) "- Installed SUBSIM"_col(33) ": Version `inst_ver'" _col(50) "| Date: `inst_dat'  "
dis _col(5) "- Available updated SUBSIM" _col(33) ": Version $srv_ver " _col(50) "| Date: $srv_dat  "

cap macro drop srv_dat
cap macro drop srv_ver

end


