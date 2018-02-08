#!/bin/bash
export imageName=index.alauda.cn/chareice/suncity-hrm:$(git rev-parse --short HEAD) 
export containerName=suncity-hrm
