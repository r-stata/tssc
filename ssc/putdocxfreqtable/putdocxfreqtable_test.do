cd C:\Midlertidig_Lagring\putdocxfreqtable
capture program drop putdocxfreqtable
sysuse auto , clear
egen pricecat = cut(price), at(0,5000,10000,999999) label
*egen pricecat = cut(price), at(0,5000,10000,999999) 
label variable pricecat "Price (categorical)"
tab pricecat

putdocx clear
putdocx begin
putdocx paragraph, style(Title)
putdocx text ("Test of putdocxfreqtable")

putdocx paragraph, style(Heading1)
putdocx text ("Standard, no options")
putdocxfreqtable pricecat 

putdocx paragraph, style(Heading1)
putdocx text ("Nosum")
putdocxfreqtable pricecat , nosum

putdocx paragraph, style(Heading1)
putdocx text ("Nocum")
putdocxfreqtable pricecat , nocum

putdocx paragraph, style(Heading1)
putdocx text ("Nocum nosum")
putdocxfreqtable pricecat , nocum nosum

putdocx paragraph, style(Heading1)
putdocx text ("Percent digits 0")
putdocxfreqtable pricecat , percd(0)

putdocx paragraph, style(Heading1)
putdocx text ("Percent digits 3")
putdocxfreqtable pricecat , percd(3)

putdocx paragraph, style(Heading1)
putdocx text ("Percent digits 2, nocum")
putdocxfreqtable pricecat , percd(2) nocum 

putdocx paragraph, style(Heading1)
putdocx text ("Percent digits 2, nocum, nosum")
putdocxfreqtable pricecat , percd(2) nocum nosum

label list pricecat
label drop pricecat
foreach i of numlist 1(1)32 {
	local mediumlabel "`mediumlabel'm"
}
foreach i of numlist 1(1)300 {
	local longlabel "`longlabel'l"
}
label define pricecatlong ///
	0 "0-" ///	
	1 "`mediumlabel'" ///
	2 "`longlabel'"
label list pricecatlong
label values pricecat pricecatlong 
tab pricecat

putdocx paragraph, style(Heading1)
putdocx text ("Long labels of 300 characters")
putdocxfreqtable pricecat 

putdocx paragraph, style(Heading1)
putdocx text ("Labels truncated at 5 characters")
putdocxfreqtable pricecat , lablen(5)

putdocx paragraph, style(Heading1)
putdocx text ("Label length -1")

cap putdocxfreqtable pricecat , lablen(-1)
if _rc == 120 {
	putdocx paragraph
	putdocx text ("Option lablen failed as expected when its value was -1.")
}
else {
	putdocx paragraph
	putdocx text ("Option lablen DID NOT fail as expected when its value was -1.")
}


putdocx save "auto.docx", replace
