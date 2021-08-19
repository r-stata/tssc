{smcl}
{* *! version 0.2 16 NOV 2019}{...}
{cmd:help dependencies}{...}
{right:also see:  {help "adopath"} {help "sysdir"} {help "net"} {help "ssc"} }
{hline}

{title:Title}

{pstd}
{hi:dependencies} {hline 2} Manages user-written commands for reproducible code (ado version freeze)

{title:Syntax}

{pstd} Manages user-written commands required in a project (dependencies) to ensure reproducibility of all code, as ado files available online may change. This is achieved by freezing the current version of installed packages into a zip file, and later unfreezing it into an {it:{help "adopath"}} that takes top priority.

{p 8 15 2}
{cmd:dependencies} {opt subcommand} [ {opt using }{it:filename.zip} ], [ {opt adolist(string)} {opt all} {opt replace} ]
{p_end}

{synoptset 30 tabbed}{...}
{synopthdr :Options}
{synoptline}
{syntab :Subcommand: {it:one and only one required}}
{synopt :{opt freeze}}save {it:filename.zip} with the dependencies passed in {it:adolist} or {it:all}{p_end}
{synopt :{opt unfreeze}}unzip to {it:dependencies} adopath the frozen dependencies in {it:filename.zip}{p_end}
{synopt :{opt which}}list whethever is currently in the {it:dependencies} adopath{p_end}
{synopt :{opt remove}}remove the {it:dependencies} adopath and all its contents{p_end}
{synoptline}
{syntab :Using: {it:required for freeze/unfreeze}}
{synopt :{opt using}}indicates the {it:zipfile} to be written/read{p_end}
{synoptline}
{syntab :Others: {it:for freeze only}}
{synopt :{opt adolist}({it:string}{cmd:)}}freeze the selection of commands in {it:adolist} (cannot be combined with {it:all}){p_end}
{synopt :{opt all}}freeze everything in the {it:adopath} that is properly registered in stata.trk (cannot be combined with {it:adolist}){p_end}
{synopt :{opt replace}}freeze will replace the {it:using filename.zip} if it already exists{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:dependencies} manages required user-written commands for a project (dependencies) to ensure reproducibility of all code, as ado files available online may change. This is achieved by freezing the current version of installed packages into a zip file, and later unfreezing it into an {it:{help "adopath"}} that takes top priority.

{pstd} For example, suppose a project uses a package that is available in {it:{help "SSC"}}. You could include in your master run do file a line to install the required package on the fly from ssc - but if the version in ssc changes, you may run into compatibility issues. This could happen because {it: ssc install} will always retrieve the most up to date version of a package.

{pstd} The suggested use of {cmd:dependencies} is:

{pstd} ( 1 ) create of a zip file with all dependencies, which should be saved with all the project code. This is done by {it:dependencies freeze}

{pstd} ( 2 ) add to the start of your project master run do file {it:dependencies unfreeze}

{pstd} ( 3 ) include at the end of your project master run do file {it:dependencies remove}

{pstd} Though there is no harm in forgetting to remove the dependencies after usage, you may find yourself in trouble when trying to update or use a more recent version of a command that was copied into the {it:dependencies} priority adopath.

{pstd} At any given point, call {it:dependencies which} to check the ado files currently in the {it:dependencies} priority adopath. This functionality also displays the date of {it:freeze}, making use of the metadata file {it:dependencies.trk} that is included in any zip file created or unpacked through {it:dependencies}, analogous to the automatically generated registry of installed packages {it:stata.trk}.


{title:Options}

{dlgtab:Subcommand}

{phang} {cmdab:freeze} save a zip file with the current version of the dependencies. Requires option {opt using} {it:filename.zip}{cmd:} and either {opt adolist}({it:string}{cmd:)} or {opt all}.

{phang} {cmdab:unfreeze} unzip to {it:dependencies} adopath the frozen dependencies from a zipfile. Requires option {opt using} {it:filename.zip}{cmd:}.

{phang} {cmdab:which} list whethever ado files are currently in the {it:dependencies} adopath. No additional options accepted.

{phang} {cmdab:remove} remove the {it:dependencies} adopath and all its contents. No additional options accepted.

{dlgtab:Using}

{phang} {cmdab:using} {it:filename.zip}{cmd:} indicates the zip file to be written if subcommand {opt freeze} or read if subcommand {opt unfreeze}.

{dlgtab:Others}

{phang} {cmdab:adolist(}{it:string}{cmd:)} freeze a selection of commands, passed in {it:adolist}. Cannot be combined with {it:all}. Multiple commands and packages can be passed in the same {it:string}, separated by spaces. First, the adopath registries of installed packages -{it:stata.trk}- are searched for matching packages, then, remaining commands are searched as standalone files in the adopath by {it:{help "findfile"}}. Commands that are not found will trigger a warning display but won't cause errors.

{phang} {cmdab:all} freeze everything in the {it:adopath} for which a corresponding entry in the adopath registries of installed packages -{it:stata.trk}- exists (multiple files are appended / combined). Cannot be combined with {it:adolist}.

{phang} {cmdab:replace} freeze will replace the zip file specified in {it:using filename.zip} if it already exists.


{title:Examples}

{pstd}Suppose your project requires the commands {cmd:iegraph} and {cmd:iematch}, which are part of the awesome package {cmd:ietoolkit}, available in SSC and in {browse "https://github.com/worldbank/ietoolkit":GitHub}. Your project runs well with the version of {cmd:ietoolkit} that you have currently installed. Maybe you even had already included a provisional installation from SSC in your master do file:{p_end}
{phang2}. {stata `"cap ssc install ietoolkit"'}{p_end}

{pstd}But you want to make sure your project will be reproducible as is. Thus, you freeze the dependencies:{p_end}
{phang2}. {stata `"dependencies freeze using dependencies_myproject.zip, adolist(iegraph iematch)"'}{p_end}

{pstd}Note that you could also have listed the whole package instead of naming just some of its components:{p_end}
{phang2}. {stata `"dependencies freeze using "dependencies_myproject.zip", adolist(ietoolkit) replace"'}{p_end}

{pstd}Moreover, you learn that if you list both the package and the components, it's equivalent to just listing the package. Thus it's a bit silly (but won't break) to request:{p_end}
{phang2}. {stata `"dependencies freeze using "dependencies_myproject.zip", adolist(ietoolkit iegraph iematch) replace"'}{p_end}

{pstd}For reproducibility, your master run do file will not install {cmd:ietoolkit} from SSC on the fly. Instead, you unfreeze the dependencies at the beginning:{p_end}
{phang2}. {stata `"dependencies unfreeze using "dependencies_myproject.zip" "'}{p_end}

{pstd}At the end of your master run, it's recommended that you remove the dependencies, to avoid trouble when trying to update or use a more recent version of those commands in the future.{p_end}
{phang2}. {stata `"dependencies remove"'}{p_end}

{pstd}At any time, you can consult the contents of your dependencies adopath:{p_end}
{phang2}. {stata `"dependencies which"'}{p_end}


{title:Author}

{pstd}Diana Goldemberg{p_end}
{pstd}diana_goldemberg@g.harvard.edu{p_end}


{title:Acknowledgements}

{phang}Kristoffer Bjarkefur and Joao Pedro Azevedo provided invaluable contributions to this package. The idea for the command was originated in this {browse "https://www.statalist.org/forums/forum/general-stata-discussion/general/1523554-version-control-of-user-written-ados":statalist discussion}. A big thank you to all contributors creating commands for the Stata community, especially in SSC! Without your time and effort, this command would be useless.{p_end}

{phang}You can see the code, make comments to the code, report bugs, and submit additions or
      edits to the code through the {browse "https://github.com/dianagold/dependencies":GitHub repository of dependencies}.{p_end}
