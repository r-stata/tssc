/*Program to estimate power for interaction effects by simulation*/
/*v1.0.0 05 Apr 2014*/
/*v1.0.1 14 Apr 2014: 	add missing data mechanisms*/
/*v1.0.2 16 Apr 2014: 	add mi impute and mi estimate approaches*/
/*v1.0.3 17 Apr 2014: 	make continuous exposure acceptable*/
/*v1.0.4 20 Apr 2014: 	allow random-effects covariance matrix*/
/*v1.0.5 25 Apr 2014: 	changed distribution of higher unit size from uniform to Poisson
						added option for cluster randomisation
						added option for higher level units to be as close as possible as an alternative to Poisson distribution*/
/*v1.0.6 30 Apr 2014:	added expanded outputs for the outcome, as feedbacks to help users adjust input betas if needed*/
/*v1.1.0 25 Feb 2015:	debugged covariance matrix issue
                        beautified outputs*/
/*v1.1.1 27 May 2016:	seed number is not set automatically any more*/
/*v1.2.0 02 Aug 2017:	added high-level variability in distribution of binary covariate*/
program define ipdpower, rclass
	/*stata version define*/
	version 12.1
    /*command syntax*/
    syntax, sn(integer) ssl(integer) ssh(integer) b0(real) b1(real) b2(real) b3(real) [minsh(integer 50) hpoisson icluster outc(string) cb(real 0.5) cexp cexpd(string) errsd(real 1) /*
	*/ sderrsd(real 0) derr(string) bcov bcb(real 0.5) bsd(real 0) ccovd(string) slcov model(integer 1) tsq0(real 0) tsq1(real 0) tsq2(real 0) tsq3(real 0) dtp0(string) /*
	*/ dtp1(string) dtp2(string) dtp3(string) covmat(name) missp(real -127.77) mar(real -127.77) mnar(real -127.77) minum(integer -127) mipmm(integer -127) /*
	*/ clvl(real 95) seed(integer -127) nskip dnorm xnodts NODIsplay moreon]

	/*INPUTS-model*/
	/*mandatory*/
	/*number of simulations*/
	scalar simnum=`sn'
	/*total size of cases (patients)*/
	scalar totalsize=`ssl'
	/*number of studies*/
	scalar studynum=`ssh'
	/*minimum size of study*/
	scalar minsize=`minsh'
	scalar meansize=totalsize/studynum
	/*issue errors*/
	if "`hpoisson'"=="" {
		if meansize<minsize {
      		di as error "Overall study size too small: increase or reduce # of studies and/or minimum study size"
      		error 197
		}
	}
	else {
		//arbitrary rule, meansize needs to be at least 5
		if meansize<5 {
      		di as error "Overall study size too small: needs to be at least 5"
      		error 197
		}	
	}
	/*if user wants poisson distributed study sizes*/
	scalar hlpos=0
	if "`hpoisson'"!="" {
        /*cannot be issued with mininum higher unit size*/
        if minsize!=50 {
		  di as error "Minimum higher unit size cannot be defined when Poisson distribution for higher unit sizes is selected"
		  error 197
        }
        scalar hlpos=1
    }
    /*clustered intervention i.e. cluster-RCT*/
	scalar iclus=0
	if "`icluster'"!="" {
        /*cannot be used with continuous exposure*/
        if "`cexp'"!="" {
		  di as error "Clustered intervention (i.e. cluster RCT) cannot be selected when exposure is continuous"
		  error 197
        }
        /*cannot be used unbalanced designs*/
        if `cb'!=0.5 {
		  di as error "Clustered intervention (i.e. cluster RCT) cannot be selected with unbalanced designs"
		  error 197
        }
        /*warning - probably wiser to use with hPoisson for more closely matched cluster, as would be the case in practice*/
        if hlpos==0 {
		  di as error "Warning: probably more realistic to select clustered intervention (icluster) with more closely matched clusters (hpoisson)"
        }
        scalar iclus=1
    }

	/*INPUTS-general optional*/
	/*level*/
	scalar clvl=`clvl'
	set level `=clvl'
	/*seed*/
	if `seed'!=-127 {
	   set seed `seed'
        }
	/*display options*/
	set more off
	if "`moreoff'"!="" {
		set more on
	}
	scalar didots=1
	if "`xnodts'"!="" {
		scalar didots=0
	}
	scalar dioutp=1
	if "`nodisplay'"!="" {
		scalar dioutp=0
	}

	/*INPUTS-specific*/
	/*proportion of the intervention group*/
	if `cb'<=0 | `cb'>=1 {
		di as error "Probability for cases must be in the (0,1) range"
		error 197
	}
	scalar caseprob=`cb'
	/*continuous exposure*/
	scalar binexp=1
	if "`cexp'"!="" {
        if `cb'!=0.5 {
		    di as error "Option cb(#), probability for exposure, cannot be used when exposure is defined as continuous"
		    error 197
        }
    	scalar binexp=0
    	/*exposure mean and sd - fixed to standardised*/
    	scalar expmn=0
		scalar expsd=1
    }
    else {
        /*distribution for covariate*/
	    if "`cexpd'"!="" {
            di as error "Option cexpd(), distribution for exposure, cannot be used when exposure is defined as dichotomous"
		    error 197
        }
    }
	/*distribution for exposure*/
	if "`cexpd'"=="" {
    	scalar distexp=0
    }
    else {
    	if inlist("`cexpd'","norm","sknorm","xsknorm")==0 {
        	di as error "Distribution of exposure:"
        	di as error _col(2) "'cexpd(norm)': default, normal distribution"
        	di as error _col(2) "'cexpd(sknorm)': moderate skew (sk=1, ku=4)"
        	di as error _col(2) "'cexpd(xsknorm)': extreme skew (sk=2, ku=9)"
        	error 197
        }
        if "`cexpd'"=="norm" {
            scalar distexp=0
        }
        else if "`cexpd'"=="sknorm" {
            scalar distexp=1
        }
        else if "`cexpd'"=="xsknorm" {
            scalar distexp=2
        }
    }
	/*type of outcome: default "cont"(linear)=0, "binr"(logit)=1, "count"(poisson)=2*/
	if "`outc'"=="" {
        scalar outtp=0
    }
    else {
    	if inlist("`outc'","cont","binr","count")==0 {
    		di as error "Outcome can be continuous (outc(cont) - default), binary (outc(binr)) or count data (outc(count))"
    		error 197
    	}
    	else {
        	if "`outc'"=="cont" {
                scalar outtp=0
            }
            else if "`outc'"=="binr" {
                scalar outtp=1
            }
            else if "`outc'"=="count" {
                scalar outtp=2
            }
        }
    }
	/*error variance - only for continuous outcome*/
	if ((`errsd'!=1 | `sderrsd'!=0) & outtp!=0) | `errsd'<=0 | `sderrsd'<0 {	
		di as error "Error SD can only be set when the outcome is continuous and errsd>0, sderrsd>=0"
		error 197
	}
	if outtp==0 {
		/*Variance of the error terms - affects model fit (R^2) and potentially outcome distribution (i.e. very high outcome skew needs large skewed errors)*/
		scalar mnsd=`errsd'
		scalar cdsd=`sderrsd'
		/*cannot be zero in the code but user might want a zero value*/
		if cdsd==0 scalar cdsd=10^-20
	}
	else {
		scalar mnsd=.
		scalar cdsd=.
	}
	/*model type 1=regress/logit 2=xtreg/xtlogit 3+=xtmixed/xtmelogit*/
	if inlist(`model',1,2,3,4,5,6,7)==0 {
		di as error "Model choice needs to be an integer in the 1-7 range:"
		di as error _col(2) "1: standard regression (regress/logit/poisson)"
		di as error _col(2) "2: random effects regression, for study i.e. intercept (xtreg/xtlogit/xtpoisson)"
		di as error _col(2) "3: fixed common intercept; random treatment effect; fixed effect for baseline (xtmixed/xtmelogit/xtmepoisson)"
		di as error _col(2) "4: fixed study specific intercepts; random treatment effect; fixed study specific effect for baseline"
		di as error _col(2) "5: random study intercept; random treatment effect; fixed study specific effect for baseline"
		di as error _col(2) "6: random study intercept; random treatment effect; random effect for baseline"
		di as error _col(2) "7: random study intercept; random treatment effect; random effect for baseline; random effect for interaction"
		error 197		
	}		
	scalar modtp=`model'
	/*if outcome binary/count and xtlogit/xtpoisson allow noskip option for returning pseudo-R^2 although computationally heavier*/
	if "`nskip'"!="" & (outtp==0 | modtp!=2){
		di as error "Option 'nskip' can only be used with a binary/count outcome and xtlogit/xtpoisson (model=2):"
		di as error _col(2) "allows the 'noskip' option in regression for returning pseudo-R^2 but is computationally heavier"
		error 197		
	}		
	if "`nskip'"=="" {
		scalar nskip=0
	}
	else {
        scalar nskip=1
    }
	/*if outcome count and xtpoisson allow estimation to vary assumption about random effect (gamma=default - normal)*/
	/*if gamma options chosen then better use skewed distributions that are similar to gamma*/
	if "`dnorm'"!="" & (outtp!=2 | modtp!=2){
		di as error "Option 'dnorm' can only be used with a count outcome and xtpoisson (model=2):"
		di as error _col(2) "allows estimation to assume random-effects normally distributed (gamma=default)"
		error 197
	}			
	if "`dnorm'"=="" {
		scalar redist=0
	}
	else {
        scalar redist=1
    }
	/*INPUT-parameters*/
	/*betas*/
	scalar b0=`b0'
	scalar b1=`b1'
	scalar b2=`b2'
	scalar b3=`b3'
	/*heterogeneity*/
	forvalues i=0(1)3 {
		if `tsq`i''<0 {
			di as error "Between-study variance cannot be negative (tsq`i')"
			error 197
		}
	}
	scalar tausq0=`tsq0'	/*intercept*/
	scalar tausq1=`tsq1'	/*grp*/
	scalar tausq2=`tsq2'	/*covariate*/
	scalar tausq3=`tsq3'	/*grp*covariate*/
	/*distribution of random effects info: normal ("norm" - default), moderate skew ("sknorm"), extreme skew ("xsknorm")*/
	forvalues i=0(1)3 {
        //distribution of RE
        if "`dtp`i''"=="" {
            scalar dtype`i'=0
        }
        else {
            if inlist("`dtp`i''","norm","sknorm","xsknorm")==0 {
                di as error "Distribution for random effects can be:"
                di as error _col(2) "'dtp`i'(norm)': default, normal distribution"
                di as error _col(2) "'dtp`i'(sknorm)': moderate skew (sk=1, ku=4)"
                di as error _col(2) "'dtp`i'(xsknorm)': extreme skew (sk=2, ku=9)"
                error 197
            }
            if "`dtp`i''"=="norm" {
                scalar dtype`i'=0
            }
            else if "`dtp`i''"=="sknorm" {
                scalar dtype`i'=1
            }
            else if "`dtp`i''"=="xsknorm" {
                scalar dtype`i'=2
            }
        }
        //heterogeneity
		if tausq`i'==0 & dtype`i'>0 {
			di as error "Distribution for random-effects can only be defined if random-effects assumed, with tausq`i'>0"
			error 197
		}
	}
	/*distribution for errors (and hence outcome) - continuous only*/
	if "`derr'"=="" {
        scalar dtype4=0
    }
    else {
    	if inlist("`derr'","norm","sknorm","xsknorm")==0 {
    		di as error "Distribution for errors:"
    		di as error _col(2) "'derr(norm)': default, normal distribution"
    		di as error _col(2) "'derr(sknorm)': moderate skew (sk=1, ku=4)"
    		di as error _col(2) "'derr(xsknorm)': extreme skew (sk=2, ku=9)"
    		error 197
    	}
    	if outtp!=0 & inlist("`derr'","sknorm","xsknorm")>0 {
    		di as error "Distribution of the errors (and hence outcome) can only be managed if the outcome is continuous"
    		error 197
    	}
      	if "`derr'"=="norm" {
            scalar dtype4=0
        }
        else if "`derr'"=="sknorm" {
            scalar dtype4=1
        }
        else if "`derr'"=="xsknorm" {
            scalar dtype4=2
        }
    }
	/*allow covariance matrix for random effects as an alternative - can't have both*/
	scalar xcovmt=0
	if "`covmat'"!="" {
		scalar xcovmt=1
		foreach x in tausq0 tausq1 tausq2 tausq3 {
        	if `x'>0 {
				di as error "Either a random-effects covariance matrix can be provided or random-effects using"
				di as error "tausq0-tausq3 (their distributions using dtp0-dtp3) - not both."
				error 197
			}
		}
		/*make sure input is matrix*/
		capture confirm matrix `covmat'
		if _rc!=0 {
			di as error "Covariance matrix `covmat' not defined"
			error 197
		}
		/*make sure it is 4x4*/
		scalar terr2=0
		if rowsof(`covmat')!=4 | colsof(`covmat')!=4 {
			scalar terr2=1
		}
		/*make sure no negatives*/
		scalar terr3=0
		scalar mincell=0
		forvalues i=1(1)4 {
        	forvalues j=1(1)4 {
            	if `covmat'[`i',`j']<mincell scalar mincell=`covmat'[`i',`j']
			}
		}
		if mincell<0 scalar terr3=1
		/*symmetric?*/
        scalar terr4=issymmetric(`covmat')
		/*overall error display*/
		if terr2!=0 | terr3!=0 | terr4!=1 {
			matrix tmatA = (0.5,0.2,0.1,0.2\0.2,0.5,0.2,0.1\0.1,0.2,0.5,0.2\0.2,0.1,0.2,0.5)
			di as error "4x4 symmetrical covariance (non-negative) matrix is expected as input with covmat(A), e.g."
			di as result "matrix A=(0.5,0.2,0.1,0.2\0.2,0.5,0.2,0.1\0.1,0.2,0.5,0.2\0.2,0.1,0.2,0.5)"
			matrix list tmatA, noblank noheader nohalf
			di as error "The diagonal elements correspond to the between-variance for intercept(A[1,1]), exposure(A[2,2]),"
			di as error "covariate(A[3,3]) and interaction(A[4,4])."
			error 197
		}
		matrix test1test2test3=`covmat'
                scalar tausq0=test1test2test3[1,1]	/*intercept*/
 	        scalar tausq1=test1test2test3[2,2]	/*exposure*/
	        scalar tausq2=test1test2test3[3,3]	/*covariate*/
	        scalar tausq3=test1test2test3[4,4]	/*exposure*covariate*/
	}
	/*INPUT-covariate*/
	/*continuous covariate (yes=1)*/
    if "`bcov'"=="" {
        scalar cncov=1
		/*distribution for covariate*/
	    if "`ccovd'"=="" {
            scalar dtype5=0
        }
        else {
            if inlist("`ccovd'","norm","sknorm","xsknorm")==0 {
        	   di as error "Distribution of the continuous covariate:"
        	   di as error _col(2) "'ccovd(norm)': default, normal distribution"
        	   di as error _col(2) "'ccovd(sknorm)': moderate skew (sk=1, ku=4)"
        	   di as error _col(2) "'ccovd(xsknorm)': extreme skew (sk=2, ku=9)"
        	   error 197
            }
            if "`ccovd'"=="norm" {
                scalar dtype5=0
            }
            else if "`ccovd'"=="sknorm" {
                scalar dtype5=1
            }
            else if "`ccovd'"=="xsknorm" {
                scalar dtype5=2
            }
        }
		/*mean and sd for covariate*/
		/*needs to be centred since we include as an interaction! if not centred the main effect is off and not interpretable*/
		/*sd needs to be 1. if >1 then power calculations return very high power*/
		scalar covmn=0
		scalar covsd=1
		/*not needed*/
		scalar covprob=.
		scalar sdcovpb=.
	}
	/*binary covariate*/
	else {
		scalar cncov=0
		/*probability for the covariate*/
		if `bcb'<=0 | `bcb'>=1 {
			di as error "Probability for the binary covariate needs to be in the (0,1) range"
			error 197
		}
		scalar covprob=`bcb'
		/*varying probability across higher units*/
		if `bsd'<0 {
			di as error "SD for probability for the binary covariate needs to be positive"
			error 197		
		}
		scalar sdcovpb=`bsd'
		/*not needed*/
		scalar dtype5=.
		scalar covmn=.
		scalar covsd=.
	}
	/*study-level covariate (yes=1)*/
	if "`slcov'"=="" {
		scalar slcov=0
	}
	else {
		scalar slcov=1
	}
	/*missing data assumptions*/
    /*make sure percentage of missing given, if mechanism is defined*/
    if `missp'==-127.77 & (`mar'!=-127.77 | `mnar'!=-127.77) {
		di as error "You need to define percentage of missing values with option missp() if you are to have a missing-data mechanism"
		error 197
	}
	/*can't have both mar and mnar*/
    if `mar'!=-127.77 & `mnar'!=-127.77 {
		di as error "You can define either MAR or NMAR, not both"
		error 197
	}
	scalar usemiss=0
	if `missp'!=-127.77 {
		/*assume MCAR*/
		scalar usemiss=1
        if `missp'<=0 | `missp'>=1 {
			di as error "Percentage of missing values needs to be in the (0,1) range. e.g. missp(0.2)"
		  	error 197
        }
        /*assume MAR*/
        if `mar'!=-127.77 {
			if `mar'<=0 {
				di as error "Odds ratio for MAR mechanism for covariate (1 implies MCAR and should be avoided)"
		  		error 197
        	}
        	scalar usemiss=2
		}
        /*assume NMAR*/
        if `mnar'!=-127.77 {
			if `mnar'<=0 {
				di as error "Odds ratio for NMAR mechanism for covariate (1 implies MCAR and should be avoided)"
		  		error 197
        	}
        	scalar usemiss=3
		}
    }
    /*multiple imputation analyses - set number of imputations within each dataset*/
    scalar numimp=0
    if `minum'!=-127 {
        /*need missing data to run mi analyses*/
        if usemiss==0 {
			di as error "Analyses using mi commands cannot be run without a missing data mechanism"
			error 197
        }
		if `minum'<2 {
			di as error "Number of imputed datasets needs to be at least two: minum(k) needs k>=2"
			error 197
    	}
    	scalar numimp=`minum'
    }
    /*pmm option for multiple imputation - only for continuous outcome*/
    scalar pmm=0
    if `mipmm'!=-127 {
        /*choice only for continuous outcome*/
        if `outc'>0 {
			di as error "Option mipmm() can only be used for a continuous outcome"
			error 197
        }
        /*need missing data to run mi analyses*/
        if usemiss==0 | numimp==0 {
			di as error "Analyses using mi commands cannot be run without a missing data mechanism"
			di as error "minum(#) needs to also be used, to define a mi analysis"
			error 197
        }
		if `mipmm'<1 {
			di as error "# of closest observations (nearest neighbors) to draw from in predictive mean matching imputation"
            di as error "mipmm(k) needs k>=1"
			error 197
    	}
    	scalar pmm=`mipmm'
    }

	/*HETEROGENEITY*/
	scalar poolwithinvar = .
	/*pooled within study variance calculations*/
	/*continuous outcome*/
	if outtp==0 {
		/*pool within variance across studies - using the true mean value rather than an estimate
		i.e. modelling using how much heterogeneity there should be not how much you measure in your dataset*/
		scalar poolwithinvar = mnsd^2
	}

	/*MAIN BIT*/
	/*not using matrices for results to avoid the IC limit of 400*/
	forvalues i=1(1)18 {
		scalar c`i'=0
	}
	forvalues i=0(1)3 {
		scalar powb`i'=0
		scalar covb`i'=0
	}
	forvalues i=0(1)1 {
		scalar perc`i'=0
		scalar mean`i'=0
		scalar sd`i'=0
	}
	/*loop number of simulations*/
	timer on 99
	scalar cntr=0
	forvalues i=1(1)`=simnum' {
		/*get basics*/
		if binexp==1 {
            /*binary exposure*/
		    studybasics1 `=totalsize' `=studynum' `=minsize' `=caseprob' `=hlpos' `=iclus'
		}
		else {
            /*continuous exposure*/
		    studybasics2 `=totalsize' `=studynum' `=minsize' `=distexp' `=expmn' `=expsd' `=hlpos'
        }
		/*call data generation*/
		modout1 `=b0' `=b1' `=b2' `=b3' `=poolwithinvar' `=cdsd' `=tausq0' `=tausq1' `=tausq2' `=tausq3' /*
		*/ `=dtype0' `=dtype1' `=dtype2' `=dtype3' `=slcov' `=totalsize' `=dtype4' /*
		*/ `=dtype5' `=covmn' `=covsd' `=covprob' `=outtp' `=xcovmt' `=binexp' `=sdcovpb'
		/*get some characteristics for the outcome*/
		if binexp==1 {
			/*binary exposure and binary outcome*/
        	if outtp==1 {
				scalar perc0=perc0+r(perc0)/simnum
				scalar perc1=perc1+r(perc1)/simnum
			}
			/*binary exposure and continuous or count outcome*/
			else {
				scalar mean0=mean0+r(mean0)/simnum
				scalar sd0=sd0+r(sd0)/simnum
				scalar mean1=mean1+r(mean1)/simnum
				scalar sd1=sd1+r(sd1)/simnum
			}
		}
		else {
			/*continuous exposure and binary outcome*/
        	if outtp==1 {
				scalar perc0=perc0+r(perc0)/simnum
			}
			/*continuous exposure and continuous or count outcome*/
			else {
				scalar mean0=mean0+r(mean0)/simnum
				scalar sd0=sd0+r(sd0)/simnum
			}
		}
		/*call missing data mechanisms*/
		/*MCAR*/
		if usemiss==1 {
        	mcarprg `missp'
		}
		else if usemiss==2 {
        	marprg `missp' `mar'
		}
		else if usemiss==3 {
        	mnarprg `missp' `mnar'
		}
		/*call modelling*/
		//nobreak {
    		/*if no multiple imputation*/
    		if numimp==0 {
                model`=modtp' `=outtp' `=cncov' `=nskip' `=redist' `=binexp'
            }
            /*mi*/
            else {
                model`=modtp'mi `=outtp' `=cncov' `=nskip' `=redist' `=numimp' `=pmm' `=binexp'
            }
        //}
		/*if successful convergence - for basic models there's no question*/
		if r(conv)==1 {
			/*mean coefficients*/
			foreach x of numlist 1 4 7 10 13/18 {
				scalar c`x' = c`x'+r(tc`x')
			}
			/*POWER - but only when the observed effect has the same direction as the in model*/
			/*intervention effect (main)*/
			if r(tc3)<=(100-clvl)/100 & r(tc1)*b1>0 {
				scalar powb1=powb1+1
			}
			/*covariate effect (main)*/
			if r(tc6)<=(100-clvl)/100 & r(tc4)*b2>0 {
				scalar powb2=powb2+1
			}
			/*interaction effect*/
			if r(tc9)<=(100-clvl)/100 & r(tc7)*b3>0 {
				scalar powb3=powb3+1
			}
			/*intercept*/
			if r(tc12)<=(100-clvl)/100 & r(tc10)*b0>0 {
				scalar powb0=powb0+1
			}
			/*COVERAGE*/
			/*intervention effect (main)*/
			if (r(tc1)-invnormal(`=1-(1-clvl/100)/2')*r(tc2))<=b1 & b1<=(r(tc1)+invnormal(`=1-(1-clvl/100)/2')*r(tc2)){
				scalar covb1=covb1+1
			}
			/*covariate effect (main)*/
			if (r(tc4)-invnormal(`=1-(1-clvl/100)/2')*r(tc5))<=b2 & b2<=(r(tc4)+invnormal(`=1-(1-clvl/100)/2')*r(tc5)){
				scalar covb2=covb2+1
			}
			/*interaction effect*/
			if (r(tc7)-invnormal(`=1-(1-clvl/100)/2')*r(tc8))<=b3 & b3<=(r(tc7)+invnormal(`=1-(1-clvl/100)/2')*r(tc8)){
				scalar covb3=covb3+1
			}
			/*intercept*/
			if (r(tc10)-invnormal(`=1-(1-clvl/100)/2')*r(tc11))<=b0 & b0<=(r(tc10)+invnormal(`=1-(1-clvl/100)/2')*r(tc11)){
				scalar covb0=covb0+1
			}
			/*overall counter*/
			scalar cntr=cntr+1
		}
		/*display progress*/
		if didots==1 {
			if r(conv)==1 {
				di "." _continue
			}
			else {
				di "x" _continue
			}
			if mod(`i',50)==0 {
				di "`i'"
			}
			else if `i'==simnum {
				di "`i'"
			}
		}
	}
	timer off 99
	qui timer list 99
	scalar tmin = r(t1)/60
	/*calculations*/
	forvalues i=0(1)3 {
		/*power*/
		qui cii cntr powb`i'
		scalar lpowb`i'=100*r(lb)
		scalar upowb`i'=100*r(ub)
		scalar powb`i'= 100*powb`i'/cntr
		/*coverage*/
		qui cii cntr covb`i'
		scalar lcovb`i'=100*r(lb)
		scalar ucovb`i'=100*r(ub)
		scalar covb`i'= 100*covb`i'/cntr
	}
	/*if covariate not calculated set everything to missing*/
	if c4==. {
		foreach x in lpowb2 upowb2 powb2 lcovb2 ucovb2 covb2 {
			scalar `x'=.
		}
	}
	if c10==. {
		foreach x in lpowb0 upowb0 powb0 lcovb0 ucovb0 covb0 {
			scalar `x'=.
		}
	}

	/*display outputs*/
	if dioutp==1 {
        scalar maxstr1=10
        scalar maxstr2=25
        scalar maxstr3=15
        //model information
        local mdlstr1 "1: standard regression"
        local mdlstr2 "2: random effects regression, for study i.e. intercept"
        local mdlstr3 "3: fixed common intercept; random treatment effect; fixed effect for baseline"
        local mdlstr4 "4: fixed study specific intercepts; random treatment effect; fixed study specific effect for baseline"
        local mdlstr5 "5: random study intercept; random treatment effect; fixed study specific effect for baseline"
        local mdlstr6 "6: random study intercept; random treatment effect; random effect for baseline"
        local mdlstr7 "7: random study intercept; random treatment effect; random effect for baseline; random effect for interaction"
		di _newline(2) as text "model " "`mdlstr`=modtp''"
		local outstr0 "continuous"
		local outstr1 "binary"
		local outstr2 "count"
		di as text "outcome type:" _col(17) as result "`outstr`=outtp''"
        local expstr0 "continuous"
        local expstr1 "binary"
		di as text "exposure type:" _col(17) as result "`expstr`=binexp''"
		local covstr0 "binary"
        local covstr1 "continuous"
		di as text "covariate type:" _col(17) as result "`covstr`=cncov''"
		di as text "random seed number:" _col(27) as result %6.0f `seed'
		di as text "number of converging runs:" _col(27) as result %6.0f `=cntr'
        di as text "computational time (min):" _col(28) as result %5.1f `=tmin'

		//characteristics for the outcome
		di _newline as text "Characteristics for the outcome"
		if binexp==1 {
			/*binary exposure and binary outcome*/
        	if outtp==1 {
				//di as result _col(3) "%(grp=0):" _col(25) %5.2f `=perc0*100'
				//di as result _col(3) "%(grp=1):" _col(25) %5.2f `=perc1*100'
                di as text "{hline `=maxstr1+1'}{c TT}{hline `=maxstr1+15'}"
                di as text "{col `=maxstr1+2'}{c |}{col `=maxstr1+6'}group0{col `=maxstr1+17'}group1
                di as text "{hline `=maxstr1+1'}{c +}{hline `=maxstr1+15'}"
                di as text "perc(%)" "{col `=maxstr1+2'}{c |}" as result _col(`=maxstr1+5') %7.3f `=perc0*100' _col(`=maxstr1+16') %7.3f `=perc1*100'
                di as text "{hline `=maxstr1+1'}{c BT}{hline `=maxstr1+15'}"
			}
			/*binary exposure and continuous or count outcome*/
			else {
				//di as result _col(3) "mean(grp=0):" _col(25) %5.3f `=mean0'
				//di as result _col(3) "sd(grp=0):" _col(25) %5.3f `=sd0'
				//di as result _col(3) "mean(grp=1):" _col(25) %5.3f `=mean1'
				//di as result _col(3) "sd(grp=1):" _col(25) %5.3f `=sd1'
                di as text "{hline `=maxstr1+1'}{c TT}{hline `=maxstr1+15'}"
                di as text "{col `=maxstr1+2'}{c |}{col `=maxstr1+6'}group0{col `=maxstr1+17'}group1
                di as text "{hline `=maxstr1+1'}{c +}{hline `=maxstr1+15'}"
                di as text "mean" "{col `=maxstr1+2'}{c |}" as result _col(`=maxstr1+5') %7.3f `=mean0' _col(`=maxstr1+16') %7.3f `=mean1'
                di as text "sd" "{col `=maxstr1+2'}{c |}" as result _col(`=maxstr1+5') %7.3f `=sd0' _col(`=maxstr1+16') %7.3f `=sd1'
                di as text "{hline `=maxstr1+1'}{c BT}{hline `=maxstr1+15'}"
			}
		}
		else {
			/*continuous exposure and binary outcome*/
        	if outtp==1 {
				//di as result _col(3) "%(overall):" _col(25) %5.1f `=perc0*100'
                di as text "{hline `=maxstr1+1'}{c TT}{hline `=maxstr1+5'}"
                di as text "{col `=maxstr1+2'}{c |}{col `=maxstr1+6'}overall
                di as text "{hline `=maxstr1+1'}{c +}{hline `=maxstr1+5'}"
                di as text "perc(%)" "{col `=maxstr1+2'}{c |}" as result _col(`=maxstr1+5') %7.3f `=perc0*100'
                di as text "{hline `=maxstr1+1'}{c BT}{hline `=maxstr1+5'}"
			}
			/*continuous exposure and continuous or count outcome*/
			else {
				//di as result _col(3) "mean(overall):" _col(25) %5.3f `=mean0'
				//di as result _col(3) "sd(overall):" _col(25) %5.3f `=sd0'
                di as text "{hline `=maxstr1+1'}{c TT}{hline `=maxstr1+5'}"
                di as text "{col `=maxstr1+2'}{c |}{col `=maxstr1+6'}overall
                di as text "{hline `=maxstr1+1'}{c +}{hline `=maxstr1+5'}"
                di as text "mean" "{col `=maxstr1+2'}{c |}" as result _col(`=maxstr1+5') %7.3f `=mean0'
                di as text "sd" "{col `=maxstr1+2'}{c |}" as result _col(`=maxstr1+5') %7.3f `=sd0'
                di as text "{hline `=maxstr1+1'}{c BT}{hline `=maxstr1+5'}"
			}
		}

		/*continuous outcome only*/
		if outtp==0 {
		    di _newline as text "Modelled variance and heterogeneity measures"
			//di as text "modelled between-study variance (tau^2)"
			//di as result _col(3) "exposure:" _col(25) %5.3f `=tausq1'
			//di as result _col(3) "covariate:" _col(25) %5.3f `=tausq2'
			//di as result _col(3) "interaction:" _col(25) %5.3f `=tausq3'
			//di as result _col(3) "intercept:" _col(25) %5.3f `=tausq0'
			//di as text "modelled heterogeneity, I^2 (range: 0 to 100%)"
			//di as result _col(3) "exposure:" _col(25) %5.2f `=100*tausq1/(tausq1+poolwithinvar)'
			//di as result _col(3) "covariate:" _col(25) %5.2f `=100*tausq2/(tausq2+poolwithinvar)'
			//di as result _col(3) "interaction:" _col(25) %5.2f `=100*tausq3/(tausq3+poolwithinvar)'
			//di as result _col(3) "intercept:" _col(25) %5.2f `=100*tausq0/(tausq0+poolwithinvar)'
			//di as text "modelled heterogeneity, H^2 (range: 1 to +inf)"
			//di as result _col(3) "exposure:" _col(25) %5.2f `=1/(1-tausq1/(tausq1+poolwithinvar))'
			//di as result _col(3) "covariate:" _col(25) %5.2f `=1/(1-tausq2/(tausq2+poolwithinvar))'
			//di as result _col(3) "interaction:" _col(25) %5.2f `=1/(1-tausq3/(tausq3+poolwithinvar))'
			//di as result _col(3) "intercept:" _col(25) %5.2f `=1/(1-tausq0/(tausq0+poolwithinvar))'
			//di as text "modelled within-study variance"
			//di as result _col(3) "pooled:" _col(25) %5.3f `=poolwithinvar'
            di as text "{hline `=maxstr2+1'}{c TT}{hline `=maxstr2+25'}"
            di as text "{col `=maxstr2+2'}{c |}{col `=maxstr2+6'}exposure{col `=maxstr2+18'}covariate{col `=maxstr2+30'}interaction{col `=maxstr2+42'}intercept
            di as text "{hline `=maxstr2+1'}{c +}{hline `=maxstr2+25'}"
            di as text "between variance (tau^2)" "{col `=maxstr2+2'}{c |}" as result _col(`=maxstr2+5') %7.3f `=tausq1' _col(`=maxstr2+17') %7.3f `=tausq2' /*
            */ _col(`=maxstr2+29') %7.3f `=tausq3' _col(`=maxstr2+41') %7.3f `=tausq0'
            di as text "I^2 (range: 0 to 100%)" "{col `=maxstr2+2'}{c |}" as result _col(`=maxstr2+5') %7.3f `=100*tausq1/(tausq1+poolwithinvar)' _col(`=maxstr2+17') %7.3f `=100*tausq2/(tausq2+poolwithinvar)' /*
            */ _col(`=maxstr2+29') %7.3f `=100*tausq3/(tausq3+poolwithinvar)' _col(`=maxstr2+41') %7.3f `=100*tausq0/(tausq0+poolwithinvar)'
            di as text "H^2 (range: 1 to +inf)" "{col `=maxstr2+2'}{c |}" as result _col(`=maxstr2+5') %7.3f `=1/(1-tausq1/(tausq1+poolwithinvar))' _col(`=maxstr2+17') %7.3f `=1/(1-tausq2/(tausq2+poolwithinvar))' /*
            */ _col(`=maxstr2+29') %7.3f `=1/(1-tausq3/(tausq3+poolwithinvar))' _col(`=maxstr2+41') %7.3f `=1/(1-tausq0/(tausq0+poolwithinvar))'
            di as text "{hline `=maxstr2+1'}{c BT}{hline `=maxstr2+25'}"
			di as text "modelled within-study variance (pooled):" _col(25) as result %7.3f `=poolwithinvar'
		}
		//di as text "mean estimates"
		//di as result _col(3) "b1 (exposure):" _col(25) %5.3f `=c1/cntr'
		//di as result _col(3) "b2 (covariate):" _col(25) %5.3f `=c4/cntr'
		//di as result _col(3) "b3 (interaction):" _col(25) %5.3f `=c7/cntr'
		//di as result _col(3) "b0 (intercept):" _col(25) %5.3f `=c10/cntr'
		/*R^2: adjusted for regress / overall for xtreg / pseudo for logit and xtlogit*/
		//di as result _col(3) "R^2(%):" _col(25) %5.2f `=100*c18/cntr'
		//di as result _col(3) "within-sd(error):" _col(25) %5.3f `=c13/cntr'
		/*e(sigma_u) in all cases except for poisson with gamma distributed RE: e(alpha)*/
		//di as result _col(3) "betw-sd(_cons):" _col(25) %5.3f `=c14/cntr'
		//di as result _col(3) "betw-sd(grp):" _col(25) %5.3f `=c15/cntr'
		//di as result _col(3) "betw-sd(covar):" _col(25) %5.3f `=c16/cntr'
		//di as result _col(3) "betw-sd(grpXcovar):" _col(25) %5.3f `=c17/cntr'
		//di as text "power to detect effects"
		//di as result _col(3) "exposure:" _col(20) %3.1f powb1 "(" %3.1f lpowb1 "-" %3.1f upowb1 ")"
		//di as result _col(3) "covariate:" _col(20) %3.1f powb2 "(" %3.1f lpowb2 "-" %3.1f upowb2 ")"
		//di as result _col(3) "interaction:" _col(20) %3.1f powb3 "(" %3.1f lpowb3 "-" %3.1f upowb3 ")"
		//di as result _col(3) "intercept:" _col(20) %3.1f powb0 "(" %3.1f lpowb0 "-" %3.1f upowb0 ")"
		//di as text "coverage for effects (reported CI includes model beta)"
		//di as result _col(3) "exposure:" _col(20) %3.1f covb1 "(" %3.1f lcovb1 "-" %3.1f ucovb1 ")"
		//di as result _col(3) "covariate:" _col(20) %3.1f covb2 "(" %3.1f lcovb2 "-" %3.1f ucovb2 ")"
		//di as result _col(3) "interaction:" _col(20) %3.1f covb3 "(" %3.1f lcovb3 "-" %3.1f ucovb3 ")"
		//di as result _col(3) "intercept:" _col(20) %3.1f covb0 "(" %3.1f lcovb0 "-" %3.1f ucovb0 ")"
		//model estimates
		di _newline as text "Results: model estimates"
        di as text "{hline `=maxstr2+1'}{c TT}{hline `=maxstr2+25'}"
        di as text "{col `=maxstr2+2'}{c |}{col `=maxstr2+6'}exposure{col `=maxstr2+18'}covariate{col `=maxstr2+30'}interaction{col `=maxstr2+42'}intercept
        di as text "{hline `=maxstr2+1'}{c +}{hline `=maxstr2+25'}"
        di as text "coefficient mean" "{col `=maxstr2+2'}{c |}" as result _col(`=maxstr2+5') %7.3f `=c1/cntr' _col(`=maxstr2+17') %7.3f `=c4/cntr' /*
        */ _col(`=maxstr2+29') %7.3f `=c7/cntr' _col(`=maxstr2+41') %7.3f `=c10/cntr'
        di as text "between-sd" "{col `=maxstr2+2'}{c |}" as result _col(`=maxstr2+5') %7.3f `=c15/cntr' _col(`=maxstr2+17') %7.3f `=c16/cntr' /*
        */ _col(`=maxstr2+29') %7.3f `=c17/cntr' _col(`=maxstr2+41') %7.3f `=c14/cntr'
        di as text "{hline `=maxstr2+1'}{c BT}{hline `=maxstr2+25'}"
	    di as text "within-sd(error):" _col(20) as result %7.3f `=c13/cntr'
	    di as text "R^2(%):" _col(20) as result %7.3f `=100*c18/cntr'
	    //coverage
		di _newline as text "Results: coverage"
        di as text "{hline `=maxstr3+1'}{c TT}{hline `=maxstr3+25'}"
        di as text "{col `=maxstr3+2'}{c |}{col `=maxstr3+6'}estimate{col `=maxstr3+18'}[95% Conf. Interval]"
        di as text "{hline `=maxstr3+1'}{c +}{hline `=maxstr3+25'}"
        di as text "exposure" "{col `=maxstr3+2'}{c |}" as result _col(`=maxstr3+5') %7.1f covb1 _col(`=maxstr3+18') %7.1f lcovb1 _col(`=maxstr3+29') %7.1f ucovb1
        di as text "covariate" "{col `=maxstr3+2'}{c |}" as result _col(`=maxstr3+5') %7.1f covb2 _col(`=maxstr3+18') %7.1f lcovb2 _col(`=maxstr3+29') %7.1f ucovb2
        di as text "interaction" "{col `=maxstr3+2'}{c |}" as result _col(`=maxstr3+5') %7.1f covb3 _col(`=maxstr3+18') %7.1f lcovb3 _col(`=maxstr3+29') %7.1f ucovb3
        di as text "intercept" "{col `=maxstr3+2'}{c |}" as result _col(`=maxstr3+5') %7.1f covb0 _col(`=maxstr3+18') %7.1f lcovb0 _col(`=maxstr3+29') %7.1f ucovb0
        di as text "{hline `=maxstr3+1'}{c BT}{hline `=maxstr3+25'}"
        //power
		di _newline as text "Results: power"
        di as text "{hline `=maxstr3+1'}{c TT}{hline `=maxstr3+25'}"
        di as text "{col `=maxstr3+2'}{c |}{col `=maxstr3+6'}estimate{col `=maxstr3+18'}[95% Conf. Interval]"
        di as text "{hline `=maxstr3+1'}{c +}{hline `=maxstr3+25'}"
        di as text "exposure" "{col `=maxstr3+2'}{c |}" as result _col(`=maxstr3+5') %7.1f powb1 _col(`=maxstr3+18') %7.1f lpowb1 _col(`=maxstr3+29') %7.1f upowb1
        di as text "covariate" "{col `=maxstr3+2'}{c |}" as result _col(`=maxstr3+5') %7.1f powb2 _col(`=maxstr3+18') %7.1f lpowb2 _col(`=maxstr3+29') %7.1f upowb2
        di as text "interaction" "{col `=maxstr3+2'}{c |}" as result _col(`=maxstr3+5') %7.1f powb3 _col(`=maxstr3+18') %7.1f lpowb3 _col(`=maxstr3+29') %7.1f upowb3
        di as text "intercept" "{col `=maxstr3+2'}{c |}" as result _col(`=maxstr3+5') %7.1f powb0 _col(`=maxstr3+18') %7.1f lpowb0 _col(`=maxstr3+29') %7.1f upowb0
        di as text "{hline `=maxstr3+1'}{c BT}{hline `=maxstr3+25'}"
	}

	/*RETURN SCALARS*/
	/*mean coefficients*/
	return scalar b0 = c10/cntr
	return scalar b1 = c1/cntr
	return scalar b2 = c4/cntr
	return scalar b3 = c7/cntr
	/*characteristics of simulations*/
	return scalar nsim = simnum        /*number of simulations*/
	return scalar nrun = cntr          /*number of successful runs*/
	return scalar ctime = tmin         /*computational time in minutes*/
    /*model fit*/
	return scalar rsq = c18/cntr       /*Adjusted or pseudo R^2*/
	/*error*/
	return scalar errsd = c13/cntr     /*within-sd (error)*/
	/*RE estimates*/
	return scalar consd = c14/cntr     /*betw-sd(_cons)*/
	return scalar grpsd = c15/cntr     /*betw-sd(grp)*/
	return scalar covsd = c16/cntr     /*betw-sd(covar)*/
	return scalar intsd = c17/cntr     /*betw-sd(grpXcovar)*/
	/*Power to detect effects (of same direction)*/
	forvalues i=0(1)3 {
        return scalar pow`i' = powb`i'
        return scalar lpow`i' = lpowb`i'
        return scalar upow`i' = upowb`i'
    }
	/*Coverage for effects (true value within CI of the estimate)*/
	forvalues i=0(1)3 {
        return scalar cov`i' = covb`i'
        return scalar lcov`i' = lcovb`i'
        return scalar ucov`i' = ucovb`i'
    }
end

/*get the study basics - exposure binary*/
program studybasics1
	/*inputs: totalsize studynum minsize caseprob*/	
	/*SET SIZE*/
	/*total size*/
	scalar totalsize=`1'
	/*number of studies*/
	scalar studynum=`2'
	/*variability in study size (meansize automatically computed and from that the maximum - only minimum needs to be inputted - uniform distribution)*/
	scalar minsize=`3'
	scalar meansize=totalsize/studynum
	scalar maxsize=2*meansize-minsize
	/*poisson distribution chosen? hlpos=1*/
	scalar hlpos=`5'
	if hlpos==0 {
    	/*generate uniformly distributed study sizes [minsize-maxsize] - repeat until the last study (not random) is within the desired range*/
    	scalar bool1=0
    	while bool1==0 {
    		scalar tsize=0
    		forvalues i=1(1)`=studynum-1'{
    			scalar stsize`i' = minsize+int((maxsize-minsize+1)*runiform())
    			scalar tsize = tsize + stsize`i'
    		}
    		scalar stsize`=studynum'=totalsize-tsize
    		if stsize`=studynum'>=minsize & stsize`=studynum'<=maxsize {
    			scalar bool1 = 1
    		}
    	}
    }
    else {
        /*generate Poisson distributed study sizes*/
    	scalar tsize=0
    	forvalues i=1(1)`=studynum-1'{
    		scalar stsize`i' = rpoisson(meansize)
    		scalar tsize = tsize + stsize`i'
    	}
    	scalar stsize`=studynum'=totalsize-tsize
    }
  	/*start generating the dataset - groups*/
  	qui clear
  	qui set obs `=totalsize'
  	/*generate overall identifier*/
  	qui egen id = seq()
  	/*study identifier*/
  	qui gen studyid=.
  	qui gen grp=0
  	scalar tsize=0
  	forvalues i=1(1)`=studynum'{
  		qui replace studyid=`i' if id>tsize
  		scalar tsize=tsize+stsize`i'
  	}
    /*clustered design or not*/
	scalar iclus=`6'
	if iclus==0 {
    	/*not clustered: set balanced-unbalanced design - proportion of intervention group*/
    	scalar caseprob=`4'
    	forvalues i=1(1)`=studynum'{
    		scalar stisize`i'=int(caseprob*stsize`i')
    		scalar stcsize`i'=int((1-caseprob)*stsize`i')
    		/*add the potential extra randomly if needed*/
    		if stisize`i'+stcsize`i'<stsize`i' {
    			if runiform()<=0.5 {
    				scalar stisize`i'=stisize`i'+1
    			}
    			else {
    				scalar stcsize`i'=stcsize`i'+1
    			}
    		}
    	}
    	/*group membership*/
    	scalar tsize=0
    	forvalues i=1(1)`=studynum'{
    		/*group identifier allocation*/
    		qui replace grp=1 if studyid==`i' & id<=tsize+stisize`i'
    		scalar tsize=tsize+stsize`i'
    	}
    }
    else {
        /*clustered design*/
    	forvalues i=2(2)`=studynum'{
    		/*group identifier allocation*/
    		qui replace grp=1 if studyid==`i'
    	}
    }
end

/*get the study basics - exposure continuous*/
program studybasics2
	/*inputs: totalsize studynum minsize distexp expmn expsd*/
	/*SET SIZE*/
	/*total size*/
	scalar totalsize=`1'
	/*number of studies*/
	scalar studynum=`2'
	/*variability in study size (meansize automatically computed and from that the maximum - only minimum needs to be inputted - uniform distribution)*/
	scalar minsize=`3'
	scalar meansize=totalsize/studynum
	scalar maxsize=2*meansize-minsize
	/*poisson distribution chosen? hlpos=1*/
	scalar hlpos=`7'
	if hlpos==0 {
    	/*generate uniformly distributed study sizes [minsize-maxsize] - repeat until the last study (not random) is within the desired range*/
    	scalar bool1=0
    	while bool1==0 {
    		scalar tsize=0
    		forvalues i=1(1)`=studynum-1'{
    			scalar stsize`i' = minsize+int((maxsize-minsize+1)*runiform())
    			scalar tsize = tsize + stsize`i'
    		}
    		scalar stsize`=studynum'=totalsize-tsize
    		if stsize`=studynum'>=minsize & stsize`=studynum'<=maxsize {
    			scalar bool1 = 1
    		}
    	}
    }
    else {
        /*generate Poisson distributed study sizes*/
    	scalar tsize=0
    	forvalues i=1(1)`=studynum-1'{
    		scalar stsize`i' = rpoisson(meansize)
    		scalar tsize = tsize + stsize`i'
    	}
    	scalar stsize`=studynum'=totalsize-tsize
    }
	/*start generating the dataset - groups*/
	qui clear
	qui set obs `=totalsize'
	/*generate overall identifier*/
	qui egen id = seq()
	/*study identifier*/
	qui gen studyid=.
	scalar tsize=0
	forvalues i=1(1)`=studynum'{
		qui replace studyid=`i' if id>tsize
		scalar tsize=tsize+stsize`i'
	}
	/*exposure*/
	scalar distexp=`4'
	scalar expmn=`5'
	scalar expsd=`6'
	/*if normally distributed*/
	if distexp==0 {
		qui gen grp = rnormal(`=expmn',`=expsd')
	}
	else {
		rambergvar distexp Rb2
		qui gen grp = expmn + Rb2*expsd
		qui drop Rb2
	}
end

/*data generation*/
program modout1, rclass
	/*inputs*/
	scalar b0=`1'
	scalar b1=`2'
	scalar b2=`3'
	scalar b3=`4'
	scalar poolwithinvar=`5'
	scalar cdsd=`6'	
	scalar tausq0=`7'
	scalar tausq1=`8'
	scalar tausq2=`9'
	scalar tausq3=`10'
	scalar dtype0=`11'
	scalar dtype1=`12'
	scalar dtype2=`13'
	scalar dtype3=`14'
	scalar slcov=`15'
	scalar totnum=`16'
	scalar dtype4=`17'
	scalar dtype5=`18'
	scalar covmn=`19'
	scalar covsd=`20'
	scalar covprob=`21'
	scalar outtp=`22'
	scalar xcovmt=`23'
	scalar binexp=`24'
	scalar sdcovpb=`25'

	/*if covariate is continuous*/
	if covprob==. {
		/*study level covariate*/
		if slcov==1 {
			qui gen xcovar=.
			forvalues i=1(1)`=studynum' {
				/*if normally distributed*/
				if dtype5==0 {
					scalar temp = rnormal(`=covmn',`=covsd')
					qui replace xcovar = temp if studyid==`i'
				}
				else {
					ramberg dtype5
					qui replace xcovar = covmn + r(rb)*covsd if studyid==`i'
				}
			}
		}
		/*patient-level covariate*/
		else {
			/*if normally distributed*/
			if dtype5==0 {
				qui gen xcovar = rnormal(`=covmn',`=covsd')
			}
			else {
				rambergvar dtype5 Rb2
				qui gen xcovar = covmn + Rb2*covsd
				qui drop Rb2
			}
		}
	}
	/*if covariate is binary*/
	else {
		/*study level covariate*/
		if slcov==1 {
			qui gen xcovar=.
			forvalues i=1(1)`=studynum' {
				/*draw for study*/
				scalar temp=0
				if runiform()<=covprob {
					scalar temp=1
				}
				qui replace xcovar=temp if studyid==`i'
			}
		}
		/*patient-level covariate*/
		else {
			tempvar truni
			qui gen `truni'=runiform()		
			qui gen xcovar=0			
			if sdcovpb==0 {
				qui replace xcovar=1 if `truni'<=covprob
			}
			else {
				forvalues i=1(1)`=studynum' {
					scalar temp = rnormal(`=covprob',`=sdcovpb')					
					qui replace xcovar=1 if studyid==`i' & `truni'<=temp
				}									
			}
		}
	}

	/*random effects*/
	/*if no covariance matrix*/
	if xcovmt==0 {
		/*distribution intercept(0), main(1), baseline(2) and interaction(3) effect*/
		forvalues x=0(1)3 {
			/*random-effects*/
			if tausq`x'==0 {
				qui gen u`x'=0
			}
			else {
				qui gen u`x'=.
				/*draw for each study*/
				forvalues i=1(1)`=studynum'{
  					/*call Ramberg method*/
  					ramberg dtype`x'
  					scalar Rb`x'=r(rb)
  					/*rescale and add*/
  					qui replace u`x' = Rb`x'*sqrt(tausq`x') if studyid==`i'
            	}
			}
		}
	}
	/*if covariance matrix*/
	else {
		qui preserve
		/*draw the study effects*/
		qui clear
		qui set obs `=studynum'
		qui drawnorm re0 re1 re2 re3, cov(test1test2test3) cstorage(full)
		/*get the generated values into scalars*/
		forvalues x=0(1)3 {
			forvalues i=1(1)`=studynum'{
  				local tmp`x'`i'=re`x' in `i'
            }
		}
		/*add to main dataset*/
		qui restore
		forvalues x=0(1)3 {
			qui gen u`x'=.
			/*add for each study*/
			forvalues i=1(1)`=studynum'{
  				qui replace u`x' = `tmp`x'`i'' if studyid==`i'
            }
		}
	}

	/*errors: only relevant for continuous outcome*/
	if outtp==0 {
		/*calculate observation error using study SD*/
		qui gen errx=.
		/*if normally distributed*/
		if dtype4==0 {
			qui gen Rb2=rnormal(0,1)
		}
		else {
			rambergvar dtype4 Rb2
		}
		/*rescale error according to study variance*/
		forvalues i=1(1)`=studynum'{
			/*within study variance*/
			scalar withinsd`i' = rnormal(`=sqrt(poolwithinvar)',cdsd)
			/*limit to positive by resampling - which will affect the mean if part of the tail is negative*/
			while withinsd`i'<=0 {
				scalar withinsd`i' = rnormal(`=sqrt(poolwithinvar)',cdsd)
			}
			/*rescaled error - e taken from N(0,s^2)*/
			qui replace errx = Rb2*withinsd`i' if studyid==`i'
		}
		qui drop Rb2
	}

	/*generate outcome for each study*/
	if outtp==0 {
		qui gen outcome= b0 + b1*grp + b2*xcovar + b3*xcovar*grp + u0 + u1*grp + u2*xcovar + u3*xcovar*grp + errx
	}
	else if outtp==1 {
        /*no need to add errors - within errors are fixed for logistic regressions and adding errx has no effect at all besides destabilising the estimates*/
		qui gen outcome = uniform() < invlogit(b0 + b1*grp + b2*xcovar + b3*xcovar*grp + u0 + u1*grp + u2*xcovar + u3*xcovar*grp)
	}
	else if outtp==2 {
        /*no need to add errors - within errors are fixed for logistic regressions and adding errx has no effect at all besides destabilising the estimates*/
		qui gen outcome =rpoisson(exp(b0 + b1*grp + b2*xcovar + b3*xcovar*grp + u0 + u1*grp + u2*xcovar + u3*xcovar*grp))
	}
	/*also return mean(s)/sd(s) for continuous/counts, percentage(s) for binary*/
	if outtp==1 {
		if binexp==1 {
			forvalues i=0(1)1 {
				qui count if grp==`i'
				scalar den`i'=r(N)
				qui count if outcome==1 & grp==`i'
				scalar perc`i'=r(N)/den`i'
				return scalar perc`i'=perc`i'
			}
		}
		else {
			qui count
			scalar den0=r(N)
			qui count if outcome==1
			scalar perc0=r(N)/den0
			return scalar perc0=perc0
		}
	}
	else {
		if binexp==1 {
			forvalues i=0(1)1 {
				qui sum outcome if grp==`i'
				scalar mean`i'=r(mean)
				scalar sd`i'=r(sd)
				return scalar mean`i'=mean`i'
				return scalar sd`i'=sd`i'
			}
		}
		else {
			qui sum outcome
			scalar mean0=r(mean)
			scalar sd0=r(sd)
			return scalar mean0=mean0
			return scalar sd0=sd0
		}
	}
	qui compress
end

/*missing data mechanisms section*/
/*MCAR mechanism*/
program mcarprg
	scalar missrate=`1'	/*missing outcome %*/
	tempvar tempx
	qui gen `tempx' = uniform()
	qui replace outcome=. if `tempx'<missrate
	qui drop `tempx'
end

/*MAR mechanism*/
program marprg
	scalar missrate=`1'	/*missing outcome %*/
	scalar missor=`2'	/*odds ratio for missingness*/
	tempvar tempx tempy
    qui gen `tempx' = uniform() < invlogit(ln(missor)*xcovar)
	/*limit missing where tempx=1 i.e. calculate updated missing rate*/
	qui count
	scalar denm=r(N)
	qui count if `tempx'==1
	scalar numm=r(N)
	scalar newmrate=missrate*denm/numm
	/*final step*/
	qui gen `tempy' = uniform()
	qui replace outcome=. if `tempy'<newmrate & `tempx'==1
	qui drop `tempx' `tempy'
end

/*MNAR mechanism*/
program mnarprg
	scalar missrate=`1'	/*missing outcome %*/
	scalar missor=`2'	/*odds ratio for missingness*/
	tempvar tempx tempy
    qui gen `tempx' = uniform() < invlogit(ln(missor)*outcome)
	/*limit missing where tempx=1 i.e. calculate updated missing rate*/
	qui count
	scalar denm=r(N)
	qui count if `tempx'==1
	scalar numm=r(N)
	scalar newmrate=missrate*denm/numm
	/*final step*/
	qui gen `tempy' = uniform()
	qui replace outcome=. if `tempy'<newmrate & `tempx'==1
	qui drop `tempx' `tempy'
end

/*modelling section*/
/*standard models*/

/*basic linear regression*/
program model1, rclass
	scalar outtp=`1'	/*0=continuous, 1=binary, 2=poisson*/
	scalar cncov=`2'	/*0=binary, 1=continuous*/
	scalar bexp=`5'	    /*1=binary exposure, 1=continuous exposure*/
	/*model components*/
	if bexp==1 {
        local exp1 "i.grp"
        local exp2 "i.grp"
        /*where in r(table)*/
        matrix tres = [2,3,5,6]
    }
    else {
        local exp1 "grp"
        local exp2 "c.grp"
        matrix tres = [1,2,3,4]
    }
	if cncov==1 {
        local xcv1 "xcovar"
        local xcv2 "c.xcovar"
    }
    else {
        local xcv1 "1.xcovar"
        local xcv2 "i.xcovar"
    }
	/*linear model*/
	if outtp==0 {
		capture regress outcome `exp1' `xcv1' `exp2'#`xcv2'
		/*adjusted R^2*/
		scalar tc18=e(r2_a)
	}
	/*logistic model*/
	else if outtp==1 {
		capture logit outcome `exp1' `xcv1' `exp2'#`xcv2'
		/*pseudo R^2*/
		scalar tc18=e(r2_p)
	}
	/*poisson model*/
	else if outtp==2 {
		capture poisson outcome `exp1' `xcv1' `exp2'#`xcv2'
		/*pseudo R^2*/
		scalar tc18=e(r2_p)
    }
	if _rc==0 {
		matrix A=r(table)
		/*main effect, se and p-value*/
		scalar tc1=A[1,tres[1,1]]
		scalar tc2=A[2,tres[1,1]]
		scalar tc3=A[4,tres[1,1]]
		/*covariate effect, se and p-value*/
		scalar tc4=A[1,tres[1,2]]
		scalar tc5=A[2,tres[1,2]]
		scalar tc6=A[4,tres[1,2]]
		/*interaction effect, se and p-value*/
		scalar tc7=A[1,tres[1,3]]
		scalar tc8=A[2,tres[1,3]]
		scalar tc9=A[4,tres[1,3]]
		/*intercept, se and p-value*/
		scalar tc10=A[1,tres[1,4]]
		scalar tc11=A[2,tres[1,4]]
		scalar tc12=A[4,tres[1,4]]
		/*empty variance scalars*/
		scalar tc13=.
		scalar tc14=.
		scalar tc15=.
		scalar tc16=.
		scalar tc17=.
		scalar conv=1
	}
	else {
		scalar conv=0
		forvalues i=1(1)18 {
			scalar tc`i'=.
		}
	}
	/*return*/
	return scalar conv=conv
	forvalues i=1(1)18 {
		return scalar tc`i'=tc`i'
	}
end

/*random effects regression - for study (intercept)*/
program model2, rclass
	scalar outtp=`1'	/*0=continuous, 1=binary*/
	scalar cncov=`2'	/*0=binary, 1=continuous*/
	scalar nskp=`3'	    /*0=no changes, 1=noskip option for xtlogit in order to return pseudo R^2*/
	scalar redist=`4'	/*0=gamma distribution for RE, 1=normal distribution for RE*/
	scalar bexp=`5'	    /*1=binary exposure, 1=continuous exposure*/
	/*model components*/
	if bexp==1 {
        local exp1 "i.grp"
        local exp2 "i.grp"
        /*where in r(table)*/
        matrix tres = [2,3,5,6]
    }
    else {
        local exp1 "grp"
        local exp2 "c.grp"
        matrix tres = [1,2,3,4]
    }
	if cncov==1 {
        local xcv1 "xcovar"
        local xcv2 "c.xcovar"
    }
    else {
        local xcv1 "1.xcovar"
        local xcv2 "i.xcovar"
    }
    /*model*/
	qui xtset studyid
	/*linear model*/
	if outtp==0 {
        capture xtreg outcome `exp1' `xcv1' `exp2'#`xcv2'
		/*variance estimates*/
		scalar tc14=e(sigma_u)	/*between (intercept)*/
    	/*within*/
		scalar tc13=e(sigma_e)
		/*Overall R^2*/
		scalar tc18=e(r2_o)
    }
	/*logistic model*/
	else if outtp==1 {
        local tstr=""
        if nskp==1 local tstr="noskip"
        capture xtlogit outcome `exp1' `xcv1' `exp2'#`xcv2', iterate(20) `tstr'
		/*variance estimates*/
		scalar tc14=e(sigma_u)	/*between (intercept)*/
    	/*within*/
		scalar tc13=sqrt(e(sigma_u)^2*(1-e(rho))/e(rho))
		/*Overall R^2*/
		scalar tc18=(e(ll_0)-e(ll))/e(ll_0)
    }
	/*poisson model*/
	else if outtp==2 {
        local tstr=""
        if nskp==1 local tstr="noskip"
        if redist==1 local tstr="`tstr' normal"
		capture xtpoisson outcome `exp1' `xcv1' `exp2'#`xcv2', iterate(20) `tstr'
		/*variance estimates*/
		if redist==0 {
            scalar tc14=e(alpha)	/*between (intercept)*/
        }
        else {
            scalar tc14=e(sigma_u)	/*between (intercept)*/
        }
		/*within - not computable*/
		scalar tc13=.
		/*Overall R^2*/
		scalar tc18=(e(ll_0)-e(ll))/e(ll_0)
    }
	if _rc==0 {
		matrix A=r(table)
		/*main effect, se and p-value*/
		scalar tc1=A[1,tres[1,1]]
		scalar tc2=A[2,tres[1,1]]
		scalar tc3=A[4,tres[1,1]]
		/*covariate effect, se and p-value*/
		scalar tc4=A[1,tres[1,2]]
		scalar tc5=A[2,tres[1,2]]
		scalar tc6=A[4,tres[1,2]]
		/*interaction effect, se and p-value*/
		scalar tc7=A[1,tres[1,3]]
		scalar tc8=A[2,tres[1,3]]
		scalar tc9=A[4,tres[1,3]]
		/*intercept, se and p-value*/
		scalar tc10=A[1,tres[1,4]]
		scalar tc11=A[2,tres[1,4]]
		scalar tc12=A[4,tres[1,4]]
		/*empty variance scalars*/
		scalar tc15=.
		scalar tc16=.
		scalar tc17=.
		scalar conv=1
	}
	else {
		scalar conv=0
		forvalues i=1(1)18 {
			scalar tc`i'=.
		}
	}
	/*return*/
	return scalar conv=conv
	forvalues i=1(1)18 {
		return scalar tc`i'=tc`i'
	}
end

/*IPDforest model 1: fixed common intercept; random treatment effect; fixed effect for baseline*/
program model3, rclass
	scalar outtp=`1'	/*0=continuous, 1=binary, 2=count*/
	scalar cncov=`2'	/*0=binary, 1=continuous*/
	scalar bsc=0		/*successful run or not*/
	scalar bexp=`5'	    /*1=binary exposure, 1=continuous exposure*/
	/*model components*/
	if bexp==1 {
        local exp1 "i.grp"
        local exp2 "i.grp"
        /*where in r(table)*/
        matrix tres = [2,3,5,6]
    }
    else {
        local exp1 "grp"
        local exp2 "c.grp"
        matrix tres = [1,2,3,4]
    }
	if cncov==1 {
        local xcv1 "xcovar"
        local xcv2 "c.xcovar"
    }
    else {
        local xcv1 "1.xcovar"
        local xcv2 "i.xcovar"
    }
	/*linear model*/
	if outtp==0 {
    	/*model*/
    	capture xtmixed outcome `exp1' `xcv1' `exp2'#`xcv2' || studyid: grp, nocons iterate(20)
		if _rc==0 {
			matrix A=r(table)					
			scalar bsc=1			
			/*variance estimates*/
			qui _diparm lnsig_e, f(exp(@)) d(exp(@))
			scalar tc13=r(est)	/*sd(Residual)*/
		}
    }
	/*logistic model*/
	else if outtp==1 {
        capture xtmelogit outcome `exp1' `xcv1' `exp2'#`xcv2' || studyid: grp, nocons iterate(20)
		if _rc==0 {
			matrix A=r(table)				
			scalar bsc=1			
			/*variance estimates*/			
			scalar tc13=.	/*sd(Residual)*/
		}
    }
	/*poisson model*/
	else if outtp==2 {
        capture xtmepoisson outcome `exp1' `xcv1' `exp2'#`xcv2' || studyid: grp, nocons iterate(20)
		if _rc==0 {
			matrix A=r(table)				
			scalar bsc=1			
			/*variance estimates*/			
			scalar tc13=.	/*sd(Residual)*/
		}
    }
	if bsc==1 {
		/*main effect, se and p-value*/
		scalar tc1=A[1,tres[1,1]]
		scalar tc2=A[2,tres[1,1]]
		scalar tc3=A[4,tres[1,1]]
		/*covariate effect, se and p-value*/
		scalar tc4=A[1,tres[1,2]]
		scalar tc5=A[2,tres[1,2]]
		scalar tc6=A[4,tres[1,2]]
		/*interaction effect, se and p-value*/
		scalar tc7=A[1,tres[1,3]]
		scalar tc8=A[2,tres[1,3]]
		scalar tc9=A[4,tres[1,3]]
		/*intercept, se and p-value*/
		scalar tc10=A[1,tres[1,4]]
		scalar tc11=A[2,tres[1,4]]
		scalar tc12=A[4,tres[1,4]]
		/*convergence*/
		scalar conv=e(converged)
		/*variance estimates*/
		qui _diparm lns1_1_1, f(exp(@)) d(exp(@))
		scalar tc15=r(est)	/*sd(grp)*/
		/*empty variance scalars*/
		scalar tc14=.
		scalar tc16=.	
		scalar tc17=.
		/*Overall R^2*/
		scalar tc18=.
	}
	else {
		scalar conv=0
		forvalues i=1(1)18 {
			scalar tc`i'=.
		}
	}
	/*return*/
	return scalar conv=conv	/*0=no covnergence*/
	forvalues i=1(1)18 {
		return scalar tc`i'=tc`i'
	}
end

/*IPDforest model 2: fixed study specific intercepts; random treatment effect; fixed study specific effect for baseline*/
program model4, rclass
	/*generate study specific baseline vars*/
	forvalues x=1(1)`=studynum' {
		qui gen xcovar`x'=0
		qui replace xcovar`x'=xcovar if studyid==`x'
	}
	scalar outtp=`1'	/*0=continuous, 1=binary*/
	scalar cncov=`2'	/*0=binary, 1=continuous*/		
	scalar bsc=0		/*successful run or not*/
	scalar bexp=`5'	    /*1=binary exposure, 1=continuous exposure*/
	/*model components*/
	if bexp==1 {
        local exp1 "i.grp"
        local exp2 "1.grp"
    }
    else {
        local exp1 "grp"
        local exp2 "c.grp"
    }
	if cncov==1 {
        local xcv2 "c.xcovar"
    }
    else {
        local xcv2 "1.xcovar"
    }
	/*linear model*/
	if outtp==0 {
	    /*model*/
        capture xtmixed outcome `exp1' `exp2'#`xcv2' i.studyid xcovar1-xcovar`=studynum' || studyid: grp, nocons iterate(20)
		if _rc==0 {
			matrix A=r(table)					
			scalar bsc=1			
			/*variance estimates*/
			qui _diparm lnsig_e, f(exp(@)) d(exp(@))
			scalar tc13=r(est)	/*sd(Residual)*/
		}		
	}
	/*logistic model*/
	else if outtp==1 {
        capture xtmelogit outcome `exp1' `exp2'#`xcv2' i.studyid xcovar1-xcovar`=studynum' || studyid: grp, nocons iterate(20)
		if _rc==0 {
			matrix A=r(table)
			scalar bsc=1
			/*variance estimates*/
			scalar tc13=.	/*sd(Residual)*/
		}
    }
	/*poisson model*/
	else if outtp==2 {
        capture xtmepoisson outcome `exp1' `exp2'#`xcv2' i.studyid xcovar1-xcovar`=studynum' || studyid: grp, nocons iterate(20)
		if _rc==0 {
			matrix A=r(table)				
			scalar bsc=1			
			/*variance estimates*/
			scalar tc13=.	/*sd(Residual)*/
		}
    }
	if bsc==1 {
        matrix tres = [1,.,2,.]
		/*main effect, se and p-value*/
		scalar tc1=A[1,tres[1,1]]
		scalar tc2=A[2,tres[1,1]]
		scalar tc3=A[4,tres[1,1]]
		/*covariate effect, se and p-value - different for each study and not reported*/		
		scalar tc4=.
		scalar tc5=.
		scalar tc6=.
		/*interaction effect, se and p-value*/
		scalar tc7=A[1,tres[1,3]]
		scalar tc8=A[2,tres[1,3]]
		scalar tc9=A[4,tres[1,3]]
		/*intercept, se and p-value*/
		/*scalar temp=colsof(A)*/
		scalar tc10=. /*A[1,`=temp-2'] - this returns intercept for 1st study*/
		scalar tc11=. /*A[2,`=temp-2']*/
		scalar tc12=. /*A[4,`=temp-2']*/
		/*convergence*/
		scalar conv=e(converged)	
		/*variance estimates*/
		qui _diparm lns1_1_1, f(exp(@)) d(exp(@))
		scalar tc15=r(est)	/*sd(grp)*/
		/*empty variance scalars*/
		scalar tc14=.	
		scalar tc16=.
		scalar tc17=.
		/*Overall R^2*/
		scalar tc18=.
	}
	else {
		scalar conv=0
		forvalues i=1(1)18 {
			scalar tc`i'=.
		}
	}	
	/*return*/
	return scalar conv=conv	/*0=no covnergence*/
	forvalues i=1(1)18 {
		return scalar tc`i'=tc`i'
	}
end

/*IPDforest model 3: random study intercept; random treatment effect; fixed study specific effect for baseline*/
program model5, rclass
	/*generate study specific baseline vars*/
	forvalues x=1(1)`=studynum' {
		qui gen xcovar`x'=0
		qui replace xcovar`x'=xcovar if studyid==`x'
	}
	/*standard error calculation might fail*/
	scalar outtp=`1'	/*0=continuous, 1=binary*/
	scalar cncov=`2'	/*0=binary, 1=continuous*/
	scalar bsc=0		/*successful run or not*/
	scalar bexp=`5'	    /*1=binary exposure, 1=continuous exposure*/
	/*model components*/
	if bexp==1 {
        local exp1 "i.grp"
        local exp2 "1.grp"
    }
    else {
        local exp1 "grp"
        local exp2 "c.grp"
    }
	if cncov==1 {
        local xcv2 "c.xcovar"
    }
    else {
        local xcv2 "1.xcovar"
    }
	/*linear model*/
	if outtp==0 {
		/*model*/
		capture xtmixed outcome `exp1' `exp2'#`xcv2' xcovar1-xcovar`=studynum' || studyid: grp, cov(uns) iterate(20)
		if _rc==0 {
			matrix A=r(table)					
			scalar bsc=1			
			/*variance estimates*/			
			qui _diparm lnsig_e, f(exp(@)) d(exp(@))
			scalar tc13=r(est)	/*sd(Residual)*/
		}			
	}
	/*logistic model*/
	else if outtp==1 {
        capture xtmelogit outcome `exp1' `exp2'#`xcv2' xcovar1-xcovar`=studynum' || studyid: grp, cov(uns) iterate(20)
		if _rc==0 {
			matrix A=r(table)
			scalar bsc=1			
			/*variance estimates*/			
			scalar tc13=.	/*sd(Residual)*/
		}		
    }
	/*poisson model*/
	else if outtp==2 {
        capture xtmepoisson outcome `exp1' `exp2'#`xcv2' xcovar1-xcovar`=studynum' || studyid: grp, cov(uns) iterate(20)
		if _rc==0 {
			matrix A=r(table)				
			scalar bsc=1			
			/*variance estimates*/
			scalar tc13=.	/*sd(Residual)*/
		}		
    }
	if bsc==1 {
		scalar temp=colsof(A)
		matrix tres = [1,.,2,`=temp-4']
		/*main effect, se and p-value*/
		scalar tc1=A[1,tres[1,1]]
		scalar tc2=A[2,tres[1,1]]
		scalar tc3=A[4,tres[1,1]]
		/*covariate effect, se and p-value - different for each study and not reported*/
		scalar tc4=.
		scalar tc5=.
		scalar tc6=.
		/*interaction effect, se and p-value*/
		scalar tc7=A[1,tres[1,3]]
		scalar tc8=A[2,tres[1,3]]
		scalar tc9=A[4,tres[1,3]]
		/*intercept, se and p-value*/
		scalar tc10=A[1,tres[1,4]]
		scalar tc11=A[2,tres[1,4]]
		scalar tc12=A[4,tres[1,4]]
		/*convergence*/
		scalar conv=e(converged)	
		/*variance estimates*/
		qui _diparm lns1_1_1, f(exp(@)) d(exp(@))
		scalar tc15=r(est)	/*sd(grp)*/
		qui _diparm lns1_1_2, f(exp(@)) d(exp(@))
		scalar tc14=r(est)	/*sd(_cons)*/
		/*empty variance scalars*/
		scalar tc16=.		
		scalar tc17=.
		/*Overall R^2*/
		scalar tc18=.
	}
	else {
		scalar conv=0
		forvalues i=1(1)18 {
			scalar tc`i'=.
		}
	}
	/*return*/
	return scalar conv=conv	/*0=no covnergence*/
	forvalues i=1(1)18 {
		return scalar tc`i'=tc`i'
	}
end

/*IPDforest model 4: random study intercept; random treatment effect; random effect for baseline*/
program model6, rclass
	/*SE calculation often fails*/
	scalar outtp=`1'	/*0=continuous, 1=binary*/
	scalar cncov=`2'	/*0=binary, 1=continuous*/
	scalar bsc=0		/*successful run or not*/
	scalar bexp=`5'	    /*1=binary exposure, 1=continuous exposure*/
	/*model components*/
	if bexp==1 {
        local exp1 "i.grp"
        local exp2 "1.grp"
    }
    else {
        local exp1 "grp"
        local exp2 "c.grp"
    }
	if cncov==1 {
        local xcv1 "xcovar"
        local xcv2 "c.xcovar"
    }
    else {
        local xcv1 "1.xcovar"
        local xcv2 "1.xcovar"
    }
	/*linear model*/
	if outtp==0 {
		/*model*/
		capture xtmixed outcome `exp1' `xcv1' `exp2'#`xcv2' || studyid: grp xcovar, cov(uns) iterate(20)
		if _rc==0 {
			matrix A=r(table)					
			scalar bsc=1			
			/*variance estimates*/
			qui _diparm lnsig_e, f(exp(@)) d(exp(@))
			scalar tc13=r(est)	/*sd(Residual)*/
		}			
	}
	/*logistic model*/
	else if outtp==1 {
        capture xtmelogit outcome `exp1' `xcv1' `exp2'#`xcv2' || studyid: grp xcovar, cov(uns) iterate(20)
		if _rc==0 {
			matrix A=r(table)				
			scalar bsc=1			
			/*variance estimates*/			
			scalar tc13=.	/*sd(Residual)*/
		}		
    }
	/*poisson model*/
	else if outtp==2 {
        capture xtmepoisson outcome `exp1' `xcv1' `exp2'#`xcv2' || studyid: grp xcovar, cov(uns) iterate(20)
		if _rc==0 {
			matrix A=r(table)				
			scalar bsc=1
			/*variance estimates*/			
			scalar tc13=.	/*sd(Residual)*/
		}
    }
	if bsc==1 {
        matrix tres = [1,2,3,4]
		/*main effect, se and p-value*/
		scalar tc1=A[1,tres[1,1]]
		scalar tc2=A[2,tres[1,1]]
		scalar tc3=A[4,tres[1,1]]
		/*covariate effect, se and p-value - different for each study and not reported*/
		scalar tc4=A[1,tres[1,2]]
		scalar tc5=A[2,tres[1,2]]
		scalar tc6=A[4,tres[1,2]]
		/*interaction effect, se and p-value*/
		scalar tc7=A[1,tres[1,3]]
		scalar tc8=A[2,tres[1,3]]
		scalar tc9=A[4,tres[1,3]]
		/*intercept, se and p-value*/
		scalar tc10=A[1,tres[1,4]]
		scalar tc11=A[2,tres[1,4]]
		scalar tc12=A[4,tres[1,4]]
		/*convergence*/
		scalar conv=e(converged)	
		/*variance estimates*/
		qui _diparm lns1_1_3, f(exp(@)) d(exp(@))
		scalar tc14=r(est)	/*sd(_cons)*/	
		qui _diparm lns1_1_1, f(exp(@)) d(exp(@))
		scalar tc15=r(est)	/*sd(grp)*/		
		qui _diparm lns1_1_2, f(exp(@)) d(exp(@))
		scalar tc16=r(est)	/*sd(xcovar)*/	
		/*empty variance scalars*/
		scalar tc17=.	
		/*Overall R^2*/
		scalar tc18=.
	}
	else {
		scalar conv=0
		forvalues i=1(1)18 {
			scalar tc`i'=.
		}
	}
	/*return*/
	return scalar conv=conv	/*0=no covnergence*/
	forvalues i=1(1)18 {
		return scalar tc`i'=tc`i'
	}
end

/*IPDforest model X: random study intercept; random treatment effect; random effect for baseline; random effect for interaction*/
program model7, rclass
	qui gen grpXxcovar = grp*xcovar
	/*SE calculation often fails*/
	scalar outtp=`1'	/*0=continuous, 1=binary*/
	scalar cncov=`2'	/*0=binary, 1=continuous*/
	scalar bsc=0		/*successful run or not*/
	scalar bexp=`5'	    /*1=binary exposure, 1=continuous exposure*/
	/*model components*/
	if bexp==1 {
        local exp1 "i.grp"
        local exp2 "1.grp"
    }
    else {
        local exp1 "grp"
        local exp2 "c.grp"
    }
	if cncov==1 {
        local xcv1 "xcovar"
        local xcv2 "c.xcovar"
    }
    else {
        local xcv1 "1.xcovar"
        local xcv2 "1.xcovar"
    }
	/*linear model*/
	if outtp==0 {
	    /*model*/
	    capture xtmixed outcome `exp1' `xcv1' `exp2'#`xcv2' || studyid: grp xcovar grpXxcovar, cov(uns) iterate(20)
		if _rc==0 {
			matrix A=r(table)					
			scalar bsc=1			
			/*variance estimates*/			
			qui _diparm lnsig_e, f(exp(@)) d(exp(@))
			scalar tc13=r(est)	/*sd(Residual)*/
		}			
	}
	/*logistic model*/
	else if outtp==1 {
        capture xtmelogit outcome `exp1' `xcv1' `exp2'#`xcv2' || studyid: grp xcovar grpXxcovar, cov(uns) iterate(20)
		if _rc==0 {
			matrix A=r(table)				
			scalar bsc=1			
			/*variance estimates*/			
			scalar tc13=.	/*sd(Residual)*/
		}
	}
	/*poisson model*/
	else if outtp==2 {
        capture xtmepoisson outcome `exp1' `xcv1' `exp2'#`xcv2' || studyid: grp xcovar grpXxcovar, cov(uns) iterate(20)
		if _rc==0 {
			matrix A=r(table)				
			scalar bsc=1
			/*variance estimates*/			
			scalar tc13=.	/*sd(Residual)*/
		}		
    }
	if bsc==1 {  
        matrix tres = [1,2,3,4]      
		/*main effect, se and p-value*/
		scalar tc1=A[1,tres[1,1]]
		scalar tc2=A[2,tres[1,1]]
		scalar tc3=A[4,tres[1,1]]
		/*covariate effect, se and p-value - different for each study and not reported*/
		scalar tc4=A[1,tres[1,2]]
		scalar tc5=A[2,tres[1,2]]
		scalar tc6=A[4,tres[1,2]]
		/*interaction effect, se and p-value*/
		scalar tc7=A[1,tres[1,3]]
		scalar tc8=A[2,tres[1,3]]
		scalar tc9=A[4,tres[1,3]]
		/*intercept, se and p-value*/
		scalar tc10=A[1,tres[1,4]]
		scalar tc11=A[2,tres[1,4]]
		scalar tc12=A[4,tres[1,4]]
		/*convergence*/
		scalar conv=e(converged)	
		/*variance estimates*/
		qui _diparm lns1_1_4, f(exp(@)) d(exp(@))
		scalar tc14=r(est)	/*sd(_cons)*/	
		qui _diparm lns1_1_1, f(exp(@)) d(exp(@))
		scalar tc15=r(est)	/*sd(grp)*/		
		qui _diparm lns1_1_2, f(exp(@)) d(exp(@))
		scalar tc16=r(est)	/*sd(xcovar)*/	
		qui _diparm lns1_1_3, f(exp(@)) d(exp(@))
		scalar tc17=r(est)	/*sd(grpXxcovar)*/	
		/*Overall R^2*/
		scalar tc18=.
	}
	else {
		scalar conv=0
		forvalues i=1(1)18 {
			scalar tc`i'=.
		}
	}
	/*return*/
	return scalar conv=conv	/*0=no covnergence*/
	forvalues i=1(1)18 {
		return scalar tc`i'=tc`i'
	}
end

/*multiple imputation models*/

/*basic linear regression with multiple imputation*/
program model1mi, rclass
	scalar outtp=`1'	/*0=continuous, 1=binary, 2=poisson*/
	scalar cncov=`2'	/*0=binary, 1=continuous*/
	scalar impnum=`5'
	scalar pmm=`6'
	scalar bexp=`7'	    /*1=binary exposure, 1=continuous exposure*/
	/*mi settings*/
	qui mi set wide
	qui mi register imputed outcome
	qui mi register regular xcovar
	/*model components*/
	if bexp==1 {
        local exp1 "i.grp"
        local exp2 "i.grp"
        /*where in r(table)*/
        matrix tres = [2,3,5,6]
    }
    else {
        local exp1 "grp"
        local exp2 "c.grp"
        matrix tres = [1,2,3,4]
    }
	if cncov==1 {
        local xcv1 "xcovar"
        local xcv2 "c.xcovar"
    }
    else {
        local xcv1 "1.xcovar"
        local xcv2 "i.xcovar"
    }
	/*linear model*/
	if outtp==0 {
        /*rather than use mi impute, can use mibeta to get R^2 as well - but does not return r(table)*/
    	/*regress (default) or pmm approach*/
    	if pmm==0 {
            qui mi impute regress outcome `exp1' `xcv1' `exp2'#`xcv2', add(`=impnum')
        }
        else {
            qui mi impute pmm outcome `exp1' `xcv1' `exp2'#`xcv2', add(`=impnum') knn(`=pmm')
        }
		//capture mibeta outcome i.grp xcovar i.grp#c.xcovar
		capture mi estimate: regress outcome `exp1' `xcv1' `exp2'#`xcv2'
	}
	/*logistic model*/
	else if outtp==1 {
    	qui mi impute logit outcome `exp1' `xcv1' `exp2'#`xcv2', add(`=impnum')
		capture mi estimate: logit outcome `exp1' `xcv1' `exp2'#`xcv2'
	}
	/*poisson model*/
	else if outtp==2 {
        qui mi impute poisson outcome `exp1' `xcv1' `exp2'#`xcv2', add(`=impnum')
		capture mi estimate: poisson outcome `exp1' `xcv1' `exp2'#`xcv2'
    }
	if _rc==0 {
		matrix A=r(table)
		/*main effect, se and p-value*/
		scalar tc1=A[1,tres[1,1]]
		scalar tc2=A[2,tres[1,1]]
		scalar tc3=A[4,tres[1,1]]
		/*covariate effect, se and p-value*/
		scalar tc4=A[1,tres[1,2]]
		scalar tc5=A[2,tres[1,2]]
		scalar tc6=A[4,tres[1,2]]
		/*interaction effect, se and p-value*/
		scalar tc7=A[1,tres[1,3]]
		scalar tc8=A[2,tres[1,3]]
		scalar tc9=A[4,tres[1,3]]
		/*intercept, se and p-value*/
		scalar tc10=A[1,tres[1,4]]
		scalar tc11=A[2,tres[1,4]]
		scalar tc12=A[4,tres[1,4]]
		/*empty variance scalars*/
		scalar tc13=.
		scalar tc14=.
		scalar tc15=.
		scalar tc16=.
		scalar tc17=.
		/*R^2 not computable in mi*/
		scalar tc18=.
		scalar conv=1
	}
	else {
		scalar conv=0
		forvalues i=1(1)18 {
			scalar tc`i'=.
		}
	}
	/*return*/
	return scalar conv=conv
	forvalues i=1(1)18 {
		return scalar tc`i'=tc`i'
	}
end

/*multiple imputation random effects regression - for study (intercept)*/
program model2mi, rclass
	scalar outtp=`1'	/*0=continuous, 1=binary*/
	scalar cncov=`2'	/*0=binary, 1=continuous*/
	scalar redist=`4'	/*0=gamma distribution for RE, 1=normal distribution for RE*/
	scalar impnum=`5'
	scalar pmm=`6'
	scalar bexp=`7'	    /*1=binary exposure, 1=continuous exposure*/
	/*mi settings*/
	qui mi set wide
	qui mi xtset studyid
	qui mi register imputed outcome
	qui mi register regular xcovar
	/*model components*/
	if bexp==1 {
        local exp1 "i.grp"
        local exp2 "i.grp"
        /*where in r(table)*/
        matrix tres = [2,3,5,6]
    }
    else {
        local exp1 "grp"
        local exp2 "c.grp"
        matrix tres = [1,2,3,4]
    }
	if cncov==1 {
        local xcv1 "xcovar"
        local xcv2 "c.xcovar"
    }
    else {
        local xcv1 "1.xcovar"
        local xcv2 "i.xcovar"
    }
	/*linear model*/
	if outtp==0 {
    	/*regress (default) or pmm approach*/
    	if pmm==0 {
            qui mi impute regress outcome `exp1' `xcv1' `exp2'#`xcv2' i.studyid, add(`=impnum')
        }
        else {
            qui mi impute pmm outcome `exp1' `xcv1' `exp2'#`xcv2' i.studyid, add(`=impnum') knn(`=pmm')
        }
        capture mi estimate: xtreg outcome `exp1' `xcv1' `exp2'#`xcv2'
		/*variance estimates*/
		if _rc==0 {
            scalar tc14=e(sigma_u_mi)	/*between (intercept)*/
    	    /*within*/
		    scalar tc13=e(sigma_e_mi)
		}
    }
	/*logistic model*/
	else if outtp==1 {
        qui mi impute logit outcome `exp1' `xcv1' `exp2'#`xcv2' i.studyid, add(`=impnum')
        capture mi estimate: xtlogit outcome `exp1' `xcv1' `exp2'#`xcv2' i.studyid, iterate(20)
		/*variance estimates*/
		if _rc==0 {
		  matrix A=r(table)
		  scalar tc14=A[1,8]	/*between (intercept)*/
    	   /*within*/
		  scalar tc13=sqrt(tc14^2*(1-A[1,9])/A[1,9])
		}
    }
	/*poisson model*/
	else if outtp==2 {
        local tstr=""
        if redist==1 local tstr="normal"
        qui mi impute poisson outcome `exp1' `xcv1' `exp2'#`xcv2' i.studyid, add(`=impnum')
		capture mi estimate: xtpoisson outcome `exp1' `xcv1' `exp2'#`xcv2' i.studyid, iterate(20) `tstr'
		/*variance estimates*/
		if _rc==0 {
		    matrix A=r(table)
            scalar tc14=A[1,8]	/*between (intercept)*/
    		/*within - not computable*/
    		scalar tc13=.
        }
    }
	if _rc==0 {
		matrix A=r(table)
		/*main effect, se and p-value*/
		scalar tc1=A[1,tres[1,1]]
		scalar tc2=A[2,tres[1,1]]
		scalar tc3=A[4,tres[1,1]]
		/*covariate effect, se and p-value*/
		scalar tc4=A[1,tres[1,2]]
		scalar tc5=A[2,tres[1,2]]
		scalar tc6=A[4,tres[1,2]]
		/*interaction effect, se and p-value*/
		scalar tc7=A[1,tres[1,3]]
		scalar tc8=A[2,tres[1,3]]
		scalar tc9=A[4,tres[1,3]]
		/*intercept, se and p-value*/
		scalar tc10=A[1,tres[1,4]]
		scalar tc11=A[2,tres[1,4]]
		scalar tc12=A[4,tres[1,4]]
		/*empty variance scalars*/
		scalar tc15=.
		scalar tc16=.
		scalar tc17=.
		/*Overall R^2*/
		scalar tc18=.
		scalar conv=1
	}
	else {
		scalar conv=0
		forvalues i=1(1)18 {
			scalar tc`i'=.
		}
	}
	/*return*/
	return scalar conv=conv
	forvalues i=1(1)18 {
		return scalar tc`i'=tc`i'
	}
end

/*multiple imputation IPDforest model 1: fixed common intercept; random treatment effect; fixed effect for baseline*/
program model3mi, rclass
	scalar outtp=`1'	/*0=continuous, 1=binary, 2=count*/
	scalar cncov=`2'	/*0=binary, 1=continuous*/
	scalar impnum=`5'
	scalar pmm=`6'
	scalar bexp=`7'	    /*1=binary exposure, 1=continuous exposure*/
	/*mi settings*/
	qui mi set wide
	qui mi xtset studyid
	qui mi register imputed outcome
	qui mi register regular xcovar
	/*model components*/
	if bexp==1 {
        local exp1 "1.grp"
        local exp2 "1.grp"
    }
    else {
        local exp1 "grp"
        local exp2 "c.grp"
    }
	if cncov==1 {
        local xcv1 "xcovar"
        local xcv2 "c.xcovar"
    }
    else {
        local xcv1 "1.xcovar"
        local xcv2 "1.xcovar"
    }
	/*strings for coefficient selection purposes*/
	if outtp==0 {
        local prfx "outcome"
    }
    else {
        local prfx "eq1"
    }
    local expstr "`prfx':`exp1'"
    local covstr "`prfx':`xcv1'"
    local intervstr "`prfx':`exp2'#`xcv2'"
	/*linear model*/
	if outtp==0 {
    	/*regress (default) or pmm approach*/
    	if pmm==0 {
            qui mi impute regress outcome `exp1' `xcv1' `exp2'#`xcv2' i.studyid, add(`=impnum')
        }
        else {
            qui mi impute pmm outcome `exp1' `xcv1' `exp2'#`xcv2' i.studyid, add(`=impnum') knn(`=pmm')
        }
    	capture mi estimate, post coefl: xtmixed outcome `exp1' `xcv1' `exp2'#`xcv2' || studyid: grp, nocons iterate(20)
    }
	/*logistic model*/
	else if outtp==1 {
        qui mi impute logit outcome `exp1' `xcv1' `exp2'#`xcv2' i.studyid, add(`=impnum')
        capture mi estimate, post coefl: xtmelogit outcome `exp1' `xcv1' `exp2'#`xcv2' || studyid: grp, nocons iterate(20)
    }
	/*poisson model*/
	else if outtp==2 {
        qui mi impute poisson outcome `exp1' `xcv1' `exp2'#`xcv2' i.studyid, add(`=impnum')
        capture mi estimate, post coefl: xtmepoisson outcome `exp1' `xcv1' `exp2'#`xcv2' || studyid: grp, nocons iterate(20)
    }
	if _rc==0 {
        matrix tres = [1,2,3,4]
		/*coefficients*/
		matrix A=e(df_mi)
        /*main effect, se and p-value*/
		scalar tc1=_b[`expstr']
		scalar tc2=_se[`expstr']
		scalar tc3=2*ttail(A[1,tres[1,1]],abs(tc1/tc2))
        /*covariate effect, se and p-value*/
		scalar tc4=_b[`covstr']
		scalar tc5=_se[`covstr']
		scalar tc6=2*ttail(A[1,tres[1,2]],abs(tc4/tc5))
        /*interaction effect, se and p-value*/
		scalar tc7=_b[`intervstr']
		scalar tc8=_se[`intervstr']
		scalar tc9=2*ttail(A[1,tres[1,3]],abs(tc7/tc8))
        /*intercept effect, se and p-value*/
		scalar tc10=_b[`prfx':_cons]
		scalar tc11=_se[`prfx':_cons]
		scalar tc12=2*ttail(A[1,tres[1,4]],abs(tc10/tc11))
		/*variance estimates*/
		/*sd(Residual)*/
        capture _diparm lnsig_e, f(exp(@)) d(exp(@))
        if _rc==0 {
		    scalar tc13=r(est)
	    }
	    else {
		    scalar tc13=.
        }
        /*sd(grp)*/
        qui _diparm lns1_1_1, f(exp(@)) d(exp(@))
		scalar tc15=r(est)
		/*convergence*/
		scalar conv=1
		/*empty variance scalars*/
		scalar tc14=.
		scalar tc16=.	
		scalar tc17=.
		/*Overall R^2*/
		scalar tc18=.
	}
	else {
		scalar conv=0
		forvalues i=1(1)18 {
			scalar tc`i'=.
		}
	}
	/*return*/
	return scalar conv=conv	/*0=no covnergence*/
	forvalues i=1(1)18 {
		return scalar tc`i'=tc`i'
	}
end

/*multiple imputation IPDforest model 2: fixed study specific intercepts; random treatment effect; fixed study specific effect for baseline*/
program model4mi, rclass
	/*generate study specific baseline vars*/
	forvalues x=1(1)`=studynum' {
		qui gen xcovar`x'=0
		qui replace xcovar`x'=xcovar if studyid==`x'
	}
	scalar outtp=`1'	/*0=continuous, 1=binary, 2=count*/
	scalar cncov=`2'	/*0=binary, 1=continuous*/
	scalar impnum=`5'
	scalar pmm=`6'
	scalar bexp=`7'	    /*1=binary exposure, 1=continuous exposure*/
	/*mi settings*/
	qui mi set wide
	qui mi xtset studyid
	qui mi register imputed outcome
	qui mi register regular xcovar
	/*model components*/
	if bexp==1 {
        local exp1 "1.grp"
        local exp2 "1.grp"
    }
    else {
        local exp1 "grp"
        local exp2 "c.grp"
    }
	if cncov==1 {
        local xcv1 "xcovar"
        local xcv2 "c.xcovar"
    }
    else {
        local xcv1 "1.xcovar"
        local xcv2 "1.xcovar"
    }
	/*strings for coefficient selection purposes*/
	if outtp==0 {
        local prfx "outcome"
    }
    else {
        local prfx "eq1"
    }
    local expstr "`prfx':`exp1'"
    local covstr "`prfx':`xcv1'"
    local intervstr "`prfx':`exp2'#`xcv2'"
	/*linear model*/
	if outtp==0 {
    	/*regress (default) or pmm approach*/
    	if pmm==0 {
            qui mi impute regress outcome `exp1' `xcv1' `exp2'#`xcv2' i.studyid, add(`=impnum')
        }
        else {
            qui mi impute pmm outcome `exp1' `xcv1' `exp2'#`xcv2' i.studyid, add(`=impnum') knn(`=pmm')
        }
    	capture mi estimate, post coefl: xtmixed outcome `exp1' `exp2'#`xcv2' i.studyid xcovar1-xcovar`=studynum' || studyid: grp, nocons iterate(20)
    }
	/*logistic model*/
	else if outtp==1 {
        qui mi impute logit outcome `exp1' `xcv1' `exp2'#`xcv2' i.studyid, add(`=impnum')
        capture mi estimate, post coefl: xtmelogit outcome `exp1' `exp2'#`xcv2' i.studyid xcovar1-xcovar`=studynum' || studyid: grp, nocons iterate(20)
    }
	/*poisson model*/
	else if outtp==2 {
        qui mi impute poisson outcome `exp1' `xcv1' `exp2'#`xcv2' i.studyid, add(`=impnum')
        capture mi estimate, post coefl: xtmepoisson outcome `exp1' `exp2'#`xcv2' i.studyid xcovar1-xcovar`=studynum' || studyid: grp, nocons iterate(20)
    }
	if _rc==0 {
        matrix tres = [1,.,2,.]
		/*coefficients*/
		matrix A=e(df_mi)
        /*main effect, se and p-value*/
		scalar tc1=_b[`expstr']
		scalar tc2=_se[`expstr']
		scalar tc3=2*ttail(A[1,tres[1,1]],abs(tc1/tc2))
        /*covariate effect, se and p-value*/
		scalar tc4=.
		scalar tc5=.
		scalar tc6=.
        /*interaction effect, se and p-value*/
		scalar tc7=_b[`intervstr']
		scalar tc8=_se[`intervstr']
		scalar tc9=2*ttail(A[1,tres[1,3]],abs(tc7/tc8))
        /*intercept effect, se and p-value*/
        /*scalar temp=colsof(A)*/
		scalar tc10=. /*_b[`prfx':_cons]*/
		scalar tc11=. /*_se[`prfx':_cons]*/
		scalar tc12=. /*2*ttail(A[1,`=temp-2'],abs(tc10/tc11))*/
		/*variance estimates*/
		/*sd(Residual)*/
        capture _diparm lnsig_e, f(exp(@)) d(exp(@))
        if _rc==0 {
		    scalar tc13=r(est)
	    }
	    else {
		    scalar tc13=.
        }
        /*sd(grp)*/
        qui _diparm lns1_1_1, f(exp(@)) d(exp(@))
		scalar tc15=r(est)
		/*convergence*/
		scalar conv=1
		/*empty variance scalars*/
		scalar tc14=.
		scalar tc16=.	
		scalar tc17=.
		/*Overall R^2*/
		scalar tc18=.
	}
	else {
		scalar conv=0
		forvalues i=1(1)18 {
			scalar tc`i'=.
		}
	}
	/*return*/
	return scalar conv=conv	/*0=no covnergence*/
	forvalues i=1(1)18 {
		return scalar tc`i'=tc`i'
	}
end

/*multiple imputation IPDforest model 3: random study intercept; random treatment effect; fixed study specific effect for baseline*/
program model5mi, rclass
	/*generate study specific baseline vars*/
	forvalues x=1(1)`=studynum' {
		qui gen xcovar`x'=0
		qui replace xcovar`x'=xcovar if studyid==`x'
	}
	scalar outtp=`1'	/*0=continuous, 1=binary, 2=count*/
	scalar cncov=`2'	/*0=binary, 1=continuous*/
	scalar impnum=`5'
	scalar pmm=`6'
	scalar bexp=`7'	    /*1=binary exposure, 1=continuous exposure*/
	/*mi settings*/
	qui mi set wide
	qui mi xtset studyid
	qui mi register imputed outcome
	qui mi register regular xcovar
	/*model components*/
	if bexp==1 {
        local exp1 "1.grp"
        local exp2 "1.grp"
    }
    else {
        local exp1 "grp"
        local exp2 "c.grp"
    }
	if cncov==1 {
        local xcv1 "xcovar"
        local xcv2 "c.xcovar"
    }
    else {
        local xcv1 "1.xcovar"
        local xcv2 "1.xcovar"
    }
	/*strings for coefficient selection purposes*/
	if outtp==0 {
        local prfx "outcome"
    }
    else {
        local prfx "eq1"
    }
    local expstr "`prfx':`exp1'"
    local covstr "`prfx':`xcv1'"
    local intervstr "`prfx':`exp2'#`xcv2'"
    /*linear model*/
	if outtp==0 {
    	/*regress (default) or pmm approach*/
    	if pmm==0 {
            qui mi impute regress outcome `exp1' `xcv1' `exp2'#`xcv2' i.studyid, add(`=impnum')
        }
        else {
            qui mi impute pmm outcome `exp1' `xcv1' `exp2'#`xcv2' i.studyid, add(`=impnum') knn(`=pmm')
        }
    	capture mi estimate, post coefl: xtmixed outcome `exp1' `exp2'#`xcv2' xcovar1-xcovar`=studynum' || studyid: grp, cov(uns) iterate(20)
    }
	/*logistic model*/
	else if outtp==1 {
        qui mi impute logit outcome `exp1' `xcv1' `exp2'#`xcv2' i.studyid, add(`=impnum')
        capture mi estimate, post coefl: xtmelogit outcome `exp1' `exp2'#`xcv2' xcovar1-xcovar`=studynum' || studyid: grp, cov(uns) iterate(20)
    }
	/*poisson model*/
	else if outtp==2 {
        qui mi impute poisson outcome `exp1' `xcv1' `exp2'#`xcv2' i.studyid, add(`=impnum')
        capture mi estimate, post coefl: xtmepoisson outcome `exp1' `exp2'#`xcv2' xcovar1-xcovar`=studynum' || studyid: grp, cov(uns) iterate(20)
    }
	if _rc==0 {
		matrix A=e(df_mi)
        scalar temp=colsof(A)
        matrix tres = [1,.,2,`=temp-4']
		/*coefficients*/
        /*main effect, se and p-value*/
		scalar tc1=_b[`expstr']
		scalar tc2=_se[`expstr']
		scalar tc3=2*ttail(A[1,tres[1,1]],abs(tc1/tc2))
        /*covariate effect, se and p-value*/
		scalar tc4=.
		scalar tc5=.
		scalar tc6=.
        /*interaction effect, se and p-value*/
		scalar tc7=_b[`intervstr']
		scalar tc8=_se[`intervstr']
		scalar tc9=2*ttail(A[1,tres[1,3]],abs(tc7/tc8))
        /*intercept effect, se and p-value*/
		scalar tc10=_b[`prfx':_cons]
		scalar tc11=_se[`prfx':_cons]
		scalar tc12=2*ttail(A[1,tres[1,4]],abs(tc10/tc11))
		/*variance estimates*/
		/*sd(Residual)*/
        capture _diparm lnsig_e, f(exp(@)) d(exp(@))
        if _rc==0 {
		    scalar tc13=r(est)
	    }
	    else {
		    scalar tc13=.
        }
        /*sd(grp)*/
        qui _diparm lns1_1_1, f(exp(@)) d(exp(@))
		scalar tc15=r(est)
        /*sd(_cons)*/
        qui _diparm lns1_1_2, f(exp(@)) d(exp(@))
		scalar tc14=r(est)
		/*convergence*/
		scalar conv=1
		/*empty variance scalars*/
		scalar tc16=.
		scalar tc17=.
		/*Overall R^2*/
		scalar tc18=.
	}
	else {
		scalar conv=0
		forvalues i=1(1)18 {
			scalar tc`i'=.
		}
	}
	/*return*/
	return scalar conv=conv	/*0=no covnergence*/
	forvalues i=1(1)18 {
		return scalar tc`i'=tc`i'
	}
end

/*multiple imputation IPDforest model 4: random study intercept; random treatment effect; random effect for baseline*/
program model6mi, rclass
	/*SE calculation often fails*/
    scalar outtp=`1'	/*0=continuous, 1=binary, 2=count*/
	scalar cncov=`2'	/*0=binary, 1=continuous*/
	scalar impnum=`5'
	scalar pmm=`6'
	scalar bexp=`7'	    /*1=binary exposure, 1=continuous exposure*/
	/*mi settings*/
	qui mi set wide
	qui mi xtset studyid
	qui mi register imputed outcome
	qui mi register regular xcovar
	/*model components*/
	if bexp==1 {
        local exp1 "1.grp"
        local exp2 "1.grp"
    }
    else {
        local exp1 "grp"
        local exp2 "c.grp"
    }
	if cncov==1 {
        local xcv1 "xcovar"
        local xcv2 "c.xcovar"
    }
    else {
        local xcv1 "1.xcovar"
        local xcv2 "1.xcovar"
    }
	/*strings for coefficient selection purposes*/
	if outtp==0 {
        local prfx "outcome"
    }
    else {
        local prfx "eq1"
    }
    local expstr "`prfx':`exp1'"
    local covstr "`prfx':`xcv1'"
    local intervstr "`prfx':`exp2'#`xcv2'"
	/*linear model*/
	if outtp==0 {
    	/*regress (default) or pmm approach*/
    	if pmm==0 {
            qui mi impute regress outcome `exp1' `xcv1' `exp2'#`xcv2' i.studyid, add(`=impnum')
        }
        else {
            qui mi impute pmm outcome `exp1' `xcv1' `exp2'#`xcv2' i.studyid, add(`=impnum') knn(`=pmm')
        }
    	capture mi estimate, post coefl: xtmixed outcome `exp1' `xcv1' `exp2'#`xcv2' || studyid: grp xcovar, cov(uns) iterate(20)
    }
	/*logistic model*/
	else if outtp==1 {
        qui mi impute logit outcome `exp1' `xcv1' `exp2'#`xcv2' i.studyid, add(`=impnum')
        capture mi estimate, post coefl: xtmelogit outcome `exp1' `xcv1' `exp2'#`xcv2' || studyid: grp xcovar, cov(uns) iterate(20)
    }
	/*poisson model*/
	else if outtp==2 {
        qui mi impute poisson outcome `exp1' `xcv1' `exp2'#`xcv2' i.studyid, add(`=impnum')
        capture mi estimate, post coefl: xtmepoisson outcome `exp1' `xcv1' `exp2'#`xcv2' || studyid: grp xcovar, cov(uns) iterate(20)
    }
	if _rc==0 {
        matrix tres = [1,2,3,4]
		/*coefficients*/
		matrix A=e(df_mi)
        /*main effect, se and p-value*/
		scalar tc1=_b[`expstr']
		scalar tc2=_se[`expstr']
		scalar tc3=2*ttail(A[1,tres[1,1]],abs(tc1/tc2))
        /*covariate effect, se and p-value*/
        /*covariate effect, se and p-value*/
		scalar tc4=_b[`covstr']
		scalar tc5=_se[`covstr']
		scalar tc6=2*ttail(A[1,tres[1,2]],abs(tc4/tc5))
        /*interaction effect, se and p-value*/
		scalar tc7=_b[`intervstr']
		scalar tc8=_se[`intervstr']
		scalar tc9=2*ttail(A[1,tres[1,3]],abs(tc7/tc8))
        /*intercept effect, se and p-value*/
		scalar tc10=_b[`prfx':_cons]
		scalar tc11=_se[`prfx':_cons]
		scalar tc12=2*ttail(A[1,tres[1,4]],abs(tc10/tc11))
		/*variance estimates*/
		/*sd(Residual)*/
        capture _diparm lnsig_e, f(exp(@)) d(exp(@))
        if _rc==0 {
		    scalar tc13=r(est)
	    }
	    else {
		    scalar tc13=.
        }
        /*sd(_cons)*/
        qui _diparm lns1_1_3, f(exp(@)) d(exp(@))
		scalar tc14=r(est)
        /*sd(grp)*/
        qui _diparm lns1_1_1, f(exp(@)) d(exp(@))
		scalar tc15=r(est)
        /*sd(xcovar)*/
        qui _diparm lns1_1_2, f(exp(@)) d(exp(@))
		scalar tc16=r(est)
		/*convergence*/
		scalar conv=1
		/*empty variance scalars*/
		scalar tc17=.
		/*Overall R^2*/
		scalar tc18=.
	}
	else {
		scalar conv=0
		forvalues i=1(1)18 {
			scalar tc`i'=.
		}
	}
	/*return*/
	return scalar conv=conv	/*0=no covnergence*/
	forvalues i=1(1)18 {
		return scalar tc`i'=tc`i'
	}
end

/*multiple imputation IPDforest model X: random study intercept; random treatment effect; random effect for baseline; random effect for interaction*/
program model7mi, rclass
    qui gen grpXxcovar = grp*xcovar
	/*SE calculation often fails*/
    scalar outtp=`1'	/*0=continuous, 1=binary, 2=count*/
	scalar cncov=`2'	/*0=binary, 1=continuous*/
	scalar impnum=`5'
	scalar pmm=`6'
    scalar bexp=`7'	    /*1=binary exposure, 1=continuous exposure*/
	/*mi settings*/
	qui mi set wide
	qui mi xtset studyid
	qui mi register imputed outcome
	qui mi register regular xcovar
	/*model components*/
	if bexp==1 {
        local exp1 "1.grp"
        local exp2 "1.grp"
    }
    else {
        local exp1 "grp"
        local exp2 "c.grp"
    }
	if cncov==1 {
        local xcv1 "xcovar"
        local xcv2 "c.xcovar"
    }
    else {
        local xcv1 "1.xcovar"
        local xcv2 "1.xcovar"
    }
	/*strings for coefficient selection purposes*/
	if outtp==0 {
        local prfx "outcome"
    }
    else {
        local prfx "eq1"
    }
    local expstr "`prfx':`exp1'"
    local covstr "`prfx':`xcv1'"
    local intervstr "`prfx':`exp2'#`xcv2'"
	/*linear model*/
	if outtp==0 {
    	/*regress (default) or pmm approach*/
    	if pmm==0 {
            qui mi impute regress outcome `exp1' `xcv1' `exp2'#`xcv2' i.studyid, add(`=impnum')
        }
        else {
            qui mi impute pmm outcome `exp1' `xcv1' `exp2'#`xcv2' i.studyid, add(`=impnum') knn(`=pmm')
        }
    	capture mi estimate, post coefl: xtmixed outcome `exp1' `xcv1' `exp2'#`xcv2' || studyid: grp xcovar grpXxcovar, cov(uns) iterate(20)
    }
	/*logistic model*/
	else if outtp==1 {
        qui mi impute logit outcome `exp1' `xcv1' `exp2'#`xcv2' i.studyid, add(`=impnum')
        capture mi estimate, post coefl: xtmelogit outcome `exp1' `xcv1' `exp2'#`xcv2' || studyid: grp xcovar grpXxcovar, cov(uns) iterate(20)
    }
	/*poisson model*/
	else if outtp==2 {
        qui mi impute poisson outcome `exp1' `xcv1' `exp2'#`xcv2' i.studyid, add(`=impnum')
        capture mi estimate, post coefl: xtmepoisson outcome `exp1' `xcv1' `exp2'#`xcv2' || studyid: grp xcovar grpXxcovar, cov(uns) iterate(20)
    }
	if _rc==0 {
        matrix tres = [1,2,3,4]
		/*coefficients*/
		matrix A=e(df_mi)
        /*main effect, se and p-value*/
		scalar tc1=_b[`expstr']
		scalar tc2=_se[`expstr']
		scalar tc3=2*ttail(A[1,tres[1,1]],abs(tc1/tc2))
        /*covariate effect, se and p-value*/
        /*covariate effect, se and p-value*/
		scalar tc4=_b[`covstr']
		scalar tc5=_se[`covstr']
		scalar tc6=2*ttail(A[1,tres[1,2]],abs(tc4/tc5))
        /*interaction effect, se and p-value*/
		scalar tc7=_b[`intervstr']
		scalar tc8=_se[`intervstr']
		scalar tc9=2*ttail(A[1,tres[1,3]],abs(tc7/tc8))
        /*intercept effect, se and p-value*/
		scalar tc10=_b[`prfx':_cons]
		scalar tc11=_se[`prfx':_cons]
		scalar tc12=2*ttail(A[1,tres[1,4]],abs(tc10/tc11))
		/*variance estimates*/
		/*sd(Residual)*/
        capture _diparm lnsig_e, f(exp(@)) d(exp(@))
        if _rc==0 {
		    scalar tc13=r(est)
	    }
	    else {
		    scalar tc13=.
        }
        /*sd(_cons)*/
        qui _diparm lns1_1_4, f(exp(@)) d(exp(@))
		scalar tc14=r(est)
        /*sd(grp)*/
        qui _diparm lns1_1_1, f(exp(@)) d(exp(@))
		scalar tc15=r(est)
        /*sd(xcovar)*/
        qui _diparm lns1_1_2, f(exp(@)) d(exp(@))
		scalar tc16=r(est)
        /*sd(grpXxcovar)*/
        qui _diparm lns1_1_3, f(exp(@)) d(exp(@))
		scalar tc17=r(est)
		/*convergence*/
		scalar conv=1
		/*Overall R^2*/
		scalar tc18=.
	}
	else {
		scalar conv=0
		forvalues i=1(1)18 {
			scalar tc`i'=.
		}
	}
	/*return*/
	return scalar conv=conv	/*0=no covnergence*/
	forvalues i=1(1)18 {
		return scalar tc`i'=tc`i'
	}
end


/*extra programs*/

/*Ramberg method - return scalar*/
program ramberg, rclass
	scalar dtype=`1'
	if dtype==0 {
		scalar sk=0
		scalar ku=3
	}
	else if dtype==1 {
		scalar sk=1
		scalar ku=4
	}
	else {
		scalar sk=2
		scalar ku=9
	}
	matrix input L = (0,3,0,0.1974,0.1349,0.1349\1,4,-0.886,0.1333,0.0193,0.1588\2,9,-0.993,-0.001081,-0.00000407,-0.001076)
    /*look up the lambda values that correspond to the inputed sk and ku*/
    local rownum = rowsof(L)
    local rowhit = 0
    local i = 0
    while `rowhit'==0 & `i'<`rownum' {
        local i = `i' + 1
        if L[`i',1]==sk & L[`i',2]==ku {
            local rowhit = `i'
        }
    }
    if `rowhit'==0 {
        display "lambda matrix does not include skewness or kurtosis values you inputed"
        error 504
    }
    else {
        forvalues i=1(1)4 {
            scalar L`i' = L[`rowhit',`i'+2]
        }
    }
	/*use the Lambdas to calculate a value to return*/
	/*random uniform dist number that will be used in Ramberg's method*/
    scalar uxt = uniform()
    if uxt == 0 scalar uxt = 10^-10
    /*Ramberg's random num generator*/
    return scalar rb = L1+(uxt^L3 - (1-uxt)^L4)/L2
    forvalues i=1(1)4 {
        return scalar L`i'=L`i'
    }
end

/*Ramberg method - return temp variable (improves speed rather than running for each case)*/
program rambergvar
	scalar dtype=`1'
	local vname = "`2'"
	if dtype==0 {
		scalar sk=0
		scalar ku=3
	}
	else if dtype==1 {
		scalar sk=1
		scalar ku=4
	}
	else {
		scalar sk=2
		scalar ku=9
	}
	matrix input L = (0,3,0,0.1974,0.1349,0.1349\1,4,-0.886,0.1333,0.0193,0.1588\2,9,-0.993,-0.001081,-0.00000407,-0.001076)
    /*look up the lambda values that correspond to the inputed sk and ku*/
    local rownum = rowsof(L)
    local rowhit = 0
    local i = 0
    while `rowhit'==0 & `i'<`rownum' {
        local i = `i' + 1
        if L[`i',1]==sk & L[`i',2]==ku {
            local rowhit = `i'
        }
    }
    if `rowhit'==0 {
        display "lambda matrix does not include skewness or kurtosis values you inputed"
        error 504
    }
    else {
        forvalues i=1(1)4 {
            scalar L`i' = L[`rowhit',`i'+2]
        }
    }
	/*use the Lambdas to calculate a value to return*/
	/*random uniform dist number that will be used in Ramberg's method*/
    qui gen `vname' = uniform()
    qui replace `vname'=10^-10 if `vname'==0
    /*Ramberg's random num generator*/
    qui replace `vname'=L1+(`vname'^L3 - (1-`vname')^L4)/L2
end
