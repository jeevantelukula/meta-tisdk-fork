# gcc15-compat.bbclass
#
# This class provides compatibility fixes for GCC 15+ which requires
# explicit inclusion of standard library headers that were previously
# included implicitly.
#
# Usage in recipe:
#   inherit gcc15-compat
#
#   # Define files and headers to add
#   GCC15_CSTDINT_FILES = "\
#       ${S}/path/to/file1.h \
#       ${S}/path/to/file2.cpp \
#   "
#
#   GCC15_CSTRING_FILES = "${S}/path/to/file3.h"
#   GCC15_ALGORITHM_FILES = "${S}/path/to/file4.h"

# Add missing #include <cstdint> for uint32_t, uint64_t, etc.
python gcc15_add_cstdint() {
    import os
    import re

    files = d.getVar('GCC15_CSTDINT_FILES')
    if not files:
        return

    for filepath in files.split():
        filepath = filepath.strip()
        if not filepath or not os.path.exists(filepath):
            continue

        with open(filepath, 'r') as f:
            content = f.read()

        # Check if already has the include
        if '#include <cstdint>' in content:
            continue

        # Add after #pragma once or after first include
        if '#pragma once' in content:
            content = re.sub(r'(#pragma once\n)', r'\1#include <cstdint>\n', content, count=1)
        elif '#include' in content:
            # Add after the first include block
            content = re.sub(r'(#include[^\n]*\n(?:#include[^\n]*\n)*)', r'\1#include <cstdint>\n', content, count=1)
        else:
            # Add at the beginning after any comments
            content = '#include <cstdint>\n' + content

        with open(filepath, 'w') as f:
            f.write(content)

        bb.note(f"Added #include <cstdint> to {filepath}")
}

# Add missing #include <cstring> for memcpy, strlen, etc.
python gcc15_add_cstring() {
    import os
    import re

    files = d.getVar('GCC15_CSTRING_FILES')
    if not files:
        return

    for filepath in files.split():
        filepath = filepath.strip()
        if not filepath or not os.path.exists(filepath):
            continue

        with open(filepath, 'r') as f:
            content = f.read()

        if '#include <cstring>' in content:
            continue

        if '#pragma once' in content:
            content = re.sub(r'(#pragma once\n)', r'\1#include <cstring>\n', content, count=1)
        elif '#include' in content:
            content = re.sub(r'(#include[^\n]*\n(?:#include[^\n]*\n)*)', r'\1#include <cstring>\n', content, count=1)
        else:
            content = '#include <cstring>\n' + content

        with open(filepath, 'w') as f:
            f.write(content)

        bb.note(f"Added #include <cstring> to {filepath}")
}

# Add missing #include <algorithm> for std::min, std::max, etc.
python gcc15_add_algorithm() {
    import os
    import re

    files = d.getVar('GCC15_ALGORITHM_FILES')
    if not files:
        return

    for filepath in files.split():
        filepath = filepath.strip()
        if not filepath or not os.path.exists(filepath):
            continue

        with open(filepath, 'r') as f:
            content = f.read()

        if '#include <algorithm>' in content:
            continue

        if '#pragma once' in content:
            content = re.sub(r'(#pragma once\n)', r'\1#include <algorithm>\n', content, count=1)
        elif '#include' in content:
            content = re.sub(r'(#include[^\n]*\n(?:#include[^\n]*\n)*)', r'\1#include <algorithm>\n', content, count=1)
        else:
            content = '#include <algorithm>\n' + content

        with open(filepath, 'w') as f:
            f.write(content)

        bb.note(f"Added #include <algorithm> to {filepath}")
}

# Shell-based alternative for simpler cases
gcc15_add_includes_shell() {
    # Add cstdint includes
    if [ -n "${GCC15_CSTDINT_FILES}" ]; then
        for header in ${GCC15_CSTDINT_FILES}; do
            if [ -f "$header" ] && ! grep -q '#include <cstdint>' "$header"; then
                sed -i '/#pragma once/a #include <cstdint>' "$header"
                bbnote "Added #include <cstdint> to $header"
            fi
        done
    fi

    # Add cstring includes
    if [ -n "${GCC15_CSTRING_FILES}" ]; then
        for header in ${GCC15_CSTRING_FILES}; do
            if [ -f "$header" ] && ! grep -q '#include <cstring>' "$header"; then
                sed -i '/#pragma once/a #include <cstring>' "$header"
                bbnote "Added #include <cstring> to $header"
            fi
        done
    fi

    # Add algorithm includes
    if [ -n "${GCC15_ALGORITHM_FILES}" ]; then
        for header in ${GCC15_ALGORITHM_FILES}; do
            if [ -f "$header" ] && ! grep -q '#include <algorithm>' "$header"; then
                sed -i '/#pragma once/a #include <algorithm>' "$header"
                bbnote "Added #include <algorithm> to $header"
            fi
        done
    fi
}

# Hook into do_patch - choose between Python or Shell implementation
# Default to shell for simplicity, but Python is available for complex cases
do_patch[postfuncs] += "${@'gcc15_add_includes_shell' if d.getVar('GCC15_USE_SHELL') != '0' else ''}"
do_patch[postfuncs] += "${@'gcc15_add_cstdint gcc15_add_cstring gcc15_add_algorithm' if d.getVar('GCC15_USE_SHELL') == '0' else ''}"

# Default to shell implementation
GCC15_USE_SHELL ??= "1"
