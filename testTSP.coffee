# making a new Graph
links = [{id: 0, to: 1, from:5, weight:99}, {id: 1, to: 1, from:2, weight:2},{id: 2, to: 1, from:3, weight:2},{id: 3, to: 3, from:5, weight:1},{id: 4, to: 2, from:4, weight:1},{id: 5, to: 4, from:3, weight:5},{id: 6, to: 1, from:0, weight:10}, ]
nodes = [0...6]
graph = new Graph nodes, links
console.log graph

# demonstrating a random search for a TSP solution
randomResult = randomTSP 5, graph
console.log "Result of randomly searching for TSP solution optimized with this path: " + randomResult.path + " with a cost of " + randomResult.cost

# demonstrating a simulated annealing search for a TSP solution
annealResult = annealTSP graph, randomResult.path
console.log "Result of applying an annealing heuristic to the existing random result gives us this path: " + annealResult.path + " with a cost of " + annealResult.cost

# demonstrating a local search for a TSP solution
localResult = localTSP graph, randomResult.path
console.log "Result of applying a local-search heuristic to the existing random result gives us this path: " + localResult.path + " with a cost of " + localResult.cost