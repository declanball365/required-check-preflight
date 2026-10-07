# Free checker quickstart

Unzip the archive into a new directory, then run from that directory:

```sh
ruby test_preflight.rb
ruby preflight.rb example.yml required.json
```

Expected: 12 tests / 25 assertions pass; the second command prints JSON containing `FILTERED_REQUIRED_CHECK` for `Python tests`. A diagnostic finding still exits 0; rejected input exits 2.

To inspect your own workflow, create a JSON array of exact required check names (for example `["Python tests"]`) and run:

```sh
ruby preflight.rb /path/to/workflow.yml /path/to/required.json
```

Only append `--merge-queue` if your repository actually enables a merge queue. Do not upload workflows or secrets. This tool uses Ruby YAML and JSON libraries, performs no network access and does not execute workflow code. Tested on Ruby 2.6.10 only. Read the scope and limitations in the offer preview before relying on any finding.

License: MIT. See LICENSE in this archive.
