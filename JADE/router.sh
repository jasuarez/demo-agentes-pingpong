#!/bin/sh

MEM=256m

java -server -Xmx$MEM jade.Boot | tee router.log
