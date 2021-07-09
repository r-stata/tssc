capture program drop _welcom_vers
program define       _welcom_vers

local  inst_ver   2.00
local  inst_dat  "30June2018"

dis _n
qui include http://dasp.ecn.ulaval.ca/welcom/Installer/version
dis _col(5) "- Installed WELCOM"_col(33) ": Version `inst_ver'"         _col(50)  "| Date: `inst_dat'  "
dis _col(5) "- Available updated WELCOM" _col(33) ": Version $srv_ver " _col(50) "| Date: $srv_dat  "

cap macro drop srv_dat
cap macro drop srv_ver

end


