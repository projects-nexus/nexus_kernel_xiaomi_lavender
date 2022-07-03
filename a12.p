From 7bd6803cb397f0b9a358ff27b5e63ece200ff975 Mon Sep 17 00:00:00 2001
From: ImSpiDy <SpiDy2713@gmail.com>
Date: Sat, 2 Apr 2022 18:41:22 +0000
Subject: [PATCH] defconfig: enable NETFILTER_XT_MATCH_OWNER

* Fixes upload speed on A12 but Rip on A10/11

Signed-off-by: ImSpiDy <SpiDy2713@gmail.com>
---
 arch/arm64/configs/lavender-perf_defconfig | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/arm64/configs/lavender-perf_defconfig b/arch/arm64/configs/lavender-perf_defconfig
index fa254892f64a..e0e4dc7595d4 100644
--- a/arch/arm64/configs/lavender-perf_defconfig
+++ b/arch/arm64/configs/lavender-perf_defconfig
@@ -907,10 +907,10 @@ CONFIG_NETFILTER_XT_MATCH_MARK=y
 CONFIG_NETFILTER_XT_MATCH_MULTIPORT=y
 # CONFIG_NETFILTER_XT_MATCH_NFACCT is not set
 # CONFIG_NETFILTER_XT_MATCH_OSF is not set
-# CONFIG_NETFILTER_XT_MATCH_OWNER is not set
+CONFIG_NETFILTER_XT_MATCH_OWNER=y
 CONFIG_NETFILTER_XT_MATCH_POLICY=y
 CONFIG_NETFILTER_XT_MATCH_PKTTYPE=y
-CONFIG_NETFILTER_XT_MATCH_QTAGUID=y
+# CONFIG_NETFILTER_XT_MATCH_QTAGUID is not set
 CONFIG_NETFILTER_XT_MATCH_QUOTA=y
 CONFIG_NETFILTER_XT_MATCH_QUOTA2=y
 # CONFIG_NETFILTER_XT_MATCH_QUOTA2_LOG is not set
-- 
2.30.2
