# Each module under this package exports:
#   LABEL: str            label that routes issues to this check
#   check(params, s) -> (satisfied: bool, detail: str)
# Adding a check only requires dropping a new file here; main scans the dir.
