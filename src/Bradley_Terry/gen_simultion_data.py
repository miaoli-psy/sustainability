# -*- coding: utf-8 -*-
"""
Created on Wed Apr 10 17:12:29 2024

@author: Miao
"""
import pandas as pd
import numpy as np
from itertools import combinations

# 10 itmes
concepts = list('ABCDEFGHIJ')

# all pairs
pairs = list(combinations(concepts, 2))


simulation_res = []

# perform 3 comparisons:
np.random.seed(10)  # For reproducible results

for trial1, trial2 in pairs:
    wins1 = 0
    wins2 = 0
    for _ in range(3):  # 3 rounds
        if np.random.rand() > 0.5:
            wins1 += 1  # trial1 is seleted
        else:
            wins2 += 1  # trial2 
    simulation_res.append({
        'trial1': trial1,
        'trial2': trial2,
        'wins1': wins1,
        'wins2': wins2
    })


# data for bradley terry model
df = pd.DataFrame(simulation_res)

# df.to_csv("data.csv", index=False)



n_trials_per_pair = 3  # each participant repeats each pair 3 times

# Creating the data frame
stimulation_data = []
for pair in pairs:
    for trial in range(n_trials_per_pair):
        chosen = np.random.choice(pair)
        stimulation_data.append({
            'item1': pair[0],
            'item2': pair[1],
            'choice': chosen,
            'trial_n': trial+1  # Trial numbering starts from 1
        })

# Convert list to DataFrame
df_simulated = pd.DataFrame(stimulation_data)

df_simulated.to_csv("data.csv", index=False)

