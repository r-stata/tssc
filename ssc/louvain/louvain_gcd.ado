*! version on 1.0 27feb2020

/*
 louvain_gcd generates a toy example of a weighted graph. It takes an integer as 
 an argument and it then generates a graph of pairs of numbers from one to the 
 its argument weighted by their gcd-1.
 This means co-primes are not connected and high weights mean high gcd. When you 
 subsequently apply the louvain clustering module you can gain insight and intuition 
 into the louvain clustering method.
 This program is a quicky so it is probably inefficient and will not scale. Then
 again it does not have to. Values of 10,20 etc are the easisets to interpret. 
*/

program def louvain_gcd
	version 16.0

	syntax anything(name=nn)

	*check python-louvain is present
	 capture confirm integer number `nn'
	if _rc != 0 {
		
		di as smcl "Argument should be integer."
		exit
	}
	clear
	python: from sfi import Macro as macro
	python: nn = int(macro.getLocal('nn'))
	python: louvain_gcd(nn)
	qui tostring *node, replace
	
	
end


*** Python below here


version 16.0
python:

def louvain_gcd(g):
	
	import itertools
	import math
	import pandas as pd
	
	from sfi import Data as data
	
	#this is the empty set.
	myset = set()
	#loop over cartesian product
	for i in itertools.product([i for i in range(1,nn+1)],[i for i in range(1,nn+1)]):
		#add to set 
		myset.add(frozenset(i))
    

	#drop the self edges
	edges = set()
	for i in myset:
		if len(i)==2:
			edges.add(i)

	#now go back to list of lists
	edges = [list(i) for i in edges]

	#this will hold our weighted graph
	g=[]
	# for every edge add the gcd of its nodes minus one if non-zero
	for edge in edges:
		if  math.gcd(edge[0],edge[1])-1 != 0:
			g.append([edge[0],edge[1], math.gcd(edge[0],edge[1])-1])
	g = pd.DataFrame.from_records(g, columns=["snode","tnode","weight"])
	#now we create the dataset
	data.setObsTotal(len(g))
	data.addVarInt('snode')
	data.store('snode',range(len(g)),g['snode'].to_list())
	data.addVarInt('tnode')
	data.store('tnode',range(len(g)),g['tnode'].to_list())
	data.addVarInt('weight')
	data.store('weight',range(len(g)),g['weight'].to_list())
	
end



