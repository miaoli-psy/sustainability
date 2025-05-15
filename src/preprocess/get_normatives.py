import os
import pandas as pd

def parse_order_column(value):
    """parse a list-like column that may be a list or string."""
    if isinstance(value, list):
        return value
    elif isinstance(value, str):
        try:
            return eval(value)
        except:
            return []
    else:
        return []

def process_normative_data(path_data, task_order):
    # working path
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)

    # raw data
    files = [f for f in os.listdir(path_data) if f.lower().endswith('.csv')]
    data_list = [pd.read_csv(os.path.join(path_data, f)) for f in files]

    # slider ranges for each normative block
    norm1_sliders = [f'slider_posi_{i}.response' for i in range(12, 22)]  # people
    norm2_sliders = [f'slider_posi_{i}.response' for i in range(23, 33)]  # friends
    norm3_sliders = [f'slider_posi_{i}.response' for i in range(34, 44)]  # family

    # cols
    col_normative = norm1_sliders + norm2_sliders + norm3_sliders + [
        "nor1_order", "nor2_order", "nor3_order", "participant", "ProlificID"
    ]

    all_rows = []

    for df in data_list:
        df = df[col_normative].dropna(how='all', subset=norm1_sliders + norm2_sliders + norm3_sliders)

        for _, row in df.iterrows():
            participant = row["participant"]
            pid = row["ProlificID"]

            norm_sets = [
                ("people", parse_order_column(row["nor1_order"]), norm1_sliders),
                ("friends", parse_order_column(row["nor2_order"]), norm2_sliders),
                ("family", parse_order_column(row["nor3_order"]), norm3_sliders),
            ]

            for norm_type, actions, sliders in norm_sets:
                if len(actions) != len(sliders):
                    continue  # skip if mismatched length

                for action, slider_col in zip(actions, sliders):
                    response = row.get(slider_col)
                    if pd.isna(response):
                        continue  # skip missing responses

                    all_rows.append({
                        "participant": participant,
                        "ProlificID": pid,
                        "task_order": task_order,
                        "norm_type": norm_type,
                        "action": action,
                        "response": response
                    })

    return pd.DataFrame(all_rows)



if __name__ == "__main__":
    PATH_IE = "../../data/ie_data/"
    PATH_EI = "../../data/ei_data/"

    df_ie = process_normative_data(PATH_IE, task_order="ie")
    df_ei = process_normative_data(PATH_EI, task_order="ei")

    df_combined = pd.concat([df_ie, df_ei], ignore_index=True)
    to_csv = True
    if to_csv:
        df_combined.to_csv("datanormatives.csv", index=False)
