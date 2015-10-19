


 

nodesDir =
0 : [1],
1 : [0, 2, 3, 5],
2 : [1, 4],
3 : [1, 4, 5],
4 : [2, 3],
5 : [1, 3]

linksDir = 
0: {1:6}
1: {2:1, 3: 2, 5:0, 0:6},
2: {1:1, 4:4},
3: {1:2, 4:5, 5:3},
4: {2:4, 3:5},
5: {3:3, 1:0}



linksAdjDir = 
0: [1,5],
1: [1, 2],
2: [1, 3],
3: [3, 5],
4: [2, 4],
5: [3, 4],
6: [0, 1]


NUM_NODES = Object.keys(nodesDir).length
NODES = [0...NUM_NODES]
MAX_WEIGHT = 10000
EDGE_WEIGHTS = [99, 2, 2, 1, 1, 5, 10]

sortByKey = (array, key) ->
    array.sort((a, b) -> a[key] - b[key])

convertAll = (array, before, after) ->
    ((if el != before then el else after) for el in array)


#taken from https://coffeescript-cookbook.github.io/chapters/arrays/removing-duplicate-elements-from-arrays
Array::unique = ->
  output = {}
  output[@[key]] = @[key] for key in [0...@length]
  value for key, value of output

# Kruskal algorithm as implemented in Skiena 198
kruskal = (nodesDir, linksDir, linksAdjDir) ->
    edgesReturn = []
    edges = ( {i:i, weight:el} for el, i in EDGE_WEIGHTS)
    nodeComponents = ( i for el, i in NODES )
    sortByKey(edges, 'weight')
    nodesUn = nodeComponents.unique()
    while nodesUn.length > 1
        newEdge = edges.shift()
        nodesToTry = linksAdjDir[newEdge.i]
        if nodeComponents[nodesToTry[0]] != nodeComponents[nodesToTry[1]]
            edgesReturn.push newEdge.i
            nodeComponents = convertAll(nodeComponents, nodeComponents[nodesToTry[1]], nodeComponents[nodesToTry[0]])
            nodesUn = nodeComponents.unique()
    return edgesReturn

# Prims algorithm as implemented in Skiena p 195
prim = (nodesDir, linksDir, startNode) ->
   # record-keeping arrays
   distance = new Array(NUM_NODES).fill(MAX_WEIGHT)
   intree = new Array(NUM_NODES).fill(-1)
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
      p = linksDir[currentNode]
      for k,v of p
          weight = EDGE_WEIGHTS[v]
          if distance[k] > weight and intree[k] < 0
              distance[k] = weight
              link[k] = v
              parent[k] = currentNode

      # determine which node is now closest to tree and add it
      dist = MAX_WEIGHT
      for i in [0...NUM_NODES]
          if intree[i] < 0 and dist > distance[i]
              dist = distance[i]
              currentNode = i
              linkAdd = link[i]
   return links
  
 


# Djikstras algorithm as a simple modification to Prims algorithm
djikstra = (nodesDir, linksDir, startNode) ->
   # record-keeping arrays
   distance = new Array(NUM_NODES).fill(MAX_WEIGHT)
   intree = new Array(NUM_NODES).fill(-1)
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
      p = linksDir[currentNode]
      for k,v of p
          weight = EDGE_WEIGHTS[v]
          if distance[k] >  weight + distance[currentNode]
              distance[k] = weight + distance[currentNode]
              link[k] = v
              parent[k] = currentNode

      # determine which node is now closest to tree and add it
      dist = MAX_WEIGHT
      for i in [0...NUM_NODES]
          if intree[i] < 0 and dist > distance[i]
              dist = distance[i]
              currentNode = i
              linkAdd = link[i]
   return {distances: distance, parents : parent}


edges = kruskal nodesDir, linksDir, linksAdjDir
alert "kruskal result: "+edges

f = prim(nodesDir, linksDir, 3)
alert "prim result: "+f    

distances = djikstra(nodesDir, linksDir, 0).distances
alert distances
