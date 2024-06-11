#Define las variables de entorno
export GEM5_DIR=/home/axeljcm/Documents/GEM5/gem5/
export BP_DIR=/CPUs/O3CPU/ARM/PARSEC/Benchmarks/BPBM
export BP_STATS=/CPUs/O3CPU/ARM/PARSEC/BPStats
export BENCHMARK=./src/blackscholes
export INPUT_FILE=./inputs/test.txt
export OUTPUT_FILE=./inputs/output.txt
export ARGUMENT="1 $INPUT_FILE $OUTPUT_FILE"
# Define y ejecuta para diferentes políticas de reemplazo de caché L2
for BP in TournamentBP LocalBP TAGE; do
    echo "Ejecutando simulación con Branch Predictor: $BP"

#Ejecuta el benchmark utilizando GEM5
    time $GEM5_DIR/build/ARM/gem5.opt \
    -d /home/axeljcm/Documents/$BP_DIR \
    $GEM5_DIR/configs/deprecated/example/se.py \
    -c $BENCHMARK \
    -o "$ARGUMENT" \
    -I 300000000 \
    --cpu-type=O3CPU \
    --caches \
    --l2cache \
    --l1d_size=128kB \
    --l1i_size=128kB \
    --l2_size=1MB \
    --l1d_assoc=2 \
    --l1i_assoc=2 \
    --l2_assoc=1 \
    --cacheline_size=64 \
    --bp-type=$BP

#Copiar el archivo de estadísticas para identificar claramente cada política # --l2_assoc=1 \    --l1d_assoc=2 --l1i_assoc=2 \
    cp /home/axeljcm/Documents/$BP_DIR/stats.txt /home/axeljcm/Documents/$BP_STATS/stats_$BP.txt
done