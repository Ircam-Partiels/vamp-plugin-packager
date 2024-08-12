# Vamp Plugin Packager
**A CMake script for packaging Vamp plugins**

This CMake script automatically generates Vamp plugin installation packages for macOS, Windows and Linux operating systems and can automatically sign and notarise packages on macOS and Windows. The variables and options used to configure the packaging and signature are described in the header of the CMake script.

## Example 
```
set(VPP_NAME "MySuperProject" CACHE PATH "The name of the project")
set(VPP_COMPANY "MySuperCompany" CACHE PATH "The name of the company")
set(VPP_URL "MySuperWebsite" CACHE PATH "The URL of the project")
...
include(vamp-plugin-packager/vamp-plugin-packager.cmake)
```

> ⚠️ Packaging under Windows requires InnoSetup. 

## Credits

- **[Vamp Plugin Packager](https://www.ircam.fr/)** by Pierre Guillot at IRCAM IMR Department
- **[Vamp SDK](https://github.com/vamp-plugins/vamp-plugin-sdk)** by Chris Cannam, copyright (c) 2005-2024 Chris Cannam and Centre for Digital Music, Queen Mary, University of London.
