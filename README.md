# Overview

Yet Another Package manager is a package manager for C++. While in most cases package installation for
C++ is handled outside of the build environment, in some situations (e.g. when building cross-platform 
code) it may be desirable to import the dependencies in a form of source codes and compile them
along the main project.

YAP takes the following approach which makes it different from CPM or Hunter:
* The root project specifies which packages to import from remote locations or local directories
* The subdirectories or dependencies specify the requirements to the imported packages

YAP thus will not decide for the user which packages to download and include in the target
binary. It will however check all the dependency requirements and inform the user about
version mismatches and possible conflicts.

A number of additional functions (like `yap_alias`) can provide additional flexibility in
the way the dependencis are managed.

# How to use

Start with including `libmanager.cmake` into your project and adding the following lines
in the top-most `CMakeLists.txt`:

```
include(yap.cmake)
yap_init()
```

To retreieve a version of a package use `yap_retrieve`:

```
yap_retrieve(git+https://github.com/alexlukichev/staj-c VERSION 1.0.0)
```

To add a requirement use `yap_require`:

```
yap_require(git+https://github.com/alexlukichev/staj-c VERSION 1 NAME STAJC LIBRARIES staj)
```

`yap_require` will set a number of variables (see below) which can hold the names of target
libraries or include directories:

```
add_executable(test test.c)
target_link_libraries(test ${STAJC_LIBRARIES})
```

# Functions

## yap_init

```
yap_init()
```

The call to this function should be placed in the top-level `CMakeLists.txt`. All subsequent calls will be ignored.


## yap_retrieve

```
yap_retrieve(path [VERSION version] [GIT_TAG tag])
```

`yap_retrieve` will instruct YAP to locate and fetch (if necessary) the dependency from the specified `PATH`. The path can
be a URL (`git+http(s)`, `git+ssh`) or a local directory. `VERSION` should be used to specify the version of the 
dependency. `GIT_TAG` can be used to specify the particular git tag to fetch. If `GIT_TAG` is not specified, then
the value of `VERSION` will be used in its place.

Only invocations of `yap_retrieve` in the top-level project are processed, all others are ignored. This allows
to use YAP for both the root projects and dependencies. However the root project is required to contain the
complete list of required packages.

## yap_require

```
yap_require(path 
   [OPTIONAL] 
   [VERSION version_spec] 
   [NAME name] 
   [LIBRARIES libs...] 
   [INCLUDE_DIRECTORIES dirs...]
   [EXCLUDE_FROM_ALL])
```

`yap_require` is used to declare dependency requirements and at the same time retrieve the information
about the dependency targets and other parameters. If the dependency contains the file `yap-config.cmake`
in its top-level directory, then this file is included and is expected to set variables in the caller's
context which allow the caller to refer to the dependency's targets and other artifacts. If no such 
file present, YAP will try to make a guess.

`OPTIONAL` indicates that the package is optional and thus it can be skipped in the retrieve section.
If the package is optional and no match for it is found, the variable `<NAME>_NOTFOUND` is populated
in the caller's scope.

`VERSION` can be used to restrict the accepted package versions. The format of the `version_spec` is as
follows:

```
version_spec ::= semver_req (',' semver_req) *
semver_req ::= 
    maj_req ['+'] | 
    maj_req '.' min_req ['+'] | 
    maj_req '.' min_req '.' patch_req ['+'] |
    maj_req '.' min_req '.' patch_req '-' ext_req
maj_req ::= ['1'..'9']['0'..'9']*
min_req ::= ['1'..'9']['0'..'9']*
patch_req ::= ['1'..'9']['0'..'9']*
ext_req ::= .+
```

When including `yap-config.cmake` or `CMakeLists.txt` of the dependency, the variable `YAP_PACKAGE_VERSION`
is set to the version of the matching retreived dependency (see `yap_retrieve`).

`NAME` is used to provide a hint to YAP and to `yap-config.cmake` about what variables the caller
expects to be set. E.g. if the caller provides `NAME` on `yap_require`, then the caller expects
that the target libraries are put in `<NAME>_LIBRARIES` variable. When including `yap-config.cmake` or 
`CMakeLists.txt` of the dependency, the variable `YAP_PACKAGE_NAME`
is set to the value of `NAME` argument.

`LIBRARIES` is used as a hint to YAP when no `yap-config.cmake` is found in the dependency
directory. In this case the variable `<NAME>_LIBRARIES` is populated with the value of 
the `LIBRARIES` argument.

`INCLUDE_DIRECTORIES` is used as a hint to YAP when no `yap-config.cmake` is found in the
dependency directory. In this case the variable `<NAME>_INCLUDE_DIRECTORIES` is populated
with the value of the `INCLUDE_DIRECTORIES` parameter prepended with the path to the dependency
directory (in the case of multiple directories, each of them is prepended).

`EXCLUDE_FROM_ALL` will ensure that the targets in the included subdirectory are not
added to the `ALL` target.

## yap_alias

In some cases it may be useful to override the location of the dependency. The most
simple usecase for that is when a GitHub repository is being inconsistently referenced 
at `git+http` or `git+https` from different dependencies. In this case a call like
this:

```
yap_alias(git+http://github.com/nodejs/http-parser git+https://github.com/nodejs/http-parser)
```

Will make sure that whenever the requirment to an `http`-based URL specified, it will
be translated into an `https`-based requirement.

A more complicated usecase is when a dependency requires a library for which the
root level project provides a patched version. In this case `yap_alias` can
be used to 'trick' that dependency into using another library instead.

