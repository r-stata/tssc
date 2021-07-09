
capture program drop simpctile

program simpctile, rclass
	version 10.1
	drop _all
	set obs 200
	generate z = invnormal(uniform())
	summarize z, detail
	return scalar p25 = r(p25)
	return scalar p50 = r(p50)
	return scalar p75 = r(p75)
end
