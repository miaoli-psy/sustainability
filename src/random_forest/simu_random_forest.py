# -*- coding: utf-8 -*-
"""
Created on Fri Apr 12 00:50:06 2024

@author: Miao
"""

import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, r2_score

# simulate a dataset

np.random.seed(10)

df = pd.DataFrame(
    {"norm_real": np.random.uniform(0, 1, 100),
     "norm_explicit": np.random.uniform(0, 1, 100),
     "norm_implicit": np.random.uniform(0, 1, 100)
     }
    )

# sep into feature and target
X = df[['norm_explicit', 'norm_implicit']]
y = df['norm_real']


# train and test df
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size = 0.2, random_state = 10)


# trainig
random_forest = RandomForestRegressor(n_estimators=1000, random_state = 10)
random_forest.fit(X_train, y_train)

# prediction on test
y_pred = random_forest.predict(X_test)


# get res
mse = mean_squared_error(y_test, y_pred)
r2 = r2_score(y_test, y_pred)


# feature importances
# here which dv has higher impact on the prediction of real score
importances = random_forest.feature_importances_

