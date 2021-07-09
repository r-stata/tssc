// Kernel BS
capture program drop diffbs
program define diffbs
version 10.0
syntax varlist [in] [if] [aw]
reg `varlist' `if' `in' [aw = _weights]
end
