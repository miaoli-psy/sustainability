import os
import pandas as pd

# col names mapping
slider_targets = {
    "slider_1.response": "sex",
    "slider_2.response": "sexual_orientation",
    "slider_3.response": "age",
    "slider_4.response": "education",
    "slider_5.response": "race",
    "slider_7.response": "employment_status",
    "slider_8.response": "political_orientation",
    "slider_9.response": "diet",
    "slider_10.response": "air_travel_freq",
    "slider_11.response": "num_children",
    "slider_12.response": "car_ownership",
}

#  value mapping
value_mapping = {
    "sex": {
        "1": "Male", "2": "Female", "3": "Other", "4": "Prefer not to say"
    },
    "sexual_orientation": {
        "1": "Heterosexual", "2": "Homosexual", "3": "Bisexual", "4": "Asexual", "5": "Other"
    },
    "age": {
        "1": "18-25", "2": "26-30", "3": "31-35", "4": "36-40", "5": "41-45",
        "6": "46-50", "7": "51-55", "8": "56-60", "9": "61-65", "10": "66 and more"
    },
    "education": {
        "1": "No formal qualifications", "2": "Secondary education", "3": "High school diploma",
        "4": "Technical/community college", "5": "Undergraduate degree",
        "6": "Graduate degree", "7": "Doctorate degree", "8": "Don't know / not applicable"
    },
    "race": {
        "1": "White/Caucasian", "2": "African American", "3": "Hispanic", "4": "Asian", "5": "Native American",
        "6": "Pacific Islander", "7": "Jewish", "8": "Arab", "9": "Other"
    },
    "employment_status": {
        "1": "Full-Time", "2": "Part-Time", "3": "Starting new job soon",
        "4": "Unemployed (job seeking)", "5": "Not in paid work", "6": "Other"
    },
    "diet": {
        "1": "Meat eater / Omnivorous", "2": "Pescetarian", "3": "Flexitarian",
        "4": "Vegetarian", "5": "Vegan"
    },
    "air_travel_freq": {
        "1": "Flights: 0",
        "2": "Flights: 1-2",
        "3": "Flights: 3-4",
        "4": "Flights: 4-5",
        "5": "Flights: 6+"
    },

    "num_children": {
        "1": "0", "2": "1", "3": "2", "4": "3", "5": "4", "6": "5", "7": "6", "8": "7",
        "9": "8", "10": "9", "11": "10 or more", "12": "Rather not say"
    },
    "car_ownership": {
        "1": "Yes - Gas", "2": "Yes - Diesel", "3": "Yes - Hybrid",
        "4": "Yes - Electric/EV", "5": "No"
    }
}

# get the first non-NaN value in a column
def extract_first_non_nan(df, colname):
    if colname in df.columns:
        val = df[colname].dropna()
        return val.iloc[0] if not val.empty else None
    return None


def process_life_questions(path_data, task_order):
    all_participant_rows = []
    files = [f for f in os.listdir(path_data) if f.lower().endswith(".csv")]
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)

    # loop csv, each file contains data from 1 participant
    for file in files:
        df = pd.read_csv(os.path.join(path_data, file))

        participant = extract_first_non_nan(df, "participant")
        prolific_id = extract_first_non_nan(df, "ProlificID")

        row_data = {
            "participant": participant,
            "ProlificID": prolific_id,
            "task_order": task_order,
        }
        # get values from all life questions
        for raw_col, new_col in slider_targets.items():
            value = extract_first_non_nan(df, raw_col)
            row_data[new_col] = value

        all_participant_rows.append(row_data)

    return pd.DataFrame(all_participant_rows)


if __name__ == "__main__":
    PATH_IE = "../../data/ie_data/"
    PATH_EI = "../../data/ei_data/"

    df_ie = process_life_questions(PATH_IE, task_order="ie")
    df_ei = process_life_questions(PATH_EI, task_order="ei")

    df_all = pd.concat([df_ie, df_ei], ignore_index=True)

    # value mapping
    for col, mapping in value_mapping.items():
        if col in df_all.columns:
            def map_value(x):
                if pd.isna(x):
                    return x #leave NaN as-is
                try:
                    # convert int->str to ensure match with maping dict
                    return mapping.get(str(int(float(x))), x)
                except:
                    return x # leave the original value if it cannot be interpreted
            df_all[col] = df_all[col].apply(map_value)

    df_all.to_csv("lq.csv", index=False)

