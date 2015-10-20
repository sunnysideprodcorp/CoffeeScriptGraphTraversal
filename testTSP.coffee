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



