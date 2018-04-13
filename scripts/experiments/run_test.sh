#!/bin/bash

rm log.txt

DATA_DIR=/home/ashastry/data/Img2Latex_Adversarial

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -e|--experiment)
    EXPERIMENT="$2"
    shift # past argument
    shift # past value
    ;;
    -d|--dataset)
    DATASET="$2"
    shift # past argument
    shift # past value
    ;;
    --default)
    DEFAULT=YES
    shift # past argument
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [ "${#EXPERIMENT}" -eq "0" ]; then
        echo "No EXPERIMENT named. Exiting"
        exit 1
fi

if [ "${#DATASET}" -eq "0" ]; then
        echo "No DATASET named. Exiting"
        exit 1
fi



th src/train.lua -phase test -gpu_id 1 -load_model -model_dir model/latex -visualize \
-data_base_dir ${DATA_DIR}/experiments/${EXPERIMENT}/${DATASET}/images_processed/ \
-data_path ${DATA_DIR}/experiments/${EXPERIMENT}/${DATASET}/test_filter.lst \
-label_path ${DATA_DIR}/experiments/${EXPERIMENT}/${DATASET}/formulas.norm.lst \
-output_dir results \
-max_num_tokens 500 -max_image_width 800 -max_image_height 800 \
-batch_size 5 -beam_size 5 -perturbations 

