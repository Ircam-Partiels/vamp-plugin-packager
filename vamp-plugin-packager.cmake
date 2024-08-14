set(VPP_NAME "${CMAKE_PROJECT_NAME}" CACHE PATH "The name of the project")
set(VPP_COMPANY "MyCompany" CACHE PATH "The name of the company")
set(VPP_URL "www.vamp-plugins.org" CACHE PATH "The URL of the project")
set(VPP_APPID "00000000-0000-0000-0000-000000000000" CACHE PATH "The unique ID of the project")
set(VPP_BUILD_TAG "${CMAKE_PROJECT_VERSION}" CACHE STRING "The current tag of the project")
set(VPP_ABOUT_FILE "" CACHE PATH "The about file to add to the distribution")
set(VPP_CHANGELOG_FILE "" CACHE PATH "The changelog file to add to the distribution")
set(VPP_ICON_FILE "" CACHE PATH "The icon file to add to the distribution")
set(VPP_DIR ${CMAKE_CURRENT_BINARY_DIR}/Package CACHE PATH "The directory of the package")

set(VPP_CODESIGN_WINDOWS_KEYFILE "" CACHE PATH "The Windows (.pfx) certificate file")
set(VPP_CODESIGN_WINDOWS_KEYPASSWORD "" CACHE STRING "The password of the Windows (.pfx) certificate file")
set(VPP_CODESIGN_APPLE_DEV_ID_APPLICATION_CERT "Developer ID Application" CACHE STRING "The Apple Developer ID Application certificate")
set(VPP_CODESIGN_APPLE_DEV_ID_INSTALLER_CERT "Developer ID Installer" CACHE STRING "The Apple Developer ID Installer certificate")
set(VPP_CODESIGN_APPLE_KEYCHAIN_PROFILE_INSTALLER "notary-installer" CACHE STRING "The Apple keychain profile for installer")
set(VPP_CODESIGN_ENTITLEMENTS "${CMAKE_CURRENT_LIST_DIR}/vamp-plugins.entitlements")

option(VPP_NOTARIZE OFF)

# Check if the notarization can be performed
if(WIN32 AND VPP_NOTARIZE)
  if(EXISTS ${VPP_CODESIGN_WINDOWS_KEYFILE})
    message(STATUS "Windows notarization with ${VPP_CODESIGN_WINDOWS_KEYFILE} certificate is available")
    set(VPP_NOTARIZE ON)
  elseif(NOT VPP_CODESIGN_WINDOWS_KEYFILE STREQUAL "")
    message(WARNING "Windows notarization with ${VPP_CODESIGN_WINDOWS_KEYFILE} certificate is not available")
    set(VPP_NOTARIZE OFF)
  else()
    set(VPP_NOTARIZE OFF)
  endif()
elseif(APPLE AND VPP_NOTARIZE)
  execute_process(COMMAND security find-certificate -c ${VPP_CODESIGN_APPLE_DEV_ID_APPLICATION_CERT} OUTPUT_VARIABLE CERTIFICATE_RESULT ERROR_VARIABLE CERTIFICATE_ERROR)
  if(CERTIFICATE_RESULT)
    message(STATUS "Apple notarization with ${VPP_CODESIGN_APPLE_DEV_ID_APPLICATION_CERT} certificate is available")
    set(VPP_NOTARIZE ON)
  else()
    message(WARNING "Apple notarization with ${VPP_CODESIGN_APPLE_DEV_ID_APPLICATION_CERT} certificate is not available")
    set(VPP_NOTARIZE OFF)
  endif()
  execute_process(COMMAND security find-certificate -c ${VPP_CODESIGN_APPLE_DEV_ID_INSTALLER_CERT} OUTPUT_VARIABLE CERTIFICATE_RESULT ERROR_VARIABLE CERTIFICATE_ERROR)
  if(CERTIFICATE_RESULT)
    message(STATUS "Apple notarization with ${VPP_CODESIGN_APPLE_DEV_ID_INSTALLER_CERT} certificate is available")
    set(VPP_NOTARIZE ON)
  else(VPP_NOTARIZE)
    message(WARNING "Apple notarization with ${VPP_CODESIGN_APPLE_DEV_ID_INSTALLER_CERT} certificate is not available")
    set(VPP_NOTARIZE OFF)
  endif()
endif()

# Generations
if(WIN32) # WINDOWs
  set(VPP_PACKAGE "${VPP_DIR}/${VPP_NAME}-Windows.exe")

  set(VPP_TEMP_DIR "${CMAKE_CURRENT_BINARY_DIR}/PkgTemp")
  cmake_path(NATIVE_PATH VPP_TEMP_DIR VPP_TEMP_DIR_NAT)
  set(VPP_ISS_FILE "${VPP_TEMP_DIR}/package.iss")
  set(VPP_SCRIPT "${VPP_TEMP_DIR}/package.bat")

  file(WRITE ${VPP_ISS_FILE} "#define MyAppName \"${VPP_NAME}\"\n")
  file(APPEND ${VPP_ISS_FILE} "\n")
  file(APPEND ${VPP_ISS_FILE} "[Setup]\n")
  file(APPEND ${VPP_ISS_FILE} "AppId={{${VPP_APPID}}}\n")
  file(APPEND ${VPP_ISS_FILE} "AppName=\"${VPP_NAME}\"\n")
  file(APPEND ${VPP_ISS_FILE} "AppVerName={#MyAppVerName}\n")
  file(APPEND ${VPP_ISS_FILE} "AppPublisher=\"${VPP_COMPANY}\"\n")
  file(APPEND ${VPP_ISS_FILE} "AppPublisherURL=\"${VPP_URL}\"\n")
  file(APPEND ${VPP_ISS_FILE} "AppSupportURL=\"${VPP_URL}\"\n")
  file(APPEND ${VPP_ISS_FILE} "AppUpdatesURL=\"${VPP_URL}\"\n")
  file(APPEND ${VPP_ISS_FILE} "DefaultDirName=\"{commonpf64}\\Vamp Plugins\"\n")
  file(APPEND ${VPP_ISS_FILE} "DisableProgramGroupPage=yes\n")
  file(APPEND ${VPP_ISS_FILE} "DisableDirPage=no\n")
  file(APPEND ${VPP_ISS_FILE} "OutputDir=..\\build\n")
  file(APPEND ${VPP_ISS_FILE} "InfoBeforeFile=${VPP_ABOUT_FILE}\n")
  file(APPEND ${VPP_ISS_FILE} "OutputBaseFilename=${VPP_NAME}-Windows\n")
  file(APPEND ${VPP_ISS_FILE} "Compression=lzma\n")
  file(APPEND ${VPP_ISS_FILE} "SolidCompression=yes\n")
  file(APPEND ${VPP_ISS_FILE} "WizardStyle=modern\n")
  file(APPEND ${VPP_ISS_FILE} "ChangesEnvironment=yes\n")
  file(APPEND ${VPP_ISS_FILE} "Uninstallable=no\n")
  file(APPEND ${VPP_ISS_FILE} "\n")
  file(APPEND ${VPP_ISS_FILE} "[Languages]\n")
  file(APPEND ${VPP_ISS_FILE} "Name: \"english\"; MessagesFile: \"compiler:Default.isl\"\n")
  file(APPEND ${VPP_ISS_FILE} "\n")
  file(APPEND ${VPP_ISS_FILE} "[Files]\n")
  
  function(vpp_add_plugin target)
    get_target_property(PLUGIN_NAME ${target} LIBRARY_OUTPUT_NAME)
    if(NOT PLUGIN_NAME)
      set(PLUGIN_NAME "${target}")
    endif()

    file(APPEND ${VPP_ISS_FILE} " Source: \"${VPP_TEMP_DIR_NAT}\\${PLUGIN_NAME}.dll\"; DestDir: \"{app}\"; Flags: ignoreversion\n")
    file(APPEND ${VPP_ISS_FILE} " Source: \"${VPP_TEMP_DIR_NAT}\\${PLUGIN_NAME}.cat\"; DestDir: \"{app}\"; Flags: ignoreversion\n")

    add_custom_target(${target}_package 
      COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:${target}> ${VPP_TEMP_DIR}/${PLUGIN_NAME}.dll
      COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE_DIR:${target}>/${PLUGIN_NAME}.cat ${VPP_TEMP_DIR}/${PLUGIN_NAME}.cat
    )
    add_dependencies(${target}_package ${target})
    add_dependencies(${VPP_NAME}_package ${target}_package)
  endfunction(vpp_add_plugin)

  find_program(ISCC_EXE "iscc" HINTS "C:/Program Files (x86)/Inno Setup 6" REQUIRED)
  cmake_path(NATIVE_PATH ISCC_EXE ISCC_EXE_NAT)
  cmake_path(NATIVE_PATH VPP_DIR VPP_DIR_NAT)
  cmake_path(NATIVE_PATH VPP_ISS_FILE VPP_ISS_FILE_NAT)
  file(WRITE ${VPP_SCRIPT} "\"${ISCC_EXE_NAT}\" /DMyAppVerName=\"${VPP_BUILD_TAG}\" /O\"${VPP_DIR_NAT}\" \"${VPP_ISS_FILE_NAT}\"\n")

  if(VPP_NOTARIZE)
    find_program(SIGNTOOL_EXE "signtool" HINTS "C:/Program Files (x86)/Windows Kits/10/bin/10.0.19041.0/x64" REQUIRED)
    cmake_path(NATIVE_PATH SIGNTOOL_EXE SIGNTOOL_EXE_NAT)
    cmake_path(NATIVE_PATH VPP_PACKAGE VPP_PACKAGE_NAT)
    cmake_path(NATIVE_PATH VPP_CODESIGN_WINDOWS_KEYFILE VPP_CODESIGN_WINDOWS_KEYFILE_NAT)
    file(APPEND ${VPP_SCRIPT} "\"${SIGNTOOL_EXE_NAT}\" sign /f \"${VPP_CODESIGN_WINDOWS_KEYFILE_NAT}\" /p \"${VPP_CODESIGN_WINDOWS_KEYPASSWORD}\" /fd SHA256 /td SHA256 /tr http://timestamp.sectigo.com \"${VPP_PACKAGE_NAT}\"\n")
    file(APPEND ${VPP_SCRIPT} "\"${SIGNTOOL_EXE_NAT}\" verify /pa \"${VPP_PACKAGE_NAT}\"\n")
  endif()

  add_custom_target(${VPP_NAME}_package ALL COMMAND ${VPP_SCRIPT} COMMENT "Packaging the Vamp plug-ins")

elseif(APPLE) # APPLE
  set(VPP_PACKAGE "${VPP_DIR}/${VPP_NAME}-MacOS.pkg")
  file(MAKE_DIRECTORY ${VPP_DIR})

  set(VPP_TEMP_DIR "${CMAKE_CURRENT_BINARY_DIR}/PkgTemp")
  set(VPP_PACKAGE_SCRIPT "${VPP_TEMP_DIR}/package.sh")
  set(VPP_DISRIB_XML "${VPP_TEMP_DIR}/distribution.xml")
  set(VPP_TEMP1 "${VPP_TEMP_DIR}/temp1.xml")
  set(VPP_TEMP2 "${VPP_TEMP_DIR}/temp2.xml")
  set(VPP_TEMP3 "${VPP_TEMP_DIR}/temp3.xml")
  set(VPP_NOTARIZE_LOG "${VPP_TEMP_DIR}/notarize.log")
  set(VPP_INFO_LOG "${VPP_TEMP_DIR}/info.log")
  
  file(WRITE ${VPP_PACKAGE_SCRIPT} "#!/bin/sh\n\n")
  file(CHMOD ${VPP_PACKAGE_SCRIPT} PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)

  if(EXISTS ${VPP_CHANGELOG_FILE})
    file(COPY ${VPP_CHANGELOG_FILE} DESTINATION ${VPP_TEMP_DIR})
  endif()

  if(DEFINED CMAKE_OSX_ARCHITECTURES AND NOT CMAKE_OSX_ARCHITECTURES STREQUAL "")
    if(CMAKE_OSX_ARCHITECTURES STREQUAL "$(ARCHS_STANDARD)")
      set(HOST_ARCH "x86_64,arm64")
    else()
      set(HOST_ARCH "${CMAKE_OSX_ARCHITECTURES}")
    endif()
  else()
    set(HOST_ARCH "${CMAKE_SYSTEM_PROCESSOR}")
  endif()

  file(WRITE ${VPP_TEMP1} "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n")
  file(APPEND ${VPP_TEMP1} "<installer-gui-script minSpecVersion=\"1\">\n")
  file(APPEND ${VPP_TEMP1} "    <title>${VPP_NAME} v${VPP_BUILD_TAG}</title>\n")
  if(EXISTS ${VPP_ABOUT_FILE})
  file(APPEND ${VPP_TEMP1} "    <readme file=\"${VPP_ABOUT_FILE}\"/>\n")
  endif()
  if(EXISTS ${VPP_ICON_FILE})
    file(APPEND ${VPP_TEMP1} "    <background file=\"${VPP_ICON_FILE}\"/>\n")
    file(APPEND ${VPP_TEMP1} "    <background alignment=\"bottomleft\"/>\n")
  endif()
  file(APPEND ${VPP_TEMP1} "    <options require-scripts=\"false\" customize=\"always\" hostArchitectures=\"${HOST_ARCH}\" rootVolumeOnly=\"true\"/>\n")
  file(WRITE ${VPP_TEMP2} "    <choices-outline>\n")
  file(WRITE ${VPP_TEMP3} "    </choices-outline>\n")

  function(vpp_add_plugin target)
    get_target_property(PLUGIN_NAME ${target} LIBRARY_OUTPUT_NAME)
    if(NOT PLUGIN_NAME)
      set(PLUGIN_NAME "${target}")
    endif()

    string(TOLOWER "com.ircam.${PLUGIN_NAME}.vamp.pkg" VPP_PACKAGE_UID)

    file(APPEND ${VPP_TEMP1} "    <pkg-ref id=\"${VPP_PACKAGE_UID}\"/>\n")
    file(APPEND ${VPP_TEMP2} "        <line choice=\"${VPP_PACKAGE_UID}\"/>\n")
    file(APPEND ${VPP_TEMP3} "    <choice id=\"${VPP_PACKAGE_UID}\" visible=\"true\" start_selected=\"true\" title=\"${PLUGIN_NAME}\"><pkg-ref id=\"${VPP_PACKAGE_UID}\"/></choice><pkg-ref id=\"${VPP_PACKAGE_UID}\" version=\"${VPP_BUILD_TAG}\" onConclusion=\"none\">${target}.pkg</pkg-ref>\n")

    if(VPP_NOTARIZE)
      set(PLUGIN_PKG_SCRIT "${VPP_TEMP_DIR}/${target}.sh")
      file(WRITE ${PLUGIN_PKG_SCRIT} "#!/bin/sh\n\n")
      file(CHMOD ${PLUGIN_PKG_SCRIT} PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
      file(APPEND ${PLUGIN_PKG_SCRIT} "codesign --sign \"${VPP_CODESIGN_APPLE_DEV_ID_APPLICATION_CERT}\" --entitlements \"${VPP_CODESIGN_ENTITLEMENTS}\" -f -o runtime --timestamp \"$1/${PLUGIN_NAME}.cat\"\n")
      file(APPEND ${PLUGIN_PKG_SCRIT} "codesign --sign \"${VPP_CODESIGN_APPLE_DEV_ID_APPLICATION_CERT}\" --entitlements \"${VPP_CODESIGN_ENTITLEMENTS}\" -f -o runtime --timestamp \"$1/${PLUGIN_NAME}.dylib\"\n")
      file(APPEND ${PLUGIN_PKG_SCRIT} "pkgbuild --sign \"${VPP_CODESIGN_APPLE_DEV_ID_INSTALLER_CERT}\" --timestamp --root \"$1\" --identifier \"${VPP_PACKAGE_UID}\" --version \"${VPP_BUILD_TAG}\" --install-location \"/Library/Audio/Plug-Ins/Vamp/\" \"${VPP_TEMP_DIR}/${target}.pkg\"\n")
      file(APPEND ${PLUGIN_PKG_SCRIT} "pkgutil --check-signature \"${VPP_TEMP_DIR}/${target}.pkg\"\n")
      add_custom_target(${target}_package COMMAND ${PLUGIN_PKG_SCRIT} $<TARGET_FILE_DIR:${target}>)
    else()
      add_custom_target(${target}_package COMMAND pkgbuild --root $<TARGET_FILE_DIR:${target}> --identifier "${VPP_PACKAGE_UID}" --version "${VPP_BUILD_TAG}" --install-location "/Library/Audio/Plug-Ins/Vamp/" "${VPP_TEMP_DIR}/${target}.pkg")
    endif()

    add_dependencies(${target}_package ${target})
    add_dependencies(${VPP_NAME}_package ${target}_package)
  endfunction(vpp_add_plugin)

  file(APPEND ${VPP_PACKAGE_SCRIPT} "cat ${VPP_TEMP1} ${VPP_TEMP2} ${VPP_TEMP3} > \"${VPP_DISRIB_XML}\"\n")
  file(APPEND ${VPP_PACKAGE_SCRIPT} "echo \"</installer-gui-script>\\n\" >> \"${VPP_DISRIB_XML}\"\n")
  if(VPP_NOTARIZE)
    file(APPEND ${VPP_PACKAGE_SCRIPT} "productbuild --sign \"${VPP_CODESIGN_APPLE_DEV_ID_INSTALLER_CERT}\" --timestamp --distribution \"${VPP_DISRIB_XML}\" --package-path \"${VPP_TEMP_DIR}\" \"${VPP_PACKAGE}\"\n")
    file(APPEND ${VPP_PACKAGE_SCRIPT} "xcrun notarytool submit \"${VPP_PACKAGE}\" --keychain-profile \"${VPP_CODESIGN_APPLE_KEYCHAIN_PROFILE_INSTALLER}\" --wait > \"${VPP_NOTARIZE_LOG}\" 2>&1\n")
    file(APPEND ${VPP_PACKAGE_SCRIPT} "notaryid=$(awk '/^  id:/{sub(/^  id:/, \"\"); print; exit}' \"${VPP_NOTARIZE_LOG}\")\n")
    file(APPEND ${VPP_PACKAGE_SCRIPT} "xcrun notarytool log $notaryid --keychain-profile \"${VPP_CODESIGN_APPLE_KEYCHAIN_PROFILE_INSTALLER}\" > \"${VPP_INFO_LOG}\" 2>&1\n")
    file(APPEND ${VPP_PACKAGE_SCRIPT} "xcrun stapler staple \"${VPP_PACKAGE}\"\n")
    file(APPEND ${VPP_PACKAGE_SCRIPT} "spctl -a -vvv -t install \"${VPP_PACKAGE}\"\n")
  else()
    file(APPEND ${VPP_PACKAGE_SCRIPT} "productbuild --distribution \"${VPP_DISRIB_XML}\" --package-path \"${VPP_TEMP_DIR}\" \"${VPP_PACKAGE}\"\n")
  endif()

  add_custom_target(${VPP_NAME}_package ALL COMMAND ${VPP_PACKAGE_SCRIPT})

elseif(UNIX) # LINUX
  set(VPP_PACKAGE "${VPP_DIR}/${VPP_NAME}-Linux.tar.gz")
  file(MAKE_DIRECTORY ${VPP_DIR})
  set(VPP_TEMP_DIR "${CMAKE_CURRENT_BINARY_DIR}/${VPP_NAME}")
  file(MAKE_DIRECTORY ${VPP_TEMP_DIR})

  if(EXISTS ${VPP_ABOUT_FILE})
    file(COPY ${VPP_ABOUT_FILE} DESTINATION ${VPP_TEMP_DIR})
  endif()

  if(EXISTS ${VPP_CHANGELOG_FILE})
    file(COPY ${VPP_CHANGELOG_FILE} DESTINATION ${VPP_TEMP_DIR})
  endif()
  
  set(VPP_INSTALL_SCRIPT "${VPP_TEMP_DIR}/Install.sh")
  file(WRITE ${VPP_INSTALL_SCRIPT} "#!/bin/sh\n\n")
  file(APPEND ${VPP_INSTALL_SCRIPT} "ThisPath=\"$( cd -- \"$(dirname \"$0\")\" >/dev/null 2>&1 ; pwd -P )\"\n")
  file(APPEND ${VPP_INSTALL_SCRIPT} "mkdir -p $HOME/vamp\n")
  file(CHMOD ${VPP_INSTALL_SCRIPT} PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)

  set(VPP_UNINSTALL_SCRIPT "${VPP_TEMP_DIR}/Uninstall.sh")
  file(WRITE ${VPP_UNINSTALL_SCRIPT} "#!/bin/sh\n\n")
  file(CHMOD ${VPP_UNINSTALL_SCRIPT} PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)

  function(vpp_add_plugin target)
    get_target_property(PLUGIN_NAME ${target} LIBRARY_OUTPUT_NAME)
    if(NOT PLUGIN_NAME)
      set(PLUGIN_NAME "${target}")
    endif()
    file(APPEND ${VPP_INSTALL_SCRIPT} "cp -f $ThisPath/${PLUGIN_NAME}.so $HOME/vamp\n")
    file(APPEND ${VPP_INSTALL_SCRIPT} "cp -f $ThisPath/${PLUGIN_NAME}.cat $HOME/vamp\n")
    file(APPEND ${VPP_UNINSTALL_SCRIPT} "rm -f $HOME/vamp/${PLUGIN_NAME}.so\n")
    file(APPEND ${VPP_UNINSTALL_SCRIPT} "rm -f $HOME/vamp/${PLUGIN_NAME}.cat\n")
    
    add_custom_target(${target}_package 
      COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:${target}> ${VPP_TEMP_DIR}/${PLUGIN_NAME}.so
      COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE_DIR:${target}>/${PLUGIN_NAME}.cat ${VPP_TEMP_DIR}/${PLUGIN_NAME}.cat
    )
    add_dependencies(${target}_package ${target})
    add_dependencies(${VPP_NAME}_package ${target}_package)
  endfunction(vpp_add_plugin)

  add_custom_target(${VPP_NAME}_package ALL COMMAND ${CMAKE_COMMAND} -E tar czf ${VPP_PACKAGE} ${VPP_TEMP_DIR})

endif()


 
