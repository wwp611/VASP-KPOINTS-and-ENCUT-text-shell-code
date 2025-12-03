#!/bin/bash
# ================================
#   VASP 自动收敛数据读取脚本
# ================================

# -------- 参数设置 --------
MAXEN=300
ENCUT0=400

KLIST="0.05 0.04 0.03 0.025 0.02 0.01"


# ======================================================
#            (1) K 点收敛测试
# ======================================================
cd k-test

for k in $KLIST
do
    cd "$k"

    # ---- 读取能量 ----
    E=$(grep "energy  without" OUTCAR | tail -1 | awk '{print $7}')
    T=$(grep "Total CPU time" OUTCAR | awk '{print $6}')

    # ---- 写入对齐表格 ----
    printf "%-10s %-20s %-20s\n" "$k" "$E" "$T" >> ../k-test-result.txt

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
    cd "$encut"

    E=$(grep "energy  without" OUTCAR | tail -1 | awk '{print $7}')
    T=$(grep "Total CPU time" OUTCAR | awk '{print $6}')

    printf "%-10s %-20s %-20s\n" "$encut" "$E" "$T" >> ../encut-test-result.txt

    cd ..
done
cd ..

echo ">>> ENCUT convergence test DONE"


# ======================================================
#         显示结果文件位置
# ======================================================
echo "======================================"
echo " All tests finished!"
echo ""
echo " Results:"
echo "   k-test/k-test-result.txt"
echo "   encut-test/encut-test-result.txt"
echo "======================================"

