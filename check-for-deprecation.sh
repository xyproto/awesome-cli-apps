#! /bin/bash

J=4
OUT_FILE=deprecated.txt

if [ "$1" = "--help" ] || [ "$1" = "-h" ] || [ "$1" = "help" ]; then
  cat <<EOF
$ check-for-deprecation.sh
Check all github apps in the readme for deprecation.
Running $J processes in parallel.

Found deprecated repos are written to: $OUT_FILE
EOF
  exit
fi

APPS=$(cat readme.md | grep -e "- \[.\+\]\(.\+\)\s" | grep 'github.com' | awk -F "(" '{ print $2 }' | cut -d ")" -f1)

check_deprecation() {
  REPO="$1"
  if nice curl -SsL "$REPO" | grep "This repository has been archived by the owner. It is now read-only." >/dev/null; then
    echo "DEPRECATED $REPO" | tee -a $OUT_FILE
  else
    echo "CHECKED $REPO"
  fi
}

# parallel exec: https://unix.stackexchange.com/a/216475
for app in $(echo $APPS); do
   ((i=i%J)); ((i++==0)) && wait
   check_deprecation "$app" &
done
