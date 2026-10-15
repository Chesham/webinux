# Alpine 版本寫死（2026-01-21 起用的版本），避免 latest 漂移
FROM alpine:3.23.2 AS base

ENV DISPLAY=:0 \
    RESOLUTION=1280x720

# 安裝核心元件
# tigervnc: Xvnc 同時是虛擬螢幕和 VNC 伺服器
#           （原本的 Xvfb＋x11vnc 會讓 IB Gateway 登入畫面白底白字，2026-10-15 查證）
# openbox: 極輕量視窗管理器 (比 Xfce/LXDE 更輕)
# novnc: Web 介面
# supervisor: 用來同時管理上述三個 process
RUN apk add --no-cache \
    tigervnc \
    openbox \
    supervisor \
    novnc \
    websockify \
    # 字型，否則會亂碼
    ttf-dejavu

RUN ln -sf /usr/share/novnc/vnc.html /usr/share/novnc/index.html

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
