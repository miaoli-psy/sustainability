import os
import pandas as pd

real_impact_dict = {
    'images/laundry.png': 0.247,
    'images/hang_dry.png': 0.21,
    'images/child.png': 117.7,
    'images/plant_based.png': 0.91,
    'images/light_bulb.png': 0.17,
    'images/green_energy.png': 1.4,
    'images/flight.png': 1.6,
    'images/car.png': 3.08,
    'images/recycling.png': 0.2125,
    'images/e_car.png': 2.21,
}

def process_explicit_data(path_data, task_order, real_impact_dict, include_child=False):
    # working path
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)

    # read raw data
    dir_list = [f for f in os.listdir(path_data) if f.lower().endswith('.csv')]
    df_list_all = [pd.read_csv(os.path.join(path_data, file)) for file in dir_list]

    # get the cols
    slider_responses = [f'slider_posi_{i}.response' for i in range(1, 11)]
    slider_times = [f'slider_posi_{i}.rt' for i in range(1, 11)]
    col_explicit = slider_responses + slider_times + [
        "expli_order", "nor1_order", "nor2_order", "nor3_order", "participant", "expName", "ProlificID"
    ]

    # normalize real impact
    if include_child:
        filtered_real_impact_dict = real_impact_dict.copy()
    else:
        filtered_real_impact_dict = {k: v for k, v in real_impact_dict.items() if k != "images/child.png"}

    max_real_impact = max(filtered_real_impact_dict.values())
    normalized_real_impact_dict = {k: v / max_real_impact for k, v in filtered_real_impact_dict.items()}

    all_processed_data = []

    for data in df_list_all:
        filtered_data = data[col_explicit]
        valid_rows = filtered_data.dropna(subset=slider_responses)

        for _, row in valid_rows.iterrows():

            # action list for each participant
            actions = row['expli_order'] if isinstance(row['expli_order'], list) else eval(row['expli_order'])

            # Pair actions with responses and RTs
            full_data = [
                (action, row[f'slider_posi_{i}.response'], row[f'slider_posi_{i}.rt'])
                for i, action in enumerate(actions[:10], start=1)
                if include_child or action != "images/child.png"
            ]

            if not full_data:
                continue

            actions_filtered, responses_filtered, rts_filtered = zip(*full_data)
            max_response = max(responses_filtered)
            normalized_measured = [resp / max_response for resp in responses_filtered]

            real_impacts = [real_impact_dict.get(a) for a in actions_filtered]
            normalized_real_impacts = [normalized_real_impact_dict.get(a) for a in actions_filtered]
            weighted_scores = [m - r for m, r in zip(normalized_measured, normalized_real_impacts)]

            measured_ranks = pd.Series(normalized_measured).rank(ascending=False, method='min').tolist()
            real_ranks = pd.Series(normalized_real_impacts).rank(ascending=False, method='min').tolist()
            deviations = [(m - r) for m, r in zip(normalized_measured, normalized_real_impacts)]

            row_data = pd.DataFrame({
                'participant': [row['participant']] * len(actions_filtered),
                'ProlificID': [row['ProlificID']] * len(actions_filtered),
                'action': actions_filtered,
                'resp_impact': responses_filtered,
                'RT': rts_filtered,
                'normalized_measured': normalized_measured,
                'real_impact': real_impacts,
                'normalized_real_impact': normalized_real_impacts,
                'weighted_score': weighted_scores,
                'measured_rank': measured_ranks,
                'real_rank': real_ranks,
                'deviation': deviations,
                'task_order': [task_order] * len(actions_filtered)  # ✅ Add task order
            })

            all_processed_data.append(row_data)

    output_data = pd.concat(all_processed_data, ignore_index=True)

    return output_data

# read data
PATH_DATA_ie = "../../data/ie_data/"
PATH_DATA_ei = "../../data/ei_data/"

include_child = True #TODO

data_ie = process_explicit_data(PATH_DATA_ie, "ie", real_impact_dict, include_child=include_child)
data_ei = process_explicit_data(PATH_DATA_ei, "ei", real_impact_dict, include_child=include_child)

data_combined = pd.concat([data_ie, data_ei], ignore_index=True)

# write to excel
write_to_csv = True
if write_to_csv:
    if include_child:
        data_combined.to_csv("explicitdata.csv", index = False)
    else:
        data_combined.to_csv("explicitdata_nochild.csv", index=False)