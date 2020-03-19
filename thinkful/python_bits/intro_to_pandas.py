# first import Pandas
import pandas as pd
import numpy as np

# create a series from an array
ages = pd.Series(np.random.randint(20, 40, 9))

# print this series
print('printing index of ages:')
print(ages)

print('\n')

# set string-based index
age_array = np.random.randint(20, 40, 9)
names_list = ['Sam', 'Frodo', 'Merry', 'Pippin', 'Aragorn', 'Gandalf', 'Boromir', 'Legolas', 'Gimli']

string_index = pd.Series(age_array, index=names_list)

print('printing string-based index - ages tied to names:')
print(string_index)

print('\n')

print('here are some basic stats about the index:')
print('The oldest age is {}'.format(string_index.max()))
print('The youngest age is {}'.format(string_index.min()))
print('The mean points in the league is {}'.format(string_index.mean()))
print('The standard deviation of points in the league is {}'.format(string_index.std()))

print('\n')

print('`describe` function also calls all of these basic stats:')
print(string_index.describe())

print('\n')

# create series from dictionary
teams = {
    'Liverpool': 69,
    'Man City': 68,
    'Tottenham': 60,
    'Arsenal': 56,
    'Man United': 55
}

# construct a series from the dictionary
standings = pd.Series(teams)

# Print the series
print('printing index from dictionary:')
print(standings)