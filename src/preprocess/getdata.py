import os
import pandas as pd


def insert_new_col_from_two_cols(input_df: pd.DataFrame, old_col1: str, old_col2: str, new_col: str,
                                 func_name):
    cols = input_df.columns
    if (old_col1 in cols) and (old_col2 in cols):
        input_df[new_col] = input_df.apply(lambda x: func_name(x[old_col1], x[old_col2]), axis=1)
    else:
        raise Exception(f"Warning: missing {old_col1} or {old_col2}")


def insert_new_col(input_df: pd.DataFrame, old_col: str, new_col: str, func_name):
    if old_col in input_df.columns:
        col_index = input_df.columns.get_loc(old_col)
        input_df.insert(col_index, new_col, input_df[old_col].map(func_name))
    else:
        raise Exception(f"Warning: missing {old_col}")


# read data
PATH_DATA = "../../data/ie_data/"
dir_list = os.listdir(PATH_DATA)
# all data files
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

def get_resp(choice_psychopy, n):
    if n < 0.5:
        if choice_psychopy == "left":
            resp = "A"
        else:
            resp = "B"
    else:
        if choice_psychopy == "left":
            resp = "B"
        else:
            resp = "A"
    return resp


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

def get_correct_ans(impactA, impactB):
    if impactA > impactB:
        currect_ans = "A"
    else:
        currect_ans = "B"
    return currect_ans

insert_new_col_from_two_cols(data_implicit, "impactA", "impactB", "correctAns", get_correct_ans)


# add correct/wrong index

def get_correct_wrong_index(correctAns, reprotedAns):
    if correctAns == reprotedAns:
        return 1
    else:
        return 0


insert_new_col_from_two_cols(data_implicit, "correctAns", "resp", "if_resp_correct", get_correct_wrong_index)
# write to excel
write_to_excel = False
if write_to_excel:
    data_implicit.to_excel("ie_implicitdata.xlsx", index = False)