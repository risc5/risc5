# Linux Basic





## Background

The **BMC** (Baseboard Management Controller) is a specialized microcontroller embedded in most server-grade motherboards. It manages system monitoring (temperature, voltage, fan speeds) and enables remote management features like IPMI, KVM-over-IP, and remote power control.

Occasionally, the BMC may become unresponsive or require a reset after configuration changes, firmware updates, or system faults. Resetting the BMC clears temporary issues without rebooting the main server.

------

## Requirements

- ipmitool package installed on the server
- Root or sudo access to execute IPMI commands
- Access to the local BMC (over ipmitool's **local** interface)

## Installation of ipmitool (if needed)

On RHEL/CentOS/Rocky Linux systems:

```
sudo yum install ipmitool
```

 

On Ubuntu/Debian systems:

```
sudo apt install ipmitool
```

##  Resetting the BMC

### 1. Verify Access to the BMC

First, ensure you can communicate with the BMC:

 

```
sudo ipmitool mc info
```

You should see output containing BMC firmware revision, manufacturer ID, etc. If this fails, verify your system’s IPMI driver is loaded  (moprobe ipmi_si)

###  

### 2. Issue the BMC Reset Command

Run the following command to perform a **soft reset**:

```
sudo ipmitool mc reset warm
```

- warm reset will restart the BMC controller without interrupting or rebooting the host server.

If a warm reset doesn't clear your problem, you can attempt a cold reset (harder reset, more disruptive):

```
sudo ipmitool mc reset cold
```

- Cold reset will reinitialize the BMC hardware more aggressively but **still does not reboot the server itself**.

 

⚠️ Important Notes

- Some BMC resets may cause temporary disconnection from remote management interfaces (IPMI/iKVM/Redfish sessions).
- Network interfaces controlled by the BMC (e.g., dedicated IPMI LAN ports) may briefly reset.
- Always prefer a warm reset first unless otherwise instructed by your hardware vendor.

## Verifying BMC Reset

After about 30–60 seconds, recheck the BMC status:

```
sudo ipmitool mc info
```

 

If you see a response, the BMC has restarted successfully.

## Example Session

```
root@benchmark-svr:# ipmitool mc info
Device ID : 32
Device Revision : 1
Firmware Revision : 1.01
IPMI Version : 2.0
Manufacturer ID : 2623
Manufacturer Name : Unknown (0xA3F)
Product ID : 4499 (0x1193)
Product Name : Unknown (0x1193)
Device Available : yes
Provides Device SDRs : yes
```

## Troubleshooting

If you encounter issues:

- Check that **ipmi_si** and **ipmi_devintf** kernel modules are loaded.
- Check `dmesg` or `journalctl -xe` for IPMI-related error logs.
- Verify no firewall or network configuration is blocking local IPMI communication.

------





# Supermicro





How to reset IPMI (Hard Reset)  *

**Locally:***

1. *Use “IPMICFG –raw* 0x30 0x41*” to reset to factory default*
2. *Remove AC power cord for ~1 minute*

*IPMICFG can be downloaded from the FTP (includes DOS, Windows and Linux versions)*

[*https://www.supermicro.nl/wftp/utility/IPMICFG/*](https://www.supermicro.nl/wftp/utility/IPMICFG/)

[*http://www.supermicro.com/SwDownload/UserInfo.aspx?sw=0&cat=IPMI*](http://www.supermicro.com/SwDownload/UserInfo.aspx?sw=0&cat=IPMI#_blank)

 

***Remote:***

1. *Use “SMCIPMITool <IP> <username> <password> IPMI RAW 30 41”*
2. *Remove AC power cord for ~1 minute*

 

*SMCIPMITool can be downloaded from the FTP (Includes Windows and Linux versions)*

[*https://www.supermicro.nl/wftp/utility/SMCIPMItool/*](https://www.supermicro.nl/wftp/utility/SMCIPMItool/)

- *The login credentials will be ADMIN /ADMIN again.* (or <span  style="color: #ff1bce; ">the default unique password for new systems (2020)</span>)
- *We highly recommend clearing the browser and JAVA caches to prevent issues coming back.*
- ***Be aware this reset will also reset networking settings to default (DHCP).\***

***If this is a problem you can try using “IPMICFG –FD”, which doesn’t reset the networking, but may also not solve your problem.\***

<span  style="color: #ff1bce; ">IPMICFG –FD</span>

 **Important information:**

|               | **Reset****Network** | **Reset****Users info** | **Reset****FRU** | **ADMIN password** |
| ------------- | -------------------- | ----------------------- | ---------------- | ------------------ |
| **0x30 0x40** | N                    | Y                       | N                | Unique Password    |
| **0x30 0x41** | Y                    | Y                       | Y                | Unique Password    |
| **0x30 0x42** | Y                    | Y                       | N                | Unique Password    |

**Related Pages:**









ADMIN

Pwd主板上







192.168.1.9





### BIOS

* DEL 进入bios
*  F11 进入 硬盘启动选项