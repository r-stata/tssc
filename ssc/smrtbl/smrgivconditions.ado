*! 2.0.0 Adam Ross Nelson 10mar2018 // Made ifable, inable, and byable
*! Companion program for smrtbl smrcol & smrfmn.

capture program drop smrgiveconditions
program smrgivconditions
	syntax [if] [in] [, NOCond]
	if "`nocond'" == "" {
		if "`if'" != "" {
			putdocx paragraph
			putdocx text ("Filters and conditions : `if'"), italic linebreak
		}
		if "`in'" != "" {
			putdocx paragraph
			putdocx text ("Filters and conditions : `in'"), italic linebreak
		}
	}
end
