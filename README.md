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
# Add a plugin to the package.
vpp_add_plugin(my-vamp-plugin)
# Add a file to the package.
vpp_add_file(my-extra-file.txt my-destination-dir)
# Configure target debugging with the Partials application and a document (Xcode only). Specify PARTIELS_EXE_HINT_PATH if you want to use a specific path for Partiels.
vpp_set_plugin_debug(my-vamp-plugin "my-partielsdoc.ptldoc")
# Configure the install command for the plugin.
vpp_set_plugin_install(my-vamp-plugin)
# Create two targets to check and apply clang-format the formatting of sources with clang-format. 
vpp_create_clang_format_targets(my-vamp-plugin ${MY_PLUGIN_SOURCES})
# Add ctest using the vamp-plugin-tester executable 
vpp_enable_vamp_plugin_tester()
```

> ⚠️ Packaging under Windows requires InnoSetup. 

## Credits

- **[Vamp Plugin Packager](https://www.ircam.fr/)** by Pierre Guillot at IRCAM IMR Department
- **[Vamp SDK](https://github.com/vamp-plugins/vamp-plugin-sdk)** by Chris Cannam, copyright (c) 2005-2024 Chris Cannam and Centre for Digital Music, Queen Mary, University of London.
