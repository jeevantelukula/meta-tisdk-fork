# Machine-specific backend and renderer configuration for slint-demos.
#
# AM62P (PowerVR GPU present): run as a Wayland client inside the Weston
# compositor with the Skia GPU-accelerated renderer. This mirrors how TI SDK
# Qt demos operate — Wayland client + hardware-accelerated rendering via the
# PowerVR GPU (mesa-pvr / virtual/libgl).
CARGO_FEATURES:am62pxx-evm = "slint/backend-winit-wayland slint/renderer-skia"

# AM62L (no GPU): bypass the compositor and drive the KMS framebuffer directly.
# FemtoVG and Skia both require OpenGL ES which has no hardware path on AM62L;
# the software renderer is purpose-built for CPU-only operation and delivers
# the best performance on this platform.
CARGO_FEATURES:am62lxx-evm = "slint/backend-linuxkms slint/renderer-software"

# Proxy handling for network-dependent do_compile (Skia binary/source download,
# Cargo registry fetch). No proxy URLs are hardcoded here; values come from
# the host environment and are forwarded into BitBake tasks via
# BB_ENV_PASSTHROUGH_ADDITIONS in conf/setenv. The explicit re-export ensures
# they propagate through the full cargo -> build-script -> curl sub-process
# chain, which would otherwise not inherit shell-level variables automatically.
do_compile:prepend() {
    export http_proxy https_proxy HTTP_PROXY HTTPS_PROXY no_proxy NO_PROXY
}
