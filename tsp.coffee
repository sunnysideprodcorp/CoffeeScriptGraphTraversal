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

#
# simulated annealing constants
#
INITIAL_TEMPERATURE = 5
COOLING_STEPS = 5
STEPS_PER_TEMP = 5
COOLING_FRACTION = .8
K = .03
E = 2.718





#
# graph-related helper functions
#

shortenPath = (fullPath) ->
    shortPath = []
    for i in [0...fullPath.length]
        if fullPath[i] not in shortPath
            shortPath.push fullPath[i]
     shortPath.push fullPath[0]
     return shortPath
 
solutionCost = (currentSolution, graph) ->
       cost = 0
       for i in [0...(currentSolution.length-1)]
          cost += graph.dist([currentSolution[i], currentSolution[i+1]])
       return cost

getIntermediateNodes = (current, next, parents) ->
    parentTrace = next
    nodesUsed = []
    j = 1
    while parents[parentTrace] not in [current, -1] and j < 20
        nodesUsed.push parents[parentTrace]
        parentTrace = parents[parentTrace] 
        j++
    nodesUsed.reverse()
    nodesUsed

getSegment = (current, next, graph) ->
        results = djikstra graph, current
        cost = results.distances[next]
        nodesBetween = getIntermediateNodes current, next, results.parents
        { nodesBetween : nodesBetween, cost : cost}

getPair =  (currentSolution) ->
    i1 = pickRandom(currentSolution)
    while i1 in [0, (currentSolution.length - 1)]
      i1 = pickRandom(currentSolution)       
    i2 = pickRandom(currentSolution)
    while i2 in [0, (currentSolution.length - 1)] or i2 == i1
      i2 = pickRandom(currentSolution)
    return [i1, i2]

transitionDelta = (graph, proposedSolution, node1, node2, position1, position2) ->
  pairs = [[proposedSolution[Math.max(position1 - 1, 0)], node1], [node1, proposedSolution[Math.min(proposedSolution.length - 1, position1 + 1)]], [proposedSolution[Math.max(position2 - 1, 0)], node2], [node2, proposedSolution[Math.min(proposedSolution.length - 1, position2 + 1)]]];
  cost = 0
  for pair in pairs
    cost +=  graph.dist pair
  return cost


transition = (graph, proposedSolution, currentValue, swap1, swap2) ->
  trySolution = proposedSolution.slice(0)
  val1 = proposedSolution[swap1]
  val2 = proposedSolution[swap2]
  beforeDelta = transitionDelta graph, trySolution, val1, val2, swap1, swap2
  swap trySolution, swap1, swap2
  afterDelta = transitionDelta graph, trySolution, val2, val1, swap1, swap2
  afterDelta - beforeDelta

# picks and traverses vertices in an entirely random order. may double-traverse indices 
randomTSP = (numTrials, graph) ->
    nodes = graph.nodes
    bestPath = []
    bestPathCost = Graph.maxWeight*graph.numNodes

    for i in [1..numTrials]
        # setup to generate another sample
        nodesRemaining = Object.keys(graph.nodesDir)
        nodesRemaining = (Number(n) for n in nodesRemaining)
        currentPath = []
        currentPathCost = 0

        # randomly selected first node, then continue selecting a random node for next step
        first = popRandom nodesRemaining
        currentPath.push first
        current = first

        while nodesRemaining.length > 0
          next = popRandom nodesRemaining
          segment = getSegment current, next, graph
          currentPathCost += segment.cost
          currentPath = currentPath.concat segment.nodesBetween, [next]
          nodesRemaining = removeOverlap nodesRemaining, segment.nodesBetween
          current = next

          if nodesRemaining.length == 0 and currentPath[currentPath.length - 1] != first
              nodesRemaining.push first

        # update best scenario if appropriate
        if currentPathCost < bestPathCost
            bestPath = currentPath
            bestPathCost = currentPathCost

    return {cost : bestPathCost, path : bestPath} 


# following Skiena p 257
annealingTSP = (graph, proposedSolution) ->
    # setup for iteration
    currentSolution = proposedSolution
    currentValue = solutionCost currentSolution, graph
    temperature = INITIAL_TEMPERATURE
    nodesToPick =  Object.keys(graph.nodesDir)

    for i in [1..COOLING_STEPS]
        temperature *= COOLING_FRACTION
        startValue = currentValue

        for j in [1..STEPS_PER_TEMP]
            swapPair = getPair(currentSolution)      
            i1 = swapPair[0]
            i2 = swapPair[1]

            delta = transition graph, proposedSolution, currentValue, i1, i2
            exponent = -1*delta/currentValue * Math.pow((K*temperature),-1)
            merit = Math.pow(E, exponent)
            flip = Math.random()
            Kcontrib = Math.pow(K*temperature,-1)
            if delta < 0 or merit > flip
               currentValue = currentValue + delta
               swap(currentSolution, i1, i2)
            
        if currentValue - startValue < 0
            temperature /= COOLING_FRACTION

    return {path: currentSolution, cost: currentValue}


#
# local Search
#
# Skiena p 252

localTSP = (graph, proposedSolution) ->
    # setup for iteration
    currentSolution = proposedSolution
    currentValue = solutionCost currentSolution, graph
    nodesToPick =  Object.keys(graph.nodesDir)
    counter = 0
    loop
       stuck = true
       for i in [1...graph.numNodes]
          for j in [1...graph.numNodes]
             delta = transition graph, currentSolution, currentValue, i, j            
             if delta < 0
                stuck = false
                swap currentSolution, i, j
                currentValue =  solutionCost currentSolution, graph
             counter++
       
       break unless (not stuck) and (counter < 1)

    return {path : currentSolution, cost : currentValue}
   console.log "\n\n\n\n\n\nNEW RUN"
links = [{id: 0, to: 1, from:5, weight:99}, {id: 1, to: 1, from:2, weight:2},{id: 2, to: 1, from:3, weight:2},{id: 3, to: 3, from:5, weight:1},{id: 4, to: 2, from:4, weight:1},{id: 5, to: 4, from:3, weight:5},{id: 6, to: 1, from:0, weight:10}, ]
nodes = [0...6]
graph = new Graph nodes, links
console.log graph



obj = randomTSP(1, graph)
shortPath =  shortenPath obj.path
console.log "\n\n\n testing with full path"+shortPath+"  "+obj.path
console.log("TESTING"+obj.path + " is random solution with calc cost of " + obj.cost + " and a real cost of " + solutionCost obj.path, graph )
console.log "\n\n\n testing with short"
console.log(shortPath + " is random solution with calc cost of " + obj.cost + " and a real cost of " + solutionCost shortPath, graph)
a = annealingTSP(graph, shortPath)
console.log a.path+" is annealing result with cost "+a.cost+" and a verified cost of "+solutionCost a.path, graph
a = localTSP(graph, shortPath)
console.log a.path+" is local result with cost "+a.cost+" and a verified cost of "+solutionCost a.path, graph



