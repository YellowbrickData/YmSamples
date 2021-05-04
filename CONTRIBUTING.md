# Contributing Guidelines

Contributions are always welcome!

## Process

Fork and clone the repo, and add a new directory containing your .sql files. Usually, it is best to separate "setup" or DDL activity from "load" activity. Having separate .sql files per sample query is also a good idea.

Each sample must have:

1. A README.md file
2. An icon.svg file
3. One or more .sql or .ddl files

Once the structure for the sample is in place, hook it into the registry. To publish, add an entry to registry.json (see format below), supplying summary information and other metadata.

When you are done with your example, send a pull request!

## Registry

The registry.json file lives in the root of this repository, and contains one entry per sample. A sample appears below:

```
  {
    "name": "Premier League Database",
    "id": "premdb",
    "icon": "premdb/icon.svg",
    "description": "A tiny database that contains actual English Premier League soccer results for about 20 seasons and details about each team in the league. You can run a script that creates and loads five small tables in about 5 seconds. These tables are used extensively in the main Yellowbrick documentation to provide simple, reproducible examples of SQL commands and functions. ",
    "actions": [
       {
         "name": "Setup/Load",
         "scripts": [
           "premdb/premdb_external_objects.ddl",
           "premdb/premdb_testdrive.ddl"
         ]
       }
    ],
    "author": "Yellowbrick Staff",
    "files": [
      {
        "dir": "premdb",
        "include": "sql|ddl"
      },
      {
        "dir": "premdb/queries",
        "include": "sql|ddl"
      }
    ],
    "size": 831662
  },

```

As well as the name, description, author, icon, and size values, which drive the Sample Catalog, additional sections supply "actions" and "files."

### Actions

Actions are simply shortcuts to sets of .sql that go together to get the sample up and running quickly.

The action for the sample is an array of objects, each containing a name and one or more scripts. When more than one script is provided, Yellowbrick Manager will load all the scripts and concatenate them.

### Files

To enable shortcuts to commonly used files (such as queries), supply one or more directories, along with an "include" regular expression to fine-tune the file types. 
