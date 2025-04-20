import os
import pandas as pd

from src.common.process import insert_new_col_from_two_cols, insert_new_col, get_resp, \
    get_correct_ans, get_correct_wrong_index

# read data
PATH_DATA = "../../data/ie_data/"
dir_list = os.listdir(PATH_DATA)
# all data files
dir_list = [f for f in os.listdir(PATH_DATA) if f.lower().endswith('.csv')]

df_list_all = [pd.read_csv(PATH_DATA + file) for file in dir_list]

# get implicit task data

col_implicit = ["participant", "expName", "imageA", "imageB", "key_resp_im.keys", "random_n",
                "key_resp_im.rt", "trials.thisRepN", "trials.thisTrialN"]

df_implicit_list = list()
for data in df_list_all:
    # get implicit task relevant cols
    data_implicit = data[col_implicit]
    # clean up the rows
    data_implicit = data_implicit.dropna(subset=["trials.thisTrialN"])
    df_implicit_list.append(data_implicit)

data_implicit = pd.concat(df_implicit_list)


# get participants resp
insert_new_col_from_two_cols(data_implicit, "key_resp_im.keys", "random_n", "resp", get_resp)

# add impact of each actions
actions1 = data_implicit["imageA"].unique().tolist()
actions2 = data_implicit["imageB"].unique().tolist()
actions = list(set(actions1 + actions2))

impact_mapping = {
    actions[0]: 0.247,
    actions[1]: 0.21,
    actions[2]: 117.7,
    actions[3]: 1.6,
    actions[4]: 0.17,
    actions[5]: 1.4,
    actions[6]: 1.6,
    actions[7]: 3.08,
    actions[8]: 0.2125,
    actions[9]: 2.21,
}


def get_impact_value(action):
    return impact_mapping.get(action)


insert_new_col(data_implicit, "imageA", "impactA", get_impact_value)
insert_new_col(data_implicit, "imageB", "impactB", get_impact_value)

# add correct answer

insert_new_col_from_two_cols(data_implicit, "impactA", "impactB", "correctAns", get_correct_ans)


# add correct/wrong index


insert_new_col_from_two_cols(data_implicit, "correctAns", "resp", "if_resp_correct",
                             get_correct_wrong_index)
# write to excel
write_to_excel = False
if write_to_excel:
    data_implicit.to_excel("ie_implicitdata.xlsx", index = False)