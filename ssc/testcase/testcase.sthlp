{smcl}
{* 31mar2014}{...}
{cmd:help testcase()}
{hline}

{title:Title}

{p 4 4 2}
{bf:testcase {hline 2}} A Mata class for code testing


{title:Contents}

	{help testcase##intro:Introduction}
	{help testcase##syntax:Syntax}
	{help testcase##example:Example}
	{help testcase##creating:Creating tests}
	{help testcase##methods:testcase functions}
	{help testcase##attributes:testcase variables}
	{help testcase##failures_errors:Failures and errors}
	{help testcase##diagnostics:Diagnostics}
		
		
{marker intro}{...}
{title:Introduction}

{p 4 4 4}
{cmd:testcase} is a Mata class for testing Mata code. The class provides an
"xUnit" type of testing framework (see Wikipedia "xUnit" article). To create
tests, create a subclass of {cmd:testcase} and write test functions
within that subclass. Users who are new to Mata class programming should 
probably read {help m2_class}.


{marker syntax}{...}
{title:Syntax}
    
{p 4 4 4}
For a test class called (for example) "mytestclass" and a test instance called
"mytest", usage would look like this:

        class mytestclass extends testcase {
            void test_1()
            ... [other declarations]
        }
        
        mytestclass::test_1()
        {
            ...
        }
        
        ... [other function definitions]
        
        mytest = mytestclass()
		
        mytest.name = "mytest"
        mytest.test_names = (
            "test_1",
            ...
        )
        
        mytest.run()

		
{marker example}{...}
{title:Example}

{p 4 4 4}
Suppose you've made a function that tries to return the sum of any two inputs
it receives.

        function add(a, b)
        {
            return(a + b)
        }
		
{p 4 4 4}		
Now you want to write tests for this function, either to verify that it
behaves as intended, or to make sure that it will behave as intended after
changes are made to the code. We'll walk through how you can
make these tests using {cmd:testcase}. As a preview, the completed tests
will look like this:

        class add_test extends testcase {
            void test_errors()
            void test_output()
        }
        
        void add_test::test_errors()
        {
            pointer(function) scalar fp
            
            fp = &add()
            
            this.assert_error(3250, fp, (&0, &"a"))
            this.assert_error(3250, fp, (&"a", &0))
            this.assert_error(., fp, (&(1, 2, 3), &(1, 2)))
        }
        
        void add_test::test_output()
        {            
            this.assert_equal(add("a", "b"), "ab")
            this.assert_equal(add(0, 1), 1)
            this.assert_equal(add((0, 1), (1, 0)), (1, 1))
        }
        
        mytest = add_test()
        
        mytest.name = "mytest"
        mytest.test_names = (
            "test_errors",
            "test_output"
        )
        
        mytest.run()

{p 4 4 4}
In this example, all of our tests
of the {cmd:add()} function will reside within a single class, which we'll
call {cmd:add_test}:

        class add_test extends testcase {
            ...
        }
			
{p 4 4 4}
We'll write tests to verify that {cmd:add()} raises errors when we
expect it to and otherwise returns the value we expect. We'll put
tests for errors within a single function called {cmd:test_errors()}, and
we'll put the other tests in {cmd:test_output()}. These will be functions within
our {cmd:add_test} class, so our class declaration now looks like

        class add_test extends testcase {
            void test_errors()
            void test_output()
        }

{p 4 4 4}
The tests will use two of the 
{it:assert} methods provided by {cmd:testcase}: {cmd:assert_error()} and 
{cmd:assert_equal()} (see {help testcase##methods:testcase functions}
below).
        
        void add_test::test_errors()
        {
            pointer(function) scalar fp
            
            fp = &add
            
            this.assert_error(3250, fp, (&0, &"a"))
            this.assert_error(3250, fp, (&"a", &0))
            this.assert_error(., fp, (&(1, 2, 3), &(1, 2)))
        }
        
        void add_test::test_output()
        {
            this.assert_equal(add("a", "b"), "ab")
            this.assert_equal(add(0, 1), 1)
            this.assert_equal(add((0, 1), (1, 0)), (1, 1))
        }

{p 4 4 4}
The majority of the work is finished. All that we need to do now is
create an instance of this class
        
        mytest = add_test()
        
{p 4 4 4}
then record the instance name and test names (so the
class knows which methods comprise the tests)
			
        mytest.name = "mytest"
        mytest.test_names = (
            "test_errors",
            "test_output"
        )
			
{p 4 4 4}
Finally, we run the tests with
        
        mytest.run()
			
{p 4 4 4}
and the output it produces looks like this:

        {txt}test_errors {res}... ok{txt}
        {txt}test_output {res}... ok{txt}

		
{marker creating}{...}
{title:Creating tests}

{p 4 4 2}
As demonstrated in the {help testcase##example:example} above, you use
{cmd:testcase} by

{p 8 8 8}
1) subclassing {cmd:testcase},{break}
2) creating test functions within your subclass, and{break}
3) creating sub-tests with the inherited {help testcase##example:assert functions}.

{p 4 4 2}
The test functions you create should have a declaration like

        void mytestfunction()
		
{p 4 4 2}
In other words, these functions should not return any values and should not 
take any arguments.

{p 4 4 2}
As with any Mata class, you must declare the test functions in the (sub)class
declaration and then define them. With test functions there is an additional
requirement. You must put the name of the function in the {cmd:test_names}
variable (see {help testcase##example:example} above or 
{help testcase##attributes:testcase variables} below).

	
{marker methods}{...}
{title:testcase functions}

    {title:Assert functions}

{p 8 8 2}
{it:void} {cmd:assert(}{it:real scalar} {it:v}{cmd:)}

{p 8 8 2}
{it:void} {cmd:assert_equal(}{it:transmorphic} {it:a}, {it:transmorphic} {it:b}{cmd:)}

{p 8 8 2}
{it:void} {cmd:assert_unequal(}{it:transmorphic} {it:a}, {it:transmorphic} {it:b}{cmd:)}

{p 8 8 2}
{it:void} {cmd:assert_equal_contents(}{it:transmorphic} {it:a}, {it:transmorphic} {it:b} [, {it:real scalar} {it:samecount}]{cmd:)}

{p 8 8 2}
{it:void} {cmd:assert_close(}{it:numeric} {it:a}, {it:numeric} {it:b} [, {it:real scalar} {it:tolerance}]{cmd:)}

{p 8 8 2}
{it:void} {cmd:assert_all(}{it:real} {it:a}{cmd:)}

{p 8 8 2}
{it:void} {cmd:assert_any(}{it:real} {it:a}{cmd:)}

{p 8 8 2}
{it:void} {cmd:assert_error(}{break}
{space 4}{it:real scalar} {it:err},{break}
{space 4}{it:pointer(function) scalar} {it: func_ptr}{break}
{space 4}[, {it:pointer matrix} {it:arg_ptrs}]{break}
{cmd:)}

{p 8 8 2}
{it:void} {cmd:assert_method_error(}{break}
{space 4}{it:real scalar} {it:err},{break}
{space 4}{it:string scalar} {it:class_name},{break}
{space 4}{it:string scalar} {it: func_ptr}{break}
{space 4}[, {it: pointer matrix} {it:arg_ptrs}]{break}
{cmd:)}


{p 8 12 8}
{cmd:assert()} is used to test that a condition is true. In Mata "true" is
encoded as 1 (or non-zero real scalar), and "false" is encoded as 0. Thus,
{cmd:assert()} only accepts a real scalar as input. It records an "error" if 
the input is not a real scalar, a "fail" if the input is zero, or a "pass"
otherwise.

{p 8 12 8}
{cmd:assert_equal()} is used to test that its two inputs are equal. It records 
a "pass" if the inputs are equal or a "fail" otherwise.

{p 8 12 8}
{cmd:assert_unequal()} is used to test that its two inputs are not equal. It 
records a "pass" if the inputs are not equal or a "fail" otherwise.

{p 8 12 8}
{cmd:assert_equal_contents()} is used to test that two matrices (or scalars) 
{it:a} and {it:b} have the same (equal) contents, regardless of how they are arranged. 
For example, the matrices 

                (9, 10, 11),  (10, 11, 9),  and  (11 \ 10 \ 9)

{p 12 12 8}	
all have the same
contents. The optional input {it:samecount} determines whether the same elements 
must occur the same number of times. For example, with {it:samecount} zero,

                (9, 10, 11)  and  (9, 9, 10 \ 11, 11, 11)

{p 12 12 8}
are judged to have the same contents. The default value for {it:samecount} is 1, 
i.e., each element must occur the same number of times. {cmd:assert_equal_contents()} 
records an "error" if {it:a} or {it:b} is (a matrix of) {it:class} (classes instances 
are difficult to compare). It records a "fail" if {it:a} and {it:b} do not 
have the same contents (as described above). It records a "pass" otherwise.

{p 8 12 8}
{cmd:assert_close()} is used to test that its first two inputs {it:a}, {it:b} 
are nearly the same, element by element. More specifically, it checks that

                mreldif(a, b) < tolerance

{p 12 12 8}
where {it:tolerance} is the third, optional input (default value is 1e-12). 
{cmd:assert_close()} records an "error" if either {it:a} or {it:b} is not numeric, 
or if the {it:tolerance} (if specified) is not a real scalar. It records a "fail" 
if any of the corresponding elements are not close or {it:a} and {it:b} have 
different dimensions. It records a "pass" otherwise.

{p 8 12 8}
{cmd:assert_all()} is used to test that all elements of a matrix evaluate to
"true", i.e., are real and non-zero. It records an "error" if its input is not
real, a "fail" if any of the input's elements is zero, or a "pass" otherwise.

{p 8 12 8}
{cmd:assert_any()} is used to test that any element of a matrix evaluates to
"true", i.e., is real and non-zero. It records an "error" if its input is not
real, a "fail" if all of the input's elements are zero, or a "pass" otherwise.

{p 8 12 8}
{cmd:assert_error()} is used to test that a function raises an error when 
expected to. The first input should be the intended error code (or zero for "no
error") or a missing value. If the first input is a missing value, the test 
passes when the function raises any (non-zero) error. {cmd:assert_error()} 
records an "error" if any of the inputs is miss-specified, a "fail" if the 
function does not raise the intended error, or a "pass" otherwise.

{p 8 12 8}
{cmd:assert_method_error()} is used to test that a class member function raises 
an error when expected to. The first input should be the intended error code 
(or zero for "no error") or a missing value. If the first input is a missing 
value, the test passes when the function raises any (non-zero) error. It records 
an "error" if any of the inputs is miss-specified, a "fail" if the function does 
not raise the intended error, or a "pass" otherwise.


    {title:Running tests and viewing results}

{p 8 8 2}
{it:void} {cmd:run()}

{p 8 8 2}
{it:void} {cmd:print_summary()}


{p 8 12 8}
{cmd:run()} instructs the class to "run the tests". Each of the functions named in 
{cmd:test_names} is called, information about passed tests, failures, and errors
is collected, and, if {cmd:verbose} is not zero (see 
{help testcase##attributes:testcase variables} below), a summary is printed.

{p 8 12 8}
{cmd:print_summary()} instructs the class to print a summary of the previous run.
The printed summary is the same as when using {cmd:run()} with nonzero {cmd:verbose}.


    {title:Pre- and post-test functions}
	
{p 8 8 2}
virtual void {cmd:setup()}

{p 8 8 2}
virtual void {cmd:setup_once()}

{p 8 8 2}
virtual void {cmd:teardown()}

{p 8 8 2}
virtual void {cmd:teardown_once()}
		
{p 8 8 2}
void {cmd:new()}


{p 8 12 8}
{cmd:setup()} is used for any kind of preparation that is
desired to occur before each test function in your {cmd:testcase}
subclass is called. {cmd:setup()} is automatically called before each test
function.

{p 8 12 8}
{cmd:setup_once()} is used for any kind of preparation that is
desired to occur just once, before any test function in your 
{cmd:testcase} subclass is called. {cmd:setup_once()} is automatically called 
before the first test function is called (and before the first {cmd:setup()}).

{p 8 12 8}
{cmd:teardown()} is used for any kind of activity that is desired
to occur after each test function in your 
{cmd:testcase} subclass is called. {cmd:teardown()} is automatically called after
each test function.

{p 8 12 8}
{cmd:teardown_once()} is used for any kind of post-test activity that is
desired to occur just once, after all of the test functions in your 
{cmd:testcase} subclass have been called. {cmd:teardown_once()} is automatically 
called after the last test function is called (and after the last {cmd:teardown()}).

{p 8 12 8}
{cmd:new()}, as with any Mata class, is used during class creation. 
Use this function for any kind of preparation or customization that you 
wish to occur when your {cmd:testcase} subclass is created.


{marker attributes}{...}
{title:testcase variables}

    {title:Required}
	
{p 8 8 2}
{it:string scalar} {cmd:name}
		
{p 8 8 2}
{it:string vector} {cmd:test_names}


{p 8 12 8}
{cmd:name} should be equal to the name of the class {it:instance}, as in the
{help testcase##example:example} above. {cmd:name} must be supplied for each 
class instance.

{p 8 12 8}
{cmd:test_names} should be a vector containing the names of all of the class 
functions that serve as tests, as in the {help testcase##example:example} 
above. You may define other class functions if desired and not include them, 
but the class will only know to run the tests in {cmd:test_names}. 
{cmd:test_names} must be supplied for each class instance.


    {title:Optional}
	
{p 8 8 2}
{it:real scalar} {cmd:verbose}

{p 8 8 2}
{it:real scalar} {cmd:noisy_capture}

{p 8 8 2}
{it:real scalar} {cmd:noisy_assert}

{p 8 8 2}
{it:real scalar} {cmd:exit_setup_error}

{p 8 8 2}
{it:real scalar} {cmd:exit_teardown_error}


{p 8 12 8}
{cmd:verbose} determines whether there is any output when {cmd:run()} is invoked.
Set {cmd:mytest.verbose = 0} to silence output. Set {cmd:mytest.verbose = 1} (or
any non-zero real value) to see output. The default value is 1. To see
output when {cmd:verbose} is zero, use {cmd:print_summary()}.

{p 8 12 8}
{cmd:noisy_capture} determines whether the default Mata error messages are shown
when there is an unexpected error in a test. (See example below in {help testcase##failures_errors:failures and errors}.) Set 
{cmd:mytest.noisy_capture = 0} to silence these error messages. Set 
{cmd:mytest.noisy_capture = 1} (or any non-zero real value) to see these error 
messages. The default value is 1.

{p 8 12 8}
{cmd:noisy_assert} determines whether the default Mata error messages are shown
for the {cmd:assert_error()} and {cmd:assert_method_error()} functions. This will
not usually be helpful, since errors are usually expected with these functions,
but may be helpful when diagnosing an unexpected result. Set 
{cmd:mytest.noisy_assert = 0} to silence these error messages. Set 
{cmd:mytest.noisy_assert = 1} (or any non-zero real value) to see these error 
messages. The default value is 0.

{p 8 12 8}
{cmd:exit_setup_error} determines whether testing should continue after an
error in {cmd:setup()} or {cmd:setup_once()}. A non-zero value signals that
testing should be aborted, a zero value signals that testing should continue. The 
default value is 1.

{p 8 12 8}
{cmd:exit_teardown_error} determines whether testing should continue after an
error in {cmd:teardown()} (testing is complete after {cmd:teardown_once()} 
regardless of errors). A non-zero value signals that testing should be aborted,
a zero value signals that testing should continue. The default value is 1.


{marker failures_errors}{...}
{title:Failures and errors}

{p 4 4 4}
Let's add a couple lines to the {cmd:test_output()} function from the {help testcase##syn_example:example} above.
        
        void add_test::test_output()
        {
            this.assert_equal(add("a", "b"), "ab")
            this.assert_equal(add(0, 1), 1)
            this.assert_equal(add((0, 1), (1, 0)), (1, 1))
		    	
            {bf}this.assert_equal(add(0, 1), "a")
            this.assert(add("a", "b"))
            add(){sf}
        }
		
{p 4 8 4}
The new lines are in bold, and add{break}
1) an assertion that fails (0 + 1 does not equal "a"),{break}
2) an assertion with an error ({cmd:assert()} expects a real scalar input), and{break}
3) an error outside of an assertion.

{p 4 4 4}
When we run the tests now, we get output that shows failure and errors (if 
continuing from the previous example, you'll have to drop {cmd:mytest} and 
redefine it first):

        : mytest.run()        
        {err}                   add():  3001  expected 2 arguments but received 0
         add_test::test_output():     -  function returned error
                         <istmt>:     -  function returned error

        {txt}test_errors {res}... ok
        {txt}test_output
          {err}subtest 4: assert_equal()
              values are not equal
              > element types differ: real vs string
          subtest 5: assert()
              error: input was string scalar, should be real scalar
          ** unexpected error 3001 after subtest 5 **{txt}
		  
{p 4 4 4}
The error message immediately after {cmd:mytest.run()} corresponds to the 
"unexpected error" in the last line. If we want to turn off the default Mata
error message, we set {cmd:noisy_capture} to zero:

        : mytest.noisy_capture = 0

        : mytest.run()

        {txt}test_errors {res}... ok
        {txt}test_output
          {err}subtest 4: assert_equal()
              values are not equal
              > element types differ: real vs string
          subtest 5: assert()
              error: input was string scalar, should be real scalar
          ** unexpected error 3001 after subtest 5 **{txt}


{marker diagnostics}{...}
{title:Diagnostics}

{p 4 4 4}
If you get an error message when you invoke {cmd:run()}, like

        : mytest.run()
        {err}type mismatch:  exp.exp:  transmorphic found where struct expected{txt}
	
{p 4 4 4}
make sure that you've set the {cmd:name} variable, and that you've set it to the 
name of the {it:instance} and not, for example, the name of the {it:class}.

{p 4 4 4}
If you implement the optional {cmd:setup()}, {cmd:setup_once()}, {cmd:teardown()}, 
or {cmd:teardown_once()} functions, you might have difficulty dropping your test 
class and/or {cmd:testcase()}. The only remedy at present is to clear Mata.

{p 4 4 4}
There are several variables and functions used internally that are not listed
above. To prevent collision with existing functions and variables, avoid names
beginning with double underscore. Alternately, if wanting to use a name that
begins with double underscore, verify that the name is not in use by checking
the class declaration in testcase.mata.


{marker source}{...}
{title:Source code}

{p 4 4 2}
{view testcase.mata, adopath asis:testcase.mata}
{p_end}


{title:Author}

{pstd}
James Fiedler{break}
{browse "mailto:jrfiedler@gmail.com":jrfiedler@gmail.com}

