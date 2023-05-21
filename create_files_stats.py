import os
import sys


def write_matrix_to_txt(m, output_file):
    # Open the file in write mode
    with open(output_file, 'w') as f:
        # Iterate over each row in the matrix
        for r in m:
            # Convert each element to a string and join them with a space delimiter
            row_string = ' '.join(map(str, r))
            # Write the row to the file
            f.write(row_string + '\n')


def remove_zero_columns(m):
    # Get the number of columns in the matrix
    num_columns = len(m[0])

    # Find the columns to remove
    columns_to_remove = [i for i in range(num_columns) if all(r[i] == 0 for r in m)]

    # Remove the columns from the matrix
    updated_matrix = [[r[i] for i in range(num_columns) if i not in columns_to_remove] for r in m]

    return updated_matrix


# Directory containing the filenames
cwd = os.getcwd()
directory = cwd + '/subjects'

# Select comparison and groups to analyse comparison
# comp = input("Choose comparison [midinter| midpre | preict | interpre]: ")
comp = sys.argv[1]
metric = sys.argv[2]
suf = sys.argv[3]

if not suf == "":
    suffix = "_"+suf
else:
    suffix = suf

if comp == "midinter":
    group1 = "midcycle"
    group2 = "interictal"
elif comp == "midpre":
    group1 = "midcycle"
    group2 = "premenstrual"
elif comp == "preict":
    group1 = "premenstrual"
    group2 = "ictal"
else:
    group1 = "interictal"
    group2 = "ictal"


# List to store the design matrix rows
design_matrix = []
subjects = [filename.split('_')[0].split('-')[1] for filename in os.listdir(directory) if filename.startswith('sub') and (filename.endswith(group1) or filename.endswith(group2))]
subjects = list(set(subjects))
files = []

# Iterate over the chosen files in the directory
for filename in os.listdir(directory):
    if filename.startswith('sub') and (filename.endswith(group1) or filename.endswith(group2)):

        # Extract the subject, group, and session information from the filename
        subject = filename.split('_')[0].split('-')[1]
        group = '1' if group1 in filename else '0'
        session = '1' if group2 in filename else '0'

        # Make subjects columns
        people = [str(int(subject == subjects[i])) for i in range(len(subjects))]

        # Create a row for the design matrix
        row = [1, group, session] + people
        design_matrix.append(row)
        files.append(["template" + suffix + "/" + metric + "/" + filename + ".mif"])

# Create txt file
matrix = remove_zero_columns(design_matrix)
write_matrix_to_txt(matrix, cwd+"/text_files/design_matrix_" + comp + ".txt")


contrast_matrix = [
    [0, 1, -1] + [0 for i in range(len(subjects))],
    [0, -1, 1] + [0 for i in range(len(subjects))]
]

write_matrix_to_txt(contrast_matrix, cwd+"/text_files/contrast_matrix.txt")
write_matrix_to_txt(files, cwd+"/text_files/files_" + metric + "_" + comp + ".txt")
