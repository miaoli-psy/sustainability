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


def get_correct_ans(impactA, impactB):
    if impactA > impactB:
        currect_ans = "A"
    else:
        currect_ans = "B"
    return currect_ans


def get_correct_wrong_index(correctAns, reprotedAns):
    if correctAns == reprotedAns:
        return 1
    else:
        return 0
