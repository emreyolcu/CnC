CNF=$1
PAR=30
DIR="$(pwd)"
OUT="$(pwd)/tmp"

rm -f $OUT/output*.txt
$DIR/march_cu/march_cu $CNF -o $OUT/cubes$$ $2 $3 $4 $5 $6 $7 $8 $9

FLAG=1
while [[ $FLAG == "1" ]]
do
  cat $OUT/output*.txt | grep "SAT" | awk '{print $1}' | sort | uniq -c | tr "\n" "\t";
   
  SAT=`cat $OUT/output*.txt | grep "^s SAT" | awk '{print $1}' | uniq`
  if [[ $SAT == "s SAT" ]]
  then
    echo "DONE"
    pkill -TERM -P $$
    FLAG=0
  fi

  UNSAT=`cat $OUT/output*.txt | grep "^s UNSAT" | wc |awk '{print $1}'`
  echo $UNSAT $PAR
  if [[ $UNSAT == $PAR ]]; then echo "c ALL JOBS UNSAT"; FLAG=0; break; fi
  ALIVE=`ps $$ | wc | awk '{print $1}'`
  if [[ $ALIVE == "1" ]]; then echo "c PARENT TERMINATED"; FLAG=0; break; fi 
  if [[ $FLAG  == "1" ]]; then sleep 1; fi
done &

for (( CORE=0; CORE<$PAR; CORE++ ))
do
  echo "p inccnf" > $OUT/formula$$-$CORE.icnf
  cat $CNF | grep -v c >> $OUT/formula$$-$CORE.icnf
  awk 'NR % '$PAR' == '$CORE'' $OUT/cubes$$ >> $OUT/formula$$-$CORE.icnf
  $DIR/icadical/build/cadical $OUT/formula$$-$CORE.icnf -q > $OUT/output-$CORE.txt &
done
wait

rm $OUT/cubes$$
for (( CORE=0; CORE<$PAR; CORE++ ))
do
  rm $OUT/formula$$-$CORE.icnf
done
