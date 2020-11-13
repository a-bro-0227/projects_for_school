# Importing the libraries
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd

from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.neighbors import KNeighborsClassifier
from sklearn.metrics import confusion_matrix
from sklearn.metrics import accuracy_score



# Importing the dataset
dataset = pd.read_csv('wine.csv')
x = dataset.iloc[:, [0, 1]].values
y = dataset.iloc[:, 2].values

# Splitting the dataset into the Training set and Test set
x_train, x_test, y_train, y_test = train_test_split(x, y, test_size = 0.20, random_state = 0)

# Feature Scaling
sc = StandardScaler()
x_train = sc.fit_transform(x_train)
x_test = sc.transform(x_test)

# Fitting classifier to the Training set
classifier = KNeighborsClassifier(n_neighbors = 3, metric='minkowski', p=2)
classifier.fit(x_train, y_train)

# Predicting the Test set results
y_pred = classifier.predict(x_test)

cm = confusion_matrix(y_test, y_pred)
print("confusion matrix:")
print(cm)
print(accuracy_score(y_test, y_pred))