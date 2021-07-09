*! version 1.1.1 Stephen P. Jenkins September 2004

program define hshaz_ll

	version 8.2

	args todo b lnf


	if $S_E_nmp == 2 {

		tempvar I logitp2 m2 h1 h2 sum1 sum2 ST1 ST2 last lnfi
		tempname p2


		mleval `I' = `b'
		mleval `m2' = `b', scalar eq(2)
		mleval `logitp2' = `b', scalar eq(3)

		quietly {

			scalar `p2' = invlogit(`logitp2')
			by $S_E_id: gen double `h1' = 1-exp(-exp(`I')) 
			by $S_E_id: gen double `h2' = 1-exp(-exp(`I' + `m2')) 

			by $S_E_id: gen double `sum1' = sum(exp(`I'))
			by $S_E_id: gen double `sum2' = sum(exp(`I' + `m2'))

			by $S_E_id: gen double `ST1' = exp(-`sum1'[_N]) if _n==_N
			by $S_E_id: gen double `ST2' = exp(-`sum2'[_N]) if _n==_N

			by $S_E_id: gen byte `last' = (_n==_N)

			gen double `lnfi' = cond(!`last',0,	///
				ln( (1-`p2')*`ST1' * (`h1'/(1-`h1'))^$ML_y1 	///
				+ `p2'*`ST2' * (`h2'/(1-`h2'))^$ML_y1 )	)
			mlsum `lnf' = `lnfi'

		}
	}

	if $S_E_nmp == 3 {

		tempvar I logitp2 logitp3 m2 m3 h1 h2 h3 ///
			sum1 sum2 sum3 ST1 ST2 ST3 last lnfi
		tempname p2 p3


		mleval `I' = `b'
		mleval `m2' = `b', scalar eq(2)
		mleval `m3' = `b', scalar eq(3)
		mleval `logitp2' = `b', scalar eq(4)
		mleval `logitp3' = `b', scalar eq(5)

		quietly {

			scalar `p2' = invlogit(`logitp2')
			scalar `p3' = invlogit(`logitp3')

			by $S_E_id: gen double `h1' = 1-exp(-exp(`I')) 
			by $S_E_id: gen double `h2' = 1-exp(-exp(`I' + `m2')) 
			by $S_E_id: gen double `h3' = 1-exp(-exp(`I' + `m3')) 

			by $S_E_id: gen double `sum1' = sum(exp(`I'))
			by $S_E_id: gen double `sum2' = sum(exp(`I' + `m2'))
			by $S_E_id: gen double `sum3' = sum(exp(`I' + `m3'))

			by $S_E_id: gen double `ST1' = exp(-`sum1'[_N]) if _n==_N
			by $S_E_id: gen double `ST2' = exp(-`sum2'[_N]) if _n==_N
			by $S_E_id: gen double `ST3' = exp(-`sum3'[_N]) if _n==_N

			by $S_E_id: gen byte `last' = (_n==_N)

			gen double `lnfi' = cond(!`last',0,	///
					ln( (1-`p2'-`p3')*`ST1' * (`h1'/(1-`h1'))^$ML_y1 	///
					+ `p2'*`ST2' * (`h2'/(1-`h2'))^$ML_y1 		///
					+ `p3'*`ST3' * (`h3'/(1-`h3'))^$ML_y1 ) )
			mlsum `lnf' = `lnfi'

		}
	}

	if $S_E_nmp == 4 {

		tempvar I logitp2 logitp3 logitp4 m2 m3 m4 h1 h2 h3 h4 ///
			sum1 sum2 sum3 sum4 ST1 ST2 ST3 ST4 last lnfi
		tempname p2 p3 p4


		mleval `I' = `b'
		mleval `m2' = `b', scalar eq(2)
		mleval `m3' = `b', scalar eq(3)
		mleval `m4' = `b', scalar eq(4)
		mleval `logitp2' = `b', scalar eq(5)
		mleval `logitp3' = `b', scalar eq(6)
		mleval `logitp4' = `b', scalar eq(7)

		quietly {

			scalar `p2' = invlogit(`logitp2')
			scalar `p3' = invlogit(`logitp3')
			scalar `p4' = invlogit(`logitp4')

			by $S_E_id: gen double `h1' = 1-exp(-exp(`I')) 
			by $S_E_id: gen double `h2' = 1-exp(-exp(`I' + `m2')) 
			by $S_E_id: gen double `h3' = 1-exp(-exp(`I' + `m3')) 
			by $S_E_id: gen double `h4' = 1-exp(-exp(`I' + `m4')) 

			by $S_E_id: gen double `sum1' = sum(exp(`I'))
			by $S_E_id: gen double `sum2' = sum(exp(`I' + `m2'))
			by $S_E_id: gen double `sum3' = sum(exp(`I' + `m3'))
			by $S_E_id: gen double `sum4' = sum(exp(`I' + `m4'))

			by $S_E_id: gen double `ST1' = exp(-`sum1'[_N]) if _n==_N
			by $S_E_id: gen double `ST2' = exp(-`sum2'[_N]) if _n==_N
			by $S_E_id: gen double `ST3' = exp(-`sum3'[_N]) if _n==_N
			by $S_E_id: gen double `ST4' = exp(-`sum4'[_N]) if _n==_N

			by $S_E_id: gen byte `last' = (_n==_N)

			gen double `lnfi' = cond(!`last',0,	///
				 ln( (1-`p2'-`p3'-`p4')*`ST1' * (`h1'/(1-`h1'))^$ML_y1 	///
					+ `p2'*`ST2' * (`h2'/(1-`h2'))^$ML_y1 		///
					+ `p3'*`ST3' * (`h3'/(1-`h3'))^$ML_y1 		///
					+ `p4'*`ST4' * (`h4'/(1-`h4'))^$ML_y1 	) )
			mlsum `lnf' = `lnfi'
		}
	}

	if $S_E_nmp == 5 {

			tempvar I logitp2 logitp3 logitp4 logitp5 m2 m3 m4 m5 h1 h2 h3 h4 h5 ///
				sum1 sum2 sum3 sum4 sum5 ST1 ST2 ST3 ST4 ST5 last lnfi
			tempname p2 p3 p4 p5


			mleval `I' = `b'
			mleval `m2' = `b', scalar eq(2)
			mleval `m3' = `b', scalar eq(3)
			mleval `m4' = `b', scalar eq(4)
			mleval `m5' = `b', scalar eq(5)
			mleval `logitp2' = `b', scalar eq(6)
			mleval `logitp3' = `b', scalar eq(7)
			mleval `logitp4' = `b', scalar eq(8)
			mleval `logitp5' = `b', scalar eq(9)

			quietly {

				scalar `p2' = invlogit(`logitp2')
				scalar `p3' = invlogit(`logitp3')
				scalar `p4' = invlogit(`logitp4')
				scalar `p5' = invlogit(`logitp5')

				by $S_E_id: gen double `h1' = 1-exp(-exp(`I')) 
				by $S_E_id: gen double `h2' = 1-exp(-exp(`I' + `m2')) 
				by $S_E_id: gen double `h3' = 1-exp(-exp(`I' + `m3')) 
				by $S_E_id: gen double `h4' = 1-exp(-exp(`I' + `m4')) 
				by $S_E_id: gen double `h5' = 1-exp(-exp(`I' + `m5')) 

				by $S_E_id: gen double `sum1' = sum(exp(`I'))
				by $S_E_id: gen double `sum2' = sum(exp(`I' + `m2'))
				by $S_E_id: gen double `sum3' = sum(exp(`I' + `m3'))
				by $S_E_id: gen double `sum4' = sum(exp(`I' + `m4'))
				by $S_E_id: gen double `sum5' = sum(exp(`I' + `m5'))

				by $S_E_id: gen double `ST1' = exp(-`sum1'[_N]) if _n==_N
				by $S_E_id: gen double `ST2' = exp(-`sum2'[_N]) if _n==_N
				by $S_E_id: gen double `ST3' = exp(-`sum3'[_N]) if _n==_N
				by $S_E_id: gen double `ST4' = exp(-`sum4'[_N]) if _n==_N
				by $S_E_id: gen double `ST5' = exp(-`sum5'[_N]) if _n==_N

				by $S_E_id: gen byte `last' = (_n==_N)

				gen double `lnfi' = cond(!`last',0,	///
					ln( (1-`p2'-`p3'-`p4'-`p5')*`ST1' * (`h1'/(1-`h1'))^$ML_y1 	///
						+ `p2'*`ST2' * (`h2'/(1-`h2'))^$ML_y1 		///
						+ `p3'*`ST3' * (`h3'/(1-`h3'))^$ML_y1 		///
						+ `p4'*`ST4' * (`h4'/(1-`h4'))^$ML_y1 		///
						+ `p5'*`ST5' * (`h5'/(1-`h5'))^$ML_y1 ) )
				mlsum `lnf' = `lnfi'
			}



	}



end

