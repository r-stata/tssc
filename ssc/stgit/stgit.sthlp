{smcl}
{* *! version 1.0.1 Matthew White 09mar2015}{...}
{title:Title}

{phang}
{cmd:stgit} {hline 2} Retrieve information about a Git repository


{marker syntax}{...}
{title:Syntax}

{p 8 10 2}
{cmd:stgit} [{cmd:status}]{cmd:,} [{it:options}]

{* Using -help odbc- as a template.}{...}
{* 26 is the position of the last character in the first column + 3.}{...}
{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt git_dir(directory_name)}}GIT_DIR, the directory containing
the repository metadata{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:stgit} retrieves information about a Git repository,
including the current branch and the SHA-1 hash of the current commit.
In Stata 13 and above, it uses
the Java library {browse "https://eclipse.org/jgit/":JGit} to return
the status of the working tree.


{marker remarks}{...}
{title:Remarks}

{pstd}
In Stata 13 and above, {cmd:stgit} requires
the {help SSC} package {cmd:statajava}.
You must also {browse "https://eclipse.org/jgit/download/":download}
the JGit {cmd:.jar} file. (On the download page, it may be called
the "raw API library.") Place the {cmd:.jar} file on your {help ado-path}.
For instance, you may save it in your {help PERSONAL} system directory.
On your computer, this is {cmd}{ccl sysdir_personal}{txt}.

{pstd}
{cmd:stgit} respects {help version:version control} when deciding
which values to retrieve. Even in Stata 13 and above,
if the command interpreter is set to before version 13,
{cmd:stgit} does not use JGit, and returns limited information.

{pstd}
One use of {cmd:stgit} is adding commit hashes to dataset {help notes} and
to exported results such as tables. This facilitates reproducible research,
pinpointing the code that produced the files.

{pstd}
The GitHub repository for {cmd:stgit} is
{browse "https://github.com/matthew-white/stgit":here}.


{marker options}{...}
{title:Options}

{phang}
{opt git_dir()} specifies the path of GIT_DIR,
the repository metadata directory. This is typically named {cmd:.git}.
If {cmd:git_dir()} is not specified, {cmd:stgit} attempts to find GIT_DIR;
it assumes that the current working directory is within the Git repository.
Whether or not {cmd:git_dir()} is specified, {cmd:stgit} stores
the absolute path of GIT_DIR in {cmd:r(git_dir)}.


{marker examples}{...}
{title:Examples}

{pstd}Retrieve information about the repository within which
the current working directory is located{p_end}
{phang2}{cmd:stgit}

{pstd}Same as the previous {cmd:stgit} command{p_end}
{phang2}{cmd:stgit status}

{pstd}Retrieve information about the repository whose GIT_DIR is
{cmd:GitHub/cfout/.git}{p_end}
{phang2}{cmd:stgit, git_dir("GitHub/cfout/.git")}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
In Stata 9 and above, {cmd:stgit} stores the following in {cmd:r()}:

{synoptset 23 tabbed}{...}
{p2col 5 23 27 2: Scalars}{p_end}
{synopt:{cmd:r(has_detached_head)}}{cmd:1} if HEAD is detached,
{cmd:0} if not{p_end}

{p2col 5 23 27 2: Macros}{p_end}
{synopt:{cmd:r(git_dir)}}absolute path of GIT_DIR{p_end}
{synopt:{cmd:r(sha)}}SHA-1 hash of current commit{p_end}
{synopt:{cmd:r(branch)}}name of current branch or
{cmd:r(sha)} if HEAD is detached{p_end}
{p2colreset}{...}

{pstd}
In Stata 13 and above, {cmd:stgit} also stores the following in {cmd:r()}.
{cmd:stgit} retrieves these values using
the JGit class {cmd:org.eclipse.jgit.api.Status}, and much of
the language below is copied from
that class's {browse "https://eclipse.org/jgit/documentation/":API}
(version 3.5.3).

{synoptset 29 tabbed}{...}
{p2col 5 29 33 2: Scalars}{p_end}
{synopt:{cmd:r(is_clean)}}{cmd:1} if no differences exist between
the working tree, the index, and the current HEAD,
{cmd:0} if differences do exist{p_end}
{synopt:{cmd:r(has_uncommitted_changes)}}{cmd:1} if any tracked file is changed,
{cmd:0} if not{p_end}

{synoptset 26 tabbed}{...}
{p2col 5 26 30 2: Macros}{p_end}
{synopt:{cmd:r(untracked)}}list of files that are not ignored and not in
the index (e.g., what you get if you create a new file without adding it to
the index){p_end}
{synopt:{cmd:r(untracked_folders)}}list of directories that are not ignored and
not in the index{p_end}
{synopt:{cmd:r(uncommitted_changes)}}list of files and folders that are known to
the repository and changed either in the index or in the working tree{p_end}
{synopt:{cmd:r(added)}}list of files added to the index, not in HEAD (e.g.,
what you get if you call {cmd:git add ...} on a newly created file){p_end}
{synopt:{cmd:r(modified)}}list of files modified on disk relative to
the index (e.g., what you get if you modify an existing file without adding
it to the index){p_end}
{synopt:{cmd:r(changed)}}list of files changed from HEAD to index (e.g.,
what you get if you modify an existing file and call {cmd:git add ...} on
it){p_end}
{synopt:{cmd:r(missing)}}list of files in index but not filesystem (e.g.,
what you get if you call {cmd:rm ...} on an existing file){p_end}
{synopt:{cmd:r(removed)}}list of files removed from index, but in HEAD (e.g.,
what you get if you call {cmd:git rm ...} on an existing file){p_end}
{synopt:{cmd:r(conflicting)}}list of files that are in conflict (e.g.,
what you get if you modify a file that was modified by someone else in
the meantime){p_end}
{synopt:{cmd:r(ignored_not_in_index)}}list of files and folders that are
ignored and not in the index{p_end}
{p2colreset}{...}


{marker author}{...}
{title:Author}

{pstd}Matthew White{p_end}

{pstd}For questions or suggestions, submit a
{browse "https://github.com/matthew-white/stgit/issues":GitHub issue}
or e-mail researchsupport@poverty-action.org.{p_end}


{title:Also see}

{psee}
User-written:  {helpb git}
{p_end}
