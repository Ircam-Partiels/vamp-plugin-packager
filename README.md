# Vamp Plugin Packager
**A CMake script for packaging Vamp plugins**

This CMake script automatically generates Vamp plugin installation packages for macOS, Windows and Linux operating systems and can automatically sign and notarise packages on macOS and Windows. The variables and options used to configure the packaging and signature are described in the header of the CMake script.

The script can also generate:
- the installation rules for a target
- the debug scheme for a target using the Partiels application
- clang format targets to check and apply the format to the sources
- manual target to generate a PDF from a markdown file
- a CMake test that runs the vamp-plugin-tester application on all the generated plugins

## Example 
```cmake
# Basic Properties 
set(VPP_NAME "MySuperProject" CACHE PATH "The name of the project")
set(VPP_COMPANY "MySuperCompany" CACHE PATH "The name of the company")
set(VPP_URL "MySuperWebsite" CACHE PATH "The URL of the project")
# Advanced Properties
set(VPP_APPID "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" CACHE PATH "The unique ID of the project")
set(VPP_BUILD_TAG "${CVP_BUILD_TAG}" CACHE STRING "The current tag of the project" FORCE)
set(VPP_ABOUT_FILE "${CMAKE_CURRENT_SOURCE_DIR}/resource/About.txt" CACHE PATH "The about file to add to the distribution" FORCE)
set(VPP_CHANGELOG_FILE "${CMAKE_CURRENT_SOURCE_DIR}/resource/ChangeLog.txt" CACHE PATH "The changelog file to add to the distribution" FORCE)
set(VPP_ICON_FILE "${CMAKE_CURRENT_SOURCE_DIR}/resource/my-logo.png" CACHE PATH "The icon file to add to the distribution" FORCE)
set(VPP_DIR "${CMAKE_CURRENT_SOURCE_DIR}/package" CACHE PATH "The directory of the package" FORCE)
# Windows Signing Properties
set(VPP_CODESIGN_WINDOWS_KEYFILE "" CACHE PATH "The Windows (.pfx) certificate file")
set(VPP_CODESIGN_WINDOWS_KEYPASSWORD "" CACHE STRING "The password of the Windows (.pfx) certificate file")
# Apple Signing Properties
set(VPP_CODESIGN_APPLE_DEV_ID_APPLICATION_CERT "Developer ID Application" CACHE STRING "The Apple Developer ID Application certificate")
set(VPP_CODESIGN_APPLE_DEV_ID_INSTALLER_CERT "Developer ID Installer" CACHE STRING "The Apple Developer ID Installer certificate")
set(VPP_CODESIGN_APPLE_KEYCHAIN_PROFILE_INSTALLER "notary-installer" CACHE STRING "The Apple keychain profile for installer")
...
# Include the Vamp Plugin Packager sources.
include(vamp-plugin-packager/vamp-plugin-packager.cmake)
...
# Add a plugin to the package and generate the Vamp bundle with the required output name
# of the library and the category file, and an optional copyright used to generate the
# Info.plist file of a macOS bundle, and an optional version that defines the PLUGIN_VERSION
# macro for the compilation of the sources of the target. The plugin can be installed
# (INSTALL ON), debugged with the Partiels application (DEBUG ON with DEBUG_DOCUMENT) and
# tested with the vamp
# plugin tester (TESTER ON with the arguments of its command line and a timeout in seconds).
# Note that the tests are run with ctest, hence enable_testing() must have been called
# in the top-level CMakeLists file of the project that includes the packager.
vpp_add_plugin(my-vamp-plugin
  OUTPUT_NAME my-plugin-name
  CATFILE my-plugin.cat
  COPYRIGHT "Copyright MyCompany. All rights reserved"
  VERSION 1
  INSTALL ON
  DEBUG ON
  DEBUG_DOCUMENT my-partielsdoc.ptldoc
  TESTER ON
  TESTER_ARGUMENTS -a -t C1
  TESTER_TIMEOUT 600
)
# Add a file to the package.
vpp_add_file(my-extra-file.txt my-destination-dir)
# Create two targets to check and apply clang-format the formatting of sources with clang-format. 
vpp_create_clang_format_targets(my-vamp-plugin ${MY_PLUGIN_SOURCES})
```

> ⚠️ Packaging under Windows requires InnoSetup. 

## Credits

- **[Vamp Plugin Packager](https://www.ircam.fr/)** by Pierre Guillot at IRCAM IMR Department
- **[Vamp SDK](https://github.com/vamp-plugins/vamp-plugin-sdk)** by Chris Cannam, copyright (c) 2005-2024 Chris Cannam and Centre for Digital Music, Queen Mary, University of London.
