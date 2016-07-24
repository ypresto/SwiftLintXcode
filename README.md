SwiftLintXcode
==============

An Xcode plug-in to format your code using [SwiftLint](https://github.com/realm/SwiftLint).

Runs `swiftlint autocorrect --path CURRENT_FILE` before \*.swift file is saved.

![Screenshot](https://cloud.githubusercontent.com/assets/400558/14304460/d2a133dc-fbed-11e5-9573-2c21cce699e0.png)

IMPORTANT:  Xcode 8
-------------------

Xcode 8 won't load any unsigned plugins.
https://github.com/alcatraz/Alcatraz/issues/475

INSTALLATION
------------

Install via [Alcatraz](https://github.com/alcatraz/Alcatraz), a package manager for Xcode.

This plugin does not bundle swiftlint binary. Please ensure swiftlint is on PATH.

```bash
brew update && brew install swiftlint
```

### Manual installation

```bash
git clone https://github.com/ypresto/SwiftLintXcode
cd SwiftLintXcode
# Build and install.
xcodebuild -configuration Release
```

To uninstall, just remove plug-in directory.

```bash
rm -rf "$HOME/Library/Application Support/Developer/Shared/Xcode/Plug-ins/SwiftLintXcode.xcplugin"
```


THANKS
------

This plug-in contains TRVSXcode from [ClangFormat-Xcode](https://github.com/travisjeffery/ClangFormat-Xcode)
to interact with Xcode internal interface.

ClangFormat-Xcode is awesome plugin for auto-formatting Objective-C code..!


LICENSE
-------

```
The MIT License (MIT)

Copyright (c) 2016 Yuya Tanaka <https://github.com/ypresto>

(For TRVSXcode from ClangFormat-Xcode)
Copyright (c) 2014 Travis Jeffery <https://travisjeffery.com, https://twitter.com/travisjeffery, https://github.com/travisjeffery>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```
