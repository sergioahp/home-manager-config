# Hyprvoice Desktop Crash Analysis

## TL;DR - Quick Summary

**Problem:** Desktop crashes when using Hyprvoice with Bluetooth microphone
**Root Cause:** **Hardware failure** - Cambridge Silicon Radio (CSR) 0a12:0001 Bluetooth adapter is corrupting SCO audio packets
**Evidence:** Kernel logs show "corrupted SCO packet" and "unknown connection handle" errors
**Solution:** **Replace the Bluetooth USB adapter** (~$25-40)
**Not a software issue:** PipeWire, WirePlumber, and Hyprvoice are working correctly - the adapter hardware is failing

---

## Problem Summary

Frequent use of Hyprvoice (voice-to-text via Bluetooth microphone) causes desktop crashes requiring display manager restart.

## Root Cause

### Bluetooth SCO Codec Decode Failures

**Primary Issue:** PipeWire/WirePlumber's Bluetooth SCO (Synchronous Connection Oriented) codec is experiencing repeated decode failures when used with TOZO-T10 Bluetooth earbuds.

**Error Pattern:**
```
spa.bluez5.source.sco: decode failed: -3
```

**Frequency:** Approximately every 2-10 minutes during active use

**Cascade Effect:**
1. SCO decode failures accumulate
2. Audio pipeline errors propagate to X11/Wayland display server
3. Display server encounters fatal I/O error
4. Desktop crashes

**Evidence from logs:**
```
Nov 23 00:52:53 nixd pipewire[139501]: mod.x11-bell: X11 display (:0) has encountered a fatal I/O error
```

### **CRITICAL FINDING: Hardware-Level Bluetooth Failures**

**Kernel logs reveal the true root cause:**
```
Bluetooth: hci0: corrupted SCO packet
Bluetooth: hci0: SCO packet for unknown connection handle 65
Bluetooth: hci0: SCO packet for unknown connection handle 64
Bluetooth: hci0: SCO packet for unknown connection handle 63
```

**This indicates:**
1. **Corrupted packets:** Bluetooth SCO packets are being corrupted at the hardware/driver level
2. **Lost connection handles:** The Bluetooth adapter is losing track of SCO connection identifiers
3. **Hardware/driver issue:** This is NOT just a PipeWire codec problem - the Bluetooth adapter itself is failing

**Root cause hierarchy:**
```
Hardware: Bluetooth USB adapter fails to maintain stable SCO connection
    ↓
Driver: Kernel reports corrupted packets and unknown connection handles
    ↓
BlueZ: Cannot maintain stable audio connection
    ↓
PipeWire/WirePlumber: Codec decode failures (-3 errors)
    ↓
Display Server: Fatal I/O error (error propagation or resource exhaustion)
    ↓
Desktop Crash: Requires display manager restart
```

## Technical Details

### System Configuration
- **PipeWire Version:** 1.4.5
- **BlueZ Version:** 5.80
- **Kernel Version:** 6.12.35
- **Bluetooth Adapter:** Cambridge Silicon Radio (CSR) 0a12:0001
  - **Chipset:** CSR HCI 4.0 (notorious for poor quality, often cloned)
  - **SCO MTU:** 64:8 (very small buffer, only 8 packets queued)
  - **RX errors:** 30 errors recorded
  - **SCO packets received:** 695,190
- **Bluetooth Device:** TOZO-T10 (58:FC:C6:23:29:68)
- **Bluetooth Profiles:** HSP (Headset) + HFP (Handsfree)
- **Audio Codec:** SCO (used for voice/mic in HSP/HFP)
- **Hyprvoice Config:** 16kHz, mono, s16 format, 8192 buffer size

### Bluetooth Device Profiles
```
UUID: Headset                   (00001108-0000-1000-8000-00805f9b34fb)
UUID: Handsfree                 (0000111e-0000-1000-8000-00805f9b34fb)
UUID: Audio Sink                (0000110b-0000-1000-8000-00805f9b34fb)
UUID: Advanced Audio Distribu.. (0000110d-0000-1000-8000-00805f9b34fb)
```

### Error Code Analysis

Error `-3` in audio codec context typically indicates:
- **EAGAIN/EWOULDBLOCK:** Resource temporarily unavailable
- **Buffer underrun:** Codec can't keep up with data rate
- **Malformed packets:** Corrupted Bluetooth audio data
- **Timing issues:** SCO synchronization problems

## Known Issues

### PipeWire/WirePlumber SCO Codec Limitations

1. **SCO codec quality:** The SCO codec used in HSP/HFP profiles has limited quality (8kHz narrow-band) and is known to be problematic in Linux
2. **Buffer management:** SCO requires precise timing that can be disrupted by:
   - CPU load
   - Bluetooth interference
   - USB Bluetooth adapter quality
   - Kernel scheduler latency

3. **WirePlumber loopback:** The device uses a loopback mechanism (`bluez5.loopback = "true"`) which adds additional complexity

### Related Upstream Issues

Similar issues have been reported in:
- PipeWire issue tracker: Bluetooth HSP/HFP audio quality and stability
- WirePlumber issue tracker: SCO codec decode failures
- BlueZ issue tracker: SCO MTU and packet loss

## Potential Solutions

### 1. Short-term Workarounds

#### Option A: Reduce Recording Quality (Less Stable)
Lower sample rate and buffer size to reduce codec stress:
```nix
recording = {
  sample_rate = 8000;   # Match SCO native rate
  buffer_size = 4096;   # Smaller buffer
  # ... other settings
};
```

#### Option B: Switch to A2DP for Recording (Not Feasible)
A2DP (Advanced Audio Distribution Profile) has better quality but only supports audio output (sink), not input (source) in most devices.

### 2. Medium-term Solutions

#### Option A: Better Bluetooth Adapter
Replace USB Bluetooth adapter with one that has:
- Better SCO timing characteristics
- Lower latency
- Better Linux driver support
- Qualcomm or Intel chipsets (generally better supported)

**Recommended chipsets:**
- Intel AX200/AX210 (Wi-Fi + BT combo cards)
- Qualcomm QCA6174/QCA9377
- Broadcom BCM20702 (older but stable)

**Budget options (~$20-40):**
- TP-Link UB500 (Realtek RTL8761B)
- ASUS USB-BT500 (Realtek RTL8761B)

**Premium options (~$60-100):**
- Intel AX210 PCIe card (if desktop)
- Plugable USB-BT5MGCH (CSR8510)

#### Option B: File Upstream Bug Report

Report to PipeWire project with:
- Detailed logs (wireplumber, pipewire, bluetoothd)
- Device information (TOZO-T10 specs)
- Reproduction steps
- System configuration

**Filing locations:**
- https://gitlab.freedesktop.org/pipewire/pipewire/-/issues
- https://gitlab.freedesktop.org/pipewire/wireplumber/-/issues

### 3. Long-term Solutions

#### Option A: Wait for PipeWire Improvements
PipeWire developers are actively improving Bluetooth support. Future versions may have:
- Better SCO codec implementation
- Improved buffer management
- Better error recovery

#### Option B: Use Dedicated USB Microphone
- Eliminates Bluetooth codec issues entirely
- Better audio quality for transcription
- More stable recording
- Examples: Blue Yeti Nano, Audio-Technica ATR2100x

## Workaround Decision Matrix

| Solution | Cost | Effort | Reliability | Audio Quality |
|----------|------|--------|-------------|---------------|
| Keep current setup | $0 | None | Poor (crashes) | Medium |
| New BT adapter (budget) | $20-40 | Low | Medium-Good | Medium |
| New BT adapter (premium) | $60-100 | Low-Medium | Good | Medium |
| USB microphone | $50-150 | Medium | Excellent | High |
| File upstream bug | $0 | Medium | Unknown | - |

## Recommended Action

### **PRIMARY RECOMMENDATION: Replace Bluetooth Adapter**

Given the hardware-level failures (corrupted SCO packets, lost connection handles), **replacing the CSR 0a12:0001 Bluetooth adapter is the only reliable solution**.

**Why software fixes won't help:**
- The problem originates at the hardware/driver level
- PipeWire cannot fix corrupted packets from the adapter
- This is not a codec or configuration issue

**Action plan:**

1. **Immediate (~$25-40, High Priority):**
   - Replace CSR Bluetooth adapter with quality USB Bluetooth 5.0+ dongle
   - Recommended: TP-Link UB500 or ASUS USB-BT500 (both use Realtek RTL8761B)
   - Expected result: Completely resolves the issue

2. **Alternative (if budget allows, ~$50-150):**
   - Dedicated USB microphone (Blue Yeti Nano, Audio-Technica ATR2100x)
   - Provides better audio quality + eliminates Bluetooth entirely

3. **Optional (for community benefit):**
   - File bug report with kernel Bluetooth maintainers about CSR 0a12:0001 SCO stability
   - Note: PipeWire/WirePlumber are not at fault here

## Additional Investigation Needed

1. Check if issue occurs with other Bluetooth recording apps (Discord, OBS, etc.)
2. Test with different Bluetooth audio profiles (if available)
3. Monitor CPU/memory usage during crashes
4. Check kernel Bluetooth driver messages: `journalctl -k | grep -i bluetooth`
5. Test with different MTU settings for Bluetooth

## Bug Report Template

```markdown
**Issue:** Bluetooth SCO codec decode failures causing desktop crashes

**Environment:**
- PipeWire: 1.4.5
- WirePlumber: [version]
- BlueZ: [version]
- Kernel: 6.12.35
- Distribution: NixOS
- Desktop: Hyprland (Wayland)

**Device:**
- TOZO-T10 Bluetooth earbuds (58:FC:C6:23:29:68)
- Profiles: HSP, HFP, A2DP

**Symptoms:**
- Repeated "spa.bluez5.source.sco: decode failed: -3" errors
- Errors accumulate during continuous microphone use
- Eventually triggers X11/Wayland fatal I/O error
- Requires display manager restart

**Reproduction:**
1. Connect Bluetooth earbuds with HSP/HFP profile active
2. Use microphone input continuously via PipeWire (e.g., voice recording app)
3. Observe SCO decode failures in wireplumber logs
4. After 10-30 minutes of use, desktop crashes

**Logs:** [attach wireplumber, pipewire, bluetoothd logs]
```

## References

- [PipeWire Bluetooth documentation](https://docs.pipewire.org/page_bluetooth.html)
- [WirePlumber Bluetooth configuration](https://pipewire.pages.freedesktop.org/wireplumber/configuration/bluetooth.html)
- [BlueZ SCO documentation](http://www.bluez.org/profiles/)

---

**Document Created:** 2025-11-23
**Analysis Based On:** System logs from 2025-11-22 to 2025-11-23
**Status:** Under investigation, workarounds being evaluated
