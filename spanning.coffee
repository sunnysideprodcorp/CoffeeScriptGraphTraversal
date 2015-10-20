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


#
# helper functions
#



sortByKey = (array, key) ->
    array.sort((a, b) -> a[key] - b[key])

convertAll = (array, before, after) ->
    ((if el != before then el else after) for el in array)


#taken from https://coffeescript-cookbook.github.io/chapters/arrays/removing-duplicate-elements-from-arrays
Array::unique = ->
  output = {}
  output[@[key]] = @[key] for key in [0...@length]
  value for key, value of output

swap = (array, ind1, ind2) ->
       temp = array[ind1]
       array[ind1] = array[ind2]
       array[ind2] = temp

removeOverlap = (array, overlapArray) ->
    array.filter (x) -> x not in overlapArray


popRandom = (array) ->
    indexToPop = Math.floor((array.length - 1 )*Math.random())
    returnVal = array[indexToPop]
    array.splice(indexToPop, 1)
    returnVal


pickRandom = (array) ->
    indexToPop = Math.floor((array.length - 1 )*Math.random())
    returnVal = array[indexToPop]

# Kruskal algorithm as implemented in Skiena 198
kruskal = (graph) ->
    edgesReturn = []
    edges = ( {i:i, weight:el} for el, i in graph.edgeWeights)
    nodeComponents = ( i for el, i in graph.nodes )
    sortByKey(edges, 'weight')
    nodesUn = nodeComponents.unique()
    while nodesUn.length > 1
        newEdge = edges.shift()
        nodesToTry = graph.linksAdjDir[newEdge.i]
        if nodeComponents[nodesToTry[0]] != nodeComponents[nodesToTry[1]]
            edgesReturn.push newEdge.i
            nodeComponents = convertAll(nodeComponents, nodeComponents[nodesToTry[1]], nodeComponents[nodesToTry[0]])
            nodesUn = nodeComponents.unique()
    return edgesReturn

# Prims algorithm as implemented in Skiena p 195
prim = (graph, startNode) ->
   # record-keeping arrays
   distance = new Array(graph.numNodes).fill(Graph.maxWeight)
   intree = new Array(graph.numNodes).fill(-1)
   link = Array.from(intree)
   parent = Array.from(intree)

   distance[startNode] = 0  
   links = []
   linkAdd = -1
   currentNode = startNode

   while intree[currentNode] < 0
      # add new node and new edge to record of edges/nodes
      intree[currentNode] = 1
      linkAdd = link[currentNode]
      links.push linkAdd if linkAdd > 0

      # update any distances to tree that have become shorter with addition of new node
      p = graph.linksDir[currentNode]
      for k,v of p
          weight = graph.edgeWeights[v]
          if distance[k] > weight and intree[k] < 0
              distance[k] = weight
              link[k] = v
              parent[k] = currentNode

      # determine which node is now closest to tree and add it
      dist = Graph.maxWeight
      for i in [0...graph.numNodes]
          if intree[i] < 0 and dist > distance[i]
              dist = distance[i]
              currentNode = i
              linkAdd = link[i]
   return links
  
 


# Djikstras algorithm as a simple modification to Prims algorithm
djikstra = (graph, startNode) ->
   # record-keeping arrays
   distance = new Array(graph.numNodes).fill(Graph.maxWeight)
   intree = new Array(graph.numNodes).fill(-1)
   link = Array.from(intree)
   parent = Array.from(intree)

   distance[startNode] = 0
   links = []
   linkAdd = -1
   currentNode = startNode

   while intree[currentNode] < 0
      # add new node and new edge to record of edges/nodes
      intree[currentNode] = 1
      linkAdd = link[currentNode]
      links.push linkAdd if linkAdd > 0

      # update any distances to tree that have become shorter with addition of new node
      p = graph.linksDir[currentNode]
      for k,v of p
          weight = graph.edgeWeights[v]
          if distance[k] >  weight + distance[currentNode]
              distance[k] = weight + distance[currentNode]
              link[k] = v
              parent[k] = currentNode

      # determine which node is now closest to tree and add it
      dist = Graph.maxWeight
      for i in [0...graph.numNodes]
          if intree[i] < 0 and dist > distance[i]
              dist = distance[i]
              currentNode = i
              linkAdd = link[i]
   return {distances: distance, parents : parent}

 
console.log "\n\n\n\n\n\nNEW RUN"
links = [{id: 0, to: 1, from:5, weight:99}, {id: 1, to: 1, from:2, weight:2},{id: 2, to: 1, from:3, weight:2},{id: 3, to: 3, from:5, weight:1},{id: 4, to: 2, from:4, weight:1},{id: 5, to: 4, from:3, weight:5},{id: 6, to: 1, from:0, weight:10}, ]
nodes = [0...6]
graph = new Graph nodes, links
console.log graph



console.log "\n\n\n\n\n\nNEW RUN"
links = [{id: 0, to: 1, from:5, weight:99}, {id: 1, to: 1, from:2, weight:2},{id: 2, to: 1, from:3, weight:2},{id: 3, to: 3, from:5, weight:1},{id: 4, to: 2, from:4, weight:1},{id: 5, to: 4, from:3, weight:5},{id: 6, to: 1, from:0, weight:10}, ]
nodes = [0...6]
graph = new Graph nodes, links
console.log graph


a = kruskal graph
console.log a
a = prim graph, 0
console.log a
a = djikstra graph, 0
console.log a