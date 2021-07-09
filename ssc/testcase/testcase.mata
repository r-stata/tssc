*! version 1.0.0 
*! 07apr2014
*! James Fiedler jrfiedler@gmail.com

mata
	class testcase {
		// users *must* set these values
		string scalar name
		string vector test_names
		
		
		// user *may* redefine these
		real scalar verbose
		real scalar noisy_capture
		real scalar noisy_assert
		real scalar exit_setup_error
		real scalar exit_teardown_error
		
		void new()
		virtual void setup(), setup_once()
		virtual void teardown(), teardown_once()
		
		
		// user *must not* redefine any of the following
		final void run()
		final void print_summary()
		final void assert()
		final void assert_equal()
		final void assert_unequal()
		final void assert_equal_contents()
		final void assert_close()
		final void assert_all()
		final void assert_any()
		final void assert_error()
		final void assert_method_error()
		
		final real scalar __capture()
		final real scalar __method_capture()
		final real scalar __run_method()
		final void __equal_struct_contents()
		final void __contents_failures()
		
		final real matrix __pass_fail_error
		final real scalar __testnum
		final real scalar __subtestnum
		final real scalar __subtestcomplete
		final pointer(pointer(string) vector) colvector __msgs
		final string colvector __setup_teardown_msgs
		final pointer matrix __arg_ptrs
		final pointer(function) scalar __func_ptr
	}
	
	void testcase::new()
	{
		this.verbose = 1
		this.noisy_capture = 1
		this.noisy_assert = 0
		this.exit_setup_error = 1
		this.exit_teardown_error = 1
		
		// subtestnum is set to zero at the beginning of each test,
		// but initialize it to zero in case it is used interactively
		this.__subtestnum = 0
	}

	void testcase::run()
	{
		real scalar n_tests, rc, i
		
		// check that testcase instance has been given a name
		if (this.name == "") {
			display(`"{err}need instance name in member variable -name-"')
			display(`"{err}example: mytest.name = "mytest""')
			return
		}
		
		n_tests = length(this.test_names)
		this.__pass_fail_error = J(n_tests, 3, 0)
		this.__msgs = J(n_tests, 1, &(&""))
		this.__setup_teardown_msgs = J(2, 1, "")
		
		// check that there are tests listed in test_name
		if (n_tests == 0) {
			display("{err}" + this.name + ".test_names is empty")
			return
		}
		
		this.__testnum = 0
		rc = this.__run_method("setup_once")
		if (rc) {
			this.__setup_teardown_msgs[1] = sprintf(
				"** unexpected error %f **", rc
			)
			if (this.exit_setup_error) {
				if (this.verbose) this.print_summary()
				return
			}
		}
		for (i = 1; i <= n_tests; i++) {
			this.__testnum = i
			this.__subtestnum = 0
			
			rc = this.__run_method("setup")
			if (rc) {
				this.__pass_fail_error[i, 3] = this.__pass_fail_error[i, 3] + 1
				this.__msgs[i] = &(
					*this.__msgs[i] \ 
					&sprintf("** unexpected error %f in setup() **", rc)
				)
				if (this.exit_setup_error) {
					if (this.verbose) this.print_summary()
					return
				}
			}
			rc = this.__run_method(this.test_names[i])
			if (rc) {
				this.__pass_fail_error[i, 3] = this.__pass_fail_error[i, 3] + 1
				if (this.__subtestnum == 0) {
					this.__msgs[i] = &(
						*this.__msgs[i] \ 
						&sprintf(
							"** unexpected error %f before first subtest **",
							rc
						)
					)
				}
				else if (this.__subtestcomplete) {
					this.__msgs[i] = &(
						*this.__msgs[i] \ 
						&sprintf(
							"** unexpected error %f after subtest %f **",
							rc,
							this.__subtestnum
						)
					)
				}
				else {
					this.__msgs[i] = &(
						*this.__msgs[i] \ 
						&sprintf(
							"** unexpected error %f in subtest %f **",
							rc,
							this.__subtestnum
						)
					)
				}
			}
			rc = this.__run_method("teardown")
			if (rc) {
				this.__pass_fail_error[i, 3] = this.__pass_fail_error[i, 3] + 1
				this.__msgs[i] = &(
					*this.__msgs[i] \ 
					&sprintf("** unexpected error %f in teardown() **", rc)
				)
				if (this.exit_teardown_error) {
					if (this.verbose) this.print_summary()
					return
				}
			}
		}
		rc = this.__run_method("teardown_once")
		if (rc) {
			this.__setup_teardown_msgs[2] = sprintf(
				"** unexpected error %f **", rc
			)
		}
		
		if (this.verbose) {
			this.print_summary()
		}
	}
	
	void testcase::print_summary()
	{
		real scalar i, j, ntests
		pointer(string) vector msgs
		real matrix pfe
		string colvector stm
		
		pfe = this.__pass_fail_error
		stm = this.__setup_teardown_msgs
		
		if (rows(pfe) == 0 & rows(stm) == 0) {
			display(`"{err}The summary is empty. Have you run any tests?"')
			return
		}
		
		ntests = min((this.__testnum, rows(pfe), length(this.test_names)))
		
		stata(`"noi di """')
		if (stm[1] != "") {
			stata(`"noi di "{txt}setup_once""')
			stata(`"noi di "  {err}"' + this.__setup_teardown_msgs[1] + `"""')
		}
		for (i = 1; i <= ntests; i++) {
			stata(`"noi di "{txt}"' + this.test_names[i] + `"" _continue"')
			if (pfe[i,2] == 0 && pfe[i,3] == 0) {
				stata(`"noi di " ... ok""')
			}
			else {
				msgs = *this.__msgs[i]
				for (j = 1; j <= length(msgs); j++) {
					stata(`"noi di "  {err}"' + *msgs[j] + `"""')
				}
			}
		}
		if (stm[2] != "") {
			stata(`"noi di "{txt}teardown_once""')
			stata(`"noi di "  {err}"' + this.__setup_teardown_msgs[2] + `"""')
		}
		stata(`"noi di """')
	}

	real scalar testcase::__run_method(string scalar test_name)
	{
		if (this.noisy_capture) {
			stata("capture noisily mata: " + this.name + "." + test_name + "()")
		}
		else {
			stata("capture mata: " + this.name + "." + test_name + "()")
		}
		stata("local __testcase_rc = _rc")
		return(strtoreal(st_local("__testcase_rc")))
	}
	
	void testcase::assert(transmorphic b)
	{
		real scalar n
		
		n = this.__testnum
		this.__subtestnum = this.__subtestnum + 1
		this.__subtestcomplete = 0
		
		if (eltype(b) != "real" | orgtype(b) != "scalar") {
			this.__pass_fail_error[n, 3] = this.__pass_fail_error[n, 3] + 1
		
			this.__msgs[n] = &(
				*this.__msgs[n] \ 
				(
					&sprintf("subtest %f: assert()", this.__subtestnum) \ 
					&sprintf(
						"    error: input was %s %s, should be real scalar",
						eltype(b),
						orgtype(b)
					)
				)
			)
			
			this.__subtestcomplete = 1
			return
		}
		
		if (b) {
			this.__pass_fail_error[n, 1] = this.__pass_fail_error[n, 1] + 1
			this.__subtestcomplete = 1
			return
		}
		
		this.__pass_fail_error[n, 2] = this.__pass_fail_error[n, 2] + 1
	
		this.__msgs[n] = &(
			*this.__msgs[n] \ 
			(
				&sprintf("subtest %f: assert()", this.__subtestnum) \ 
				&"    assertion failed"
			)
		)
		this.__subtestcomplete = 1
	}
	
	real scalar testcase::__capture(pointer(function) scalar func_ptr, 
	                                pointer matrix arg_ptrs)
	{
		real scalar rc, i, nargs
		string scalar run_str, arg_template
		
		this.__func_ptr = func_ptr
		this.__arg_ptrs = arg_ptrs
		
		run_str = "(*" + this.name + ".__func_ptr)("
		arg_template = sprintf("*(%s.__arg_ptrs[%%f])%%s", this.name)
		
		nargs = length(arg_ptrs)
		for (i = 1; i <= nargs; i++) {
			run_str = run_str + sprintf(arg_template, i, i == nargs ? "" : ",") 
		}
		run_str = run_str + ")"
		
		if (this.noisy_assert) {
			stata("capture noisily mata: " + run_str)
		}
		else {
			stata("capture mata: " + run_str)
		}
		stata("local __testcase_rc = _rc")
		rc = strtoreal(st_local("__testcase_rc"))
		
		// remove references
		this.__func_ptr = NULL
		this.__arg_ptrs = J(0,0,NULL)
	
		return(rc)
	}

	void testcase::assert_error(transmorphic err_num, 
	                            transmorphic func_ptr, 
	                            | transmorphic arg_ptrs)
	{
		real scalar n, rc, err_good, func_good, arg_good
		pointer(string) scalar msg_ptr
		
		msg_ptr = NULL
		
		n = this.__testnum
		this.__subtestnum = this.__subtestnum + 1
		this.__subtestcomplete = 0
		
		err_good = (eltype(err_num) == "real" & orgtype(err_num) == "scalar")
		func_good = (eltype(func_ptr) == "pointer" & orgtype(func_ptr) == "scalar")
		
		arg_good = 1
		if (args() == 3) {
			// Check dimensions of arg_ptrs. It is allowed to be a vector, or
			// a zero-dimensional matrix if wanting to pass zero arguments.
			// I.e., J(0,0,.), J(0,1,.) J(123,0,.) are all allowed.
			if (rows(arg_ptrs) > 1 & cols(arg_ptrs) > 1) {
				arg_good = 0
			}
			else if (rows(arg_ptrs) != 0 & cols(arg_ptrs) !=0 & 
					eltype(arg_ptrs) != "pointer") {
				arg_good = 0
			}
		}
		else {
			arg_ptrs = J(0, 0, NULL)
		}
		
		if (!err_good | !func_good | !arg_good) {
			this.__pass_fail_error[n, 3] = this.__pass_fail_error[n, 3] + 1
			this.__msgs[n] = &(
				*this.__msgs[n] \ 
				&sprintf("subtest %f: assert_error()", this.__subtestnum)
			)
			if (!err_good) {
				this.__msgs[n] = &(
					*this.__msgs[n] \ 
					&sprintf(
						"    error: 1st input was %s %s, should be real scalar",
						eltype(err_num),
						orgtype(err_num)
					)
				)
			}
			if (!func_good) {
				this.__msgs[n] = &(
					*this.__msgs[n] \ 
					&sprintf(
						"    error: 2nd input was %s %s, " +
						"should be pointer scalar",
						eltype(func_ptr),
						orgtype(func_ptr)
					)
				)
			}
			if (!arg_good) {
				if (rows(arg_ptrs) > 1 & cols(arg_ptrs) > 1) {
					this.__msgs[n] = &(
						*this.__msgs[n] \ 
						&sprintf(
							"    error: 3rd input is %fx%f, " +
							"should be vector or zero-dim matrix", 
							rows(arg_ptrs),
							cols(arg_ptrs)
						)
					)
				}
				else {
					this.__msgs[n] = &(
						*this.__msgs[n] \ 
						&sprintf(
							"    error: 3rd input was %s matrix, " +
							"should be pointer matrix", 
							eltype(arg_ptrs)
						)
					)
				}
			}
			this.__subtestcomplete = 1
			return
		}
		
		rc = this.__capture(func_ptr, arg_ptrs)
		
		if (rc == err_num | (missing(err_num) & rc != 0)) {
			this.__pass_fail_error[n, 1] = this.__pass_fail_error[n, 1] + 1
			this.__subtestcomplete = 1
			return
		}
		
		this.__pass_fail_error[n, 2] = this.__pass_fail_error[n, 2] + 1
		this.__msgs[n] = &(
			*this.__msgs[n] \ 
			&sprintf("subtest %f: assert_error()", this.__subtestnum)
		)
		if (rc == 0) {
			msg_ptr = &sprintf(
				"    no error found when expecting error %f", err_num
			)
		}
		else {
			msg_ptr = &sprintf(
				"    got error %f when expecting error %f", rc, err_num
			)
		}
		this.__msgs[n] = &(*this.__msgs[n] \ msg_ptr)
		this.__subtestcomplete = 1
	}
	
	real scalar testcase::__method_capture(string scalar class_name,
	                                       string scalar func_name, 
	                                       pointer matrix arg_ptrs)
	{
		real scalar rc, i, nargs
		string scalar run_str, arg_template
		
		this.__arg_ptrs = arg_ptrs
		
		run_str = class_name + "." + func_name + "("
		arg_template = sprintf("*(%s.__arg_ptrs[%%f])%%s", this.name)
		
		nargs = length(arg_ptrs)
		for (i = 1; i <= nargs; i++) {
			run_str = run_str + sprintf(arg_template, i, i == nargs ? "" : ",") 
		}
		run_str = run_str + ")"
		
		if (this.noisy_assert) {
			stata("capture noisily mata: " + run_str)
		}
		else {
			stata("capture mata: " + run_str)
		}
		stata("local __testcase_rc = _rc")
		rc = strtoreal(st_local("__testcase_rc"))
		
		// remove references
		this.__arg_ptrs = J(0,0,NULL)
	
		return(rc)
	}

	void testcase::assert_method_error(transmorphic err_num, 
	                                   transmorphic class_name,
	                                   transmorphic func_name, 
	                                   | transmorphic arg_ptrs)
	{
		real scalar n, rc, err_good, class_good, func_good, arg_good
		pointer(string) scalar msg_ptr
		
		msg_ptr = NULL
		
		n = this.__testnum
		this.__subtestnum = this.__subtestnum + 1
		this.__subtestcomplete = 0
		
		err_good = (eltype(err_num) == "real" & orgtype(err_num) == "scalar")
		class_good = (eltype(class_name) == "string" & orgtype(class_name) == "scalar")
		func_good = (eltype(func_name) == "string" & orgtype(func_name) == "scalar")
		
		arg_good = 1
		if (args() == 4) {
			// Check dimensions of arg_ptrs. It is allowed to be a vector, or
			// a zero-dimensional matrix if wanting to pass zero arguments.
			// I.e., J(0,0,.), J(0,1,.) J(123,0,.) are all allowed.
			if (rows(arg_ptrs) > 1 & cols(arg_ptrs) > 1) {
				arg_good = 0
			}
			else if (rows(arg_ptrs) != 0 & cols(arg_ptrs) !=0 & 
					eltype(arg_ptrs) != "pointer") {
				arg_good = 0
			}
		}
		else {
			arg_ptrs = J(0, 0, NULL)
		}
		
		if (!err_good | !class_good | !func_good | !arg_good) {
			this.__pass_fail_error[n, 3] = this.__pass_fail_error[n, 3] + 1
			this.__msgs[n] = &(
				*this.__msgs[n] \ 
				&sprintf("subtest %f: assert_method_error()", this.__subtestnum)
			)
			if (!err_good) {
				this.__msgs[n] = &(
					*this.__msgs[n] \ 
					&sprintf(
						"    error: 1st input was %s %s, should be real scalar",
						eltype(err_num),
						orgtype(err_num)
					)
				)
			}
			if (!class_good) {
				this.__msgs[n] = &(
					*this.__msgs[n] \ 
					&sprintf(
						"    error: 2nd input was %s %s, should be string scalar",
						eltype(class_name),
						orgtype(class_name)
					)
				)
			}
			if (!func_good) {
				this.__msgs[n] = &(
					*this.__msgs[n] \ 
					&sprintf(
						"    error: 3rd input was %s %s, should be string scalar", 
						eltype(func_name),
						orgtype(func_name)
					)
				)
			}
			if (!arg_good) {
				if (rows(arg_ptrs) > 1 & cols(arg_ptrs) > 1) {
					this.__msgs[n] = &(
						*this.__msgs[n] \ 
						&sprintf(
							"    error: 4th input is %fx%f," +
							"should be vector or zero-dim matrix", 
							rows(arg_ptrs),
							cols(arg_ptrs)
						)
					)
				}
				else {
					this.__msgs[n] = &(
						*this.__msgs[n] \ 
						&sprintf(
							"    error: 4th input was %s matrix," +
							"should be pointer matrix", 
							orgtype(arg_ptrs)
						)
					)
				}
			}
			this.__subtestcomplete = 1
			return
		}
		
		rc = this.__method_capture(class_name, func_name, arg_ptrs)
		
		if (rc == err_num | (missing(err_num) & rc != 0)) {
			this.__pass_fail_error[n, 1] = this.__pass_fail_error[n, 1] + 1
			this.__subtestcomplete = 1
			return
		}
		
		this.__pass_fail_error[n, 2] = this.__pass_fail_error[n, 2] + 1
		this.__msgs[n] = &(
			*this.__msgs[n] \
			&sprintf(
				"subtest %f: assert_method_error()", this.__subtestnum
			)
		)
		if (rc == 0) {
			msg_ptr = &sprintf(
				"    no error found when expecting error %f", err_num
			)
		}
		else {
			msg_ptr = &sprintf(
				"    got error %f when expecting error %f", rc, err_num
			)
		}
		this.__msgs[n] = &(*this.__msgs[n] \ msg_ptr)
		this.__subtestcomplete = 1
	}
	
	void testcase::__contents_failures(
		string scalar which, | string scalar type1, string scalar type2
	)
	{
		real scalar n
		
		n = this.__testnum
		this.__pass_fail_error[n, 2] = this.__pass_fail_error[n, 2] + 1
		if (which == "difftypes") {
			this.__msgs[n] = &(
				*this.__msgs[n] \
				(
					&sprintf(
						"subtest %f: assert_equal_contents()",
						this.__subtestnum
					) \
					&"    contents are incomparable" \
					&(
						"    > element types differ: " +
						sprintf("%s vs %s", type1, type2)
					)
				)
			)
		}
		else if (which == "diffnum") {
			this.__msgs[n] = &(
				*this.__msgs[n] \
				(
					&sprintf(
						"subtest %f: assert_equal_contents()",
						this.__subtestnum
					) \
					&"    inputs have different numbers of distinct elements"
				)
			)
		}
		else if (which == "diffels") {
			this.__msgs[n] = &(
				*this.__msgs[n] \
				(
					&sprintf(
						"subtest %f: assert_equal_contents()",
						this.__subtestnum
					) \
					&"    inputs have elements not in common"
				)
			)
		}
		else if (which == "diffcounts") {
			this.__msgs[n] = &(
				*this.__msgs[n] \
				(
					&sprintf(
						"subtest %f: assert_equal_contents()",
						this.__subtestnum
					) \
					&"    counts differ"
				)
			)
		}
		else {
			this.__msgs[n] = &(
				*this.__msgs[n] \
				(
					&sprintf(
						"subtest %f: assert_equal_contents()",
						this.__subtestnum
					) \
					&("    unknown reason: " + which)
				)
			)
		}
	}
	
	void testcase::__equal_struct_contents(
		transmorphic a, transmorphic b, real scalar samecount
	)
	{
		transmorphic items, item
		real matrix counts
		real scalar nitems, i, j, k, found
		
		counts = J(1,2,0)
		
		items = a[1,1]
		nitems = 1
		
		for (i = 1; i <= rows(a); i++) {
			for (j = 1; j <= cols(a); j++) {
				item = a[i,j]
				found = 0
				for (k = 1; k <= nitems; k++) {
					if (item == items[k]) {
						found = 1
						counts[k,1] = counts[k,1] + 1
					}
				}
				if (!found) {
					items = items \ item
					counts = counts \ (1, 0)
					nitems = nitems + 1
				}
			}
		}
		
		for (i = 1; i <= rows(b); i++) {
			for (j = 1; j <= cols(b); j++) {
				item = b[i,j]
				found = 0
				for (k = 1; k <= nitems; k++) {
					if (item == items[k]) {
						found = 1
						counts[k,2] = counts[k,2] + 1
						if (samecount & counts[k,2] > counts[k,1]) {
							this.__contents_failures("diffcounts")
							return
						}
					}
				}
				if (!found) {
					this.__contents_failures("diffels")
					return
				}
			}
		}
		
		if (samecount & counts[.,1] != counts[.,2]) {
			this.__contents_failures("diffcounts")
			return
		}
	}
	
	void testcase::assert_equal_contents(
		transmorphic a, transmorphic b, | real scalar samecount
	)
	{
		transmorphic val, acounter, bcounter, loc, key
		real scalar n, i, j, acols, bcols
		string scalar atype, btype
		
		n = this.__testnum
		this.__subtestnum = this.__subtestnum + 1
		this.__subtestcomplete = 0
		
		if (args() == 2) samecount = 1
		
		acols = cols(a)
		bcols = cols(b)
		if (samecount & rows(a) * acols != rows(b) * bcols) {
			this.__pass_fail_error[n, 2] = this.__pass_fail_error[n, 2] + 1
			
			this.__msgs[n] = &(
				*this.__msgs[n] \
				(
					&sprintf(
						"subtest %f: assert_equal_contents()", this.__subtestnum
					) \
					&"    counts differ; (rows(a) * cols(a)) != (rows(b) * cols(b))"
				)
			)
			this.__subtestcomplete = 1
			return
		}
		
		atype = eltype(a)
		btype = eltype(b)
		if (atype == "class" | btype == "class") {
			this.__pass_fail_error[n, 3] = this.__pass_fail_error[n, 3] + 1
			
			this.__msgs[n] = &(
				*this.__msgs[n] \
				(
					&sprintf(
						"subtest %f: assert_equal_contents()", this.__subtestnum
					) \
					&"    error: classes not allowed"
				)
			)
			this.__subtestcomplete = 1
			return
		}
		
		if (atype == "struct" | btype == "struct") {
			if (atype != btype) {
				this.__contents_failures("difftypes", atype, btype)
			}
			else {
				this.__equal_struct_contents(a, b, samecount)
			}
			this.__subtestcomplete = 1
			return
		}
		
		if (atype != btype) {
			if (atype == "string" | btype == "string" | 
					atype == "pointer" | btype == "pointer") {
				this.__contents_failures("difftypes", atype, btype)
				this.__subtestcomplete = 1
				return
			}
			
			// else one of a,b is real and the other is complex
			if (!isrealvalues(a) | !isrealvalues(b)) {
				this.__contents_failures("difftypes", atype, btype)
				this.__subtestcomplete = 1
				return
			}
			else {
				// Both are actually real. Need to make both eltype's 
				// real so asarray keys types will be same.
				a = Re(a)
				b = Re(b)
				atype = "real"
				btype = "real"
			}
		}
		
		acounter = asarray_create(atype)
		bcounter = asarray_create(btype)
		asarray_notfound(acounter, 0)
		asarray_notfound(bcounter, 0)
		
		for (i = 1; i <= rows(a); i++) {
			for (j = 1; j <= acols; j++) {
				val = a[i,j]
				asarray(acounter, val, 1 + asarray(acounter, val))
			}
		}
		
		for (i = 1; i <= rows(b); i++) {
			for (j = 1; j <= bcols; j++) {
				val = b[i,j]
				asarray(bcounter, val, 1 + asarray(bcounter, val))
			}
		}
		
		if (length(asarray_keys(acounter)) != length(asarray_keys(bcounter))) {
			this.__contents_failures("diffnum")
			this.__subtestcomplete = 1
			return
		}
		
		if (samecount) {
			loc = asarray_first(acounter)
			while (loc != NULL) {
				key = asarray_key(acounter, loc)
				if (asarray(acounter, key) != asarray(bcounter, key)) {
					if (asarray(bcounter, key) == 0) {
						this.__contents_failures("diffels")
					}
					else {
						this.__contents_failures("diffcounts")
					}
					this.__subtestcomplete = 1
					return
				}
				loc = asarray_next(acounter, loc)
			}
		} else {
			loc = asarray_first(acounter)
			while (loc != NULL) {
				key = asarray_key(acounter, loc)
				if (asarray(bcounter, key) == 0) {
					this.__contents_failures("diffels")
					this.__subtestcomplete = 1
					return
				}
				loc = asarray_next(acounter, loc)
			}
		}
	}

	void testcase::assert_equal(transmorphic a, transmorphic b)
	{
		real scalar n
		string scalar eltype1, eltype2, orgtype1, orgtype2
		
		n = this.__testnum
		this.__subtestnum = this.__subtestnum + 1
		this.__subtestcomplete = 0
		
		if (a == b) {
			this.__pass_fail_error[n, 1] = this.__pass_fail_error[n, 1] + 1
			this.__subtestcomplete = 1
			return
		}
		
		this.__pass_fail_error[n, 2] = this.__pass_fail_error[n, 2] + 1
		
		this.__msgs[n] = &(
			*this.__msgs[n] \
			(
				&sprintf("subtest %f: assert_equal()", this.__subtestnum) \
				&"    values are not equal"
			)
		)
	
		eltype1 = eltype(a)
		eltype2 = eltype(b)
		orgtype1 = orgtype(a)
		orgtype2 = orgtype(b)
		
		if (eltype1 != eltype2) {
			this.__msgs[n] = &(
				*this.__msgs[n] \
				&(
					"    > element types differ: " +
					sprintf("%s vs %s", eltype1, eltype2)
				)
			)
		}
		if (orgtype1 != orgtype2) {
			this.__msgs[n] = &(
				*this.__msgs[n] \ 
				&(
					"    > org. types differ: " +
					sprintf("%s vs %s", orgtype1, orgtype2)
				)
			)
		}
		this.__subtestcomplete = 1
	}

	void testcase::assert_unequal(transmorphic a, transmorphic b)
	{
		real scalar n
		
		n = this.__testnum
		this.__subtestnum = this.__subtestnum + 1
		this.__subtestcomplete = 0
		
		if (a != b) {
			this.__pass_fail_error[n, 1] = this.__pass_fail_error[n, 1] + 1
			this.__subtestcomplete = 1
			return
		}
		
		this.__pass_fail_error[n, 2] = this.__pass_fail_error[n, 2] + 1
	
		this.__msgs[n] = &(
			*this.__msgs[n] \ 
			(
				&sprintf("subtest %f: assert_unequal()", this.__subtestnum) \
				&"    values are equal"
			)
		)
		this.__subtestcomplete = 1
	}

	void testcase::assert_all(transmorphic a)
	{
		real scalar n, nrows, ncols, i, j
		
		n = this.__testnum
		this.__subtestnum = this.__subtestnum + 1
		this.__subtestcomplete = 0
		
		if (eltype(a) != "real") {
			this.__pass_fail_error[n, 3] = this.__pass_fail_error[n, 3] + 1
		
			this.__msgs[n] = &(
				*this.__msgs[n] \ 
				(
					&sprintf("subtest %f: assert_all()", this.__subtestnum) \ 
					&sprintf(
						"    error: input was %s, should be real",
						eltype(a)
					)
				)
			)
			
			this.__subtestcomplete = 1
			return
		}
		
		nrows = rows(a)
		ncols = cols(a)
		
		for (i = 1; i <= nrows; i++) {
			for (j = 1; j <= ncols; j++) {
				if (!a[i,j]) {
					this.__pass_fail_error[n, 2] = this.__pass_fail_error[n, 2] + 1
					this.__msgs[n] = &(
						*this.__msgs[n] \ 
						(
							&sprintf(
								"subtest %f: assert_all()", this.__subtestnum
							) \
							&sprintf(
								"    first false entry in %f,%f", i, j
							)
						)
					)
					this.__subtestcomplete = 1
					return
				}
			}
		}
		
		this.__pass_fail_error[n,1] = this.__pass_fail_error[n, 1] + 1
		this.__subtestcomplete = 1
	}

	void testcase::assert_any(transmorphic a)
	{
		real scalar n, nrows, ncols, i, j
		string scalar inputtype
		
		n = this.__testnum
		this.__subtestnum = this.__subtestnum + 1
		this.__subtestcomplete = 0
		
		inputtype = eltype(a)
		if (inputtype != "real") {
			this.__pass_fail_error[n, 3] = this.__pass_fail_error[n, 3] + 1
		
			this.__msgs[n] = &(
				*this.__msgs[n] \ 
				(
					&sprintf("subtest %f: assert_any()", this.__subtestnum) \ 
					&sprintf(
						"    error: input was %s, should be real", inputtype
					)
				)
			)
			
			this.__subtestcomplete = 1
			return
		}
		
		nrows = rows(a)
		ncols = cols(a)
		
		for (i = 1; i <= nrows; i++) {
			for (j = 1; j <= ncols; j++) {
				if (a[i,j]) {
					this.__pass_fail_error[n,1] = this.__pass_fail_error[n,1] + 1
					this.__subtestcomplete = 1
					return
				}
			}
		}
		
		this.__pass_fail_error[n,2] = this.__pass_fail_error[n, 2] + 1
		this.__msgs[n] = &(
			*this.__msgs[n] \
			(
				&sprintf("subtest %f: assert_any()", this.__subtestnum) \
				&"    all entries evaluate to false"
			)
		)
		this.__subtestcomplete = 1
	}
	
	void testcase::assert_close(transmorphic a, transmorphic b, 
	                            | transmorphic tolerance)
	{
		real scalar n, nrows, ncols, i, j, a_numeric, b_numeric, tol_good
		string scalar atype, btype
		
		n = this.__testnum
		this.__subtestnum = this.__subtestnum + 1
		this.__subtestcomplete = 0
		
		atype = eltype(a)
		btype = eltype(b)
		a_numeric = (atype == "real" | atype == "complex")
		b_numeric = (btype == "real" | btype == "complex")
		
		if (args() == 3) {
			tol_good = (
				eltype(tolerance) == "real" & orgtype(tolerance) == "scalar"
			)
		}
		else {
			tolerance = 1e-12
			tol_good = 1
		}
		
		if (!a_numeric | !b_numeric | !tol_good) {
			this.__pass_fail_error[n, 3] = this.__pass_fail_error[n, 3] + 1
			this.__msgs[n] = &(
				*this.__msgs[n] \ 
				&sprintf("subtest %f: assert_close()", this.__subtestnum)
			)
			if (!a_numeric) {
				this.__msgs[n] = &(
					*this.__msgs[n] \ 
					&sprintf(
						"    error: 1st input was %s, should be numeric", atype
					)
				)
			}
			if (!b_numeric) {
				this.__msgs[n] = &(
					*this.__msgs[n] \ 
					&sprintf(
						"    error: 2nd input was %s, should be numeric", btype
					)
				)
			}
			if (!tol_good) {
				this.__msgs[n] = &(
					*this.__msgs[n] \ 
					&sprintf(
						"    error: 3rd input was %s %s, should be real scalar", 
						eltype(tolerance),
						orgtype(tolerance)
					)
				)
			}
			this.__subtestcomplete = 1
			return
		}
		
		nrows = rows(a)
		ncols = cols(b)
		
		// Check dimensions. If both are vectors, or zero-dim,  
		// but one's dims is just transpose of other, flip b. 
		// Otherwise, if dims don't match, test fails.
		if (rows(b) != nrows | cols(b) != ncols) {
			this.__pass_fail_error[n, 2] = this.__pass_fail_error[n, 2] + 1
			this.__msgs[n] = &(
				*this.__msgs[n] \
				(
					&sprintf(
						"subtest %f: assert_close()", this.__subtestnum
					) \
					&sprintf(
						"    dimensions don't match: %fx%f vs %fx%f",
						nrows,
						ncols,
						rows(b),
						cols(b)
					)
				)
			)
			this.__subtestcomplete = 1
			return
		}
		
		if (mreldif(a, b) <= tolerance) {
			this.__pass_fail_error[n, 1] = this.__pass_fail_error[n, 1] + 1
			this.__subtestcomplete = 1
			return
		}
		
		this.__pass_fail_error[n, 2] = this.__pass_fail_error[n, 2] + 1
		
		// find first failure
		for (i = 1; i <= nrows; i++) {
			for (j = 1; j <= ncols; j++) {
				if (reldif(a[i,j], b[i,j]) > tolerance) {
					this.__msgs[n] = &(
						*this.__msgs[n] \
						(
							&sprintf(
								"subtest %f: assert_close()",
								this.__subtestnum
							) \
							&sprintf(
								"    first not-close entry in %f,%f",
								i,
								j
							)
						)
					)
					this.__subtestcomplete = 1
					return
				}
			}
		}
		this.__subtestcomplete = 1
	}

	void testcase::setup()
	{
		return
	}
	
	void testcase::setup_once()
	{
		return
	}

	void testcase::teardown()
	{
		return
	}
	
	void testcase::teardown_once()
	{
		return
	}
end
