# Contributing Guidelines

Contributions are always welcome!

## Setup

To update this repo, we require a commit hook to be installed.  A one-time setup
step should be run:

```
./setup.sh
```

## Process

Fork and clone the repo, and add a new directory containing your .sql files. Usually, it is best to separate "setup" or DDL activity from "load" activity. Having separate .sql files per sample query is also a good idea.

Each sample must have:

1. A sample.yaml file
2. A README.md file
3. An icon.svg file
4. One or more .sql or .ddl files

Once the structure for the sample is in place, the registry must be updated.  To
update the registry, run the `scripts/updateregistry.sh` script.

When you are done with your example, send a pull request!

NB: Your sample can stay hidden until you are ready to publish by adding a hidden: true
attribute.

## Registry

The registry.yaml file lives in the root of this repository, and contains one entry per sample.  Each sample
contributes its sample.yaml file to the whole document using the `scripts/updateregistry.sh` script.

A `sample.yaml` file appears below:

```
name: Premier League Database
id: premdb
icon: premdb/icon.svg
description: 'A tiny database that contains actual English Premier League soccer
  results for about 20 seasons and details about each team in the league. You can
  run a script that creates and loads five small tables in about 5 seconds. These
  tables are used extensively in the main Yellowbrick documentation to provide simple,
  reproducible examples of SQL commands and functions. '
actions:
- name: Setup/Load
  scripts:
  - premdb/premdb_external_objects.ddl
  - premdb/premdb_testdrive.ddl
author: Yellowbrick Staff
files:
- dir: premdb
  include: sql|ddl
- dir: premdb/queries
  include: sql|ddl
size: 831662
```

As well as the name, description, author, icon, and size values, which drive the Sample Catalog, additional sections supply "actions" and "files."

### Description

The description should be short, as it is included in the top-level catalog browser.  It may include markdown content.

### Actions

Actions are simply shortcuts to sets of .sql that go together to get the sample up and running quickly.

The action for the sample is an array of objects, each containing a name and one or more scripts. When more than one script is provided, Yellowbrick Manager will load all the scripts and concatenate them.

### Files

To enable shortcuts to commonly used files (such as queries), supply one or more directories, along with an "include" regular expression to fine-tune the file types.
