# Display  Hardware Information





This chart summarizes all the commands covered in this article need <span  style="color: #ff1bce; ">sudo </span>

| Describe                                                     | CMD                                                          |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| Display info about all hardware                              | **inxi -Fx**   *--or--*  **lshw -short**                     |
| Determine the amount of video memory                         | **lspci \| grep -i vga**  then reissue with the device number;  for example: **lspci -v -s 00:02.0**  The VRAM is the *prefetchable* value. |
| Display all CPU info                                         | **lscpu**         *--or--*  **lshw -C cpu**                  |
| List information about disks and partitions                  | **lsblk**   (simple)   *--or--*  **fdisk -l**  (detailed)    |
| List USB devices                                             | **lsusb**                                                    |
| List PCI devices                                             | **lspci**                                                    |
| List partition IDs (UUIDs)                                   | **blkid**                                                    |
| List mounted filesystems, their mount points,  and megabytes used and available for each | **df -h**                                                    |
| Show kernel version, network hostname, more                  | **uname -a**                                                 |
| Show current memory use                                      | **free -m**  *--or--*  **top**                               |
| Show detailed information about a specific disk drive        | **hdparm -i /dev/sda**                                       |
| Display routing tables                                       | **ip route \| column -t` `**--or--  **netstat -r**           |
| Show network interfaces                                      | **ifconfig -a**    *--or--*  **ip link show**  *--or--*  **netstat -i** |
| Get type                                                     | **lshw -short **                                             |
|                                                              | **lshw -c cpu\|**                                            |
| Show CPU features (e.g., PAE, SSE2)                          | **lshw -c cpu \| grep -i capabilities**                      |
| Report whether the CPU is 32- or 64-bit                      | **lshw -c cpu \| grep -i width**                             |
| Determine whether memory slots are available                 | **lshw -short -c memory \| grep -i empty**  (a null answer means no slots available) |
| List the disk drives                                         | **lshw -short -c disk**                                      |
| Show network card details                                    | **lshw -c network**                                          |
| Show maximum memory for the hardware                         | **dmidecode -t memory \| grep -i max**                       |
| Get type                                                     | **dmidecode -t **                                            |
| display information about the processor/cpu                  | **dmidecode -t processor**                                   |
| memory/ram information                                       | **dmidecode -t memory**                                      |
| Display UEFI/BIOS info                                       | **dmidecode -t bios**                                        |
| Show current memory size and configuration                   | **dmidecode -t memory \| grep -i size**  *--or--*  **lshw -short -C memory** |
| Inxi                                                         | **sudo inxi -C; inxi -b; inxi -m; inxi -Fx**                 |
|                                                              |                                                              |
| List nvme                                                    | nvme list                                                    |
| Check nvme health                                            | sudo smartctl --all /dev/nvme1n1                             |
|                                                              |                                                              |
|                                                              |                                                              |
|                                                              |                                                              |
| DMI                                                          | Desktop Management Interface                                 |
| **System Management BIOS** (**SMBIOS**)                      | SMBIOS was originally known as Desktop Management BIOS (**DMIBIOS**), since it interacted with the |
| dmidecode                                                    | It extracts hardware information by reading data from the [SMBOIS data structures](https://en.wikipedia.org/wiki/System_Management_BIOS) (also called DMI tables). |





### Install tool



~~~shell

sudo apt-get install smartmontools

sudo apt install nvme-cli
~~~

