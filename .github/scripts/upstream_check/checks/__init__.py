# Each module under this package exports only:
#   check(params, s) -> (satisfied: bool, detail: str)
# The label that routes an issue to this check is `upstream:<module_name>`
# (e.g. release_version.py -> upstream:release_version). Adding a check only
# requires dropping a new file here; main scans the directory.
