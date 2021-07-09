 
{ // Data Level Parrellisation
	! rmdir _output /s /q
    ! rmdir _queue /s /q
	
    mkdir _output
    mkdir _queue

    * Create some source data.

    set seed 1
    clear
    set obs 200000
    gen myid = round(50* uniform(),1.0)
    save mylist.dta , replace


    * Read in your source data and create a list of variables to parallelise your code over.
    use mylist.dta , clear
    levelsof myid , local(myidlist)

    * Write a loop which creates a jobfile which echoes a do using mydofile with arguments.
    foreach id in `myidlist' {
    file open mydofile using _queue\job_`id'.do, write replace
    file write mydofile `"do mydofile.do `id' "'
    file close mydofile
    }

    * Where mydofile.do contains your code of interest for example:

    *---mydofile.do--------------------------------------
    * sysuse mylist.dta ,clear
    * keep if myid==`1'
    * egen count = count(myid)
    * save _output\myid`1' , replace
    *----------------------------------------------------

    qsub , jobdir(_queue) maxproc(8) append deletelogs outputdir(_output) outputsavename(compiledresults.dta)
}




{ // Simulation
 * Clear and then create a job, output and data directory.
    * WARNING ! rmdir "folder" /s /q forcefully reomves all content WARNING

    ! rmdir _output /s /q
    ! rmdir _queue /s /q
    ! rmdir _data /s /q

    mkdir _output
    mkdir _que
    mkdir _data

    * Create your simulated data of interest

    set seed 1
    clear
    set obs 100
    gen x = 100*uniform()
    gen y = 10 + 0.1*x
    save _data/design.dta , replace

    * Write a loop which creates a jobfile which echos a do using mydofile with arguments.
    forvalues sim = 1/20 {
    file open mydofile using _queue\sim`sim'.do, write replace
    file write mydofile `"do mysimfile.do `sim' "'
    file close mydofile
    }

    * Where mysimfile.do contains your code of interest for example:

    * ----mysimfile.do----------------------------------------------------------------
    * postfile results sim cons cons_se x x_se using _output/results`1'.dta, replace
    * use _data/design.dta , replace
    * set rngstream `1'
    * set seed 1
    * gen e =15*invnorm(uniform())
    * gen yobs = y + e

	* reg yobs x 
    * post results (`1') (_b[_cons]) (_se[_cons]) (_b[x]) (_se[x])
    * postclose results
    * --------------------------------------------------------------------------------
        
    qsub , jobdir(_queue) maxproc(4) append deletelogs outputdir(_output) outputsavename(simresults.dta)
		use simresults.dta , clear
}
	


{ // Bootstrapping
    * Clear and then create a job, output and data directory.
    * !WARNING! ! rmdir "folder" /s /q forcefully reomves all content, useful for quick clears when debugging but be careful. !WARNING!
	
    ! rmdir _output /s /q
    ! rmdir _queue /s /q
    ! rmdir _data /s /q

    mkdir _output
    mkdir _que
    mkdir _data

    * Write a loop which creates a jobfile which echos a do using mydofile with arguments.
    forvalues bs = 1/10 {
    file open mydofile using _queue\boot`bs'.do, write replace
    file write mydofile `"do mybootfile.do `bs' "'
    file close mydofile
    }

    * Where mybootfile.do contains your code of interest for example:

    * ----mybootfile.do----------------------------------------------------------------
    * postfile results i proportion using _output/boot`1'.dta, replace
    * webuse bsample1 ,clear
    * set rngstream `1'
    * set seed 1
    * bsample
	* ci proportion female ,  wald
    * post results (`1') (`r(proportion)')
    * postclose results
    * --------------------------------------------------------------------------------

    qsub , jobdir(_queue) maxproc(4) append deletelogs outputdir(_output) outputsavename(bootresults.dta)
		use bootresults.dta ,clear
	}
{ // Multiple Imputation

    ! rmdir _output /s /q
    ! rmdir _queue /s /q
    ! rmdir _data /s /q

    mkdir _output
    mkdir _queue
    mkdir _data
	
	webuse mheart8s0 , clear
		mi unset
			drop mi_*
				gen id = _n
					save mheart8s0 , replace

	
    forvalues mi = 1/10 {
    file open mydofile using _queue\mi`mi'.do, write replace
    file write mydofile `"do "mymifile.do" `mi' "'
    file close mydofile
    }
	
   qsub , jobdir(_queue) maxproc(4) deletelogs


use mheart8s0 , clear	
	cd _output 
	cap erase myimp.dta
	mi import flongsep myimp , using( _1_imp{1-10} ) id(id) clear imputed( age bmi)

	logit smokes age bmi , or
	
	mi estimate , post: logit smokes age bmi , or
}

*END
