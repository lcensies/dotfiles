#!/bin/bash

virsh list --name | while read n
do
  [[ ! -z $n ]] && echo $n &&  virsh domifaddr $n
done

