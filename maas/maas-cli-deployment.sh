#!/bin/bash

machines=( snn6ss 8b4r3r amfrmt x8kwyb m8kf4x )

for i in ${machines[@]}
do
  maas xtrusia machine deploy $i
done
