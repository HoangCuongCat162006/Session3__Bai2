#!/usr/bin/env bash
# ==============================================================================
# Script tự động hóa Bài 2: Khởi tạo User thường và thiết lập đặc quyền sudo
# Target OS: Ubuntu 20.04 / 22.04 / 24.04 LTS
# ==============================================================================

set -euo pipefail

NEW_USER="devops"

echo "=== [1/5] Kiểm tra quyền root ==="
if [ "$EUID" -ne 0 ]; then
  echo "[-] Vui lòng chạy script này với quyền root hoặc sudo."
  exit 1
fi

echo "=== [2/5] Tạo người dùng $NEW_USER (nếu chưa tồn tại) ==="
if id "$NEW_USER" &>/dev/null; then
  echo "[+] Người dùng $NEW_USER đã tồn tại."
else
  # Tạo user với bash shell và thư mục home
  adduser --gecos "DevOps User,,," --disabled-password "$NEW_USER"
  echo "[+] Đặt mật khẩu cho $NEW_USER:"
  passwd "$NEW_USER"
  echo "[+] Tạo người dùng $NEW_USER thành công."
fi

echo "=== [3/5] Thêm $NEW_USER vào nhóm sudo ==="
usermod -aG sudo "$NEW_USER"
echo "[+] Đã thêm $NEW_USER vào nhóm sudo."

echo "=== [4/5] Sao chép cấu hình SSH Key từ root sang $NEW_USER ==="
if [ -d "/root/.ssh" ]; then
  rsync --archive --chown="${NEW_USER}:${NEW_USER}" /root/.ssh "/home/${NEW_USER}/"
  
  # Đảm bảo phân quyền chuẩn mực cho SSH
  chmod 700 "/home/${NEW_USER}/.ssh"
  if [ -f "/home/${NEW_USER}/.ssh/authorized_keys" ]; then
    chmod 600 "/home/${NEW_USER}/.ssh/authorized_keys"
  fi
  echo "[+] Sao chép và phân quyền SSH thành công."
else
  echo "[!] Cảnh báo: /root/.ssh không tồn tại. Vui lòng kiểm tra lại cấu hình SSH Key."
fi

echo "=== [5/5] Kiểm tra lại kết quả cấu hình ==="
echo "- User & Group info: $(id "$NEW_USER")"
echo "- SSH Directory permission: $(ls -ld "/home/${NEW_USER}/.ssh")"
if [ -f "/home/${NEW_USER}/.ssh/authorized_keys" ]; then
  echo "- Authorized keys permission: $(ls -l "/home/${NEW_USER}/.ssh/authorized_keys")"
fi

echo ""
echo "=== HOÀN TẤT THIẾT LẬP ==="
echo "Bây giờ bạn có thể mở terminal máy cá nhân và đăng nhập bằng:"
echo "  ssh -i <private_key> ${NEW_USER}@<IP_ADDRESS_DROPLET>"
echo "Sau đó kiểm tra quyền quản trị:"
echo "  sudo whoami"
