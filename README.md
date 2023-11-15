# Drop-in replacement for Swift dylib used in https://github.com/roife/emt

Since compile Emacs dynamic module written in Swift requires both
Xcode and macOS 10.15 upwards, this is a replacement for those still
use an older version of OS X (lowest requirement is 10.5) (However, for
this particular module the NatrualLanguage framework used requires
at least 10.14).

This also serves as a demonstration on how to using Objective-C
directly for Emacs dynamic module.

Copyright 2023 LdBeth
