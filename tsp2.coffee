nodesDir =
0 : [1],
1 : [0, 2, 3, 5],
2 : [1, 4],
3 : [1, 4, 5],
4 : [2, 3],
5: [1, 3]

linksDir = {
0: {1:6}
1: {2:1, 3: 2, 5:0, 0:6},
2: {1:1, 4:4},
3: {1:2, 4:5, 5:3},
4:{2:4, 3:5},
5:{3:3, 1:0},
}


linksConDir = 
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

#
# helper functions
#
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


#
# djikstra
#

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
  


#
# calc shortests paths and cache
#


class DynamicResults
    shortestPaths = {}
    adjacencyMatrix = [0...NUM_NODES].map (x)->
          [0...NUM_NODES].map (y) -> Math.pow(MAX_WEIGHT,2)
    adjacencyPathBackMatrix = [0...NUM_NODES].map (x)->
          [0...NUM_NODES].map (y) -> x
    computedAdjacency = false

    @pathDist: (pair, nodesDir, linksDir) ->
              from = pair[0]
              to = pair[1]
              if shortestPaths[from]?
                  return shortestPaths[from][to]
              else if shortestPaths[to]?
                  return shortestPaths[to][from]
              else
                  result = djikstra nodesDir, linksDir, to
                  shortestPaths[to] = result.distances
                  return shortestPaths[to][from]


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

solutionCost = (currentSolution, nodesDir, edgeWeights, linksDir) ->
       cost = 0
       for i in [0...(currentSolution.length-1)]
          cost += DynamicResults.pathDist([currentSolution[i], currentSolution[i+1]], nodesDir, linksDir)
          console.log "for distance from "+currentSolution[i]+ " to "+currentSolution[i+1]+" adding a cost of "+DynamicResults.pathDist([currentSolution[i], currentSolution[i+1]], nodesDir, linksDir)
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

getSegment = (current, next) ->
        results = djikstra nodesDir, linksDir, current
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

transitionDelta = (proposedSolution, node1, node2, position1, position2) ->
  pairs = [[proposedSolution[Math.max(position1 - 1, 0)], node1], [node1, proposedSolution[Math.min(proposedSolution.length - 1, position1 + 1)]], [proposedSolution[Math.max(position2 - 1, 0)], node2], [node2, proposedSolution[Math.min(proposedSolution.length - 1, position2 + 1)]]];
  cost = 0
  for pair in pairs
    cost +=  DynamicResults.pathDist([pair[0], pair[1]], nodesDir, linksDir)#graph.shortestPaths[pair[0]][pair[1]]
  return cost


transition = (proposedSolution, currentValue, swap1, swap2) ->
  trySolution = proposedSolution.slice(0)
  val1 = proposedSolution[swap1]
  val2 = proposedSolution[swap2]
  beforeDelta = transitionDelta(trySolution, val1, val2, swap1, swap2)
  swap trySolution, swap1, swap2
  afterDelta = transitionDelta(trySolution, val2, val1, swap1, swap2)
  afterDelta - beforeDelta

# picks and traverses vertices in an entirely random order. may double-traverse indices 
randomTSP = (numTrials, nodesDir, edgeWeights, linksDir) ->
    nodes = nodesDir.keys
    bestPath = []
    bestPathCost = MAX_WEIGHT^2

    for i in [1..numTrials]
        # setup to generate another sample
        nodesRemaining = Object.keys(nodesDir)
        nodesRemaining = (Number(n) for n in nodesRemaining)
        currentPath = []
        currentPathCost = 0

        # randomly selected first node, then continue selecting a random node for next step
        first = popRandom nodesRemaining
        currentPath.push first
        current = first

        while nodesRemaining.length > 0
          next = popRandom nodesRemaining
          segment = getSegment current, next
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

console.log "\n\n\n\n\n\nNEW RUN"


#
# simulated annealing constants
#
INITIAL_TEMPERATURE = 5
COOLING_STEPS = 5
STEPS_PER_TEMP = 5
COOLING_FRACTION = .8
K = .03
E = 2.718



# following Skiena p 257
annealingTSP = (nodesDir, edgeWeights, edgesDir, proposedSolution) ->
    # setup for iteration
    currentSolution = proposedSolution
    currentValue = solutionCost(currentSolution, nodesDir, edgeWeights, edgesDir)
    temperature = INITIAL_TEMPERATURE
    nodesToPick =  Object.keys(nodesDir)

    for i in [1..COOLING_STEPS]
        temperature *= COOLING_FRACTION
        startValue = currentValue

        for j in [1..STEPS_PER_TEMP]
            swapPair = getPair(currentSolution)      
            i1 = swapPair[0]
            i2 = swapPair[1]

            delta = transition proposedSolution, currentValue, i1, i2
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


obj = randomTSP(1, nodesDir, EDGE_WEIGHTS, linksDir)
shortPath =  shortenPath obj.path
console.log "\n\n\n testing with full path"
console.log("TESTING"+obj.path + " is random solution with calc cost of " + obj.cost + " and a real cost of " + solutionCost obj.path, nodesDir, EDGE_WEIGHTS, linksDir )
console.log "\n\n\n testing with short"
console.log(shortPath + " is random solution with calc cost of " + obj.cost + " and a real cost of " + solutionCost shortPath, nodesDir, EDGE_WEIGHTS, linksDir )
a = annealingTSP(nodesDir, EDGE_WEIGHTS, linksDir, shortPath)
console.log a.path+" is annealing result with cost "+a.cost+" and a verified cost of "+solutionCost a.path, nodesDir, EDGE_WEIGHTS, linksDir 



#
# local Search
#
# Skiena p 252

localTSP = (nodesDir, edgeWeights, linksDir, proposedSolution) ->
    # setup for iteration
    currentSolution = proposedSolution
    currentValue = solutionCost(currentSolution, nodesDir, edgeWeights, linksDir)
    nodesToPick =  Object.keys(nodesDir)
    counter = 0
    loop
       stuck = true
       for i in [1...NUM_NODES]
          for j in [1...NUM_NODES]
             delta = transition currentSolution, currentValue, i, j            
             if delta < 0
                stuck = false
                swap currentSolution, i, j
                currentValue =  solutionCost(currentSolution, nodesDir, edgeWeights, linksDir)
             counter++
       
       break unless (not stuck) and (counter < 1)

    return {path : currentSolution, cost : currentValue}
   

a = localTSP(nodesDir, EDGE_WEIGHTS, linksDir, shortPath)
console.log a.path+" is local result with cost "+a.cost+" and a verified cost of "+solutionCost a.path, nodesDir, EDGE_WEIGHTS, linksDir 