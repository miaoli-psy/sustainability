import os
import pandas as pd

# read data
PATH_DATA = "../../data/ie_data/"
dir_list = os.listdir(PATH_DATA)
# all data files
df_list_all = [pd.read_csv(PATH_DATA + file) for file in dir_list]

# get all col names
col_names = df_list_all[0].columns.tolist()

# sliders
col_explicit = [col for col in col_names if col.startswith("slider")]
col_explicit = col_explicit + ["expli_order", "nor1_order", "nor2_order", "nor3_order", "participant", "expName"]


# try process one file

data = df_list_all[0]

slider_responses = [f'slider_posi_{i}.response' for i in range(1, 11)]
slider_times = [f'slider_posi_{i}.rt' for i in range(1, 11)]
relevant_columns = slider_responses + slider_times + ['participant', 'expli_order']

filtered_data = data[relevant_columns]

valid_row = filtered_data.dropna(subset=[f'slider_posi_{i}.response' for i in range(1, 11)]).iloc[0]

actions = valid_row['expli_order'] if isinstance(valid_row['expli_order'], list) else eval(valid_row['expli_order'])

output_data = pd.DataFrame({
    'impact': [valid_row[f'slider_posi_{i}.response'] for i in range(1, 11)],  # Slider response values
    'action': actions[:10],
    'RT': [valid_row[f'slider_posi_{i}.rt'] for i in range(1, 11)]  # Slider RT values
})