# bash2version
### bash your version number into place
Well i got fed up by the incompleteness and sheer pythonness of bumpversion, bump2version, advbumpversion and whatnot so i wrote my own, in bash.

It should be able to run pretty much in any unix system. The only requirements are, well, bash and sed.

### Usage
To use it just add it to your project:
```
curl https://raw.githubusercontent.com/maxaudron/bash2version/master/bash2version -o bash2version
```

add your projects files and the regex to match the version string to the FILES array:
```
FILES=(
  'package.json;"version": "VERSION" # instead of writing a version number here use VERSION literally
)

```

Here you can use normal posix extended regex. `VERSION` is used to indicate a version string, it is replaced with the `$SEMVER` regex and the actual version in the script.

You can also adjust what you want to use to indicate a prerelease. For that adjust `$PRERELEASE_STRING`

And should you manage to have a collision with `VERSION` you can also set that to use something else in the `$VER` variable

and here have the `--help` text:
```
bash2version - bump your version, in style, and with violence

bash2version --set VERSION | --bump major|minor|patch|prerelease [--build BUILD] [-c | --commit] [-p | --push] [FILES]

OPTIONS:
  -b, --bump major|minor|patch|prerelease:
      bumps the specified version segment, prerelease either adds 
      or removes the prerelease segment ('-rc' by default)

  --build BUILD:
      add build metadata specified by BUILD

  --prefix PREFIX:
      set the prefix for the version

  -s, --set VERSION:
      set the version to the string provided by VERSION

  -c, --commit:
      git commit and git tag the version

  -p, --push:
      push the tag

  FILES:
      the files and regex to run on in the format file;regex VERSION
      Use VERSION as a placeholder for where the version would be"
```
