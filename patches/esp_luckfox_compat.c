// SPDX-License-Identifier: GPL-2.0-only
/*
 * Build glue for the Rockchip/Luckfox 5.10 BSP kernel (RV1103/RV1106).
 *
 * 1. That kernel is Android-derived and exports filp_open()/kernel_read()
 *    only inside a symbol namespace, which the OTA path of this driver uses.
 * 2. The stock Luckfox kernel is built without CONFIG_BT, so the HCI core
 *    symbols referenced by esp_bt.c do not exist. Wi-Fi does not need them:
 *    Bluetooth is only started on request (radio_service=bt), so provide
 *    stubs that make that request fail cleanly instead of failing the link.
 */

#include <linux/module.h>
#include <linux/version.h>
#include <linux/skbuff.h>
#include <net/bluetooth/bluetooth.h>
#include <net/bluetooth/hci_core.h>

#ifdef MODULE_IMPORT_NS
MODULE_IMPORT_NS(VFS_internal_I_am_really_a_filesystem_and_am_NOT_a_driver);
#endif

#if !IS_ENABLED(CONFIG_BT)

struct hci_dev *hci_alloc_dev(void)
{
	pr_warn("esp32: kernel built without CONFIG_BT, Bluetooth is unavailable\n");
	return NULL;
}

void hci_free_dev(struct hci_dev *hdev)
{
}

int hci_register_dev(struct hci_dev *hdev)
{
	return -EOPNOTSUPP;
}

void hci_unregister_dev(struct hci_dev *hdev)
{
}

int hci_recv_frame(struct hci_dev *hdev, struct sk_buff *skb)
{
	kfree_skb(skb);
	return -EOPNOTSUPP;
}

void bt_err(const char *format, ...)
{
	struct va_format vaf;
	va_list args;

	va_start(args, format);
	vaf.fmt = format;
	vaf.va = &args;
	pr_err("esp32 bt: %pV", &vaf);
	va_end(args);
}

#endif /* !CONFIG_BT */
