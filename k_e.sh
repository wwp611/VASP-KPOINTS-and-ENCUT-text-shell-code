#!/bin/bash
# ================================
#   VASP 自动收敛测试脚本
#   1) k 点收敛 (变量：RECIPROCAL LENGTH)
#   2) ENCUT 收敛
# ================================

# -------- 参数设置 --------
MAXEN=300
ENCUT0=400
kENCUT=520

# K 点步长列表（vaspkit 102 模式下的 resolution）
KLIST="0.05 0.04 0.03 0.025 0.02 0.01"

# -------- 创建目录 --------
mkdir -p k-test
mkdir -p encut-test

# ======================================================
#            (1) K 点收敛测试
# ======================================================
cd k-test

for k in $KLIST
do
    echo ">>> Testing K = $k"
    mkdir "$k"
    cp ../POTCAR "$k/"
    cp ../POSCAR "$k/"
    cp ../vasp.sh "$k/"
    cd "$k"

    # ---- 写 INCAR ----
    cat > INCAR <<EOF
SYSTEM = AUTO TEST K POINTS
ISTART = 0
ICHARG = 2
ENCUT = $kENCUT
LREAL = A
PREC = A
LWAVE = F
LCHARG = F
NCORE = 4
ISMEAR = 0
SIGMA = 0.01
NSW = 0
IBRION = -1
NELMIN = 6
NELM = 400
EDIFF = 1E-6
ALGO = VeryFast
EOF

    # ---- 用 VASPkit 生成 K 点 ----
    echo -e "102\n2\n$k\n" | vaspkit

    # ---- 运行 VASP ----
    yhbatch vasp.sh 

    cd ..
done
cd ..

echo ">>> K-point convergence test DONE"


# ======================================================
#            (2) ENCUT 收敛测试
# ======================================================

cd encut-test

for encut in $(seq $ENCUT0 50 $(echo "$ENCUT0+250" | bc))
do
    echo ">>> Testing ENCUT = $encut"
    mkdir "$encut"
    cp ../POTCAR "$encut/"
    cp ../POSCAR "$encut/"
    cp ../vasp.sh "$encut/"
    cd "$encut"

    # ---- INCAR ----
    cat > INCAR <<EOF
SYSTEM = AUTO TEST ENCUT
ISTART = 0
ICHARG = 2
ENCUT = $encut
LREAL = A
PREC = A
LWAVE = F
LCHARG = F
NCORE = 4
ISMEAR = 0
SIGMA = 0.01
NSW = 0
IBRION = -1
NELMIN = 6
NELM = 400
EDIFF = 1E-6
ALGO = VeryFast
EOF

    # ---- 固定 K 点步长 ----
    echo -e "102\n2\n0.03\n" | vaspkit

    # ---- 运行 VASP ----
    yhbatch vasp.sh

    cd ..
done
cd ..

echo ">>> ENCUT convergence test DONE"

echo "======================================"
echo " All tests finished!"
echo " Results:"
echo "   k-test/k-test-result.txt"
echo "   encut-test/encut-test-result.txt"
echo "======================================"

