import os
import pandas as pd

from src.common.process import insert_new_col_from_two_cols, insert_new_col, get_resp, \
    get_correct_ans, get_correct_wrong_index

script_dir = os.path.dirname(os.path.abspath(__file__))
os.chdir(script_dir)

# mapping action impacts

impact_mapping = {
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

def get_impact_value(action):
    return impact_mapping.get(action)

def process_raw(raw_data_path, task_order):

    dir_list = [f for f in os.listdir(raw_data_path) if f.lower().endswith('.csv')]
    df_list_all = [pd.read_csv(raw_data_path + file) for file in dir_list]

    # get implicit task data
    col_implicit = ["participant", "ProlificID", "expName", "imageA", "imageB", "key_resp_im.keys", "random_n",
                    "key_resp_im.rt", "trials.thisRepN", "trials.thisTrialN"]

    data_all = pd.concat([
        df[col_implicit].dropna(subset=["trials.thisTrialN"]) for df in df_list_all])


    insert_new_col_from_two_cols(data_all, "key_resp_im.keys", "random_n", "resp", get_resp)
    insert_new_col(data_all, "imageA", "impactA", lambda x: impact_mapping.get(x))
    insert_new_col(data_all, "imageB", "impactB", lambda x: impact_mapping.get(x))
    insert_new_col_from_two_cols(data_all, "impactA", "impactB", "correctAns", get_correct_ans)
    insert_new_col_from_two_cols(data_all, "correctAns", "resp", "if_resp_correct", get_correct_wrong_index)
    data_all["task_order"] = task_order

    # update col participant, remove col ProlificID
    data_all["participant"] = data_all["participant"].astype(str) + "_" + data_all["ProlificID"].astype(str)
    data_all.drop(columns=["ProlificID"], inplace=True)

    return data_all



# read data
PATH_DATA_ie = "../../data/ie_data/"
PATH_DATA_ei = "../../data/ei_data/"

data_ie = process_raw(PATH_DATA_ie, 'ie')
data_ei = process_raw(PATH_DATA_ei, 'ei')

data_combined = pd.concat([data_ie, data_ei], ignore_index=True)

data_combined_no_child = data_combined[(data_combined["imageA"] != "images/child.png") & (data_combined["imageB"] != "images/child.png")]
# write to excel
write_to_csv = False
if write_to_csv:
    data_combined.to_csv("implicitdata.csv", index = False)
    data_combined_no_child.to_csv("implicitdata_nochild.csv", index = False)