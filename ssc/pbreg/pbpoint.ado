********************************************************************************************************************************
* pbpoint fits the Preece and Baines 1978 family of growth curves.
* version 1.0
* Author: Adrian Sayers
* Date: 06.03.2013
*
********************************************************************************************************************************
	prog define pbpoint , sclass
		version 9.2
		syntax varlist(min=2 max=2 numeric) [if] [in] , [Model( integer 1) iterate(integer 100)  ]

tokenize `varlist'
	tempname outcome time
		gen `outcome' = `1'
		gen `time' = `2'

		if `model'==1 |`model'==2 {


		if `model'==1 {
		qui nlcom 	(h1: _b[/h1]) (htheta: _b[/htheta]) (s0: _b[/s0]) (s1: _b[/s1]) (theta: _b[/theta]) (g: 1) , post
						}
		if `model'==2 {
		qui nlcom 	(h1: _b[/h1]) (htheta: _b[/htheta]) (s0: _b[/s0]) (s1: _b[/s1]) (theta: _b[/theta]) (g: _b[/ga]) , post
					}


# delimit ;
noisily di _n "Calculating Point Estimates" _n ;

local nliterate = `iterate' ;
* Calculate values of s ;

capture nlcom 	(s_neg: ( - _b[g] * (_b[s0] + _b[s1]) - sqrt(_b[g]^2 * (_b[s0] - _b[s1])^2 - 4*_b[g] * _b[s0] * _b[s1] )) / ( - 2 - 2 * _b[g]))
		(s_pos: ( - _b[g] * (_b[s0] + _b[s1]) + sqrt(_b[g]^2 * (_b[s0] - _b[s1])^2 - 4 * _b[g] * _b[s0] * _b[s1] )) / ( - 2 - 2 * _b[g]))
		(h1: _b[h1]) (htheta: _b[htheta]) (s0: _b[s0]) (s1: _b[s1]) (theta: _b[theta]) (g: _b[g])		, post iterate(`nliterate');

if _rc!=0 {; di as err "Point Estimates Fail" ; exit _rc ; } ;

* Calculate age at phv , and take off ;

capture nlcom	(t_neg: _b[theta] + (log( - (_b[s_neg] - _b[s1]) / (_b[s_neg] - _b[s0])) / (_b[g] * (_b[s0] - _b[s1] ))))
(t_pos: _b[theta] + (log( - (_b[s_pos] - _b[s1]) / (_b[s_pos] - _b[s0])) / (_b[g] * (_b[s0] - _b[s1]))))
(h1: _b[h1]) (htheta: _b[htheta]) (s0: _b[s0]) (s1: _b[s1]) (theta: _b[theta]) (g: _b[g]) (s_neg: _b[s_neg]) (s_pos: _b[s_pos]) , post iterate(`nliterate') ;

if _rc!=0 {; di as err "Point Estimates Fail" ; exit _rc ; } ;

* Calculate Max velocity ;

capture nlcom 	(ht_vel_pos: _b[h1] - ((_b[h1] - _b[htheta]) / (((0.5 * exp(_b[g] * _b[s0] * (_b[t_pos]-_b[theta]))) + (0.5 * exp(_b[g] * _b[s1] * (_b[t_pos] - _b[theta]))))^(1 / _b[g]))))
		(ht_vel_neg: _b[h1] - ((_b[h1] - _b[htheta]) / (((0.5 * exp(_b[g] * _b[s0] * (_b[t_neg]-_b[theta]))) + (0.5 * exp(_b[g] * _b[s1] * (_b[t_neg] - _b[theta]))))^(1 / _b[g]))))
	(h1: _b[h1]) (htheta: _b[htheta]) (s0: _b[s0]) (s1: _b[s1]) (theta: _b[theta]) (g: _b[g])
	(s_neg: _b[s_neg]) (s_pos: _b[s_pos])  (t_neg: _b[t_neg]) (t_pos: _b[t_pos])
	, post iterate(`nliterate') ;

if _rc!=0 {; di as err "Point Estimates Fail" ; exit _rc ; } ;


capture nlcom 	(vel_pos:  _b[s_pos] * (_b[h1] - _b[ht_vel_pos]) )
		(vel_neg:  _b[s_neg] * (_b[h1] - _b[ht_vel_neg]) )
		(h1: _b[h1]) (htheta:_b[htheta]) (s0:_b[s0]) (s1:_b[s1]) (theta:_b[theta]) (g:_b[g])
		(s_neg: _b[s_neg]) (s_pos: _b[s_pos]) (t_neg: _b[t_neg]) (t_pos: _b[t_pos]) (ht_vel_pos: _b[ht_vel_pos]) (ht_vel_neg: _b[ht_vel_neg])
		, post iterate(`nliterate') ;

if _rc!=0 {; di as err "Point Estimates Fail" ; exit _rc ; } ;

local h1  = _b[h1] ;
local htheta	= _b[htheta] ;

if `h1' > `htheta' { ;
 capture noisily nlcom 	 (age_at_take_off: _b[t_pos]) 	(ht_at_take_off: _b[ht_vel_pos]) 	(vel_at_take_off: _b[vel_pos])
   				 (age_at_phv : _b[t_neg]) 		(ht_at_phv: _b[ht_vel_neg]) 		(phv: _b[vel_neg])
 				 (age_at_finish_off: 0 ) 		(ht_at_finish_off: 0 ) 				(vel_at_finish_off: 0 ), post  level(`level') iterate(`nliterate') ;
 					 if _rc!=0 {; di as err "Point Estimates Fail" ; exit _rc ; } ;
 				 } ;

if `h1' < `htheta' { ;
 capture noisily nlcom 	 (age_at_take_off: 0) 				(ht_at_take_off: 0) 				(vel_at_take_off: 0)
  				 (age_at_phv : _b[t_pos]) 			(ht_at_phv: _b[ht_vel_pos]) 		(phv: _b[vel_pos])
 				 (age_at_finish_off: _b[t_neg] ) 	(ht_at_finish_off: _b[ht_vel_neg] ) (vel_at_finish_off: _b[vel_neg] ), post  level(`level') iterate(`nliterate') ;
						if _rc!=0 {; di as err "Point Estimates Fail" ; exit _rc ; } ;
 				  				 		} ;
estimates store pb_point ;

#delimit cr
}

end
