
/* 


pvtest

This program is used for testing SINGLE linear combinations of previously estimated coefficients

The difference between using this and the regular test command is that the t statistic is calculated according to the tech
reports

It assumes that

	1. the coefficients have been saved in e(b)
	2. the total variance-covariance matrix has been saved in e(V)
	3. the imputation variance-covariance matrix has been saved in e(B)
	4. the degrees of freedom had their been no PV's is saved in e(df_p)
	5. the number of plausible values has been saved as e(pv_n)


*/

	program define pvtest, rclass

		version 9.0

	/* 1. Run the test command to get restriction matrix */

		test `0'

	/* 2. Setup the linear combination */

		tempname Rr eV nb R J b V B

		mat `Rr' = get(Rr)

		matrix `eV' = e(V)

		local `nb' = rowsof(`eV')

		mat `R' = `Rr'[1...,1..``nb'']	

		scalar `J' = rowsof(`R')
    
		matrix `b' = `R'*e(b)' - `Rr'[1...,`=``nb''+1']

		matrix `V' = `R'*e(V)*`R''

		matrix `B' = `R'*e(B)*`R''

	/* 3. Display Results */

		tempname O PV SE talpha rows row

		matrix `O' = J(`J',5,0)

		matrix `PV' = J(`J', 1, .)

		matrix `SE' = J(`J', 1, .)

		matrix colnames `O' = "Coef" "Std Err" "t" "t Param" "P>|t|"

		local `talpha' = (1 - (0.95)) / 2 

		local `rows' = `J'

		tempname fm df 

		forvalues `row' = 1 (1) ``rows'' {

			scalar `fm'=(1 + (1 / e(pv_n)))*`B'[``row'',``row'']/`V'[``row'',``row'']

			scalar `df' = 1/((`fm'^2/(e(pv_n)-1)) + (((1-`fm')^2)/(e(df_p))))

			if `df' == . {

				scalar `df' = e(df_p)

			}
		
			matrix `O'[``row'',1] = `b'[``row'',1]

			matrix `O'[``row'',2] = sqrt(`V'[``row'',``row''])

			matrix `SE'[``row'',1] = `O'[``row'',2]

			matrix `O'[``row'',3] = `b'[``row'',1] / sqrt(`V'[``row'',``row''])

			matrix `O'[``row'',4] = `df'

			matrix `O'[``row'',5] = 2*ttail(`df', abs(`O'[``row'', 3]))

			matrix `PV'[``row'',1] = `O'[``row'',5]

		}

		di

		di in gr "Linear Restrictions:"

		matrix list `O', noheader	

		di

	/* 4. Save Results */	

		return matrix b = `b'

		return matrix V = `V'

		return matrix B = `B'

		return matrix SE = `SE'

		return matrix PV = `PV'

		return scalar df_p = e(df_p)

		return scalar pv_n = e(pv_n)

	end





