# 📖 Hướng Dẫn Triển Khai CarPlay Guard

## 🎯 Tổng Quan

Tweak này hoạt động bằng cách:

1. **Hook vào các system frameworks** để phát hiện khi CarPlay kết nối/ngắt
2. **Tự động thực thi các hành động** (bật/tắt WiFi, Bluetooth, etc.)
3. **Quản lý vòng đời ứng dụng** (mở/đóng apps)
4. **Tiết kiệm pin** bằng cách tắt các kết nối không cần thiết

## 🔍 Luồng Hoạt Động

```
┌─────────────────────────────────────────────────────────────┐
│                    CarPlay Connected                        │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
         ┌─────────────────────────────┐
         │  handleCarPlayConnected()   │
         └─────────────────────────────┘
                       │
         ┌─────────────┼─────────────┐
         ▼             ▼             ▼
      WiFi ON      Mobile ON    YouTube Open
      
─────────────────────────────────────────────────────────────

┌─────────────────────────────────────────────────────────────┐
│                   CarPlay Disconnected                      │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
        ┌──────────────────────────────────┐
        │   scheduleCarPlayDisconnectActions()  │
        │      (Wait 15 seconds)           │
        └──────────────────────────────────┘
                       │
         ┌─────────────┼──────────────────┐
         ▼             ▼                  ▼
      Check if   If still      Close all apps,
      re-connected disconnected  turn off WiFi,
                                 Bluetooth, 4G
```

## 🛠️ Chi Tiết Kỹ Thuật

### 1. Phát Hiện CarPlay

**Framework**: `MediaPlayer.framework` + `AVFoundation.framework`

```objc
%hook MPAVController
- (void)setExternalPlaybackActive:(BOOL)active {
    // active = YES  → CarPlay connected
    // active = NO   → CarPlay disconnected
}
%end
```

### 2. Bật/Tắt WiFi

**Private API**: `WiFiManager`

```objc
+ (void)enableWiFi {
    id wifiManager = objc_getClass("WiFiManager");
    [wifiManager performSelector:NSSelectorFromString(@"enableWiFi")];
}
```

### 3. Bật/Tắt Bluetooth

**Private API**: `BluetoothManager`

```objc
+ (void)disableBluetooth {
    id bluetoothManager = objc_getClass("BluetoothManager");
    [bluetoothManager performSelector:NSSelectorFromString(@"powerOff")];
}
```

### 4. Đóng Ứng Dụng

**Framework**: Sử dụng `SpringBoard` service

```objc
id springBoard = [objc_getClass("SBApplicationController") sharedInstance];
id app = [springBoard performSelector:@selector(applicationWithBundleIdentifier:) 
                           withObject:@"com.google.ios.youtube"];
[app performSelector:@selector(kill)];
```

### 5. Khóa Màn Hình

**Private API**: `SBLockScreenManager`

```objc
id lockScreenMgr = [objc_getClass("SBLockScreenManager") sharedInstance];
[lockScreenMgr performSelector:@selector(lock)];
```

## 🔐 Bảo Mật & Quyền

### Private APIs được sử dụng:

| API | Framework | Mục đích |
|-----|-----------|---------|
| `WiFiManager` | Private | Bật/tắt WiFi |
| `BluetoothManager` | Private | Bật/tắt Bluetooth |
| `SBApplicationController` | SpringBoard | Quản lý ứng dụng |
| `SBLockScreenManager` | SpringBoard | Khóa màn hình |
| `MPAVController` | MediaPlayer | Phát hiện CarPlay |

### ⚠️ Lưu ý:
- Private APIs có thể thay đổi giữa các phiên bản iOS
- Cần test trên nhiều device khác nhau
- Có thể bị từ chối bởi các tweaked repo nếu vi phạm chính sách

## 🧪 Kiểm Thử

### 1. Kiểm Thử Cơ Bản

```bash
# Xem logs
log stream --predicate 'eventMessage contains "CarPlay Guard"' --level debug

# Từ từng kết nối CarPlay đến ngắt kết nối, quan sát logs
```

### 2. Test Scenarios

| Scenario | Kỳ vọng |
|----------|--------|
| Kết nối CarPlay | WiFi bật, 4G bật, YouTube mở |
| Ngắt sau 16 giây | Tất cả actions thực thi |
| Kết nối lại trong 14 giây | Cancel disconnect, tiếp tục dùng |
| Không có app bên thứ ba | Không lỗi, log bình thường |

### 3. Debugging

```bash
# SSH vào iPhone
ssh root@<ip>

# Xem real-time logs
log stream --level debug

# Check system status
sysctl -a | grep -i carplay
```

## 🔧 Cải Tiến Tiêu Tiếp

- [ ] Thêm settings panel (Preferences)
- [ ] Bộ sắc lựa chọn apps nào sẽ đóng
- [ ] Toggle các tính năng ON/OFF
- [ ] Thay đổi delay time
- [ ] Thêm hỗ trợ Android Auto
- [ ] Log lịch sử hoạt động
- [ ] Notification khi CarPlay kết nối/ngắt

## 📚 Tài Liệu Tham Khảo

1. **Theos Documentation**: https://theos.dev
2. **ElleKit Documentation**: https://github.com/elihwyma/ElleKit
3. **iOS Private APIs**: Reversed-engineered from iOS headers
4. **CarPlay Framework**: https://developer.apple.com/carplay/

## 💡 Tips & Tricks

1. **Logging**: Sử dụng `NSLog()` để debug (visible in `log stream`)
2. **Error Handling**: Luôn check `respondsToSelector:` trước khi gọi
3. **Performance**: Sử dụng `dispatch_async` để không block main thread
4. **Testing**: Test trên physical device, không chỉ simulator

## 🚀 Triển Khai Lên Repo

1. **Buộc gói**:
   ```bash
   make package
   ```

2. **Upload lên Sileo/Cydia repo** của bạn

3. **Hoặc upload trực tiếp**:
   ```bash
   make install THEOS_DEVICE_IP=<your-iphone-ip>
   ```

---

**Chúc bạn thành công với CarPlay Guard! 🎉**
