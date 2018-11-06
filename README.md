# Mach4-scripts
Modifications and extensions of Newfangled Solutions Mach4

## CustomHomingScript.lua
Custom homing script that performs a two-phase homing cycle. Replace the built-in RefAllHome function in the screen Load script with this one. Rename and keep the old function as a backup in case you want to revert to the original behaviour later.

This custom function first performs a high speed homing operation followed by a small back-off movement and finally a slow but accurate homing cycle from close distance. All by clicking once on the **Reference All Axes (Home)** button. This should be faster and more precise than a single pass homing operation.

The first homing pass speed is according to the speeds in the Mach4 control configuration. Adjust the speeds so that the first homing pass is as quick as possible while still feeling safe. You don't want your machine to overrun your homing/limit switches and crash. The second homing pass speed is a factor of the first pass homing speed and the multiplier variable **SPEED_FACTOR**.

Adjust the **BACKOFF_DISTANCE** variable so that the back-off operation between the passes is just long enough to clear all switches.\
Adjust the **SPEED_FACTOR** so that the second pass is slow enough to produce accurate homing results.\
