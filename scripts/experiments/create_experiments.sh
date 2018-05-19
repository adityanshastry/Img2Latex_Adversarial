#/bin/bash

CODE_SOURCE=/path/where/source/code/present
DATA_DIR=/path/where/data/present

EXPERIMENTS_SOURCE=/path/where/experiment/code/should/be/copied


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

echo "Creating files for experiment ${EXPERIMENT}, with dataset ${DATASET}"


rm -rf ${EXPERIMENTS_SOURCE}/${EXPERIMENT}
rm -rf ${DATA_DIR}/experiments/${EXPERIMENT}

echo "Creating directories for source and data files"
mkdir ${EXPERIMENTS_SOURCE}/${EXPERIMENT}
mkdir -p ${DATA_DIR}/experiments/${EXPERIMENT}/${DATASET}

echo "Copying source and data files"
cp -R ${CODE_SOURCE}/. ${EXPERIMENTS_SOURCE}/${EXPERIMENT}/
cp -R ${DATA_DIR}/${DATASET}/. ${DATA_DIR}/experiments/${EXPERIMENT}/${DATASET}/








