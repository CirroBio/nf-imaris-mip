#!/usr/bin/env python3

from typing import List
import boto3
from cirro.helpers.preprocess_dataset import PreprocessDataset
from cirro.models.s3_path import S3Path
import json


def select_all_inputs(ds: PreprocessDataset, suffix=None, prefix=None) -> List[str]:
    """
    Select all images in the dataset as inputs
    :param ds: PreprocessDataset object
    :param suffix: Suffix of the files to select
    :param prefix: Prefix of the files to select
    :return: List of selected files
    """
    return [
        file
        for input_dataset in ds.metadata["inputs"]
        for file in list_files(input_dataset)
        if (suffix is None or file.endswith(suffix)) and (prefix is None or file.startswith(prefix))
    ]


def list_files(input_dataset) -> List[str]:
    """
    List all files in the input dataset
    :param input_dataset: Input dataset
    :return: List of files
    """

    # Get the list of files in the input dataset by parsing the manifest.json file
    path = f"{input_dataset['s3']}/artifacts/manifest.json"
    s3_path = S3Path(path)
    s3 = boto3.client('s3')
    retr = s3.get_object(Bucket=s3_path.bucket, Key=s3_path.key)
    text = retr['Body'].read().decode()
    manifest = json.loads(text)

    return [
        input_dataset["dataPath"] + "/" + file["name"]
        for file in manifest["files"]
    ]


if __name__ == '__main__':
    ds = PreprocessDataset.from_running()

    # Get the images which were selected as inputs
    inputs = ds.params.get("inputs")

    # If no input images were selected, include all .ims files in the dataset
    if inputs is None or len(inputs) == 0:
        ds.logger.info("Selecting all images as inputs")
        inputs = select_all_inputs(ds, suffix=".ims")
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
