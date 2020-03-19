import numpy as np

print('''
Problem:
A class of 30 students completed a coursework assessment worth 40% and a final exam worth
60% of the final grade. The grades for the coursework and the marks for the exam are in two
arrays. Find the total for each student by adding corresponding grades from the two arrays.
''')

# use numpy's random methods to create an array of random values
cw_marks = np.random.randint(0, 41, 30)
exam_marks = np.random.randint(0, 61, 30)

print('The coursework marks are:')
print(cw_marks)
print('The final exam marks are:')
print(exam_marks)

total = cw_marks + exam_marks

print('The total marks are:')
print(total)