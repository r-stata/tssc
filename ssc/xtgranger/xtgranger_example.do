xtset cert time
xtgranger roa inefficiency quality, maxlags(4) het
xtgranger roa inefficiency, maxlags(4) het
xtgranger roa quality, maxlags(4) het
xtgranger roa inefficiency quality, maxlags(4) het sum, if cluster==2 & time>20