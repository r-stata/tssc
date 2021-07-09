*! version 1.1 beta  02mar2012
*alexander.schmidt@wiso.uni-koeln.de; moehring@wiso.uni-koeln.de
*postestimation command for mltcooksd


capture program drop mltshowm
program define mltshowm, rclass
version 11.0, missing

syntax [, all]

if "`all'" == "all" {
	est tab FULL WJ* , star b(%5.4f)

}
else {
	est tab $mcdac , star b(%5.4f)
} 





end
