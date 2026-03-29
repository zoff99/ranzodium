# Ranzodium

libsodium secure random numbers for Android<br>
<br>
Ranzodium is a specialized Android library designed to provide cryptographically secure random numbers by bridging the high-performance libsodium library to the Android ecosystem. It addresses the need for reliable, audited entropy sources in mobile applications by exposing libsodium's randombytes_uniform functionality through a Java Native Interface (JNI) wrapper.<br>
<br>
The project encompasses the entire lifecycle of this bridge: from the automated cross-compilation of native C dependencies for multiple Android ABIs to the packaging of an Android Archive (AAR) and a demonstration application that visualizes the distribution of the generated randomness.

Status
=
[![Android CI](https://github.com/zoff99/ranzodium/actions/workflows/app_startup.yml/badge.svg?branch=master)](https://github.com/zoff99/ranzodium/actions/workflows/app_startup.yml)
[![Liberapay](https://img.shields.io/liberapay/goal/zoff.svg?logo=liberapay)](https://liberapay.com/zoff/donate)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/zoff99/ranzodium)

Latest Automated Screenshots
=

<img src="https://github.com/zoff99/ranzodium/releases/download/nightly/android_screen01_21.png" width="150">&nbsp;<img src="https://github.com/zoff99/ranzodium/releases/download/nightly/android_screen01_29.png" width="150">&nbsp;<img src="https://github.com/zoff99/ranzodium/releases/download/nightly/android_screen01_33.png" width="150">&nbsp;<img src="https://github.com/zoff99/ranzodium/releases/download/nightly/android_screen01_35.png" width="150">

<br>
Any use of this project's code by GitHub Copilot, past or present, is done
without our permission.  We do not consent to GitHub's use of this project's
code in Copilot.
<br>
No part of this work may be used or reproduced in any manner for the purpose of training artificial intelligence technologies or systems.

