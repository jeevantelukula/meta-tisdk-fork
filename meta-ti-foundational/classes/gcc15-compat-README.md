# GCC 15+ Compatibility Class

## Overview
This bbclass (`gcc15-compat.bbclass`) provides reusable fixes for GCC 15+ compatibility issues where standard library headers must be explicitly included.

## Common Issues Fixed
- Missing `#include <cstdint>` for `uint32_t`, `uint64_t`, etc.
- Missing `#include <cstring>` for `memcpy`, `strlen`, etc.
- Missing `#include <algorithm>` for `std::min`, `std::max`, etc.

## Usage

### Basic Usage
```bitbake
inherit gcc15-compat

# Specify files that need cstdint include
GCC15_CSTDINT_FILES = "\
    ${S}/src/header1.h \
    ${S}/src/header2.cpp \
"
```

### Multiple Include Types
```bitbake
inherit gcc15-compat

# Files needing different includes
GCC15_CSTDINT_FILES = "${S}/include/types.h"
GCC15_CSTRING_FILES = "${S}/src/utils.cpp"
GCC15_ALGORITHM_FILES = "${S}/include/algorithms.h"
```

### Using Python Implementation
For more complex scenarios (multiline includes, specific placement):
```bitbake
inherit gcc15-compat

GCC15_USE_SHELL = "0"  # Use Python implementation instead of shell
GCC15_CSTDINT_FILES = "${S}/complex/header.h"
```

## Real-World Examples

### Example 1: PowerVR Graphics
```bitbake
inherit cmake pkgconfig gcc15-compat

EXTRA_OECMAKE += " -DCMAKE_POLICY_VERSION_MINIMUM=3.5"

GCC15_CSTDINT_FILES = "\
    ${S}/framework/PVRCore/strings/StringFunctions.h \
    ${S}/framework/PVRCore/stream/Stream.h \
"
```

### Example 2: Legacy C++ Library
```bitbake
inherit autotools gcc15-compat

GCC15_CSTDINT_FILES = "\
    ${S}/include/types.h \
    ${S}/include/platform.h \
"

GCC15_CSTRING_FILES = "\
    ${S}/src/string_utils.cpp \
"
```

### Example 3: Header-Only Library
```bitbake
inherit gcc15-compat

GCC15_CSTDINT_FILES = "${S}/single_header.hpp"
GCC15_ALGORITHM_FILES = "${S}/single_header.hpp"
```

## How It Works
1. The class hooks into `do_patch[postfuncs]`
2. After patches are applied, it scans specified files
3. Checks if includes are already present (idempotent)
4. Adds missing includes after `#pragma once` or first include block
5. Logs actions via `bbnote`

## Implementation Modes

### Shell Mode (Default)
- Fast and simple
- Uses `sed` to add includes
- Works for 99% of cases
- Set via: `GCC15_USE_SHELL = "1"` (default)

### Python Mode
- More robust
- Better regex handling
- Can handle complex file structures
- Set via: `GCC15_USE_SHELL = "0"`

## Extending for Other Headers
To add support for other standard library headers, edit the bbclass:

```python
python gcc15_add_yourheader() {
    # Similar implementation to existing functions
    files = d.getVar('GCC15_YOURHEADER_FILES')
    # ... add logic
}
```

Then add to postfuncs:
```bitbake
do_patch[postfuncs] += "gcc15_add_yourheader"
```

## Benefits
✅ **Reusable**: Single bbclass for all recipes
✅ **Scalable**: Easy to add new recipes
✅ **Maintainable**: Centralized fix location
✅ **Idempotent**: Safe to run multiple times
✅ **Flexible**: Supports shell and Python modes
✅ **Documented**: Clear usage examples

## Troubleshooting

### Issue: Files not being modified
**Check:**
1. File paths use `${S}` correctly
2. Files exist at patch time (not generated later)
3. Check bitbake output for `bbnote` messages

### Issue: Include added in wrong place
**Solution:**
- Switch to Python mode: `GCC15_USE_SHELL = "0"`
- Python mode has better placement logic

### Issue: Multiple recipes need same fix
**Solution:**
- Create a common `.inc` file:
```bitbake
# gcc15-common.inc
inherit gcc15-compat
GCC15_CSTDINT_FILES = "${S}/common/header.h"
```

Then in recipes:
```bitbake
require gcc15-common.inc
```
