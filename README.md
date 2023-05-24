# fixel-based-analysis

This repository consists of the code created in order to perform the fixel based analysis of MRtrix in diffusion data. In this work, a comparison of the fixel metrics was made not only between controls and patients but also longitudinally between different stages of the menstrual cycle.

To run this code, you only need to sequentially run the scripts with numbers in the beginning of their name. If you want to restrict the statistical analysis to a specific mask, the `atlas2temp.sh` script must be run before the `05_statistical_analysis.sh` file.

Additionally, the `population_template_ana` file was modified from the original `population_template` from MRtrix3 because there was consistently a permissions error before a mrregister step and so I added a line to change permissions to allow all before this step (see the [line in question](https://github.com/anamatoso/fixel-based-analysis/blob/0f51e81e7a31194940dbcf9d65e2bd4bf48d4026/population_template_ana#L1326)).
