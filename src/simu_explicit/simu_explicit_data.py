# -*- coding: utf-8 -*-
"""
Created on Sat Apr 27 13:27:22 2024

@author: Miao
"""
import pandas as pd
import numpy as np

# seed
np.random.seed(2)


# parameters
n_participants = 2
items = ['car_free', 'flight', 'plant', 'e_car', 'green', 'laundry', 'recycle', 'cloth', 'bulb']
real_scores_provided = [2.4, 1.6, 0.8, 1.15, 2.63, 0.247, 0.5, 0.21, 0.1]
measurement_error_std = 1.5
include_child = False #TODO

if include_child:
    items = ['child'] + items
    real_scores_provided = [58.6] + real_scores_provided

# normalize real scores 0-1
max_real_score = max(real_scores_provided)
norm_real_scores = [score / max_real_score for score in real_scores_provided]


data = pd.DataFrame()

# measured scores for each participant
for participant in range(1, n_participants + 1):
    measured_scores = np.random.normal(5, measurement_error_std, len(items))  # centered at 5 with some noise
    measured_scores = np.clip(measured_scores, 0, 10)  # as psychopy 0-10
    
    max_measured_score = max(measured_scores)
    norm_measured_scores = measured_scores / max_measured_score if max_measured_score > 0 else measured_scores

    
    participant_label = f"s{participant}"  
    temp_df = pd.DataFrame({
        'participant': participant_label,
        'item': items,
        'real_score': real_scores_provided,
        'norm_real': norm_real_scores,
        'measured_score': measured_scores,
        'norm_easured': norm_measured_scores
    })
    data = pd.concat([data, temp_df])

# Reset the index of the DataFrame
data.reset_index(drop=True, inplace=True)
print(data)

if include_child:
    data.to_csv("data_with_child.csv", index = False)
else:
    data.to_csv("data_without_child.csv", index = False)

