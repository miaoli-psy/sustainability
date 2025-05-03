import os
import pandas as pd

# Toggle: include or exclude "images/child.png"
include_child = False

# working path
script_dir = os.path.dirname(os.path.abspath(__file__))
os.chdir(script_dir)

# read data
PATH_DATA = "../../data/ie_data/"
dir_list = [f for f in os.listdir(PATH_DATA) if f.lower().endswith('.csv')]
df_list_all = [pd.read_csv(os.path.join(PATH_DATA, file)) for file in dir_list]

# cols
slider_responses = [f'slider_posi_{i}.response' for i in range(1, 11)]
slider_times = [f'slider_posi_{i}.rt' for i in range(1, 11)]
col_explicit = slider_responses + slider_times + [
    "expli_order", "nor1_order", "nor2_order", "nor3_order", "participant", "expName"]

# real impact scores
real_impact_dict = {
    "images/child.png": 58.6,
    "images/car.png": 2.4,
    "images/flight.png": 1.6,
    "images/plant_based.png": 0.8,
    "images/e_car.png": 1.15,
    "images/green_energy.png": 2.63,
    "images/laundry.png": 0.247,
    "images/recycling.png": 0.5,
    "images/hang_dry.png": 0.21,
    "images/light_bulb.png": 0.1}

# normalize real impact scores

if include_child:
    filtered_real_impact_dict = real_impact_dict.copy()
else:
    filtered_real_impact_dict = {k: v for k, v in real_impact_dict.items() if k != "images/child.png"}

# normalize real impacts based on filtered actions only
max_real_impact = max(filtered_real_impact_dict.values())
normalized_real_impact_dict = {k: v / max_real_impact for k, v in filtered_real_impact_dict.items()}


all_processed_data = []

for data in df_list_all:
    filtered_data = data[col_explicit]
    valid_rows = filtered_data.dropna(subset=slider_responses)

    for _, row in valid_rows.iterrows():
        # read action list
        actions = row['expli_order'] if isinstance(row['expli_order'], list) else eval(row['expli_order'])

        # pair actions with corresponding responses and RTs
        full_data = [
            (action, row[f'slider_posi_{i}.response'], row[f'slider_posi_{i}.rt'])
            for i, action in enumerate(actions[:10], start=1)
            if include_child or action != "images/child.png" 
        ]

        # apply filtering if include_child is False
        if not include_child:
            full_data = [tup for tup in full_data if tup[0] != "images/child.png"]

        # skip if empty after filtering
        if not full_data:
            continue


        # unpack
        actions_filtered, responses_filtered, rts_filtered = zip(*full_data)

        # normalize measured scores
        max_response = max(responses_filtered)
        normalized_measured = [resp / max_response for resp in responses_filtered]

        # real impact  (raw and normalized)
        real_impacts = [real_impact_dict.get(a) for a in actions_filtered]

        normalized_real_impacts = [normalized_real_impact_dict.get(a) for a in actions_filtered]


        # weighted scores
        weighted_scores = [m - r for m, r in zip(normalized_measured, normalized_real_impacts)]

        # ranks and deviations
        measured_ranks = pd.Series(normalized_measured).rank(ascending=False, method='min').tolist()
        real_ranks = pd.Series(normalized_real_impacts).rank(ascending=False, method='min').tolist()
        deviations = [(m - r) for m, r in zip(normalized_measured, normalized_real_impacts)]


        row_data = pd.DataFrame({
            'participant': [row['participant']] * len(actions_filtered),
            'action': actions_filtered,
            'resp_impact': responses_filtered,
            'RT': rts_filtered,
            'normalized_measured': normalized_measured,
            'real_impact': real_impacts,
            'normalized_real_impact': normalized_real_impacts,
            'weighted_score': weighted_scores,
            'measured_rank': measured_ranks,
            'real_rank': real_ranks,
            'deviation': deviations})

        all_processed_data.append(row_data)


output_data = pd.concat(all_processed_data, ignore_index=True)

# save it
write_to_excel = True
if write_to_excel:
    filename_suffix = "with_child" if include_child else "no_child"
    output_filename = f"ie_explicitdata_{filename_suffix}.xlsx"
    output_data.to_excel(output_filename, index=False)


