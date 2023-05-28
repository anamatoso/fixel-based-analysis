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
if len(sys.argv)==4:
    suf=sys.argv[3]
else:
    suf=""


# Resolve suffix
if not suf == "":
    suffix="_"+suf
else:
    suffix=suf

# Get names of groups from comparison
if comp ==  "midinter":
    group1 = "-midcycle"
    group2 = "-interictal"
elif comp ==  "midprem":
    group1 = "-midcycle"
    group2 = "-premenstrual"
elif comp ==  "premict":
    group1 = "-premenstrual"
    group2 = "-ictal"
elif comp ==  "interict":
    group1 = "-interictal"
    group2 = "-ictal"
elif comp ==  "prempost":
    group1 = "-premenstrual"
    group2 = "-postictal"
elif comp ==  "prempre":
    group1 = "-premenstrual"
    group2 = "-preictal"
elif comp ==  "ictpost":
    group1 = "-ictal"
    group2 = "-postictal"
elif comp ==  "postinter":
    group1 = "-postictal"
    group2 = "-interictal"
elif comp ==  "preict":
    group1 = "-preictal"
    group2 = "-ictal"
elif comp ==  "preinter":
    group1 = "-preictal"
    group2 = "-interictal"
elif comp ==  "prepost":
    group1 = "-preictal"
    group2 = "-postictal"

# Check whether it is a paired or unpaired design
if comp == "midinter" or comp == "premict" or comp == "prempost" or comp == "prempre":
    paired=False
else:
    paired=True

# Define variables
design_matrix = [] # List to store the design matrix rows
files=[] # List to store the filenames for the files text file

# Define list of subjects: paired of unpaired
if not paired: # unpaired
    subjects=[filename.split('_')[0].split('-')[1] for filename in os.listdir(directory) if filename.startswith('sub') and (filename.endswith(group1) or filename.endswith(group2))] # List of subject names from comparison (has duplicates)
    subjects=list(set(subjects)) # List of subject names from comparison without duplicates
else:
    subjects=[filename.split('_')[0].split('-')[1] for filename in os.listdir(directory) if filename.startswith('sub') and (filename.endswith(group1) or filename.endswith(group2))] # List of subject names from comparison (has duplicates)
    subjects_common=[i for i in subjects if subjects.count(i)>1] # List of subject that have both sessions (and so appear more then once)
    subjects=list(set(subjects_common)) # List of subject names from comparison without duplicates


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

        # Create a row for the design matrix and for the files (different depending on if it is paired or not)
        if not paired: # unpaired
            row = [group, session]
        else: # paired
            g = 1 if group == '1' else -1
            row = [g] + people

        # Add subject to design matrix and to files text file
        design_matrix.append(row)
        files.append(["template" + suffix + "/" + metric + "_smooth/" + filename + ".mif"])

# Create txt file of design matrix
matrix=remove_zero_columns(design_matrix)
write_matrix_to_txt(matrix, cwd + "/template" + suffix + "/text_files/design_matrix_"+ comp +".txt")

# Create contrast matrices
contrast_matrix_unpaired=[
    [1, -1],
    [-1, 1]
]
contrast_matrix_paired=[
    [1] + [0 for i in range(len(people))],
    [-1] + [0 for i in range(len(people))]
]
# Create txt file of contrast matrix an files
write_matrix_to_txt(contrast_matrix_unpaired, cwd+ "/template" + suffix + "/text_files/contrast_matrix_unpaired.txt")
write_matrix_to_txt(contrast_matrix_paired, cwd+ "/template" + suffix + "/text_files/contrast_matrix_paired.txt")
write_matrix_to_txt(files, cwd + "/template" + suffix +"/text_files/files_" + metric + "_" + comp + ".txt")
