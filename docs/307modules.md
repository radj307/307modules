@page 307modules

# 307modules

## Usage

First you need to tell CMake where to locate these modules, by appending the path to the 307modules directory to `CMAKE_MODULE_PATH`:
```cmake
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/307modules")
```
_You may have to change the path depending on where 307modules is located._

Now all of the modules are available to be included. To include a module, use:
```cmake
include(<ModuleName>)
```

## Modules

This is a list of all of the available modules, and a short description of each.

| Module                  | Description                                                                                                       |  
|-------------------------|-------------------------------------------------------------------------------------------------------------------|  
| InputFinder             | Used internally to find files located in the `307modules/input` directory.                                        |  
| AutoVersion             | Functions to retrieve the project version number from git tags, and use them in CMake or in the C++ preprocessor. |  
| VersioninfoMaker        | Used to create versioninfo `.rc` resource files. This adds project information to the generated executable.       |  
| PrependEach             | Prepends a string to each element in a list. Useful for separating `BUILD_INTERFACE` & `INSTALL_INTERFACE` paths. |  
| PackageInstaller        | This module provides a few functions that can be used to generate installation information for CMake.             |  
| OptionalArgs            | _(Work-in-Progress)_ Provides functions intended to reduce the repetition of checking optional arguments.         |  

### InputFinder
- FIND_INPUT_FILE(<OUT_VAR> <FILENAME> [REQUIRED] [Possible-Path-To-Filename...])  
  Looks for ${FILENAME} in each element of the `CMAKE_MODULE_PATH` list, and sets ${OUT_VAR} to its absolute path.
  If "REQUIRED" is specified as the 3rd parameter, an error is thrown if the file wasn't located.
  Additional parameters can be specified that point directly to ${FILENAME}. The first extant path will be used.

### AutoVersion
- GET_VERSION(<DIRECTORY> <OUT_MAJOR_VERSION> <OUT_MINOR_VERSION> <OUT_PATCH_VERSION>)  
  This function retrieves the current git tag by calling "git describe --tags" in ${DIRECTORY}, splits it using '.' as a delimiter, and sets the output variable names to the values.  
  This assumes you use semantic versioning in your git tags.  

- MAKE_VERSION(<OUT_VAR> <MAJOR> <MINOR> <PATCH>)  
  Sets ${OUT_VAR} to "${MAJOR}.${MINOR}.${PATCH}".  
  The merged version number can then be used as a CMake project version.  

- CREATE_VERSION_HEADER(<TARGET> <MAJOR> <MINOR> <PATCH>)  
  Uses configure_file to create a `version.h` file in the caller's current source directory from a template.  
  This file contains preprocessor macros with the given version numbers.  

  | Definition              | Value                        |
  |-------------------------|------------------------------|
  | ${TARGET}_VERSION_MAJOR | "${MAJOR}"                   |
  | ${TARGET}_VERSION_MINOR | "${MINOR}"                   |
  | ${TARGET}_VERSION_PATCH | "${PATCH}"                   |
  | ${TARGET}_VERSION       | "${MAJOR}.${MINOR}.${PATCH}" |

### VersioninfoMaker
- CREATE_VERSION_RESOURCE(<DIRECTORY> <MAJOR> <MINOR> <PATCH> <COMPANY_NAME> <FILE_DESCRIPTION> <INTERNAL_NAME> <COPYRIGHT> <ORIGINAL_FILENAME> <PRODUCT_NAME>)  
  Uses configure_file to create a `versioninfo.rc` file in ${DIRECTORY}.  
  See the _Properties -> Details_ tab of an executable for an idea of what this will look like.  

### PrependEach
- PREPEND_EACH(<OUT_VAR> <LIST> <STRING>)  
  This copies ${LIST} to ${OUT_VAR} with each element prefixed with ${STRING}.  
  This is especially useful when separating a list of file paths between BUILD_INTERFACE & INSTALL_INTERFACE,  
  where the build interface requires absolute paths, while the install interface requires relative paths.  


### PackageInstaller
- GENERATE_PACKAGING(<TARGET>)  
  Creates `export.h` & `${TARGET}Config.cmake` in the caller's current binary directory.  
  These files contain the required packaging information for cmake to install and use installed libraries.  

- WRITE_VERSION_FILE(<TARGET> [COMPAT_MODE])  
  Creates a `${TARGET}ConfigVersion.cmake` file in the caller's current binary directory.  
  This is just a wrapper for calling `write_basic_package_version_file` that handles the filename/filepath argument.  
  If the user specifies a version, `COMPAT_MODE` determines whether the package will be considered compatible or not.  
  Possible values for `COMPAT_MODE` are listed in the table below.  
  If no compatibility mode is specified, "SameMajorVersion" is used by default.  

  | Compatibility Mode               | Compatible When User-Specified Version...                 |  
  |----------------------------------|-----------------------------------------------------------|  
  | AnyNewerVersion                  | is the same, or newer than the package version.           |  
  | SameMajorVersion                 | has the same major version number as the package.         |  
  | SameMinorVersion  _(CMake 3.11)_ | has the same major & minor version number as the package. |  
  | ExactVersion                     | is exactly the same as the package version.               |  

- CREATE_PACKAGE(<TARGET> [COMPAT_MODE])  
  This calls the `GENERATE_PACKAGING` & `WRITE_VERSION_FILE` functions with the given arguments.  

- INSTALL_PACKAGE(<TARGET> [[GENERATE] [COMPAT_MODE]])  
  This uses the `install` function to create installation targets for the given target.  
  If "GENERATE" is included as the 2nd argument, `CREATE_PACKAGE` will be called first using the 3rd argument as the compatibility mode if it exists, otherwise "SameMajorVersion" is used.  

### OptionalArgs
- GET_ARG(<ARGN> <INDEX> <OUT_VAR> [TOLOWER|TOUPPER])  
  Retrieves the element at the given index in `ARGN`, and optionally converts it to lowercase or uppercase if "TOLOWER" or "TOUPPER" were included as the 4th argument, respectively.  
