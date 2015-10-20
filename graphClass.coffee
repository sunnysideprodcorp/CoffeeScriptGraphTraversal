#
# this class holds data provided by a gorce-directed graph d3.js web app
# this web app records links and nodes in arrays of objects
# this class builds helpful data structures from those objects to illustrate graph traversals
#



class Graph
    # set this value impossibly high as a theoretical upper limit      
    @maxWeight = 10000000

    constructor: (nodes, links) ->
       @nodes = nodes
       @links = links

       # retrieve edge weights from object properties to have this readily accessible
       @edgeWeights = (l.weight for l in links)
       @numNodes = nodes.length

       # shortest paths and related shortest-path parents are lazily computed as required
       # in dist and parent member functions
       @shortestPaths = {}
       @shortestPathsParents = {}

       # these alternate graph-structure recordings enable fast illustration and calculation
       # of various graph traversals
       @nodesDir = {}
       @linksDir = {}
       @linksAdjDir = {}

       for l in links

           # general format
           # linksDir[fromNode][toNode] = edgeID
           if not @linksDir[l.to]
               @linksDir[l.to] = {}
           if not @linksDir[l.from]
               @linksDir[l.from] = {}
           @linksDir[l.to][l.from] = l.id
           @linksDir[l.from][l.to] =  l.id

           # general format
           # linksAdjDir[edgeID] = [toNode, fromNode]
           @linksAdjDir[l.id] = [l.to, l.from]

           # general format
           # nodesDir[fromNode] = [array of all nodes connected to fromNode]
           if not @nodesDir[l.to]
               @nodesDir[l.to] = []
           if not @nodesDir[l.from]
               @nodesDir[l.from] = []
           @nodesDir[l.to].push(l.from)
           @nodesDir[l.from].push(l.to)

    # calculates and caches shortest distance between pair of nodes [fromNode, toNode] (order doesn't matter)
    # also calculates shortest path parent, which is first node you would travel through
    # on shortest path between fromNode and toNode
    # returns shortest distance
    dist: (pair) ->
        from = pair[0]
        to = pair[1]
        if @shortestPaths[from]?
            return @shortestPaths[from][to]
        else if @shortestPaths[to]?
            return @shortestPaths[to][from]
        else 
            @calcDjikstra from
            return @shortestPaths[from][to]

   # same as member function dist but
   # returns parent
    parent: (pair) ->
        from = pair[0]
        to = pair[1]
        if @shortestPaths[from]?
            return @shortestPathsParents[from][to]
        else
            @calcDjikstra from
            return @shortestPaths[from][to]

   # same as member function parent but
   # returns all parents for all nodes on path back to from
    toNodeAllParents: (from) ->
        if @shortestPaths[from]?
            return @shortestPathsParents[from]
        else
            @calcDjikstra from
            return @shortestPaths[from]

   # in-place modifications to shortestPaths and shortestPathsParents 
   # called when a needed value has not yet been calculated
    calcDjikstra: (from) ->
        result = djikstra @, from
        @shortestPaths[from] = result.distances
        @shortestPathsParents[from] = result.parents
