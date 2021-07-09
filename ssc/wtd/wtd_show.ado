*! version 0.1, HS

/* wtd_show */

program define wtd_show
version 8.0

wtd_is

local start : char _dta[wtd_start]
local end : char _dta[wtd_end]
local event : char _dta[wtd_ev]
local exvar : char _dta[wtd_ex]
local id : char _dta[wtd_id]
local cluster : char _dta[wtd_clus]
local scale : char _dta[wtd_scale]

di _n
if "`id'" != "" {
  di in gr "        Subject ID: " in ye "`id'"
}
if "`cluster'" != "" {
  di in gr "        Cluster ID: " in ye "`cluster'"
}

di in gr "        Event time: " in ye "`event'"
di in gr "         Exit time: " in ye "`exvar'"
di in gr "obs. time interval: " in ye "(`start', `end']"
di in gr "             Scale: " in ye "`scale'"
noi tab _ot [fw = _nev]

end

