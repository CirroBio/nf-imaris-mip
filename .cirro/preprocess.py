#!/usr/bin/env python3

from cirro.helpers.preprocess_dataset import PreprocessDataset
import json

if __name__ == '__main__':
    ds = PreprocessDataset.from_running()

    # Get the images which were selected as inputs
    inputs = ds.params.get("inputs")

    # If no input images were selected, include all .ims files in the dataset
    if inputs is None or len(inputs) == 0:
        ds.logger.info("Selecting all images as inputs")
        inputs = [
            f for f in ds.files["file"] if f.endswith(".ims")
        ]
        if len(inputs) == 0:
            raise ValueError("No .ims files found in dataset")

    # If the images are a list, collapse into a comma delimited string
    if isinstance(inputs, str) and inputs[0] == '[':
        inputs = json.loads(inputs)
    if isinstance(inputs, list):
        inputs = ",".join(inputs)

    n_inputs = len(inputs.split(","))

    ds.logger.info(f"Selected {n_inputs:,} inputs")

    # Add the updated inputs to the parameters
    ds.add_param("inputs", inputs, overwrite=True)
