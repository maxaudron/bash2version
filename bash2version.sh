#!/usr/bin/env bash
VER='VERSION'
PRERELEASE_STRING='rc'

# FILES,REGEX
FILES=(
  "testfile,test $VER"
)

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
            shift
        ;;
    esac
done

if [ -z $BUMP ]; then
  SETVERSION=""
  perl -ne '/$ENV{"SEMVER"}/ and print "$1 $2 $3 $4 $5"' ${FILES[0]} | IFS=' ' read -ra PERLVER <<< "$IN"
	MAJOR=${PERLVER[0]}
	MINOR=${PERLVER[1]}
	PATCH=${PERLVER[2]}
	PRERE=${PERLVER[3]}
	IFS=''
	if [ "${BUMP,,}" == "major" ]; then
		VERSION=$((MAJOR + 1)).$MINOR.$PATCH$(if [ ! -z $PRERE ]; then echo -$PRERE; fi)$(if [ ! -z $BUILD ]; then echo +$BUILD; fi)
	fi
	if [ "${BUMP,,}" == "minor" ]; then
		VERSION=$MAJOR.$((MINOR + 1)).$PATCH$(if [ ! -z $PRERE ]; then echo -$PRERE; fi)$(if [ ! -z $BUILD ]; then echo +$BUILD; fi)
	fi
	if [ "${BUMP,,}" == "patch" ]; then
		VERSION=$MAJOR.$MINOR.$((PATCH + 1))$(if [ ! -z $PRERE ]; then echo -$PRERE; fi)$(if [ ! -z $BUILD ]; then echo +$BUILD; fi)
	else
	if [ "${BUMP,,}" == "prerelease" ]; then
		VERSION=$MAJOR.$MINOR.$((PATCH + 1))$(if [ ! -z $PRERE ]; then; else echo "-$PRERELEASE_STRING"; fi)$(if [ ! -z $BUILD ]; then echo +$BUILD; fi)
	else
		echo "No valid Version segment provided"
		exit 1
	fi
fi


SEMVER='(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?'

OLDIFS=$IFS
IFS=','

echo $VERSION

for i in "${FILES[@]}"; do
  set -- $i
  echo "s/${2/VERSION/$SEMVER}/${2/VERSION/$VERSION}/g"
  perl -i -p0e "s/${2/VERSION/$SEMVER}/${2/VERSION/$VERSION}/g" $1
done


