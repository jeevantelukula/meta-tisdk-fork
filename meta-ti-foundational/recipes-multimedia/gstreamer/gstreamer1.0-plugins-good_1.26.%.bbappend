PR:append = ".tisdk1"

PACKAGECONFIG:append = " ${@bb.utils.contains('BBFILE_COLLECTIONS', 'qt6-layer', 'qt6', '', d)}"

QT6WAYLANDDEPENDS = "${@bb.utils.contains("DISTRO_FEATURES", "wayland", "qtwayland", "", d)}"

PACKAGECONFIG[qt6] = "-Dqt6=enabled, -Dqt6=disabled, qtbase qtbase-native qtdeclarative qttools-native ${QT6WAYLANDDEPENDS}"

# Qt tools like rcc, moc and uic are located in /usr/libexec, instead of
# /usr/bin, which is not in PATH by default.
do_configure:prepend:class-target() {
	export PATH=${STAGING_DIR_NATIVE}${libexecdir}:$PATH

	# Fix Meson Qt6 cross-compilation: prepend sysroot to Qt private header paths
	MESON_QT_PY="${STAGING_DIR_NATIVE}/usr/lib/python3.13/site-packages/mesonbuild/dependencies/qt.py"

	if [ -f "$MESON_QT_PY" ] && ! grep -q "YOCTO_SYSROOT_FIX" "$MESON_QT_PY"; then
		bbnote "Patching Meson Qt module for sysroot support"
		sed -i '/^def _qt_get_private_includes/,/^    return \[private_dir/ {
			s|^    private_dir = os.path.join(mod_inc_dir, mod_version)$|&\n    sysroot = os.environ.get("PKG_CONFIG_SYSROOT_DIR", "")|
			s|if os.path.isdir(mod_inc_dir) and not os.path.exists(private_dir):|if os.path.isdir((sysroot + mod_inc_dir) if sysroot else mod_inc_dir) and not os.path.exists((sysroot + private_dir) if sysroot else private_dir):|
			s|os.listdir(mod_inc_dir)|os.listdir((sysroot + mod_inc_dir) if sysroot else mod_inc_dir)|
			s|os.path.isdir(os.path.join(mod_inc_dir, filename))|os.path.isdir(os.path.join((sysroot + mod_inc_dir) if sysroot else mod_inc_dir, filename))|
			s|private_dir = dirname$|private_dir = os.path.join(mod_inc_dir, dirname)|
			s|^    return \[private_dir|    # YOCTO_SYSROOT_FIX\n    private_dir = (sysroot + private_dir) if sysroot and not private_dir.startswith(sysroot) else private_dir\n&|
		}' "$MESON_QT_PY"
	fi
}
