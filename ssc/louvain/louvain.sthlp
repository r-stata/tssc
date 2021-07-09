dpedit {smcl}
{cmd:help louvain}
{hline}

{title:Title}

    {hi: Find communities in weighted graph}

{title:Syntax}

{p 8 17 2}
{cmd:louvain}
<source node var> <target node var> <edge weight var>, [REsolution(0<=number<=1)] [Reset(YES|no)]  [Draw(string)] 

{title:Description}

{phang}
{cmd: louvain} exploits the Python integration which, Stata introduced starting 
with version 16 ({stata man python}) and wraps itself around the Python module 
{browse "https://github.com/taynaud/python-louvain":"python-louvain"} to find 
clusters in a weighted graph. 

{phang}
It assumes you have loaded your network's weighted edges in stata 
in the form of three variables. So if you have string variables "snode" (the source node) 
and "tnode" (the target node) and some numerical variable "weight" then you feed the 
weighted edges by running:

{p 8 17 2}
{cmd:. louvain snode tnode weight}

{phang}
The command creates a frame called "louvain" in which it saves two variables: 
one called "node" holding the unique values of snode and tnode combined and one called 
"cluster_1" indicating the cluster each node belongs to. 

{phang}
If you run the command again it wipes the frame "louvain" away and starts over 
unless you say: 

{p 8 17 2}
{cmd:. louvain snode tnode weight, reset(no)} 

{phang}
in which case it adds "cluster_2" to the frame "louvain". A third run of: 

{p 8 17 2}
{cmd:. louvain snode tnode weight, reset(no)} 

{phang}
will  add "cluster_3" etc. 

{phang}
You might give it a resolution (defaults to 1) which is a number between 
zero and one. The variable "cluster_i" is labeled with the resolution that produced it. 
This way one can experiment around.

{phang}
You might also ask it to plot the clusters. It will save "louvain.pdf" in c(pwd)
and open it with the default OS application.

{phang}
You need Python 3.7 (go with Anaconda) and, besides Stata 16 or more, you need to 
have configured your Stata to use the right Python on your system. To install 
"python-louvain" run the command: 

{p 8 17 2}
{cmd:pip install python-louvain} at the command line. 
{p_end}


{title:Examples}
{phang}
The command {cmd: louvain_gcd} takes an integer argument n. It then creates all 
unique, unordered pairs of distinct integers between 1 and n and weighs them by their gcd minus 1.
This way the weight expresses codivisibility of the pair. Those with gcd=1 are dropped. You can use
this weight graph to play around with {cmd: louvain}. 

{phang}
For example, create the gcd weighted graph of 1,...10:

{p 8 17 2}
1.{stata louvain_gcd 10}.

{phang}
Now partition it with{cmd: louvain}:

{p 8 17 2}
2.{stata louvain snode tnode weight},

{phang}
append a second partition to it with resolution .7, plot it:

{p 8 17 2}
3.{stata louvain snode tnode weight, resolution(.7) reset(no) draw(yes) },

{phang}
and check the results:

{p 8 17 2}
4. {stata frame change louvain}

{p 8 17 2}
5. {stata list}

{p 8 17 2}
6. {stata frame change default}
{p_end}

{title:References}

{phang}
1. Blondel, V. D., Guillaume, J. L., Lambiotte, R., & Lefebvre, E. (2008).
{browse "https://arxiv.org/pdf/0803.0476.pdf":{it:Fast unfolding of communities in large networks. Journal of statistical mechanics: theory and experiment}.}

{phang}
2. Newman, M. E. (2004). {browse "https://journals.aps.org/pre/pdf/10.1103/PhysRevE.70.056131?casa_token=5AGQ235I4RwAAAAA%3AblBIvIA4WXIyUeM2wnbZaUzLAvlrde3ujMuHUHWzkaGQouu-9fzxKJjA2lsvnwk27qN9ydoyDEfjg0Y":{it:Analysis of weighted networks}.}

{phang}
3. {browse "https://github.com/taynaud/python-louvain":{it:python-louvain module}.} Copyright (c) 2009-2018, Thomas Aynaud   
{p_end}

{title: Remarks}

{phang}
The main purpose of this module is to demonstrate that polyglotism is as useful in programming as in natural languages. 
It imports an implementation of an algorithm (louvain) of a certain type of unsupervised learning (modularity based) to 
Stata and at the same time it demonstrates several new features in Stata. It uses the {browse "https://www.stata.com/python/api16/index.html":Stata Function Interface (sfi)} which is an API developed by Stata to allow interaction of Stata with python. Writing it allowed me to practice using sfi and also to learn stata frames ({stata man frames}). It applies the following sfi classes: sfi.Data, sfi.Macro and sfi.Frame. I hope people will have fun disecting it. 


{title: Author}
{phang}
Nikos Askitas, IZA - Institute of Labor Economics, Bonn, Germany.

{phang}
Email: nikos@iza.org, Twitter: {browse "https://twitter.com/askitas":@askitas} 

{phang}
Web: {browse "https://askitas.com":askitas.com}
{p_end}
