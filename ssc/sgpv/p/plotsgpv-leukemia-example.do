*!plotsgpv-leukemia-example.do
*!Used to run the example which could otherwise not be executed from within the help file.	
preserve
	sysuse leukstats ,clear 
	plotsgpv, esthi(ci_hi) estlo(ci_lo) nulllo(-0.3) nullhi(0.3)  setorder(p_value) xshow(7000) title("Leukemia Example") ///
	xtitle("Classical p-value ranking") ytitle("Fold Change (base 10)") nullpt(0) nomata replace noshow ///
	twoway_opt(ylabel(`=log10(1/1000)' "1/1000" `=log10(1/100)' "1/100" `=log10(1/10)' "1/10" `=log10(1/2)' "1/2" `=log10(2)' ///
	"2" `=log10(10)' "10" `=log10(100)' "100" `=log10(1000)'  "1000")) 
restore
