# How to Connect a Bluetooth Barcode Scanner

## 🎯 Complete Guide: Bluetooth Scanner Setup

There are **two ways** to connect a Bluetooth barcode scanner:

---

## Method 1: Pair with Computer (Recommended & Easiest)

This method makes your Bluetooth scanner work like a keyboard - **no special setup needed in the app!**

### Step 1: Turn On Your Bluetooth Scanner

1. **Power on** the scanner
2. **Enable Bluetooth pairing mode**
   - Usually: Hold the Bluetooth button for 3-5 seconds
   - Scanner LED will blink (usually blue)
   - Check your scanner's manual for specific instructions

### Step 2: Pair with Your Computer

#### On Windows:

1. **Open Settings**
   - Press `Windows + I`
   - Or click Start → Settings

2. **Go to Bluetooth & Devices**
   - Click "Bluetooth & devices" in the left menu
   - Make sure Bluetooth is **ON**

3. **Add Device**
   - Click "Add device" or "Add Bluetooth or other device"
   - Select "Bluetooth"

4. **Select Your Scanner**
   - Wait for your scanner to appear in the list
   - It might show as "Barcode Scanner" or the brand name
   - Click on it to pair

5. **Enter PIN (if asked)**
   - Most scanners use: `0000` or `1234`
   - Some don't require a PIN
   - Check your scanner's manual

6. **Wait for "Connected"**
   - You'll see "Connected" or "Paired"
   - Scanner LED will stop blinking

#### On Mac:

1. **Open System Preferences**
   - Click Apple menu → System Preferences

2. **Go to Bluetooth**
   - Click "Bluetooth"
   - Make sure Bluetooth is **ON**

3. **Pair Device**
   - Your scanner should appear in the list
   - Click "Connect" or "Pair"
   - Enter PIN if asked (usually `0000` or `1234`)

4. **Wait for "Connected"**

### Step 3: Test the Scanner

1. **Open Notepad** (or any text editor)
2. **Scan a barcode**
3. **You should see the barcode number appear!**

If this works, your scanner is ready to use with the app!

### Step 4: Use in Your App

1. **Open your POS app** (http://localhost:8518)
2. **Go to Barcode Scanner Settings**
3. **Select "Keyboard (HID)"** (first option)
4. **Click "Connect Scanner"**
5. **Enable "External Scanner"** toggle
6. **Start scanning!**

---

## Method 2: Web Bluetooth API (Advanced)

This method connects the scanner **directly to the browser** using Web Bluetooth API.

### ⚠️ Requirements:

- Chrome or Edge browser
- HTTPS website (or localhost)
- Scanner's Bluetooth service UUID
- Scanner must support BLE (Bluetooth Low Energy)

### When to Use This:

Only use this if:
- Your scanner doesn't work as a keyboard
- You need battery level monitoring
- You need to configure the scanner
- You want multiple scanners simultaneously

### How to Use:

1. **Deploy app to Vercel** (HTTPS required)
2. **Open in Chrome/Edge**
3. **Go to Barcode Scanner Settings**
4. **Select "Bluetooth Scanner"**
5. **Click "Connect Scanner"**
6. **Browser will show device list**
7. **Select your scanner**
8. **Grant permission**

### Note:

This method requires the scanner's **Bluetooth service UUID**, which varies by manufacturer. You'll need to:
- Check scanner documentation
- Or use a Bluetooth scanner app to find the UUID
- Update the code with the correct UUID

---

## 📱 Recommended Approach

### For 99% of Users: Method 1 (Pair with Computer)

**Why?**
- ✅ Simple and fast
- ✅ Works immediately
- ✅ No browser permissions
- ✅ Works in all browsers
- ✅ More reliable
- ✅ Already implemented in your app

**Steps:**
1. Pair scanner with Windows/Mac Bluetooth settings
2. Test in Notepad
3. Use "Keyboard (HID)" mode in app
4. Done!

### For Advanced Users: Method 2 (Web Bluetooth)

**Why?**
- Only if Method 1 doesn't work
- For advanced features
- Requires technical setup

---

## 🔧 Troubleshooting

### Scanner Won't Pair

**Solutions:**
1. Make sure scanner is in pairing mode (LED blinking)
2. Turn Bluetooth off and on again on your computer
3. Restart the scanner
4. Try PIN: `0000`, `1234`, or `123456`
5. Check scanner manual for pairing instructions

### Scanner Paired but Not Working

**Solutions:**
1. Make sure scanner is connected (not just paired)
2. Test in Notepad first
3. Check scanner battery
4. Re-pair the device
5. Make sure scanner is in HID/keyboard mode (check manual)

### Scanner Works in Notepad but Not in App

**Solutions:**
1. Make sure you selected "Keyboard (HID)" in app
2. Click "Connect Scanner" button
3. Enable "External Scanner" toggle
4. Check input timeout settings (increase if needed)
5. Make sure scanner sends "Enter" key after barcode

---

## 📋 Quick Setup Checklist

### Physical Setup:
- [ ] Scanner is charged/has batteries
- [ ] Scanner is powered on
- [ ] Scanner is in pairing mode (LED blinking)
- [ ] Computer Bluetooth is ON
- [ ] Scanner is paired in Windows/Mac Bluetooth settings
- [ ] Scanner shows as "Connected"
- [ ] Test scan works in Notepad

### App Setup:
- [ ] Open Barcode Scanner Settings
- [ ] Select "Keyboard (HID)"
- [ ] Click "Connect Scanner"
- [ ] Enable "External Scanner" toggle
- [ ] Adjust timeout if needed (default 100ms is usually fine)
- [ ] Test scan in the app

---

## 🎯 Example: Common Bluetooth Scanners

### Honeywell Voyager 1472g:
1. Press and hold Bluetooth button until LED blinks blue
2. Pair with computer (PIN: `0000`)
3. Scan "HID Keyboard" barcode in manual
4. Use in app with Keyboard mode

### Symbol/Zebra DS6878:
1. Press and hold scan button + Bluetooth button
2. LED blinks blue
3. Pair with computer (PIN: `0000`)
4. Use in app with Keyboard mode

### Inateck BCST-70:
1. Hold Bluetooth button for 3 seconds
2. LED blinks blue rapidly
3. Pair with computer (no PIN needed)
4. Use in app with Keyboard mode

---

## 💡 Pro Tips

### Tip 1: Configure Scanner for "Enter" Key
Most scanners can be configured to send an "Enter" key after each scan. This makes the app work better. Check your scanner manual for the configuration barcode.

### Tip 2: Test in Notepad First
Always test your scanner in Notepad before using in the app. If it works in Notepad, it will work in the app.

### Tip 3: Keep Scanner Manual Handy
Scanner manuals have configuration barcodes for:
- HID keyboard mode
- Adding Enter key suffix
- Adjusting beep volume
- Changing LED behavior

### Tip 4: Battery Life
Bluetooth scanners sleep after inactivity. If scanner doesn't respond, press the scan button once to wake it up.

---

## 🚀 Summary

**Easiest Way to Connect Bluetooth Scanner:**

1. **Turn on scanner** → Put in pairing mode
2. **Windows Settings** → Bluetooth → Add device
3. **Select scanner** → Enter PIN if needed
4. **Test in Notepad** → Scan should type numbers
5. **Open app** → Barcode Scanner Settings
6. **Select "Keyboard (HID)"** → Connect Scanner
7. **Start scanning!** → It just works!

**No need for Web Bluetooth API** - the keyboard mode works perfectly with Bluetooth scanners that are paired with your computer!

---

## 📞 Need Help?

If your scanner still doesn't work:
1. Check scanner manual for HID keyboard mode
2. Make sure scanner firmware is updated
3. Try a different USB Bluetooth adapter
4. Contact scanner manufacturer support

---

**Most Bluetooth scanners work perfectly in Keyboard mode once paired with your computer!** 🎯

Would you like help with a specific scanner model?
