import os
import pandas as pd
import numpy as np
import re

os.chdir('/Users/mac/Desktop/project')


#--------------ECONOMETRICS_DATASET.csv--------------
file_path_1 = 'ECONOMETRICS_DATASET.csv'
output_path_1 = 'econometrics_dataset_cleaned.csv'
df = pd.read_csv(file_path_1, header = None)
df = df.apply(lambda x: x.str.replace(',', '') if x.dtype == "object" else x)

# Fill empty column names
df.iloc[0] = df.iloc[0].replace('', np.nan).ffill()

# Keep the first line only
df.iloc[0] = df.iloc[0].astype(str).str.split('\n').str[0]

# Map FY to actual years
fy = {'FY0': 2024, 'FY-1': 2023, 'FY-2': 2022, 'FY-3': 2021,
      'FY-4': 2020, 'FY-5': 2019, 'FY-6': 2018, 'FY-7': 2017}

df.iloc[1] = df.iloc[1].fillna(0).replace(fy)

# Merge first and second rows
df.iloc[0] = df.iloc[0] + '_' + df.iloc[1].astype(str)
df.iloc[0] = df.iloc[0].str.replace('_0', '', regex=True)

# Set the first row as header
df.columns = df.iloc[0]
df = df.drop(index=[0, 1]).reset_index(drop=True)

# Fill missing values in DIR Diversity Score with mean
df.iloc[:, 3:11] = df.iloc[:, 3:11].apply(pd.to_numeric, errors='coerce')
df.iloc[:, 3:11] = df.iloc[:, 3:11].apply(lambda row: row.fillna(row.mean()), axis=1)
# Drop empty or 0 rows
df = df[df.iloc[:, 3] != 0]
df = df[df.iloc[:, 3].notna()]

# Fill missing values in DIR Inclusion Score with mean
df.iloc[:, 11:19] = df.iloc[:, 11:19].apply(pd.to_numeric, errors='coerce')
df.iloc[:, 11:19] = df.iloc[:, 11:19].apply(lambda row: row.fillna(row.mean()), axis=1)
df = df[df.iloc[:, 11] != 0]
df = df[df.iloc[:, 11].notna()]

# Fill missing values in EBITDA with mean
df.iloc[:, 19:27] = df.iloc[:, 19:27].replace('%', '', regex=True).astype(float)
df.iloc[:, 19:27] = df.iloc[:, 19:27].apply(pd.to_numeric, errors='coerce')
df.iloc[:, 19:27] = df.iloc[:, 19:27].apply(lambda row: row.fillna(row.mean()), axis=1)
df = df[df.iloc[:, 19] != 0]
df = df[df.iloc[:, 19].notna()]

# Fill missing values in Total Capital with mean
print(df.iloc[:, 27:35].head())
df.iloc[:, 27:35] = df.iloc[:, 27:35].apply(pd.to_numeric, errors='coerce')
df.iloc[:, 27:35] = df.iloc[:, 27:35].apply(lambda row: row.fillna(row.mean()), axis=1)
df = df[df.iloc[:, 27] != 0]
df = df[df.iloc[:, 27].notna()]

# Fill missing values in Employees, Prd/Prd Avg, FY with mean
df.iloc[:, 35:43] = df.iloc[:, 35:43].apply(pd.to_numeric, errors='coerce')
df.iloc[:, 35:43] = df.iloc[:, 35:43].apply(lambda row: row.fillna(row.mean()), axis=1)
df = df[df.iloc[:, 35] != 0]
df = df[df.iloc[:, 35].notna()]

# Fill missing values in Policy Diversity and Opportunity with FALSE
df.iloc[:, 43:51] = df.iloc[:, 43:51].apply(lambda row: row.fillna('FALSE'), axis=1)
df = df[df.iloc[:, 43].notna()]

# Fill missing values in Training Hours Total with mean
df.iloc[:, 51:59] = df.iloc[:, 51:59].apply(pd.to_numeric, errors='coerce')
df.iloc[:, 51:59] = df.iloc[:, 51:59].apply(lambda row: row.fillna(row.mean()), axis=1)
df = df[df.iloc[:, 51] != 0]
df = df[df.iloc[:, 51].notna()]

# Fill missing values in Board Cultural Diversity, Percent with mean
df.iloc[:, 59:67] = df.iloc[:, 59:67].apply(pd.to_numeric, errors='coerce')
df.iloc[:, 59:67] = df.iloc[:, 59:67].apply(lambda row: row.fillna(row.mean()), axis=1)
df = df[df.iloc[:, 59] != 0]
df = df[df.iloc[:, 59].notna()]

# Drop a redundant column, originally called 'Board Cultural Diversity, Percent Score'
df = df.drop(df.columns[67], axis=1)

# Fill missing values in Board Gender Diversity, Percent Score with mean
df.iloc[:, 67:75] = df.iloc[:, 67:75].apply(pd.to_numeric, errors='coerce')
df.iloc[:, 67:75] = df.iloc[:, 67:75].apply(lambda row: row.fillna(row.mean()), axis=1)
df = df[df.iloc[:, 67] != 0]
df = df[df.iloc[:, 67].notna()]

# Fill missing values in Executives Cultural Diversity Score with mean
df.iloc[:, 75:83] = df.iloc[:, 75:83].apply(pd.to_numeric, errors='coerce')
df.iloc[:, 75:83] = df.iloc[:, 75:83].apply(lambda row: row.fillna(row.mean()), axis=1)
df = df[df.iloc[:, 75] != 0]
df = df[df.iloc[:, 75].notna()]

# Fill missing values in Executive Members Gender Diversity, Percent Score with mean
df.iloc[:, 83:91] = df.iloc[:, 83:91].apply(pd.to_numeric, errors='coerce')
df.iloc[:, 83:91] = df.iloc[:, 83:91].apply(lambda row: row.fillna(row.mean()), axis=1)
df = df[df.iloc[:, 83] != 0]
df = df[df.iloc[:, 83].notna()]

# Fill missing values in Board Size with mean
df.iloc[:, 91:99] = df.iloc[:, 91:99].apply(pd.to_numeric, errors='coerce')
df.iloc[:, 91:99] = df.iloc[:, 91:99].apply(lambda row: row.fillna(row.mean()), axis=1)
df = df[df.iloc[:, 91] != 0]
df = df[df.iloc[:, 91].notna()]

# Fill missing values in Women Employees Score with mean
df.iloc[:, 99:107] = df.iloc[:, 99:107].apply(pd.to_numeric, errors='coerce')
df.iloc[:, 99:107] = df.iloc[:, 99:107].apply(lambda row: row.fillna(row.mean()), axis=1)
df = df[df.iloc[:, 99] != 0]
df = df[df.iloc[:, 99].notna()]

# Save cleaned dataset
df.to_csv(output_path_1, index = False)



#-------------panel data---------------
output_path_2 = 'panel_data_1.csv'
# Identify year from column names
year = re.compile(r'_(\d{4})$')
year_cols = [col for col in df.columns if year.search(col)]

# Reshape data into long format
long = df.melt(id_vars = [col for col in df.columns if col not in year_cols],
                      value_vars = year_cols,
                      var_name = "Variable",
                      value_name = "Value")

# Extract year from column name
long["Year"] = long["Variable"].str.extract(r'_(\d{4})$')

# Remove year in variable name
long["Variable"] = long["Variable"].str.replace(r'_\d{4}$', '', regex=True)

long['Value'] = pd.to_numeric(long['Value'], errors='coerce')

# Pivot to get variables in the same column for each company and year
panel = long.pivot_table(index = ['Identifier (RIC)', 'Company Name',
                                  'GICS Industry Name', 'Year'],
                         columns = 'Variable',
                         values = 'Value').reset_index()

panel.to_csv(output_path_2, index=False)