SRCREV:tie-jailhouse = "896df1648441f58a953f837e517e0410d374f3ed"

IPC_DM_FW = "ipc_echo_testb_mcu1_0_release_strip.xer5f"

# DM FW to be used only for AM62P tisdk-display-cluster image
DISPLAY_CLUSTER_FW = "dss_display_share.wkup-r5f0_0.release.strip.out"

DM_FIRMWARE:am62pxx = "${@oe.utils.conditional("DISPLAY_CLUSTER_ENABLE", "1", "${DISPLAY_CLUSTER_FW}", "${IPC_DM_FW}", d)}"

TI_DM="${STAGING_DIR_HOST}${nonarch_base_libdir}/firmware/ti-dm/${PLAT_SFX}/${DM_FIRMWARE}"

EXTRA_OEMAKE += "TI_DM=${TI_DM}"

PR:append = "_tisdk_5"

