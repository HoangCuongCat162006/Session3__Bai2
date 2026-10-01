# Báo Cáo Bài Tập 2: Khởi Tạo User Thường và Thiết Lập Đặc Quyền Quản Trị (Sudoers Configuration)

**Môn học / Khóa học:** DevOps / Cloud Computing  
**Đường dẫn bài nộp trên GitHub:** `homework/session_02/ex2/`  
**Hệ điều hành thực nghiệm:** Ubuntu Server 22.04 LTS (DigitalOcean Droplet)  
**Tài khoản cấu hình:** `devops`  

---

## 1. Mục Tiêu & Bối Cảnh

- **Nguyên tắc Đặc quyền Tối thiểu (Principle of Least Privilege):** Không sử dụng tài khoản `root` cho các hoạt động vận hành, bảo trì máy chủ thường nhật nhằm hạn chế tối đa rủi ro thao tác sai gây tê liệt hệ thống, hoặc rủi ro tấn công leo thang đặc quyền.
- **Mục tiêu kỹ thuật:**
  1. Tạo tài khoản thường có tên `devops` trên máy chủ Ubuntu.
  2. Gán quyền quản trị an toàn thông qua nhóm hệ thống `sudo`.
  3. Kế thừa cấu hình xác thực SSH Key từ tài khoản `root` sang thư mục home của user `devops`.
  4. Thiết lập chuẩn phân quyền bảo mật cho thư mục `~/.ssh` và tệp tin `~/.ssh/authorized_keys` theo yêu cầu của SSH Daemon (`StrictModes`).
  5. Kiểm tra kết nối từ máy cá nhân bằng SSH Key và thẩm định đặc quyền với lệnh `sudo whoami`.

---

## 2. Quy Trình Thực Hiện Từng Bước (Step-by-Step)

### Bước 1: Kết nối vào máy chủ với quyền `root`
Từ máy cá nhân (Local Machine), SSH vào Droplet bằng khóa bí mật đã thiết lập ở Bài 1:
```bash
ssh -i ~/.ssh/id_ed25519 root@<IP_ADDRESS_DROPLET>
```

---

### Bước 2: Tạo tài khoản người dùng mới `devops`
Chạy lệnh `adduser` trên Ubuntu Server:
```bash
adduser devops
```
> **Giải thích kỹ thuật:** Lệnh `adduser` là script cấp cao trên Debian/Ubuntu. Lệnh này tự động:
> - Tạo thư mục cá nhân `/home/devops/`.
> - Sao chép các tệp tin cấu hình khung từ `/etc/skel/` (`.bashrc`, `.profile`, ...).
> - Tạo nhóm riêng `devops` (Primary group).
> - Nhắc người quản trị đặt mật khẩu an toàn và cung cấp các thông tin cá nhân.

---

### Bước 3: Cấp quyền quản trị thông qua nhóm `sudo`
Thêm người dùng `devops` vào nhóm `sudo`:
```bash
usermod -aG sudo devops
```
> **Giải thích kỹ thuật:**
> - Cờ `-a` (*append*): Thêm nhóm bổ sung mà không ghi đè hoặc loại bỏ user khỏi các nhóm hiện tại.
> - Cờ `-G` (*groups*): Chỉ định danh sách nhóm bổ trợ.
> - Trong `/etc/sudoers` của Ubuntu, nhóm `%sudo` đã được định nghĩa sẵn quyền: `%sudo ALL=(ALL:ALL) ALL`. Vì vậy, mọi thành viên thuộc nhóm này đều có quyền thực thi lệnh với tư cách quản trị viên qua `sudo`.

---

### Bước 4: Sao chép SSH Key từ `root` sang user `devops`
Sử dụng công cụ `rsync` với tính năng bảo toàn thuộc tính và gán quyền sở hữu tự động (theo gợi ý đề bài):
```bash
sudo rsync --archive --chown=devops:devops ~/.ssh /home/devops/
```
> **Giải thích kỹ thuật:**
> - `--archive` (`-a`): Bảo toàn cấu trúc thư mục, tệp, thuộc tính và mốc thời gian (*timestamps*).
> - `--chown=devops:devops`: Tự động thay đổi Owner và Group của toàn bộ thư mục và tệp con sang `devops:devops`.
>
> *(Phương pháp thay thế nếu không dùng rsync)*:
> ```bash
> mkdir -p /home/devops/.ssh
> cp /root/.ssh/authorized_keys /home/devops/.ssh/authorized_keys
> chown -R devops:devops /home/devops/.ssh
> ```

---

### Bước 5: Phân quyền bảo mật theo tiêu chuẩn OpenSSH
Áp dụng phân quyền chặt chẽ cho thư mục `.ssh` và tệp `authorized_keys`:
```bash
sudo chmod 700 /home/devops/.ssh
sudo chmod 600 /home/devops/.ssh/authorized_keys
```
> **Giải thích kỹ thuật về phân quyền SSH (`StrictModes`):**
> - Thư mục `.ssh` được đặt `chmod 700` (`rwx------`): Chỉ user `devops` mới có quyền đọc, ghi, duyệt thư mục. Cấm tuyệt đối nhóm (group) và người khác (others) truy cập.
> - Tệp `authorized_keys` được đặt `chmod 600` (`rw-------`): Chỉ user `devops` mới có quyền đọc và ghi.
> - OpenSSH Server có cơ chế kiểm tra an toàn `StrictModes yes`. Nếu thư mục `.ssh` hoặc tệp khóa có quyền ghi cho group/others (ví dụ: `777`, `755`, `664`), OpenSSH sẽ **từ chối xác thực** vì nguy cơ bị tệp tin độc hại chèn vào.

---

## 3. Log Terminal Thực Tế (Terminal Execution Logs)

### 3.1. Các lệnh khởi tạo trên Server (thực thi dưới quyền `root`)
```bash
root@ubuntu-s-1vcpu-1gb-sgp1:~# adduser devops
Adding user `devops' ...
Adding new group `devops' (1001) ...
Adding new user `devops' (1001) with group `devops' ...
Creating home directory `/home/devops' ...
Copying files from `/etc/skel' ...
New password: 
Retype new password: 
passwd: password updated successfully
Changing the user information for devops
Enter the new value, or press ENTER for the default
	Full Name []: DevOps Admin
	Room Number []: 
	Work Phone []: 
	Home Phone []: 
	Other []: 
Is the information correct? [Y/n] Y

root@ubuntu-s-1vcpu-1gb-sgp1:~# usermod -aG sudo devops

root@ubuntu-s-1vcpu-1gb-sgp1:~# sudo rsync --archive --chown=devops:devops ~/.ssh /home/devops/

root@ubuntu-s-1vcpu-1gb-sgp1:~# sudo chmod 700 /home/devops/.ssh
root@ubuntu-s-1vcpu-1gb-sgp1:~# sudo chmod 600 /home/devops/.ssh/authorized_keys

root@ubuntu-s-1vcpu-1gb-sgp1:~# ls -ld /home/devops/.ssh
drwx------ 2 devops devops 4096 Oct  1 16:20 /home/devops/.ssh

root@ubuntu-s-1vcpu-1gb-sgp1:~# ls -l /home/devops/.ssh/authorized_keys
-rw------- 1 devops devops  571 Oct  1 16:20 /home/devops/.ssh/authorized_keys
```

---

### 3.2. Kiểm tra xác thực từ Máy cá nhân (Local Client)

#### Lệnh 1: Đăng nhập SSH qua user `devops`
```bash
$ ssh -i ~/.ssh/id_ed25519 devops@159.223.45.188
Welcome to Ubuntu 22.04.4 LTS (GNU/Linux 5.15.0-105-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

System information as of Thu Oct  1 16:22:15 UTC 2026

  System load:  0.0                Processes:             98
  Usage of /:   4.8% of 24.05GB    Users logged in:       0
  Memory usage: 22%                IPv4 address for eth0: 159.223.45.188

Last login: Thu Oct  1 16:15:02 2026 from 14.162.145.20
devops@ubuntu-s-1vcpu-1gb-sgp1:~$ 
```
*Kết quả:* Đăng nhập thành công trực tiếp vào tài khoản `devops` bằng SSH Key mà không gặp bất kỳ lỗi từ chối khóa (*Permission denied (publickey)*).

---

#### Lệnh 2: Kiểm tra thông tin định danh và nhóm
```bash
devops@ubuntu-s-1vcpu-1gb-sgp1:~$ id
uid=1001(devops) gid=1001(devops) groups=1001(devops),27(sudo)
```
*Kết quả:* User `devops` đã nằm trong nhóm `sudo` (gid 27).

---

#### Lệnh 3: Kiểm tra đặc quyền quản trị với `sudo whoami`
```bash
devops@ubuntu-s-1vcpu-1gb-sgp1:~$ sudo whoami
[sudo] password for devops: **********
root
```
*Kết quả:* Lệnh `sudo whoami` yêu cầu nhập mật khẩu của user `devops` và in ra kết quả **`root`** chính xác, minh chứng user `devops` đã sở hữu đặc quyền quản trị an toàn.

---

## 4. Bảng Tổng Hợp Kiểm Thử & Tiêu Chí Đạt Được

| STT | Yêu cầu bài lab | Lệnh kiểm tra | Kết quả đạt được | Trạng thái |
|:---:|:---|:---|:---|:---:|
| 1 | Tạo tài khoản `devops` | `id devops` | `uid=1001(devops) gid=1001(devops)` | **PASSED** |
| 2 | Cấp nhóm quản trị `sudo` | `groups devops` | `devops : devops sudo` | **PASSED** |
| 3 | Đăng nhập SSH bằng SSH Key | `ssh -i <private_key> devops@<IP>` | Đăng nhập thành công không cần password SSH | **PASSED** |
| 4 | Quyền thư mục `.ssh` | `stat -c "%a %U:%G" /home/devops/.ssh` | `700 devops:devops` | **PASSED** |
| 5 | Quyền tệp `authorized_keys` | `stat -c "%a %U:%G" /home/devops/.ssh/authorized_keys` | `600 devops:devops` | **PASSED** |
| 6 | Thực thi đặc quyền quản trị | `sudo whoami` | Trả về `root` sau khi xác thực mật khẩu | **PASSED** |

---

## 5. Kết Luận
Cấu hình đã đáp ứng đầy đủ và chuẩn xác các tiêu chuẩn bảo mật hệ thống:
- Hệ thống áp dụng thành công nguyên tắc đặc quyền tối thiểu.
- SSH Key được chuyển giao an toàn, phân quyền đúng chuẩn `StrictModes`.
- User `devops` có đầy đủ quyền quản trị cần thiết thông qua cơ chế `sudo` mà không cần trực tiếp đăng nhập bằng `root`.
