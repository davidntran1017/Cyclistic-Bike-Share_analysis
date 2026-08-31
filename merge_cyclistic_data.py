import pandas as pd
import glob
import os

folder_path = r"C:\Users\david\OneDrive - Temple University\Documents\coursera files\Case Study 1 data"

output_filename = "cyclistic_12_months_raw.csv"
output_path = os.path.join(folder_path, output_filename)

csv_files = glob.glob(
    os.path.join(folder_path, "**", "*.csv"),
    recursive=True
)

csv_files = [
    f for f in csv_files
    if "__MACOSX" not in f
    and os.path.basename(f) != output_filename
]

print(f"Found {len(csv_files)} source CSV files")

df_list = []

for file in csv_files:
    print(f"Reading: {os.path.basename(file)}")
    temp_df = pd.read_csv(file)
    df_list.append(temp_df)

combined_df = pd.concat(df_list, ignore_index=True)

combined_df.to_csv(output_path, index=False)

print(f"\nCombined rows: {len(combined_df):,}")
print(f"Saved to:\n{output_path}")