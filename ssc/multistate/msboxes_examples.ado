program define msboxes_examples

	version 11.1
	preserve
	clear

	if `1' == 1 {
		DIS use http://fmwww.bc.edu/repec/bocode/m/multistate_example
		DIS msset, id(pid) states(rfi osi) times(rf os)
		DIS matrix tmat = r(transmatrix)
		DIS matrix list tmat

		DIS msboxes, transmatrix(tmat) id(pid) ///
			xvalues(0.2 0.7 0.45) ///
			yvalues(0.7 0.7 0.2) ///
			statenames(Surgery Recurrence Dead)
	}
	

	if `1' == 2 {
		DIS use http://fmwww.bc.edu/repec/bocode/m/multistate_example
		DIS matrix tmat = (.,1,2,. \ ///
  .,.,.,3 \ ///
  .,.,.,. \ ///
  .,.,.,.)
		DIS matrix list tmat  
 		DIS msset, id(pid) states(rfi osi osi) times(rf os os) transmatrix(tmat)
DIS msboxes, transmatrix(tmat) id(pid) ///
  xvalues(0.2 0.7 0.2 0.7) ///
  yvalues(0.7 0.7 0.2 0.2) ///
  statenames(Surgery Recurrence Dead Dead) ///
  boxheight(0.2) yrange(0.09 0.81) ysize(3)
}
restore
end

program define DIS
	display as input ". `0'"
	`0'
end

