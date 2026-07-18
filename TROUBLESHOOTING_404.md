# 🚗 CarPlay Guard - Build & Deploy Guide

## ⚠️ Vấn đề Hiện Tại

Lỗi 404 xuất hiện khi cài trên Sileo vì:
- ❌ Repository không có file `.deb` thực tế
- ✓ Chỉ có file metadata (Release, Packages)

## ✅ Giải Pháp

### Cách 1: Tự Build trên Mac/Linux (Khuyên Dùng)

**1. Cài Theos:**
```bash
git clone --recursive https://github.com/theos/theos.git ~/theos
export THEOS=~/theos
export PATH=$THEOS/bin:$PATH
```

**2. Build Package:**
```bash
git clone https://github.com/window8/carplay-guard.git
cd carplay-guard
make clean
make package
```

**3. File .deb được tạo ở:**
```
packages/com.window8.carplayguard_1.0.0_iphoneos-arm64.deb
```

**4. Upload lên GitHub:**

**Qua Web:**
- Vào https://github.com/window8/carplay-guard
- Click **Add file** → **Upload files**
- Tạo/chọn folder `debs`
- Upload `.deb` file
- Commit

**Qua CLI:**
```bash
mkdir -p debs
cp packages/*.deb debs/
git add debs/
git commit -m "Add CarPlay Guard 1.0.0 package"
git push origin main
```

### Cách 2: Build trực tiếp trên iPhone (Khó hơn)

- SSH vào iPhone
- Cài Theos + build tools
- Build trên device
- Transfer file .deb

---

## 📝 Update Packages File

Sau khi upload `.deb`, tính checksums và update `Packages`:

```bash
cd debs
md5sum *.deb > md5.txt
sha1sum *.deb > sha1.txt
sha256sum *.deb > sha256.txt
```

Rồi update file `Packages` trong repo với checksums thực tế.

---

## 🧪 Test Lại Sileo

1. Xóa repo khỏi Sileo
2. Thêm lại: `https://raw.githubusercontent.com/window8/carplay-guard/main/`
3. Refresh
4. Cài CarPlay Guard

---

## 💡 Nếu Vẫn Gặp Lỗi

1. **Kiểm tra URL đúng:**
   - `https://raw.githubusercontent.com/window8/carplay-guard/main/debs/com.window8.carplayguard_1.0.0_iphoneos-arm64.deb`
   - Phải trả về file thực tế

2. **Kiểm tra Packages file:**
   - Filename path phải đúng
   - Checksums phải khớp

3. **Xem logs:**
   ```bash
   ssh root@<iphone-ip>
   log stream --predicate 'eventMessage contains sileo'
   ```

---

**Liên hệ nếu cần giúp với quá trình build! 👍**
