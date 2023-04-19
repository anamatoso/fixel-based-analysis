#!/bin/bash
set -e

# TO DO: create files.txt, design_matrix.txt and contrast_matrix.txt

# Perform statistical analysis of FD, FC, and FDC
fixelcfestats fd_smooth/ files.txt design_matrix.txt contrast_matrix.txt matrix/ stats_fd/
fixelcfestats log_fc_smooth/ files.txt design_matrix.txt contrast_matrix.txt matrix/ stats_log_fc/
fixelcfestats fdc_smooth/ files.txt design_matrix.txt contrast_matrix.txt matrix/ stats_fdc/


