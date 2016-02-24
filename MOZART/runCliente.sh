#!/bin/sh

SALIDA="./benchmark/multi$1.txt"

echo "##############################################################" > $SALIDA
echo "## ./bin/Cliente -n $1                                        " >> $SALIDA
echo "##                                                            " >> $SALIDA
echo "## Por $(whoami) ($(date))                                    " >> $SALIDA
echo "##############################################################" >> $SALIDA
echo >> $SALIDA

./bin/Cliente -n $1 | tee -a $SALIDA
