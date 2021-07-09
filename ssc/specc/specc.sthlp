{smcl}
{* 7 Dec 2019}{...}
{hline}
help for {hi:specc}
{hline}

{title:Title}

{p 2 4}{cmdab:specc} {hline 2} manages component dofiles and alternative specifications
for the creation of specification curves in Stata.

{title:Description}
{marker description}{...}

{p 2 4}{cmdab:specc} is designed to automate the creation of specification curves.
First, it enables the assisted creation of sets of alternative options ("methods")
for each choice in the estimation of a given statistical parameter
(such as outcome definition, covariate choice, and functional form; i.e. "the garden of forking paths").
Second, it automatically assembles all of these individual decisions
into the full set of possible specifications formed by interacting these various choices.
In other words, the intent of {cmdab:specc} is to reduce the programming task
for an exponential number of specifications to a linear amount of coding.
{p_end}

{title:Functions}

{p 2 4}{cmdab:specc initialize}{break} creates the directory and database
that the command will use to build a particular specification curve,
and need only be used at the first call of the command.

{p 2 4}{cmdab:specc new}{break} is used to create a new method
which represents a possible choice at some stage in the choice tree;
it creates a dofile to hold the instructions and a registry entry for the method.

{p 2 4}{cmdab:specc remove}{break} is used to delete a method
which represents a possible choice at some stage in the choice tree;
it deletes the corresponding dofile and registry entry for the method.

{p 2 4}{cmdab:specc set}{break} is used to inform the command
the order in which the choices ("classes") are to be iterated over.
This sequence of choices must end with the estimation ("model") class
so that the estimated parameters are passed back to the results.

{p 2 4}{cmdab:specc report}{break} returns the current state
of the {cmdab:specc} registry (i.e., the available choice classes and methods).
It also reports whether an execution order has been {cmdab:set}
and what the corresponding methods for the ordered classes will be.

{p 2 4}{cmdab:specc run}{break} calculates and executes the full set
of possible choices over the entire range of classes that are {cmdab:set}
and returns the results in the form of a specification curve,
reporting the combination of methods that corresponds to each estimate.


{title:Syntax}

{dlgtab 0:Setting up the specc directory}

{p 2}{cmdab:specc} {opt init:ialize} {help using} {it:"/specc/directory/"}{p_end}

{p 2 4 } This function will initialize the specc.dta registry in the specified directory.
It will use the directory /specc/ in the current working directory if none is specified.
It will also create the "main" method for the "model" choice class
since this is always required.{p_end}

{dlgtab 0:Creating choice classes and methods}

{p 2 4}{cmdab:specc new} {it:class_name method_name}
{break}{it:Method Description}{p_end}
{p 2 1}{help using} {it:"/specc/directory/"}
{break}[, {opt c:ode("starter Stata code")}] [{bf:replace}]
{p_end}

{p 2 4 } This function will initialize a new method for the specified class.
Each "class" groups a set of mutually exclusive choices for that point
in the decision tree; the choices within each class are referred to as "methods".
Class names and method names must be one word and must be valid Stata variable names.
Method descriptions can be anything but should be kept short for legibility.
If the class does not exist, the command will create a directory for it;
if the method does not exist, the command will create a registry entry for it.
It will also create a corresponding dofile for the method in the class directory.
Finally, it can pass up to one line of code into the template dofile.
You typically must manually edit the dofile to achieve the desired result.
Additionally, methods of the "model" class will come with template instructions
to create a matrix holding the key parameters for the specification curve.{p_end}

{dlgtab 0:Removing choice classes and methods}

{p 2 4}{cmdab:specc remove} {it:class_name method_name}
{break}{help using} {it:"/specc/directory/"}
{p_end}

{p 2 4 } This function will remove any method matching the specified class and method names.
You can specify {bf:drop} as an alternative to {bf:remove}.{p_end}

{dlgtab 0:Setting the execution order}

{p 2 4}{cmdab:specc set} {it:class_name} [{it:class_name}] [{it:class_name}] [...] model
{break}{help using} {it:"/specc/directory/"} , {bf:reset}
{p_end}

{p 2 4 } This function instructs {cmdab:specc} to prepare to execute
a series of possible specifications using the methods stored in the registry.
For each of the classes specified in the {cmdab:set} execution order,
{cmdab:specc} will iterate over each of the available combinations of methods.
Since {cmdab:model} is required to be last and at least one model method is required,
the estimation results will then be returned to the command for visualization.{p_end}

{dlgtab 0:Reporting the current status}

{p 2 4}{cmdab:specc report} [{it:class_name method_name}]
{break}{help using} {it:"/specc/directory/"} , [{bf:sort}]
{p_end}

{p 2 4 } This function requests {cmdab:specc} to return the current status of the registry.
If the command is specified without a class or model,
it will return a list of all registered classes and models
as well as the currently {cmdab:set} execution order, if any.
Specifying {bf:sort} will list them in alphabetical order rather than in timestamp order.
If a class and model are specified, it will report the contents of the corresponding dofile.
Note that macro characters will not display properly and the dofile is definitive.{p_end}

{dlgtab 0:Running the execution order}

{p 2 4}{cmdab:specc run} {help using} {it:"/specc/directory/"}
{break}, [{bf:sort}] [{bf:save}] [{help twoway_options}]
{p_end}

{p 2 4 } This function requests {cmdab:specc} to run the currently {cmdab:set} execution order.
In the order specified, it will iteratively substitute each method dofile in the given class,
and obtain an estimation result from each registered model.
The results will be displayed in the form of a specification curve.
If {bf:sort} is specified the curve will be displayed in the order of methods;
by default it is ordered such that the estimated parameter is increasing.
If {bf:save} is specified it will save {it:results.dta} in the directory
containing the results of each of the estimated specifications.{p_end}

{hline}

{title:Authors}

{p 2}Benjamin Daniels

{p 2 4}Please send bug reports, suggestions and requests for clarifications
		 writing "specc" in the subject line to bbdaniels@gmail.com.

{p 2 4}You can also see the code, make comments to the code, see the version
		 history of the code, and submit additions or edits to the code through
		 the GitHub repository for specc:{break}
		 {browse "https://github.com/bbdaniels/specc"}
		 {p_end}

{title:References and Acknowledgements}

{p 2 4}The Garden of Forking Paths{break}
		 {browse "https://statmodeling.stat.columbia.edu/2019/08/01/the-garden-of-forking-paths/"}
		 {p_end}

{p 2 4}Simonsohn, Uri, Joseph P. Simmons, and Leif D. Nelson.
"Specification curve: Descriptive and inferential statistics on all reasonable specifications."
Available at SSRN 2694998 (2015).{p_end}

{p 2 4} Hans H. Sievertsen "Specification curve using Stata"
{browse "https://github.com/hhsievertsen/speccurve"}{p_end}

{title:Notes}

{p}{bf: specc} is open for development on {browse "https://github.com/bbdaniels/specc":GitHub}.
Submit bugs and feature requests {browse "https://github.com/bbdaniels/specc/issues":here}.
If you like {bf:specc}, be sure to visit my {browse "http://www.benjaminbdaniels.com":homepage}.{p_end}
