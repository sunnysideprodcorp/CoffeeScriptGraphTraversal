##Graph Utilities in CoffeeScript

These files support [this app traversal animation utility](http://sunnysideworks.nyc/d3/directed_graph/). In particular the scripts are written to work with this [force-directed graph editor](http://bl.ocks.org/rkirsling/5001347), which imposes a data structure whereby the graph editor feeds the graph traversal functions an array of `nodes` and an array of `links`.

To create a graph, create an array of nodes and an array of edges. The expected form of an array of edges is like the following:

```
links = [{id: 0, to: 1, from:5, weight:99}, {id: 1, to: 1, from:2, weight:2},{id: 2, to: 1, from:3, weight:2},{id: 3, to: 3, from:5, weight:1},{id: 4, to: 2, from:4, weight:1},{id: 5, to: 4, from:3, weight:5},{id: 6, to: 1, from:0, weight:10}, ]
nodes = [0...6]
```

Here is the corresponding image of such a graph, when we ignore directionarlity:

![graph plotted](https://github.com/sunnysideprodcorp/CoffeeScript_GraphTraversal/blob/master/specificScreenshotWithWeights.png)

Note that the code assumes both links and nodes are numbered starting from 0. For each link, you assign a weight as well as starting and ending vertices. For all the traversals included in these scripts, the `from` and `to` fields are meaningless in that the traversal algorithms ignore directionality.

Once you've got your `links` and `nodes` insantiate a `Graph` object like so:

```
graph = new Graph nodes, links
``` 

Then you can test graph traversals like so (as illustrating in `testSpanning.coffee`):

```
startNode = 0
results = kruskal graph
console.log "edges in Kruskal minimum spanning tree are: " + results
results = prim graph, startNode
console.log "edges in Prim minimum spanning tree are: " + results + " starting from node " + startNode
results = djikstra graph, startNode
for i in [1...graph.length]
    if i != startNode
        console.log "Djikstra results starting from node " + startNode + " to node " + i + "gives a minimum distance of " + results.distances[i] + " where the path back from " + i + " would first traverse " + results.parents[i] 
```

Similar instructions are available for testing TSP Heuristics in `testTSP.coffee`

To combine all the files needed to run TSP Heuristics, run the following Linux command:

```
cat graphClass.coffee helpers.coffee djikstra.coffee TSP_Heuristics.coffee testTSP.coffee > total.coffee
```

Similarly, to combine all the files needed to run tree spanning algorithms, run the following Linux command:

```
cat graphClass.coffee helpers.coffee SpanningTrees.coffee testSpanning.coffee > total.coffee
```