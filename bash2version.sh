#!/usr/bin/env bash
# Sets the string to use a replace target
VER='VERSION'

# String used to signal a prerelease
PRERELEASE_STRING='rc'

# Provide a list of files to modify and the regex to use for them
# in the form of FILE;REGEX
# use $VER
FILES=(
  # 'package.json;"version": "$VER"'
)

# Regex used to parse semver
# \1 = MAJOR
# \2 = MINOR
# \3 = PATCH
# \5 = PRERE
# \8 = BUILD
SEMVER='(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-(0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(\.0|\.[1-9]\d*|\.\d*[a-zA-Z-][0-9a-zA-Z-]*)*)?(\+([0-9a-zA-Z-]+(\.[0-9a-zA-Z-]+)*))?'

help() {
  echo "bash2version - bump your version, in style, and with violence

bash2version [--set VERSION | --build BUILD | --bump major|minor|patch|prerelease]

OPTIONS:
  -b, --bump major|minor|patch|prerelease:
      bumps the specified version segment, prerelease either adds 
      or removes the prerelease segment ('-rc' by default)

  --build BUILD:
      add build metadata specified by BUILD

  -s, --set VERSION:
      set the version to the string provided by VERSION"
}

# Check if an argument was provided to the given option;
check_arg_exist() {
    if [[ -z $2 || $2 == "-"* ]]; then
        echo "ERROR: argument $1 requires an argument!"
        exit 1
    fi
}

while [[ "$1" != "" ]]; do
    case "$1" in
        -b | --bump)
            check_arg_exist "$1" "$2"
            BUMP=$2
            shift 2
        ;;
        --build)
            check_arg_exist "$1" "$2"
            BUILD=$2
            shift 2
        ;;
        -s | --set)
            check_arg_exist "$1" "$2"
            SETVERSION=$2
            shift 2
        ;;
        --help)
            help
            exit
            shift
        ;;
    esac
done

get_version() {
  MATCH=${FILES[0]#*;}
  TMPVERSION=$(sed -nr "s/.*${MATCH/VERSION/$SEMVER}.*/\1;\2;\3;\5;\8/gp" ${FILES[0]%;*})
  IFS=';' read -r MAJOR MINOR PATCH PRERE BUILDT <<< "$TMPVERSION"; IFS=''
  echo $MAJOR $MINOR $PATCH $PRERE $BUILDT
}

set_version() {
  if [ ! -z $SETVERSION ]; then
    VERSION=$SETVERSION$(if [ ! -z $BUILD ]; then echo "+$BUILD"; fi)
  elif [ ! -z $BUMP ]; then
    if [ "${BUMP,,}" == "major" ]; then
      VERSION=$((MAJOR + 1)).0.0$(if [ ! -z $PRERE ]; then echo -$PRERE; fi)$(if [ ! -z $BUILD ]; then echo +$BUILD; fi)
    elif [ "${BUMP,,}" == "minor" ]; then
      VERSION=$MAJOR.$((MINOR + 1)).0$(if [ ! -z $PRERE ]; then echo -$PRERE; fi)$(if [ ! -z $BUILD ]; then echo +$BUILD; fi)
    elif [ "${BUMP,,}" == "patch" ]; then
      VERSION=$MAJOR.$MINOR.$((PATCH + 1))$(if [ ! -z $PRERE ]; then echo -$PRERE; fi)$(if [ ! -z $BUILD ]; then echo +$BUILD; fi)
    elif [ "${BUMP,,}" == "prerelease" ]; then
      VERSION=$MAJOR.$MINOR.$PATCH$(if [ -z $PRERE ]; then echo "-$PRERELEASE_STRING"; fi)$(if [ ! -z $BUILD ]; then echo "+$BUILD"; fi)
    else
      echo "No valid Version segment provided"
      exit 1
    fi
  fi
}

apply_version() {
  OLDIFS=$IFS
  IFS=';'

  echo "Applying Version: $VERSION"

  for i in "${FILES[@]}"; do
    set -- $i
    sed -ri "s/${2/VERSION/$SEMVER}/${2/VERSION/$VERSION}/g" $1
  done

  IFS=''
}


if [[ -z $SETVERSION && -z $BUMP ]]; then
  help
  exit
else
  get_version
  set_version
  apply_version
fi

