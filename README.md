SwiftLintAutoCorrect
====================

An Xcode plug-in to format your code using [SwiftLint](https://github.com/realm/SwiftLint).

Runs `swiftlint autocorrect --path CURRENT_FILE` before \*.swift file is saved.


INSTALLATION
------------

```bash
# This plugin does not bundle swiftlint binary.
# Please ensure swiftlint is on PATH.
brew update && brew install swiftlint

git clone https://github.com/ypresto/SwiftLintAutoCorrect
cd SwiftLintAutoCorrect
# Build and install.
xcodebuild -configuration Release
```

To uninstall, just remove plug-in directory.

```bash
rm -rf "$HOME/Library/Application Support/Developer/Shared/Xcode/Plug-ins/SwiftLintAutoCorrect.xcplugin"
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
