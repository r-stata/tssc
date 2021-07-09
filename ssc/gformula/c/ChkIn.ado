program define ChkIn, sclass
version 9.2
args v varlist
sret clear
local k: list posof "`v'" in varlist
sret local k `k'
if `s(k)' == 0 {
   	noi di as err "`v' is not a valid covariate"
   	exit 198
}
end
