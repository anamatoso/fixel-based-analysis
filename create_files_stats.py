import os
import sys

def write_matrix_to_txt(matrix, output_file):
    """Write a matrix into a text file

    Args:
        matrix (list of lists): matrix that will be turned into a text file
        output_file (string): path to output text file
    """

    # Open the file in write mode
    with open(output_file, 'w') as f:
        # Iterate over each row in the matrix
        for row in matrix:
            # Convert each element to a string and join them with a space delimiter
            row_string = ' '.join(map(str, row))
            # Write the row to the file
            f.write(row_string + '\n')

def remove_zero_columns(matrix):
    """_summary_

    Args:
        matrix (list of lists): matrix

    Returns:
        list of lists: matrix without the columns of zeros
    """

    # Get the number of columns in the matrix
    num_columns = len(matrix[0])

    # Find the columns to remove
    columns_to_remove = [i for i in range(num_columns) if all(row[i] == 0 for row in matrix)]

    # Remove the columns from the matrix
    updated_matrix = [[row[i] for i in range(num_columns) if i not in columns_to_remove] for row in matrix]

    return updated_matrix

# Directory containing the filenames
cwd= os.getcwd()
directory = cwd+'/subjects'

# Select comparison, metrics and suffix to analyse comparison
comp=sys.argv[1]
metric=sys.argv[2]
suf=sys.argv[3]

# Resolve suffix
if not suf == "":
    suffix="_"+suf
else:
    suffix=suf

# Get names of groups from comparison
if comp ==  "midinter":
    group1 = "midcycle"
    group2 = "interictal"
elif comp ==  "midpre":
    group1 = "midcycle"
    group2 = "premenstrual"
elif comp ==  "preict":
    group1 = "premenstrual"
    group2 = "ictal"
else:
    group1 = "interictal"
    group2 = "ictal"


# Define variables
design_matrix = [] # List to store the design matrix rows
files=[] # List to store the filenames for the files text file
subjects=[filename.split('_')[0].split('-')[1] for filename in os.listdir(directory) if filename.startswith('sub') and (filename.endswith(group1) or filename.endswith(group2))] # List of subject names from comparison (has duplicates)
subjects=list(set(subjects)) # List of subject names from comparison without duplicates


# Iterate over the chosen files in the subjects directory
for filename in os.listdir(directory):

    # Only select files from the comparison
    if filename.startswith('sub') and (filename.endswith(group1) or filename.endswith(group2)):  

        # Extract the subject, group, and session information from the filename
        subject = filename.split('_')[0].split('-')[1]
        group = '1' if group1 in filename else '0'
        session = '1' if group2 in filename else '0'
        
        # Make subjects columns
        people = [str(int(subject==subjects[i])) for i in range(len(subjects))]

        # Create a row for the design matrix and for the files
        row = [1, group, session] + people
        design_matrix.append(row)
        files.append(["template" + suffix + "/" + metric + "/" + filename + ".mif"])

# Create txt file of design matrix
matrix=remove_zero_columns(design_matrix)
write_matrix_to_txt(matrix, cwd+"/text_files/design_matrix_"+ comp +".txt")

# Create contrast matrix
contrast_matrix=[
    [0, 1, -1] + [0 for i in range(len(people))],
    [0, -1, 1] + [0 for i in range(len(people))]
]

# Create txt file of contrast matrix an files
write_matrix_to_txt(contrast_matrix, cwd+"/text_files/contrast_matrix.txt")
write_matrix_to_txt(files, cwd+"/text_files/files_" + metric + "_" + comp + ".txt")
