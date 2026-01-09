#!/bin/bash
COMPILE_NAME=BoatGame

cp -r $PLAYDATE_SDK_PATH/Disk/Data/$COMPILE_NAME/LDtk_lua_levels source/levels/
pdc source ../$COMPILE_NAME.pdx
