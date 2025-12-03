#!/bin/bash
zig build-exe ./src/wasm.zig -target wasm32-freestanding -OReleaseSmall -fno-entry --export=day1_part1 --export=day1_part2 --export=day2_part1 --export=day2_part2 --export=day3_part1