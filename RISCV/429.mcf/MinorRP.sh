#Define las variables de entorno
export GEM5_DIR=/home/axeljcm/Documents/GEM5/gem5/
export RP_DIR=/CPUs/MinorCPU/RISCV/SPEC/Benchmarks/RPBM
export RP_STATS=/CPUs/MinorCPU/RISCV/SPEC/RPStats
export BENCHMARK=./src/benchmark
export ARGUMENT=./data/inp.in
# Define y ejecuta para diferentes políticas de reemplazo de caché L2
for RP in LRURP LFURP FIFORP MRURP RandomRP; do
    echo "Ejecutando simulación con política de reemplazo: $RP"

#Ejecuta el benchmark utilizando GEM5
    time $GEM5_DIR/build/RISCV/gem5.opt \
    -d /home/axeljcm/Documents/$RP_DIR \
    $GEM5_DIR/configs/deprecated/example/se.py \
    -c $BENCHMARK \
    -o "$ARGUMENT" \
    -I 300000000 \
    --cpu-type=MinorCPU \
    --caches \
    --l2cache \
    --l1d_size=16kB \
    --l1i_size=16kB \
    --l2_size=32kB \
    --cacheline_size=64 \
    --l2_rp=$RP

#Copiar el archivo de estadísticas para identificar claramente cada política # --l2_assoc=1 \    --l1d_assoc=2 --l1i_assoc=2 \
    cp /home/axeljcm/Documents/$RP_DIR/stats.txt /home/axeljcm/Documents/$RP_STATS/stats_$RP.txt
done