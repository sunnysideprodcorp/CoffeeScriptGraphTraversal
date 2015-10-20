#
# graph-related helpe- functions
#

# translates full traversal path into path showing only 
# first traversal of each node
shortenPath = (fullPath) ->
    shortPath = []
    for i in [0...fullPath.length]
        if fullPath[i] not in shortPath
            shortPath.push fullPath[i]
     shortPath.push fullPath[0]
     return shortPath
 

# calculates cost of current solution factoring in edge weights
solutionCost = (currentSolution, graph) ->
       cost = 0
       for i in [0...(currentSolution.length-1)]
          cost += graph.dist [currentSolution[i], currentSolution[i+1]]
       return cost

# returns all nodes traversed on shortest path from current to next
getIntermediateNodes = (current, next, parents) ->
    currentlyChecking = next
    nodesUsed = []
    while parents[currentlyChecking] not in [current, -1] # -1 is traversing from a node to itself
        nodesUsed.push parents[currentlyChecking]
        currentlyChecking = parents[currentlyChecking] 
    # reverse because we went backwards relative to requested direction
    nodesUsed.reverse()
    nodesUsed

# get the cost and nodes included in the shortest path from current to next
getSegment = (current, next, graph) ->
        results = djikstra graph, current
        cost = results.distances[next]
        nodesBetween = getIntermediateNodes current, next, results.parents
        { nodesBetween : nodesBetween, cost : cost}

# pick a random pair of indices to swap and return in an array
# the indices cannot be the same
getPair =  (currentSolution) ->
    i1 = pickRandom currentSolution
    while i1 in [0, (currentSolution.length - 1)]
      i1 = pickRandom currentSolution       
    i2 = pickRandom currentSolution
    while i2 in [0, (currentSolution.length - 1)] or i2 == i1
      i2 = pickRandom currentSolution
    return [i1, i2]

# calculates the cost associated with the edges that would link position1's neighbors to node1
# and the cost associated with the edges that woud link position2's neighbors to node2
# this helps calculate the cost of swapping two nodes in a proposed path
transitionDelta = (graph, proposedSolution, node1, node2, position1, position2) ->
  pairs = [[proposedSolution[Math.max(position1 - 1, 0)], node1],                               # node1 left neighbor, note these max and min guards should be redundant
           [node1, proposedSolution[Math.min(proposedSolution.length - 1, position1 + 1)]],     # node1 right neighor
           [proposedSolution[Math.max(position2 - 1, 0)], node2],                               # node2 left neighbor
           [node2, proposedSolution[Math.min(proposedSolution.length - 1, position2 + 1)]]];    # node2 right neighor
  cost = 0
  for pair in pairs
    cost +=  graph.dist pair
  return cost

# compares the total cost of proposedSolution vs the total cost of a solution that would swap the nodes at swap1 and swap2 in proposedSolution
# no in-place changes are made to proposedSolution
# calculates only affected portions of the path related to the swap rather than recalculating entire cost
transition = (graph, proposedSolution, currentValue, swap1, swap2) ->
  trySolution = proposedSolution.slice(0)
  val1 = proposedSolution[swap1]
  val2 = proposedSolution[swap2]
  beforeDelta = transitionDelta graph, trySolution, val1, val2, swap1, swap2
  swap trySolution, swap1, swap2
  afterDelta = transitionDelta graph, trySolution, val2, val1, swap1, swap2
  afterDelta - beforeDelta

# picks and traverses vertices in an entirely random order
# if a node is traversed when getting between two other randomly traversed nodes, that node is also traversed then
randomTSP = (numTrials, graph) ->
    nodes = graph.nodes
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

	# while there are still nodes that have not been traversed
        while nodesRemaining.length > 0
          next = popRandom nodesRemaining
          segment = getSegment current, next, graph
          currentPathCost += segment.cost
          currentPath = currentPath.concat segment.nodesBetween, [next]
          nodesRemaining = removeOverlap nodesRemaining, segment.nodesBetween
          current = next

	  # once you've popped the last node, add back the first node and go through loop one last time
          if nodesRemaining.length == 0 and currentPath[currentPath.length - 1] != first
              nodesRemaining.push first

        # update best scenario if appropriate
        if currentPathCost < bestPathCost
            bestPath = currentPath
            bestPathCost = currentPathCost

    return {cost : bestPathCost, path : bestPath} 



#
# simulated annealing heuristic
#

# simulated annealing constants
INITIAL_TEMPERATURE = 5
COOLING_STEPS = 5
STEPS_PER_TEMP = 5
COOLING_FRACTION = .8
K = .03
E = 2.718

# following Skiena p 257
annealTSP = (graph, proposedSolution) ->
    # setup for iteration
    currentSolution = proposedSolution
    currentValue = solutionCost currentSolution, graph
    temperature = INITIAL_TEMPERATURE
    nodesToPick =  Object.keys(graph.nodesDir)

    for i in [1..COOLING_STEPS]
        temperature *= COOLING_FRACTION
        startValue = currentValue

        for j in [1..STEPS_PER_TEMP]
            swapPair = getPair currentSolution      
            i1 = swapPair[0]
            i2 = swapPair[1]

	    # calculate factors re: whether new solution resulting from swap will be accepted
            delta = transition graph, proposedSolution, currentValue, i1, i2
            exponent = -1*delta/currentValue * Math.pow((K*temperature),-1)
            merit = Math.pow(E, exponent)

            if delta < 0 or merit > Math.random()
               currentValue = currentValue + delta
               swap currentSolution, i1, i2
            
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
   