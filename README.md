# GLiMR Scripts

Scripts to facilitate GLiMR/Liberata system integration testing

# Installation

Checkout the repository and run `bundle install`

# Usage

Set a `GLIMR_API_URL` environment variable;

```
export GLIMR_API_URL=[GLiMR API base URL]
```

## Use the scripts in the bin directory, e.g.

```
./bin/create_case
```

This will output a list of follow on commands with arguments for working
with this case.
