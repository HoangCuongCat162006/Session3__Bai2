# Bài 2: Khởi Tạo User Thường và Thiết Lập Đặc Quyền Quản Trị (Sudoers Configuration)

> **Lưu ý cấu trúc nộp bài theo yêu cầu:**  
> File báo cáo chính thức được lưu tại: [`homework/session_02/ex2/README.md`](file:///c:/IT_209/Session3/Session3__Bai2/homework/session_02/ex2/README.md)

---

## Tóm Tắt Thực Hiện

### 1. Mục tiêu
- Tạo tài khoản người dùng thường `devops` trên Ubuntu Server.
- Cấp quyền quản trị `sudo` cho `devops`.
- Sao chép và phân quyền bảo mật cho thư mục SSH Key từ `root` sang `devops`.
- Kiểm tra đăng nhập và thực thi lệnh quản trị `sudo whoami`.

---

### 2. Các Lệnh Linux Thực Hiện Trên Server
```bash
# 1. Tạo user devops
adduser devops

# 2. Thêm user devops vào group sudo
usermod -aG sudo devops

# 3. Copy thư mục SSH Key và đổi chủ sở hữu tự động sang devops:devops
sudo rsync --archive --chown=devops:devops ~/.ssh /home/devops/

# 4. Phân quyền bảo mật chính xác theo tiêu chuẩn OpenSSH
sudo chmod 700 /home/devops/.ssh
sudo chmod 600 /home/devops/.ssh/authorized_keys
```

---

### 3. Kiểm Tra Từ Máy Cá Nhân (Local Client)
```bash
# Đăng nhập bằng SSH Key
ssh -i /path/to/private_key devops@<IP_ADDRESS_DROPLET>

# Kiểm tra quyền sudo sau khi đăng nhập
sudo whoami
# Kết quả trả về: root
```

---

*Xem chi tiết toàn bộ báo cáo, giải thích kỹ thuật và log terminal đầy đủ tại: [homework/session_02/ex2/README.md](file:///c:/IT_209/Session3/Session3__Bai2/homework/session_02/ex2/README.md).*
