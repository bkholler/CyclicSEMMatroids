#! /bin/bash

pvals=(6)
evals=(6 7 8 9 10 11 12 13 14)

for ((i1=0; i1<${#pvals[@]} ;i1++)) 
do
for ((i2=0; i2<${#evals[@]} ;i2++))
do

  p=${pvals[$i1]}
  e=${evals[$i2]}
  
  fnm="./num_eq_pairs-$p-$e.out"
  OMP_NUM_THREADS=1 nohup nice python3 pairs.py $p $e 2>&1 | tee $fnm &
  echo "OMP_NUM_THREADS=1 nohup nice python3 pairs.py $p $e 2>&1 | tee $fnm &"

done
done
