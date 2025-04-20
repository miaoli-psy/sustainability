import os
import pandas as pd

# read data
PATH_DATA = "../../data/ie_data/"
dir_list = os.listdir(PATH_DATA)
# all data files
dir_list = [f for f in os.listdir(PATH_DATA) if f.lower().endswith('.csv')]

df_list_all = [pd.read_csv(PATH_DATA + file) for file in dir_list]

# get all col names
col_names = df_list_all[0].columns.tolist()

# sliders
# create lists for response and RT columns
slider_responses = [f'slider_posi_{i}.response' for i in range(1, 11)]
slider_times = [f'slider_posi_{i}.rt' for i in range(1, 11)]

col_explicit = slider_responses + slider_times + ["expli_order", "nor1_order", "nor2_order", "nor3_order", "participant", "expName"]

# Initialize an empty list to store all processed data
all_processed_data = []

# Process each dataframe
for data in df_list_all:
    filtered_data = data[col_explicit]
    # Process each valid row (rows with complete slider responses)
    valid_rows = filtered_data.dropna(subset=[f'slider_posi_{i}.response' for i in range(1, 11)])

    for _, row in valid_rows.iterrows():
        actions = row['expli_order'] if isinstance(row['expli_order'], list) else eval(
            row['expli_order'])

        # Create DataFrame for this row
        row_data = pd.DataFrame({
            'impact': [row[f'slider_posi_{i}.response'] for i in range(1, 11)],
            'action': actions[:10],
            'RT': [row[f'slider_posi_{i}.rt'] for i in range(1, 11)],
            'participant': [row['participant']] * 10
        })

        all_processed_data.append(row_data)

# Combine all processed data into one DataFrame
output_data = pd.concat(all_processed_data, ignore_index=True)

write_to_excel = False
if write_to_excel:
    output_data.to_excel("ie_explicitdata.xlsx", index = False)
