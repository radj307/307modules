@page 307modules

# 307modules

## Usage

First you need to tell CMake where to locate these modules, by appending the path to the 307modules directory to the `CMAKE_MODULE_PATH` list.  
If you're using this through [307lib](https://github.com/radj307/307lib), you would use the following:
```cmake
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/307lib/307modules")
```
_You may have to change the path depending on where 307modules is located._

Now all of the modules are available to be included. To include a module, use:
```cmake
include(<ModuleName>)
```
where `<ModuleName>` is the filename of a module, excluding the `.cmake` extension.

## Modules

This is a list of all of the available modules, and a short description of each.

| Module                  | Description                                                                                                              |  
|-------------------------|--------------------------------------------------------------------------------------------------------------------------|  
| VersionTag              | Retrieves the most recent git tag, and exposes it for usage in CMake scripts or directly in code using the preprocessor. |
| PackageInstaller        | Macros useful for creating basic installation targets for executables or libraries.                                      |
| ResourceMaker           | Create resource files for Windows-based programs, including `VersionInfo` structures & icons.                            |
| PrependEach             | Prepends each element in a list with a given string.                                                                     |
| CatFile _(Deprecated)_  | Concatenate files together.                                                                                              |
| Preprocessor _(Deprecated)_ | A variety of functions useful for interacting with the C preprocessor.                                               |
