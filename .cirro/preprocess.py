#!/usr/bin/env python3

from cirro.helpers.preprocess_dataset import PreprocessDataset
import json

if __name__ == '__main__':
    ds = PreprocessDataset.from_running()

    # Get the images which were selected as inputs
    inputs = ds.params.get("inputs")

    # Make sure that some images were selected
    if inputs is None:
        raise ValueError("No input images found")
    
    # If the images are a list, collapse into a comma delimited string
    if inputs[0] == '[':
        inputs = json.loads(inputs)
    if isinstance(inputs, list):
        inputs = ",".join(inputs)

    # Add the updated inputs to the parameters
    ds.add_param("inputs", inputs, overwrite=True)
