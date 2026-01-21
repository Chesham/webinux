FROM alpine:latest AS base

ENV DISPLAY=:0 \
    RESOLUTION=1280x720

# 安裝核心元件
# xvfb: 虛擬螢幕
# x11vnc: VNC 伺服器
# openbox: 極輕量視窗管理器 (比 Xfce/LXDE 更輕)
# novnc: Web 介面
# supervisor: 用來同時管理上述三個 process
RUN apk add --no-cache \
    xvfb \
    x11vnc \
    openbox \
    supervisor \
    novnc \
    websockify \
    # 字型，否則會亂碼
    ttf-dejavu

RUN ln -sf /usr/share/novnc/vnc.html /usr/share/novnc/index.html

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
