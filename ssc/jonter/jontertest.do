version 7.0
drawnorm latency dose, corr(1, 0.5 \ 0.5, 1) seed(`=date("2006-11-23", "ymd")') n(25) clear
summarize dose, meanonly
replace dose = floor(10 * (dose - r(min)) / (r(max) - r(min)))
replace latency = floor(250 + 100 * exp(latency))
nptrend latency, by(dose)
ktau latency dose
jonter latency, by(dose) continuity
jonter latency, by(dose)
assert (!mi(latency) & !mi(dose))
permute latency J = r(J), reps(1000) right nodots seed(`=date("2006-11-23", "ymd")'): jonter latency, by(dose) jonly
permute latency score = r(score), reps(1000) right nodots seed(`=date("2006-11-23", "ymd")'): ktau latency dose
exit
