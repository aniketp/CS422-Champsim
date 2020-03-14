#!/bin/bash

TRACES=(  "client_005.champsimtrace.xz" "server_004.champsimtrace.xz" "server_018.champsimtrace.xz" "server_027.champsimtrace.xz" "server_037.champsimtrace.xz" )
BINARY="hashed_perceptron"
NUM=-1
BUILD=NO
L1I="group2"
L1D="group2"
L2C="group2"

for i in "$@"
do
case $i in
    -t=*|--trace=*)
    NUM="${i#*=}"
    shift # past argument=value
    ;;
    -b|--build)
    BUILD=YES
    shift # past argument=value
    ;;
    -l1i=*|--l1i_pref=*)
    L1I="${i#*=}"
    shift # past argument=value
    ;;
    -l1d=*|--l1d_pref=*)
    L1D="${i#*=}"
    shift # past argument=value
    ;;
    -l2c=*|--l2c_pref=*)
    L2C="${i#*=}"
    shift # past argument=value
    ;;
    *)
          # unknown option
    ;;
esac
done

if [ $NUM == -1 ]
then
    echo "-t are necessary"
    exit 1
fi

TRACE_DIR=$PWD/dpc3_traces
BINARY_FILE="$BINARY-$L1I-$L1D-$L2C-no-lru-1core"
N_WARM=50
N_SIM=50
RESULT="result_$L1I-$L1D-$L2C-$(date +%s).txt"

if [[ ! -f "./bin/$BINARY_FILE" ]]; then
  BUILD=YES
fi

case $BUILD in
    YES)
        echo "building new $BINARY_FILE file..."
        ./build_champsim.sh $BINARY $L1I $L1D $L2C no lru 1
      ;;
    *)  
        echo "using old $BINARY_FILE file"
esac

run() {
    echo "running trace: $1"
    ./run_champsim.sh ${BINARY_FILE} ${N_WARM} ${N_SIM} ${1}
    echo ${1} >> $RESULT
    (cat results_${N_SIM}M/${1}-$BINARY_FILE.txt | grep "CPU 0 cumulative IPC:\|CPU 0 Branch Prediction Accuracy:" ) >> $RESULT
    (cat results_${N_SIM}M/${1}-$BINARY_FILE.txt | grep -A 8 "Branch types" ) >> $RESULT
    echo "---------------------------------------" >> $RESULT
    echo "output file: $RESULT"
}

case $NUM in

  0)
    echo "$RESULT" >> $RESULT
    echo " running all 5 traces..."
    for i in "${TRACES[@]}"
    do
	    run $i
    done
    ;;
  [1-5])
    echo "$RESULT" >> $RESULT
    run ${TRACES[ $NUM - 1 ]}
    ;;
  6)
    echo "$RESULT" >> $RESULT
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
