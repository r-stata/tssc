*! version on 1.0 27feb2020

/*

 Uses https://github.com/taynaud/python-louvain to apply the Louvain method which 
 is a fast algorithm to find the community structure in a weighted network which
 optimizes modularity. 

 */

program def louvain
	version 16.0

	syntax varlist(min=3 max=3), [REsolution(numlist min=1 max=1 >0 <=1)] [Reset(string)] [Draw(string)] 

	*check python-louvain is present
	capture python which community 
	if _rc != 0 {
		
		di as smcl "You need to install the Python module python-louvain: see {help louvain args: help louvain}"
		exit
	}
	python: reset = "yes"
	if "`reset'" == "no"{
		python: reset = "no"
	}
	python: draw = "no"
	if "`draw'" == "yes"{
		python: draw = "yes"
	}
	python: from sfi import Data as data
	python: from sfi import Macro as macro
	python: import pandas as pd
	if "`resolution'" != ""{
		python: res = macro.getLocal('resolution')
		python: res = float(res)
	}
	if "`resolution'" == ""{
		python: res = 1.0
	}
	python: vars = macro.getLocal('varlist').split()
	python: wedges=data.getAsDict(var=vars)
	python: gd=pd.DataFrame.from_dict(wedges)
	python: g = gd.to_numpy().tolist()
	python: louvain(g)
	*python: louvain_draw()
	
	
end


*** Python below here


version 16.0
python:

def louvain(g):
	#temp hack to precent matplotlib from nagging deprecation warning at networkx
	import warnings
	warnings.filterwarnings("ignore", category=UserWarning)
	#temp hack
	import networkx as nx
	import community
	from sfi import Frame as frame
	
	G = nx.Graph()
	G.add_weighted_edges_from(g)
	# Run Louvain algorithm
	partition = community.best_partition(G, resolution=res)
	#this holds our cluster dummy
	results = pd.DataFrame.from_dict(partition, orient='index', columns=["cluster_id"])
	
	# draw if asked to
	if draw=="yes":
		import matplotlib.pyplot as plt
		plt.figure(figsize=(10,10))
		ax = plt.axes()
		# Setting the background color
		ax.set_facecolor("#000055")
		ax.set_alpha(0.8)
		size = float(len(set(partition.values())))
		pos = nx.spring_layout(G)
		count = 0.
		#nx.draw(G,pos, with_labels=True, font_color='red')
		for com in set(partition.values()) :
			count = count + 1.
			list_nodes = [nodes for nodes in partition.keys() if partition[nodes] == com]
			nx.draw_networkx_nodes(G, pos, list_nodes, node_size = 500, node_color = str(count / size) )
			nx.draw_networkx_edges(G, pos, alpha=.4, width=1,edge_color='g')
			nx.draw_networkx_labels(G,pos, with_labels=True,font_color='red', font_size='10')
		#get stata's working directory
		ourpwd = macro.getGlobal('c(pwd)')
		#save figure
		plt.savefig(ourpwd+'/louvain.pdf')
		#close figure
		#plt.clf()
		plt.close("all")
		# use OS default app to pop drawing up
		import subprocess
		subprocess.run(['open', 'louvain.pdf'], check=True)
	
	#reindex, will help putting into the frame
	results=results.sort_index()
	results = results.reset_index()
	# reset louvain frame by going through all frames and dropping the one called louvain.
	if reset == "yes":
		nf = frame.getFrameCount()
		for i in range(nf):
			framename = frame.getFrameAt(i)
			if framename == "louvain":
				frh = frame.connect("louvain")
				frh.drop()
		#now create the louvain frame anew
		frame.create("louvain")
		#connect to the frame
		frh = frame.connect("louvain")
		#get it ready to receive data
		frh.addObs(len(results))
		frh.addVarStrL("node")
		frh.addVarInt("cluster_1")
		frh.setVarLabel("node", "Node ID")
		frh.setVarLabel("cluster_1", "Cluster ID (resolution = "+str(res)+")")
		#dump the data into the frame now 
		for i, row in results.iterrows():
			frh.store("node", i, row["index"])
			frh.store("cluster_1", i, row["cluster_id"])
	#assume user knows what they are doing (i.e. asking to not reset only if it run at least once)
	#append to louvain frame
	if reset == "no":
		#connect to frame (which we assume exists)
		frh = frame.connect("louvain")
		suffix=frh.getVarCount()
		#ge it ready to receive data
		frh.addVarInt("cluster_"+str(suffix))
		#frh.addVarStrL("node_"+str(suffix))
		frh.setVarLabel("cluster_"+str(suffix), "Cluster ID (resolution = "+str(res)+")")
		#dump the data into it.
		for i, row in results.iterrows():
			#frh.store("node_"+str(suffix), i, row["index"])
			frh.store("cluster_"+str(suffix), i, row["cluster_id"])
end
