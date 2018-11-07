# Simple OSS DB experiment with Neo4J

## Disclaimer

This is a simple experiment. It was tested only on PowerShell core on Mac OS X. Feedback welcome but use at your own risks.

## Usage

Copy ```Config.sample.ps1``` to ```Config.ps1``` and adjust the configuration to your
local setup.

Run the following command to completely cleanup your database and reload all CSV files:

    Invoke-Build -File ./OSSDb.build.ps1

You can then experiment various queries from ```query.cypher``` in the neo4j
web interface.

## Setup

### Install the Neo4j DotNet driver
    nuget install Neo4j.Driver -OutputDirectory ./nuget/

### Install Invoke Build

    Install-Module InvokeBuild

### Install Neo4j

#### On MacOS X with Homebrew

    brew install neo4j

#### On Windows with Chocolatey

    choco install neo4j-community