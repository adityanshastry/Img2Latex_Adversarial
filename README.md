# Img2Latex_Adversarial

This project generates adversarial examples for the img2latex task, specifically for the model [im2markup](https://arxiv.org/pdf/1609.04938v1.pdf). The optimization based method is used for generating the adversarial examples. More details are provided in the report present in the repository.

Requirements
-----
The requirements are present in the readme for repo [im2markup](https://github.com/harvardnlp/im2markup).

Setup
-----
1. Create a new experiment
  ```
  bash scripts/experiments/create_experiments.sh -e <EXPERIMENT_NAME> -d <DATASET_NAME>
  ```
  After this, a new experiment will be created where the source code and the data will be copied will be copied, and the new paths displayed
  
2. Run the training script
  ```
  bash scripts/experiments/run_adversarial.sh -e <EXPERIMENT_NAME> -d <DATASET_NAME>
  ```
  
  The below parameters can be adjusted according to need:
  ```
  -phase - Available values are targeted_adversarial, non_targeted_adversarial
  -learning_rate
  -num_epochs
  -initialize_perturbations - If set, the perturbations are initialized to zero before training. Else, the last available perturbations are loaded
  -backup_epochs - At how many epochs backups are to be taken
  ```
  For every `-backup_epochs` epochs, the backups are stored in the directory `adversarial_perturbations` in the experiment's data directory

3. Run the test script
  ```
  bash scripts/experiments/run_test.sh -e <EXPERIMENT_NAME> -d <DATASET_NAME>
  ```
  
  The below parameters can be adjusted according to need:
  ```
  -output_dir - folder where the results should be stored
  -perturbations - If present, the inference is performed by including the computed adversarial perturbations. Else, inference is poerformed with the original images
  ```
  The results are stored in the file results.txt, in the folder mentioned in `-output_dir` parameter. The format of the result is mentioned in the repo [im2markup](https://github.com/harvardnlp/im2markup)
