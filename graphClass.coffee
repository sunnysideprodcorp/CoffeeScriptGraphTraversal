class Graph
    @maxWeight = 10000
    constructor: (nodes, links) ->
       @nodes = nodes
       @links = links

       @edgeWeights = (l.weight for l in links)
       @numNodes = nodes.length

       @shortestPaths = {}
       @shortestPathsParents = {}

       @nodesDir = {}
       @linksDir = {}
       @linksAdjDir = {}
       for l in links
           if not @linksDir[l.to]
               @linksDir[l.to] = {}
           if not @linksDir[l.from]
               @linksDir[l.from] = {}

           @linksDir[l.to][l.from] = l.id
           @linksDir[l.from][l.to] =  l.id

           @linksAdjDir[l.id] = [l.to, l.from]

           if not @nodesDir[l.to]
               @nodesDir[l.to] = []
           if not @nodesDir[l.from]
               @nodesDir[l.from] = []

           @nodesDir[l.to].push(l.from)
           @nodesDir[l.from].push(l.to)

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

    parent: (pair) ->
        from = pair[0]
        to = pair[1]
        if @shortestPaths[from]?
            return @shortestPathsParents[from][to]
        else
            @calcDjikstra from
            return @shortestPaths[from][to]

    toNodeAllParents: (pair) ->
        from = pair[0]
        to = pair[1]
        if @shortestPaths[from]?
            return @shortestPathsParents[from]
        else
            @calcDjikstra from
            return @shortestPaths[from]

    calcDjikstra: (from) ->
        result = djikstra @, from
        @shortestPaths[from] = result.distances
        @shortestPathsParents[from] = result.parents
