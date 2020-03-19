import pandas as pd
df = pd.read_csv('https://tf-assets-prod.s3.amazonaws.com/tf-curric/data-analytics-bootcamp/songs.csv')

print('printing all the info about the dataframe')
print(df.info())

print('\n')

print('printing just the column names of the dataframe')
print(df.columns)

print('\n')

print('printing just the data types of the dataframe')
print(df.dtypes)

print('\n')

print('peek at the actual dataframe')
print(df.head())

# craete function for printing info
def printDataFrame(df):
  print('The shape of this DataFrame is {}'.format(df.shape)) # just the shape of df
  print('The columns in this DataFrame are {}'.format(df.columns)) # just the column names of the dataframe
  print('The info:')
  print(df.info())

printDataFrame(df)
print(df.head(2))

