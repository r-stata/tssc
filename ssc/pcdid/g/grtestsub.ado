//////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// Code version (v1.01): Feb 15, 2021 (v1.0: Feb 09,2021)												   ///
/// list of ado files: pcdid.ado, grtestsub.ado, pdd.ado												   ///
/// This code implements the PCDID estimator by Marc K. Chan and Simon Kwok,                               ///
/// "The PCDID Approach: Difference-in-Differences when Trends are Potentially Unparallel and Stochastic", ///
/// also previously circulated as "Policy Evaluation with Interactive Fixed Effects"                       ///
/// For more details, visit https://sites.google.com/site/marcchanecon/									   ///
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

/***************************************************************************/
/* 20210207: recursive GR test (must run it after command pca) */
	program define grtestsub
		version 14			/* v1.01 add */
		mat eigyy = e(Ev)'
		scalar eigyysum = 0			/* compute sum of eigenvalues */
		*mata : st_matrix("sumtmp", colsum(st_matrix("eigyy")) )    /* mata function to compute max value (not used, use simple command instead) */
		forval i= 1/`=rowsof(eigyy)' {
			scalar eigyysum = eigyysum + eigyy[`i',1]
		}
		mat gr = J(`=scalar(kmax)',1,0)
		mat vmuk = J(`=scalar(kmax)',2,0)
		mat vmuk[1,1] = `=scalar(eigyysum)' - eigyy[1,1]
		mat vmuk[1,2] = ln(1 + eigyy[1,1]/vmuk[1,1])
		forval i= 2/`=scalar(kmax)' {
			mat vmuk[`i',1] = vmuk[`i'-1,1] - eigyy[`i',1]
			if (abs(vmuk[`i',1])<0.000000001 | vmuk[`i',1] == . ) {
				mat vmuk[`i',2] = 0
				mat gr[`i'-1,1] = 0
			}
			else {
				mat vmuk[`i',2] = ln(1 + eigyy[`i',1]/vmuk[`i',1])
				mat gr[`i'-1,1] = vmuk[`i'-1,2] / vmuk[`i',2]
			}			
		}
		scalar factnum = 1
		scalar stmp = gr[1,1]
		forval i= 2/`=scalar(kmax)' {
			if ( gr[`i',1] > stmp ){
				scalar stmp = gr[`i',1]				
				scalar factnum = `i'			/* v1.01: fix bug in v1.0 */
			}
		}
	end program grtestsub
/***************************************************************************/
