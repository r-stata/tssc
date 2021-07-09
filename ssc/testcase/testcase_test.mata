// testcase() needs to be defined before running this,
// with, possibly, -run testcase.mata-

// code below will attempt to define -noisy_sqrt()-,
// -meta_test()-, and a variable -meta-, so these
// should not already be defined

mata
	numeric noisy_sqrt(numeric a, | real scalar noise)
	{
		real scalar nrows, ncols
		numeric matrix noise_mat
		
		if (args() == 1) {
			noise = 1e-5
		}
		
		nrows = rows(a)
		ncols = cols(a)
		noise_mat = rnormal(nrows, ncols, 0, noise) 
		if (eltype(a) == "complex") {
			noise_mat = noise_mat :+ (rnormal(nrows, ncols, 0, noise) * 1i)
		}
		
		return(sqrt(a) :+ noise_mat)
	}
	
	// Create a testcase to be tested. The instance of it will be called "meta".
	// The name is needed for any assert_method_error() calls.
	class meta_test extends testcase
	{
		real scalar setup_count, setup_once_count
		real scalar teardown_count, teardown_once_count
	
		void new()
		
		virtual void setup()
		virtual void setup_once()
		virtual void teardown()
		virtual void teardown_once()
		
		void unexp_errors()
		void test_capture()
		void test_assert()
		void test_assert_error()
		void test_method_capture()
		void test_assert_method_error()
		void test_assert_equal()
		void test_assert_unequal()
		void test_assert_all()
		void test_assert_any()
		void test_assert_equal_contents()
		void test_assert_close()
		void intentional_errors()
		void intentional_failures()
		void setup_teardown_counts()
		void simple_func()
	}

	void meta_test::new()
	{
		this.setup_count = 0
		this.setup_once_count = 0
		this.teardown_count = 0
		this.teardown_once_count = 0
	}

	// Define setup(), teardown(), setup_once(), teardown_once().
	// At the end of testing it will be verified that each ran as
	// many times as expected.
	void meta_test::setup()
	{
		this.setup_count = this.setup_count + 1
	}
	
	void meta_test::setup_once()
	{
		this.setup_once_count = this.setup_once_count + 1
	}
	
	void meta_test::teardown()
	{
		this.teardown_count = this.teardown_count + 1
	}
	
	void meta_test::teardown_once()
	{
		this.teardown_once_count = this.teardown_once_count + 1
	}
	
	void meta_test::unexp_errors()
	{
		// no args allowed in run()
		this.assert_method_error(3001, "meta", "run", &0) 
		
		// undefined test name
		this.noisy_capture = 0
		this.assert(this.__run_method("no_such_test") == 3000)
		this.noisy_capture = 1
	}
	
	void meta_test::test_capture()
	{
		real colvector score
		real scalar testnum
		
		testnum = this.__testnum
		
		// __capture() takes two arguments:
		// 1. pointer(function) scalar func_ptr
		// 2. pointer vector (or zero-dim matrix) arg_ptrs
		this.assert_method_error(
			3001, "meta", "__capture",(&(&noisy_sqrt()))
		)
		this.assert_method_error(
			3001, "meta", "__capture", (&(&noisy_sqrt()), &(&0), &(&0))
		)
								 
		this.assert_equal(this.__capture(&noisy_sqrt(), &0), 0)
		this.assert_equal(this.__capture(&noisy_sqrt(), &"blah"), 3251)
	}
	
	void meta_test::test_assert()
	{
		real colvector score
		real scalar testnum
		
		testnum = this.__testnum
		
		// assert_error() takes four arguments:
		// 1. real scalar err_num
		// 2. pointer(function) scalar func_ptr
		// 3. pointer vector (or zero-dim matrix) arg_ptrs
		this.assert_method_error(
			3001, "meta", "assert_error", (&0, &(&noisy_sqrt()))
		)
		this.assert_method_error(
			3001,
			"meta",
			"assert_error", 
		    (&0, &(&noisy_sqrt()), &(&J(0,0,NULL)), &(&0))
		)
		
		this.assert_error(3251, &noisy_sqrt(), &"blah")
		
		score = this.__pass_fail_error
		this.assert_error(0, &noisy_sqrt(), &"blah")
		if (score[testnum,1] == this.__pass_fail_error[testnum,1] && 
				score[testnum,2] + 1 == this.__pass_fail_error[testnum,2]) {
			this.__pass_fail_error[testnum, 1..3] = score[testnum, 1..3] + (1, 0, 0)
		}
		else {
			this.__pass_fail_error[testnum, 1..3] = score[testnum, 1..3] + (0, 1, 0)
		}
	}
	
	void meta_test::test_assert_error()
	{
		real colvector score
		real scalar testnum
		
		testnum = this.__testnum
		
		// assert_error() takes four arguments:
		// 1. real scalar err_num
		// 2. pointer(function) scalar func_ptr
		// 3. optional pointer vector (or zero-dim matrix) arg_ptrs
		this.assert_method_error(
			3001,
			"meta",
			"assert_error", 
		    (&0, &(&noisy_sqrt()), &(&J(0,0,NULL)), &(&0))
		)
		
		this.assert_error(3251, &noisy_sqrt(), &"blah")
		// assert_error allows missing error number in case you want to test
		// for error, but don't know the error number
		this.assert_error(., &noisy_sqrt(), &"blah")
		// assert_error allows error number zero for no error
		this.assert_error(0, &noisy_sqrt(), &1)
		
		// this is an intentional failure, so will leave an error message, but
		// the error message will only print if there are other errors here
		score = this.__pass_fail_error
		this.assert_error(0, &noisy_sqrt(), &"blah")
		if (score[testnum,1] == this.__pass_fail_error[testnum,1] && 
				score[testnum,2] + 1 == this.__pass_fail_error[testnum,2]) {
			this.__pass_fail_error[testnum, 1..3] = score[testnum, 1..3] + (1, 0, 0)
		}
		else {
			this.__pass_fail_error[testnum, 1..3] = score[testnum, 1..3] + (0, 1, 0)
		}
		
		// this is an intentional failure, so will leave an error message, but
		// the error message will only print if there are other errors here
		score = this.__pass_fail_error
		this.assert_error(., &noisy_sqrt(), &1)
		if (score[testnum,1] == this.__pass_fail_error[testnum,1] && 
				score[testnum,2] + 1 == this.__pass_fail_error[testnum,2]) {
			this.__pass_fail_error[testnum, 1..3] = score[testnum, 1..3] + (1, 0, 0)
		}
		else {
			this.__pass_fail_error[testnum, 1..3] = score[testnum, 1..3] + (0, 1, 0)
		}
	}
	
	void meta_test::test_method_capture()
	{		
		// __method_capture() takes three arguments:
		// 1. string scalar class_name
		// 2. string scalar func_name
		// 3. pointer vector (or zero-dim matrix) arg_ptrs
		
		// missing third arg for __method_capture
		this.assert_method_error(
			3001, "meta", "__method_capture", (&"meta", &"simple_func")
		)
		// too many args given to __method_capture
		this.assert_method_error(
			3001,
			"meta",
			"__method_capture", 
			(&"meta", &"simple_func", &(&0), &(&0))
		)
		
		this.assert_equal(this.__method_capture("meta", "simple_func", J(0,0,NULL)), 0)
		this.assert_equal(this.__method_capture("meta", "simple_func", &"blah"), 3001)
	}
	
	void meta_test::test_assert_method_error()
	{
		real colvector score
		real scalar testnum
		
		testnum = this.__testnum
		
		// assert_method_error() takes four arguments:
		// 1. real scalar err_num
		// 2. string scalar class_name
		// 3. string scalar func_name
		// 4. optional pointer vector (or zero-dim matrix) arg_ptrs
		this.assert_method_error(
			3001, "meta", "assert_method_error", (&"meta", &"simple_func")
		)
		this.assert_method_error(
			3001,
			"meta",
			"assert_method_error",
			(&0, &"meta", &"simple_func", &(&0), &(&0))
		)
		// assert_method_error allows missing error number in case you want 
		// to test for error, but don't know the error number
		this.assert_method_error(
			.,
			"meta",
			"assert_method_error",
			(&0, &"meta", &"simple_func", &(&0), &(&0))
		)
		// assert_error allows error number zero for no error
		this.assert_method_error(0, "meta", "simple_func", J(0,0,.))
								 
		// The next test should add one to pass _and_ fail, since it involves
		// two calls to assert_method_error(). If that happens, just count that
		// as one pass.
		score = this.__pass_fail_error
		this.assert_method_error(
			0,
			"meta",
			"assert_method_error", 
		    (&1111, &"meta", &"simple_func", &J(0,0,NULL))
		)
		if (score[testnum,1] + 1 == this.__pass_fail_error[testnum,1] && 
				score[testnum,2] + 1 == this.__pass_fail_error[testnum,2]) {
			this.__pass_fail_error[testnum, 1..3] = score[testnum, 1..3] + (1, 0, 0)
		}
		else {
			this.__pass_fail_error[testnum, 1..3] = score[testnum, 1..3] + (0, 1, 0)
		}
	}
	
	void meta_test::test_assert_equal()
	{
		real colvector score
		real scalar testnum
		
		testnum = this.__testnum
		
		// assert_close() takes one arguments, which must be numeric
		this.assert_method_error(3001, "meta", "assert_unequal", &3)
		this.assert_method_error(3001, "meta", "assert_unequal", (&3, &4, &1))
		
		
		// check that assert_unequal() passes when it should 
		// and fails when it should
		
		this.assert_equal(1, 1 + 0i)
		this.assert_equal("blah", "b" + "l" + "a" + "h")
		this.assert_equal((1, 0 + 0i \ 0, 1), I(2))
		
		score = this.__pass_fail_error
		this.assert_equal((1, 0 \ 0, 1), (1, 0 \ 1, 1))
		if (score[testnum,1] == this.__pass_fail_error[testnum,1] && 
				score[testnum,2] + 1 == this.__pass_fail_error[testnum,2]) {
			this.__pass_fail_error[testnum, 1..3] = score[testnum, 1..3] + (1, 0, 0)
		}
		else {
			this.__pass_fail_error[testnum, 1..3] = score[testnum, 1..3] + (0, 1, 0)
		}
	}
	
	void meta_test::test_assert_unequal()
	{
		real colvector score
		real scalar testnum
		
		testnum = this.__testnum
		
		// assert_close() takes one arguments, which must be numeric
		this.assert_method_error(3001, "meta", "assert_unequal", &3)
		this.assert_method_error(3001, "meta", "assert_unequal", (&3, &4, &1))
		
		
		// check that assert_unequal() passes when it should 
		// and fails when it should
		
		this.assert_unequal(NULL, 10)
		this.assert_unequal("blah", 8)
		this.assert_unequal((1, 0 \ 0, 1), (0, 1 \ 1, 0))
		this.assert_unequal((1, 0 \ 0, 1), (1, 0))
		
		score = this.__pass_fail_error
		this.assert_unequal(1, 1 + 0i)
		if (score[testnum,1] == this.__pass_fail_error[testnum,1] && 
				score[testnum,2] + 1 == this.__pass_fail_error[testnum,2]) {
			this.__pass_fail_error[testnum, 1..3] = score[testnum, 1..3] + (1, 0, 0)
		}
		else {
			this.__pass_fail_error[testnum, 1..3] = score[testnum, 1..3] + (0, 1, 0)
		}
	}
	
	void meta_test::test_assert_all()
	{
		real colvector score
		real scalar testnum
		
		testnum = this.__testnum
		
		// assert_close() takes one argument, which must be numeric
		this.assert_method_error(3001, "meta", "assert_all", J(0,0,NULL))
		this.assert_method_error(3001, "meta", "assert_all", (&3, &4))		
		
		// check that assert_all() passes when it should 
		// and fails when it should
		
		this.assert_all((1, 1, 1, 1 \ 1, 1, 1, 1))
		this.assert_all((1, 1, 1, 1))
		this.assert_all(1)
		
		score = this.__pass_fail_error
		this.assert_all((1, 1, 1, 1 \ 1, 0, 1, 1))
		if (score[testnum,1] == this.__pass_fail_error[testnum,1] && 
				score[testnum,2] + 1 == this.__pass_fail_error[testnum,2]) {
			this.__pass_fail_error[testnum, 1..3] = score[testnum, 1..3] + (1, 0, 0)
		}
		else {
			this.__pass_fail_error[testnum, 1..3] = score[testnum, 1..3] + (0, 1, 0)
		}
	}
	
	void meta_test::test_assert_any()
	{
		real colvector score
		real scalar testnum
		
		testnum = this.__testnum
		
		// assert_close() takes one argument, which must be numeric
		this.assert_method_error(3001, "meta", "assert_any", J(0,0,NULL))
		this.assert_method_error(3001, "meta", "assert_any", (&3, &4))
		
		
		// check that assert_any() passes when it should 
		// and fails when it should
		
		this.assert_any((0, 0, 1, 0 \ 0, 0, 0, 0))
		this.assert_any((0, 0, 1, 0))
		this.assert_any(1)
		
		score = this.__pass_fail_error
		this.assert_any((0, 0, 0, 0 \ 0, 0, 0, 0))
		if (score[testnum,1] == this.__pass_fail_error[testnum,1] && 
				score[testnum,2] + 1 == this.__pass_fail_error[testnum,2]) {
			this.__pass_fail_error[testnum, 1..3] = score[testnum, 1..3] + (1, 0, 0)
		}
		else {
			this.__pass_fail_error[testnum, 1..3] = score[testnum, 1..3] + (0, 1, 0)
		}
	}
	
	void meta_test::test_assert_equal_contents()
	{
		transmorphic a, b, A, B
		string scalar astr, bstr
		real scalar testnum
		
		testnum = this.__testnum
		
		// assert_close() takes two or three arguments and 
		// all args must be numeric
		this.assert_method_error(3001, "meta", "assert_equal_contents", (&3))
		this.assert_method_error(3001, "meta", "assert_equal_contents", (&3, &4, &1, &2))
		
		// check that assert_close() passes when it should 
		// and fails when it should
		
		// pass
		//--------
		// real
		a = (1, 1e-6 \ -1e-6, -10)
		b = (-10, 1, 1e-6, -1e-6)
		this.assert_equal_contents(a, b)
		
		// string
		a = ("a", "b" \ "c", "d" \ "a", "d")
		b = ("c", "d", "d", "a", "a", "b")
		this.assert_equal_contents(a, b)
		this.assert_equal_contents(a, ("a" \ "b" \ "c" \ "d" \ "a" \ "d"))
		this.assert_equal_contents(a, ("a", "b", "c", "d"), 0)
		this.assert_equal_contents(a, ("a" \ "b" \ "c" \ "d"), 0)
		
		// real and "complex" real
		a = (0, 1 \ 2, 3 \ 1, 1)
		b = (2 + 0i, 1 + 0i, 3 + 0i, 0, 1, 1 + 0i)
		this.assert_equal_contents(a, b)
		this.assert_equal_contents(a, (0 + 0i, 1 + 0i, 2 + 0i, 3 + 0i), 0)
		
		// complex
		a = (0, 1 + 12i \ 0.2 + 3.5i, 3 \ 1, 1)
		b = (0.2 + 3.5i, 1 + 0i, 3 + 0i, 0, 1, 1 + 12i)
		this.assert_equal_contents(a, b)
		
		// pointer
		astr = "a"
		bstr = "b"
		a = (&astr, &bstr \ &astr, &bstr)
		b = (&astr, &astr, &bstr, &bstr)
		this.assert_equal_contents(a, b)
		this.assert_equal_contents(a, (&bstr, &astr), 0)

		// struct
		
		A = (asarray_create(), asarray_create() \ asarray_create(), asarray_create())
		B = (asarray_create(), asarray_create(), asarray_create(), asarray_create())
		
		this.assert_equal_contents(A[1,1], B[1])
		this.assert_equal_contents(A, B)
		
		asarray(A[2,1], "a", 1)
		asarray(A[2,1], "b", 2)
		
		asarray(B[3], "a", 10)
		asarray(B[3], "b", 20)
		
		A[2,1] = B[3]
		
		this.assert_equal_contents(A, B)
		
		B = (B , asarray_create())
		
		this.assert_equal_contents(A, B, 0)
		
		
		// fail
		//--------
		// covered in this.intentional_failures()
		
		// error
		//--------
		// covered in this.intentional_errors()
	}
	
	void meta_test::test_assert_close()
	{
		real colvector score
		real matrix a, b
		complex matrix c, d
		real scalar testnum
		
		testnum = this.__testnum
		
		// assert_close() takes two or three arguments and 
		// all args must be numeric
		this.assert_method_error(3001, "meta", "assert_close", (&3))
		this.assert_method_error(3001, "meta", "assert_close", (&3, &4, &1, &2))
		
		// check that assert_close() passes when it should 
		// and fails when it should
		
		//real
		a = (1, 1e-6 \ -1e-6, -10)
		b = a :+ 1e-12
		this.assert_close(a, b)
		
		score = this.__pass_fail_error
		this.assert_close(a, b, 1e-16)
		if (score[testnum,1] == this.__pass_fail_error[testnum,1] && 
				score[testnum,2] + 1 == this.__pass_fail_error[testnum,2]) {
			this.__pass_fail_error[testnum, 1..3] = score[testnum, 1..3] + (1, 0, 0)
		}
		else {
			this.__pass_fail_error[testnum, 1..3] = score[testnum, 1..3] + (0, 1, 0)
		}
		
		score = this.__pass_fail_error
		b = a :+ 1e-10
		this.assert_close(a, b)
		if (score[testnum,1] == this.__pass_fail_error[testnum,1] && 
				score[testnum,2] + 1 == this.__pass_fail_error[testnum,2]) {
			this.__pass_fail_error[testnum, 1..3] = score[testnum, 1..3] + (1, 0, 0)
		}
		else {
			this.__pass_fail_error[testnum, 1..3] = score[testnum, 1..3] + (0, 1, 0)
		}
		
		// complex
		c = (1 + 1i, 1e-6 \ -1e-6 - 1i, -10)
		d = c :+ 1e-12
		this.assert_close(c, d)
		
		score = this.__pass_fail_error
		this.assert_close(c, d, 1e-16)
		if (score[testnum,1] == this.__pass_fail_error[testnum,1] && 
				score[testnum,2] + 1 == this.__pass_fail_error[testnum,2]) {
			this.__pass_fail_error[testnum, 1..3] = score[testnum, 1..3] + (1, 0, 0)
		}
		else {
			this.__pass_fail_error[testnum, 1..3] = score[testnum, 1..3] + (0, 1, 0)
		}
		
		score = this.__pass_fail_error
		d = c :+ 1e-10
		this.assert_close(c, d)
		if (score[testnum,1] == this.__pass_fail_error[testnum,1] && 
				score[testnum,2] + 1 == this.__pass_fail_error[testnum,2]) {
			this.__pass_fail_error[testnum, 1..3] = score[testnum, 1..3] + (1, 0, 0)
		}
		else {
			this.__pass_fail_error[testnum, 1..3] = score[testnum, 1..3] + (0, 1, 0)
		}
	}
	
	void meta_test::intentional_errors()
	{
		this.assert("blah")
		this.assert(1i)
		this.assert((1, 1))
		
		
		this.assert_error("no", &noisy_sqrt(), &J(1, 1, 1))
		this.assert_error(1i, &noisy_sqrt(), &J(1, 1, 1))
		this.assert_error((30, 20), &noisy_sqrt(), &J(1, 1, 1))
		
		this.assert_error(3200, "blah", &J(1, 1, 1))
		this.assert_error(3200, (&noisy_sqrt(), &noisy_sqrt()), &J(1, 1, 1))
		
		this.assert_error(3200, &noisy_sqrt(), J(3,1,1))
		this.assert_error(3200, &noisy_sqrt(), J(3,3,NULL))
		
		
		this.assert_method_error("no", "meta", "simple_func")
		this.assert_method_error(1i, "meta", "simple_func")
		this.assert_method_error((30, 20), "meta", "simple_func")
		
		this.assert_method_error(3200, &"meta", "simple_func")
		this.assert_method_error(3200, ("meta", "meta"), "simple_func")
		
		this.assert_method_error(3200, "meta", &"simple_func")
		this.assert_method_error(3200, "meta", ("simple_func", "simple_func"))
		
		this.assert_method_error(3200, "meta", "simple_func", J(1,1,1))
		this.assert_method_error(3200, "meta", "simple_func", J(3,3,NULL))
		
		
		// assert_equal() and assert_unequal() allow any eltype and orgtype
		
		
		this.assert_all("blah")
		this.assert_all((1, 1 + 1i, 1i))
		
		this.assert_any("blah")
		this.assert_any((0, 1i, 0))
		
		this.assert_close("blah", 3)
		this.assert_close(3, "blah")
		this.assert_close(3, 3, "blah")
		this.assert_close(3, 3, 1i * 1e-12)
		this.assert_close(3, 3, (1e-12, 1e-12))
		
		this.assert_equal_contents(10, testcase())
		this.assert_equal_contents(testcase(), 10)
		
		// make sure everything above leads to error
		::assert(this.__pass_fail_error[this.__testnum, 1..3] == (0, 0, 30))
	}
	
	void meta_test::intentional_failures()
	{
		real matrix a, b
		transmorphic A, B
		
	
		this.assert_error(0, &noisy_sqrt(), &"blah")
		
		this.assert_method_error(0, "meta", "simple_func", &"blah")
								 
		this.assert_equal((1, 0 \ 0, 1), (1, 0 \ 1, 1))
		this.assert_equal((1, 0 \ 0, 1), "blah")
		this.assert_equal((1, 0 \ 0, 1), (1, 0))
		this.assert_equal((1, 0, 0, 1), (1, 0, 0, 1)')
		
		this.assert_unequal(1, 1 + 0i)
	
		this.assert_all((1, 1, 1, 1 \ 1, 0, 1, 1))
		
		this.assert_any((0, 0, 0, 0 \ 0, 0, 0, 0))
		
		a = (1, 1e-6 \ -1e-6, -10)
		b = a :+ 1e-10
		this.assert_close(a, b)
		this.assert_close(a, (1, 1e-6))
		
		this.assert_equal_contents((9, 10), (10, 11))
		this.assert_equal_contents((9, 10), (9, 10, 11))
		this.assert_equal_contents((9, 10, 11), (9, 10))
		this.assert_equal_contents((9, 11), (9, 10))
		this.assert_equal_contents((9, 10), (9, 10, 11), 0)
		this.assert_equal_contents((9, 10), (9, 10, 10))
		this.assert_equal_contents((9, 9, 10), (9, 10, 10))
		this.assert_equal_contents((9, 10), (9, 10 + 1i))
		this.assert_equal_contents((9, 10), (&9, &10))
		this.assert_equal_contents(10, asarray_create())
		this.assert_equal_contents(asarray_create(), 10)
		
		A = (asarray_create(), asarray_create() \ asarray_create(), asarray_create())
		B = (asarray_create(), asarray_create(), asarray_create(), asarray_create())
		
		asarray(A[2,1], "a", 1)
		asarray(A[2,1], "b", 2)
		
		asarray(B[3], "a", 10)
		asarray(B[3], "b", 20)
		
		this.assert_equal_contents(A, B)
		
		A[2,1] = B[3]
		
		B = (B , asarray_create())
		
		this.assert_equal_contents(A, B)
		
		// try to get failure in different part of code
		B = (asarray_create(), asarray_create(), asarray_create(), B)
		
		this.assert_equal_contents(A, B)
		
		// make sure everything above leads to failure
		::assert(this.__pass_fail_error[this.__testnum, 1..3] == (0, 25, 0))
	}
	
	void meta_test::setup_teardown_counts()
	{
		real scalar testnum
		
		testnum = this.__testnum
		
		this.assert(this.setup_count == testnum)
		this.assert(this.setup_once_count == 1)
		this.assert(this.teardown_count == testnum - 1)
		this.assert(this.teardown_once_count == 0)
		// teardown() and teardown_once() need post-test checks; see below
	}
	
	// just a simple function for testing
	void meta_test::simple_func()
	{
		return
	}

	meta = meta_test()
	meta.name = "meta"
	meta.test_names = (
		"unexp_errors",
		"test_capture",
		"test_assert_error",
		"test_method_capture",
		"test_assert_method_error",
		"test_assert_equal",
		"test_assert_unequal",
		"test_assert_all",
		"test_assert_any",
		"test_assert_equal_contents",
		"test_assert_close",
		"intentional_errors",
		"intentional_failures",
		"setup_teardown_counts"
	)
	
	meta.run()

	// need post-test asserts to check that teardown() & teardown_once()
	// occurred the expected number of times	
	assert(meta.teardown_count == length(meta.test_names))
	assert(meta.teardown_once_count == 1)
	
	
	// drop meta, put errors in setup(), teardown(), etc
	mata drop meta
	
	void meta_test::setup_once()
	{
		noisy_sqrt()
	}
	
	void meta_test::setup()
	{
		noisy_sqrt()
	}
	
	void meta_test::teardown()
	{
		noisy_sqrt()
	}
	
	void meta_test::teardown_once()
	{
		noisy_sqrt()
	}

	meta = meta_test()
	meta.name = "meta"
	meta.test_names = (
		"test_assert_all",
		"test_assert_any"
	)
	
	meta.exit_setup_error = 0
	meta.exit_teardown_error = 0
	
	meta.run()
	
	meta.exit_setup_error = 1
	meta.exit_teardown_error = 1
	
	meta.run()
	
	// clean up
	mata drop noisy_sqrt()
	mata drop meta
	mata drop meta_test()
end
