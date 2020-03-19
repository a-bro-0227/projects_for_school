# arrays

import numpy as np

# one-dimensional array
a = np.array([5, 3, 7])

print('printing one dimensional array')
print(a)
print('\n')

# two-dimensional array
b = np.array([[2, 4, 6], [3, 5, 7]])

print('printing two dimensional array')
print(b)
print('\n')

# sequence of numbers
c = np.arange(20)

print('printing sequence of numbers 1-20 (or 0-19)')
print(c)
print('\n')

# arrange from n0 to nn: arrange(start, end, step)
d = np.arange(20, 50, 2)

print('printing ordered list of numbers 20-50 by 2')
print(d)
print('\n')

# array of zeros
e = np.zeros(10)

print('printing array of zeros')
print(e)
print('\n')

# two-dimensional array of ones
f = np.ones((5, 8))

print('printing two-dimensional array of ones')
print(f)
print('\n')

# reshape from one to multiple dimensional
g = c.reshape(4, 5)

print('`reshape` ordered one-dimensional array to mutli-dimensional array')
print(g)
print('\n')

# attributes
print("`ndim` - gives the number of axe")
print("`shape` - gives the dimensions of the array")
print("`size` - gives the number of elements in the array")
print("`dtype` - gives the data type of the elements of the array")

print('\n')

print("here is a new array: h")

# create a new array
h = np.arange(25).reshape(5, 5)

print(h)
print('\n')

# print the number of axes in this array
print('There are {} axes in this array.'.format(h.ndim))

# print the shape of the array
print('This is a {} array'.format(h.shape))

# print the size of the array
print('This array contains {} elements'.format(h.size))

# print the data type of the elements
print('This array contains values of type {}'.format(h.dtype))








