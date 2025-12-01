<a href="https://omega.gg/Sky"><img src="dist/pictures/Sky-runtime.png" alt="Sky-runtime" width="512px"></a>
---
[![azure](https://dev.azure.com/bunjee/Sky-runtime/_apis/build/status/omega-gg.Sky-runtime)](https://dev.azure.com/bunjee/Sky-runtime/_build)
[![appveyor](https://ci.appveyor.com/api/projects/status/yto6yi6aepvvl805?svg=true)](https://ci.appveyor.com/project/3unjee/Sky-runtime)
[![GPLv3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl.html)

The Sky runtime is a project driven aplication designed to run QML .sky files in tandem with [Sky kit](https://omega.gg/Sky/sources)
C++ API(s) and UI components. It allows for versatile use cases while keeping things simple and
minimalistic.

- [Bash scripts](bash/README.md)

## Extensions

- [hypergonar](https://omega.gg/hypergonar/sources) - Frame compositor for generative software

## Technology

sky is built in C++ with [Sky kit](https://omega.gg/Sky/sources).<br>

## Platforms

- Windows XP and later.
- macOS 64 bit.
- Linux 32 bit and 64 bit.
- iOS 64 bit.
- Android 32 bit and 64 bit.

## Requirements

- [Sky](https://omega.gg/Sky/sources) latest version.
- [Qt](https://download.qt.io/official_releases/qt) 4.8.0 / 5.5.0 or later.

On Windows:
- [MinGW](https://sourceforge.net/projects/mingw) or [Git for Windows](https://git-for-windows.github.io) with g++ 4.9.2 or later.

Recommended:
- [Qt Creator](https://download.qt.io/official_releases/qtcreator) 3.6.0 or later.

## 3rdparty

You can install third party libraries with:

    sh 3rdparty.sh <win32 | win64 | macOS | iOS | linux | android> [all]

## Configure

You can configure sky with:

    sh configure.sh <win32 | win64 | macOS | iOS | linux | android> [sky | clean]

## Build

You can build sky with:

    sh build.sh <win32 | win64 | macOS | iOS | linux | android> [all | deploy | clean]

## Deploy

You can deploy sky with:

    sh deploy.sh <win32 | win64 | macOS | iOS | linux | android> [clean]

## License

Copyright (C) 2015 - 2024 Sky kit runtime authors | https://omega.gg/Sky

### Authors

- Benjamin Arnaud aka [bunjee](https://bunjee.me) | <bunjee@omega.gg>

### GNU General Public License Usage

sky may be used under the terms of the GNU General Public License version 3 as published by the
Free Software Foundation and appearing in the LICENSE.md file included in the packaging of this
file. Please review the following information to ensure the GNU General Public License requirements
will be met: https://www.gnu.org/licenses/gpl.html.

### Private License Usage

sky licensees holding valid private licenses may use this file in accordance with the private
license agreement provided with the Software or, alternatively, in accordance with the terms
contained in written agreement between you and sky authors. For further information contact us at
contact@omega.gg.
