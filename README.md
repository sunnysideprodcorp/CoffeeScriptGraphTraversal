##Graph Utilities in CoffeeScript

These files support [this app traversal animation utility](http://sunnysideworks.nyc/d3/directed_graph/). In partivular they are written to work with this [force-directed graph editor](http://bl.ocks.org/rkirsling/5001347), which imposes a data structure whereby the graph editor feeds the graph traversal functions an array of `nodes` and an array of `links`.

To create a graph, create an array of nodes and an array of edges. The expected form of an array of edges is like the following:

```
links = [{id: 0, to: 1, from:5, weight:99}, {id: 1, to: 1, from:2, weight:2},{id: 2, to: 1, from:3, weight:2},{id: 3, to: 3, from:5, weight:1},{id: 4, to: 2, from:4, weight:1},{id: 5, to: 4, from:3, weight:5},{id: 6, to: 1, from:0, weight:10}, ]
nodes = [0...6]
```

Note that the code assumes both links and nodes are numbered starting from 0. For each link, you assign a weight as well as starting and ending vertices. For all the traversals included in these scripts, the `from` and `to` fields are meaningless in that the traversal algorithms ignore directionality.

 