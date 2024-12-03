#!/bin/bash
set -e

echo "Running ImageJ macro to make MIPs"
ImageJ-linux64 --default-gc \
    -macro "${macro}" \
    "\$PWD/inputs/,${params.make_MIP},${params.make_slice},${params.slice_number},${params.make_JPG},${params.include_scalebar}"

echo "Done running ImageJ macro to make MIPs"

ls -lahtr
