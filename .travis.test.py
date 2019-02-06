from paraview.simple import *

# simple pipeline that executes our example plugin
s = UnstructuredCellTypes()
t = ExamplePlugin(s)
u = servermanager.Fetch(t)

answer = u.GetFieldData().GetArray('Answer').GetValue(0)

print('The answer is {}.'.format(answer))
assert(answer == 42)
