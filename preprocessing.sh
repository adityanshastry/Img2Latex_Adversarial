#!/bin/bash

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -d|--datapath)
    DATAPATH="$2"
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

if [ "${#DATAPATH}" -eq "0" ]; then
        echo "No DATAPATH named. Exiting"
        exit 1
fi

mkdir ${DATAPATH}/adversarial_perturbations

python scripts/preprocessing/preprocess_images.py --input-dir ${DATAPATH}/images --output-dir ${DATAPATH}/images_processed

python scripts/preprocessing/preprocess_formulas.py --mode normalize --input-file ${DATAPATH}/formulas.lst --output-file ${DATAPATH}/formulas.norm.lst

python scripts/preprocessing/preprocess_filter.py --filter --image-dir ${DATAPATH}/images_processed --label-path ${DATAPATH}/formulas.norm.lst --data-path ${DATAPATH}/train.lst --output-path ${DATAPATH}/train_filter.lst

python scripts/preprocessing/preprocess_filter.py --filter --image-dir ${DATAPATH}/images_processed --label-path ${DATAPATH}/formulas.norm.lst --data-path ${DATAPATH}/validate.lst --output-path ${DATAPATH}/validate_filter.lst

python scripts/preprocessing/preprocess_filter.py --filter --image-dir ${DATAPATH}/images_processed --label-path ${DATAPATH}/formulas.norm.lst --data-path ${DATAPATH}/test.lst --output-path ${DATAPATH}/test_filter.lst

python scripts/preprocessing/generate_latex_vocab.py --data-path ${DATAPATH}/train_filter.lst --label-path ${DATAPATH}/formulas.norm.lst --output-file ${DATAPATH}/vocab.txt

echo "Preprocessing completed"

