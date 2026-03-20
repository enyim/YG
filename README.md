# YG

A modern .NET wrapper for [Facebook's Yoga](https://www.yogalayout.dev/) — a cross-platform flexbox layout engine.

[![Build](https://github.com/enyim/YG/actions/workflows/build.yml/badge.svg)](https://github.com/enyim/YG/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

# Getting Started

## Prerequisites

- .NET 10 or later
- `pwsh` and [ClangSharpPInvokeGenerator](https://www.nuget.org/packages/ClangSharpPInvokeGenerator) to regenerate the bindings
- `cmake` to build the native parts

## Clone with submodules

The Yoga C++ source is included as a git submodule:

```bash
git clone --recurse-submodules https://github.com/enyim/YG.git
```

If you already cloned without submodules:

```bash
git submodule update --init --recursive
```

## Build Native

Build native part using

```
cd native
.\build.ps1 [-Arch x64|arm64]
```
There is no cross-compiling, each binary is built separately on the target platform.

## Bindings

```
cd src
.\codegen.ps1
```

# License

This project is licensed under the [MIT License](LICENSE).  
Copyright © 2026 Attila Kiskó.

Yoga itself is also MIT licensed — see [facebook/yoga](https://github.com/facebook/yoga) for details.
