

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
