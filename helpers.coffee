

#
# helper functions used throughout graph traversal scripts
# these functions all manipulate arrays
#


# in-place array manipulations #

# sort an array of objects according to key value in ascending order
# in-place modification
sortByKey = (array, key) ->
    array.sort((a, b) -> a[key] - b[key])

# convert all members of array equal to before with after
# in-place modification
convertAll = (array, before, after) ->
    ((if el != before then el else after) for el in array)

# swaps values of array at ind1 and ind2
# array is modified in-place
swap = (array, ind1, ind2) ->
       temp = array[ind1]
       array[ind1] = array[ind2]
       array[ind2] = temp

removeOverlap = (array, overlapArray) ->
    array.filter (x) -> x not in overlapArray

# pops a random value off array and returns that value
# array is modified in-place
popRandom = (array) ->
    indexToPop = Math.floor((array.length - 1 )*Math.random())
    returnVal = array[indexToPop]
    array.splice(indexToPop, 1)
    return returnVal



# non in-place array manipulations, these functions return a value or a new array #

# return copy of array with unique values of array 
#taken from https://coffeescript-cookbook.github.io/chapters/arrays/removing-duplicate-elements-from-arrays
Array::unique = ->
  output = {}
  output[@[key]] = @[key] for key in [0...@length]
  return value for key, value of output

pickRandom = (array) ->
    index = Math.floor((array.length - 1 )*Math.random())
    return array[index]
