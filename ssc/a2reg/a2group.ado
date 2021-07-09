*! version 0.0.1 23may2006

/*
 *
 * a2group: defines mobility groups
 * 	    For a thorough reference on this question,
 *	    see Amine Ouazad, 'Dynamic Two-Way Fixed Effect Models: Identification and Estimation'
 *	    at www.pse.ens.fr/junior/ouazad
 */

global ORIGAUTHOR     = "Robert Creecy"
global CURRENTAUTHOR  = "Amine Ouazad"
global VERSION	    = "0.1"

cap program drop a2group
program define a2group, sortpreserve
version 9.0
syntax , individual(varname) unit(varname) groupvar(name)

	display "Creating mobility groups"
	display "Version $VERSION"
	display "Current Author : $CURRENTAUTHOR ; Original author: $ORIGAUTHOR"
	display "Individual ID : `individual' ; Unit ID : `unit' ; Group variable : `groupvar'"

quietly {

preserve

	confirm new variable `groupvar'

	keep `individual' `unit'

	tempvar indid unitid 
	tempfile tempgroupfile

	egen `indid'  = group(`individual')
	egen `unitid' = group(`unit')

	keep `individual' `unit'  `indid' `unitid' 

	***** Keeps only cells : we are working with cells, not observations
	duplicates drop  `indid' `unitid', force

	mata: groups( "`indid'","`unitid'","`groupvar'")

	*** Drop new school and pupil indexes
	keep `individual' `unit' `groupvar'
	sort `individual' `unit'
	save "`tempgroupfile'", replace

	*** Merge group information with main input data file

restore
	
	sort `individual' `unit'
	merge `individual' `unit' using "`tempgroupfile'"
	drop _merge
	}

tab `groupvar'
end 


mata

void groups(string scalar individualid, string scalar unitid, string scalar groupvar) {

		real scalar ncells, npers, nfirm; 	/* Data size : number of distinct observations number of pupils number of schools */
		real matrix byp, byf; 			/* Dataset sorted by pupil/by school */
		real vector pg, fg, pindex, findex, ptraced, ftraced, ponstack, fonstack;
	
		/***** Stack for tracing elements */
		real vector m;				/* Stack of pupils/schools */
		real scalar mpoint;			/* Number of elements on the stack */
	
		real scalar nptraced, nftraced;	// Number of traced elements
		real scalar lasttenp, lasttenf;
		real scalar nextfirm;

		real vector mtype; 	/* Type of the element on top of the stack */
					 	/* Convention : 					 */
					 	/* 1 for a pupil					 */
					 	/* 2 for a school					 */
	
		real scalar g;	/* Current group */
	
		real scalar j;
	
		real matrix data;		/* A data view used to add group information after the algorithm completed */
	
		printf("Grouping algorithm for CG\n");
	
		/****** Core data : cells sorted by person/by firm */

		byp = st_data(., (individualid, unitid));
		printf("Sorting data by pupil id\n");
		byp = sort(byp,1);
	
		byf = st_data(., (individualid, unitid));
		printf("Sorting data by school id\n");
		byf = sort(byf,2);
		
		/****** Data size */
	
		ncells = rows(byf);		/* Number of distinct observations (duplicates drop has to be done beforehand) */
		npers  = byp[ncells,1];		/* Number of pupils										 */
		nfirm  = byf[ncells,2];		/* Number of schools										 */

		printf("Data size : %9.0g cells, %9.0g pupils, %9.0g firms\n", ncells, npers, nfirm);
	
		/****** Initializing the stack and p/ftraced */

		printf("Initializing the stack\n");
	
		ptraced  = J(npers, 1, 0);	// No pupil has been traced yet
		ftraced  = J(nfirm, 1, 0);	// No school has been traced yet

		ponstack = J(npers, 1, 0);	// No pupil has been on the stack yet
		fonstack = J(nfirm, 1, 0);	// No school has been on the stack yet
	
		m 	= J(npers+nfirm, 1, 0); // Empty stack
		mtype = J(npers+nfirm, 1, 0);	// Unknown type of the element on top of the stack
	
		printf("Initializing pg,fg\n");
	
		pg	= J(npers, 1, 0);
		fg	= J(nfirm, 1, 0);
	
		/****** Initializing pindex, findex */
	
		printf("Initializing the index arrays\n");
	
		pindex = J(npers, 1, 0);
		findex = J(nfirm, 1, 0);
	
		for ( j = 1 ; j <= ncells ; j++) {
			pindex[byp[j,1]] = j;
			findex[byf[j,2]] = j;
		}
	
		g = 1;   	// The first group is group 1
		
		check_data(byp, byf, ncells);
	
		/***** Puts the first firm in the stack */
	
		printf("Putting first school on the stack\n");
		nextfirm = 1;
		mpoint = 1;
		m[mpoint] = 1;
		mtype[mpoint] = 2;
		fonstack[1] = 1;
	
		printf("Starting to trace the stack\n");
		
		nptraced = 0;
		nftraced = 0;
		lasttenp = 0;
		lasttenf = 0;

		while (mpoint > 0) {
	
			if (trunc((nptraced/npers)*100.0) > lasttenp || trunc((nftraced/nfirm)*100.0) > lasttenf) {
				lasttenp = trunc((nptraced/npers)*100.0);
				lasttenf = trunc((nftraced/nfirm)*100.0);
	
				printf("Progress : %9.0g pct pupils traced, %9.0g pct firms traced\n",lasttenp,lasttenf);
			}
	
			if (g > 1) {
				printf("%9.0g\t", g);
			}
			trace_stack( byp, byf, pg, fg, m, mpoint, mtype, ponstack, fonstack, ptraced, ftraced, pindex,  findex,g, nptraced, nftraced);
			if (mpoint == 0) {
				g = g + 1;
				while (nextfirm < nfirm && fg[nextfirm] != 0) {
					nextfirm = nextfirm + 1;
				}
				if (fg[nextfirm] == 0) {
					mpoint = 1;
					m[mpoint] = nextfirm;
					mtype[mpoint] = 2;
					fonstack[nextfirm] = 1;
				}
			}
		}
	
		printf("Finished processing, adding group data\n");
	
		st_addvar("long", groupvar);
	
		st_view(data, . ,(individualid, unitid,groupvar));
	
		for (j = 1 ; j<=ncells; j++ ) {
			data[j,3] = pg[data[j,1]];
			if (pg[data[j,1]] != fg[data[j,2]]) {
				printf("Error in the output data.\n");
				printf("Observation %9.0g, Pupil %9.0g, School %9.0g, Group of pupil %9.0g, Group of school %j\n",
						j, data[j,1], data[j,2], pg[data[j,1]], fg[data[j,2]]);
				exit(1);
			}
		}
	
		printf("Finished adding groups.\n");
	
	}

	/*

	Name:			check_data()
	
	Purpose:	This function checks whether data is correctly sequenced.
	
	 */
	
	function check_data(real matrix byp, real matrix byf, real scalar ncells) {
		
		real scalar thispers, thisfirm;
	
		real scalar i;
	
		thispers = 1;
		thisfirm = 1;
	
		for ( i=1 ; i <= ncells ; i++ ) {
			if ( byp[i,1] != thispers ) {
				if ( byp[i,1] != thispers+1 ) {
					printf("Error : by pupil file not correctly sorted or missing sequence number\n");
					printf("Previous person : %9.0g , This person : %9.0g , Index in file %9.0g\n", thispers, byp[i,1], i);
					exit(1);
				}
				thispers = thispers + 1 ;
			}
	

			if ( byf[i,2] != thisfirm ) {
				if ( byf[i,2] != thisfirm + 1 ) {
					printf("Error : by school file not correctly sorted or missing sequence number\n");
					printf("Previous school : %9.0g , This school : %9.0g , Index in file %9.0g\n", thisfirm, byf[i,2], i);
					exit(1);
				}
				thisfirm = thisfirm + 1;
			}
		
		}
	
		printf("Data checked - By pupil and by school files correctly sorted and sequenced\n");
	}

	/*
	
	Name: 	trace_stack()
	
	Purpose:	Builds the connex component of the graph of the elements on the stack

	 */

	void trace_stack( real matrix byp, real matrix byf, real vector pg,  real vector fg, 
				real vector m, real scalar mpoint, real vector mtype,
				real vector ponstack, real vector fonstack,
				real vector ptraced,  real vector ftraced,
				real vector pindex,   real vector findex,
				real scalar g, real scalar nptraced, real scalar nftraced) {
	
		real scalar thispers, thisfirm, person, afirm, lower, upper;
	
		if (mtype[mpoint] == 2) { // the element on top of the stack is a firm
			thisfirm = m[mpoint];
			mpoint = mpoint - 1;
			fg[thisfirm] = g;
			ftraced[thisfirm] = 1;
			fonstack[thisfirm] = 0;
			if (thisfirm == 1) {
				lower = 1;
			} else {
				lower =  findex[thisfirm - 1] + 1;
			}
			upper = findex[thisfirm];
			for (person = lower ; person <= upper ; person ++) {
				thispers = byf[person, 1];
				pg[thispers] = g;
				if (ptraced[thispers] == 0 && ponstack[thispers] == 0) {
					nptraced = nptraced + 1;
					mpoint = mpoint + 1;
					m[mpoint] = thispers;
					mtype[mpoint] = 1;
					ponstack[thispers] = 1;
				}
			}
		} else if (mtype[mpoint] == 1) { // the element on top of the stack is a person
			//printf("A person\t");
			thispers = m[mpoint];
			mpoint = mpoint - 1;
			pg[thispers] = g;
			ptraced[thispers] = 1;
			ponstack[thispers] = 0;
			if (thispers == 1) {
				lower = 1;
			} else {
				lower = pindex[thispers - 1] +1;
			}
			upper = pindex[thispers];
			for (afirm = lower; afirm <= upper; afirm++) {
				thisfirm = byp[afirm, 2];
				fg[thisfirm] = g;
				if (ftraced[thisfirm] == 0 && fonstack[thisfirm] == 0) {
					nftraced = nftraced + 1;
					mpoint = mpoint + 1;
					m[mpoint] = thisfirm;
					mtype[mpoint] = 2;
					fonstack[thisfirm] = 1;
				}
			}
		} else {
			printf("Incorrect type, element number %9.0g of the stack, type %9.0g\n",mpoint,mtype[mpoint]);
		}
	
	}

end

