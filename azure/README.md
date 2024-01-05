# Azure Pipeline Checker tool

This CLI tool can be used to run and check the status of Azure pipelines from the CLI.

## Setup and requirements

To use the script there are a couple of requirements:
1. Download and install the Azure CLI. [See the Azure CLI document for more information](https://github.com/livebuzzevents/documentation/blob/main/azure/cli.md).
2. [Download and install Charm.sh Gum](https://github.com/livebuzzevents/documentation/blob/main/azure/cli.md)

Once you have both of these installed and the CLI is configured, download either the `bash` or `powershell` script to your computer.

## Run the script

1. `cd` into the directory of the script
2. Run the script
    - If you are using the `bash` script run: `./pipeline-check.sh`
    - If you are using the `powershell` script run: `powershell.exe -File "pipeline-check.ps1"`
3. Select a pipeline to either run or check

