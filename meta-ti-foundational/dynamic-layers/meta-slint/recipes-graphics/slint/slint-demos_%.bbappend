# Default to software renderer for all TI SDK targets.
# SLINT_RENDERER = "software"

# Enable LTO for software renderer builds (no Skia = no RAM pressure).
# Gives 5-15% runtime improvement, especially beneficial on Cortex-A53
# do_compile:prepend() {
#     export CARGO_PROFILE_RELEASE_LTO=true
# }

# Explicitly re-export proxy settings so they reach curl subprocesses
# spawned deep inside the skia-bindings build script (Cargo build scripts
# run in a sub-process chain that may not inherit shell-level passthrough).
do_compile:prepend() {
    export http_proxy="http://webproxy.ext.ti.com:80"
    export https_proxy="http://webproxy.ext.ti.com:80"
    export HTTP_PROXY="http://webproxy.ext.ti.com:80"
    export HTTPS_PROXY="http://webproxy.ext.ti.com:80"
    export no_proxy="ti.com,localhost,127.0.0.1"
}
