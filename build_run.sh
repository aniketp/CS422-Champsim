#!/bin/bash

TRACES=(  "641.leela_s-1052B.champsimtrace.xz" "641.leela_s-1083B.champsimtrace.xz" "641.leela_s-149B.champsimtrace.xz" "641.leela_s-334B.champsimtrace.xz" "641.leela_s-602B.champsimtrace.xz" "641.leela_s-800B.champsimtrace.xz" "641.leela_s-862B.champsimtrace.xz")

BINARY="group2"

if [ "$#" -lt 2 ]; then
    echo "Illegal number of parameters"
    echo "Usage: ./build_run.sh [NUMBER] [BUILD] [predictor(optional) default:group2]"
    echo "NUMBER: 0-8, BUILD: 0(run) or 1(build and run)"
    echo "0: run all 7 traces"
    for i in $(seq 1 7)
    do
        echo "$i: trace- ${TRACES[$i -1]}"
    done
    echo "8: run all the traces in dpc3_traces"
    exit 1
fi

if [ ! -z "${3}" ]
  then
    BINARY=${3}
fi

NUM=${1}
BUILD=${2}
TRACE_DIR=$PWD/dpc3_traces
BINARY_FILE="$BINARY-no-no-no-no-lru-1core"
N_WARM=50
N_SIM=200
RESULT="result_${BINARY}_$(date +%s).txt"

case $BUILD in
    0) 
        echo "using old $BINARY file"
      ;;
    1)
        echo "building new $BINARY file..."
        ./build_champsim.sh $BINARY no no no no lru 1
      ;;
    *)
        echo "[ERROR] Invalid BUILD number"
        exit 1
esac

run() {
    echo "running trace: $1"
    ./run_champsim.sh ${BINARY_FILE} ${N_WARM} ${N_SIM} ${1}
    echo ${1} >> $RESULT
    (cat results_${N_SIM}M/${1}-$BINARY-no-no-no-no-lru-1core.txt | grep "CPU 0 cumulative IPC:\|CPU 0 Branch Prediction Accuracy:" ) >> $RESULT
    (cat results_${N_SIM}M/${1}-$BINARY-no-no-no-no-lru-1core.txt | grep -A 8 "Branch types" ) >> $RESULT
    echo "---------------------------------------" >> $RESULT
}

case $NUM in

  0)
    echo " running all 7 traces..."
    for i in "${TRACES[@]}"
    do
	    run $i
    done
    ;;
  [1-7])
    run ${TRACES[ $NUM - 1 ]}
    ;;
  8)
    echo "running all traces from dpc3_traces..."
    TRACES=($(ls ${TRACE_DIR}))
    for i in "${TRACES[@]}"
    do
	    run $i
    done
    ;;
  *)
    echo "[ERROR] Invalid TRACE number"
    exit 1
esac
