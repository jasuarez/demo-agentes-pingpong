#!/bin/sh

MEM=256m

java -server -Xmx$MEM pingpong.jackal.Ans | tee -a router.log
