# s-ui(精简版)

基于 [alireza0/s-ui](https://github.com/alireza0/s-ui) 的个人精简分支,面向自用/少数人使用,主要跑 **Hysteria2** 与 **SOCKS5**。协议 GPL-3.0,与上游一致。

## 相比上游改了什么

- 编译标签只保留 `with_quic`(hy2 需要),去掉 gRPC / uTLS / ACME / gVisor / Tailscale / Cloudflared / OpenConnect / OpenVPN / Naive
- Docker 构建不再下载 libcronet,镜像更小、构建更快
- 镜像只构建 amd64 / arm64 / armv7,发布到 `ghcr.io/lu8010252/s-ui`
- 默认时区 Asia/Shanghai,去掉镜像里的 nftables

> 证书不走 ACME,请自行放进 `./cert`(compose 已挂载到 `/app/cert`),面板里填证书/私钥路径即可。

## 部署

```yaml
services:
  s-ui:
    image: ghcr.io/lu8010252/s-ui:latest
    container_name: s-ui
    volumes:
      - ./db:/app/db
      - ./cert:/app/cert
    environment:
      TZ: Asia/Shanghai
    ports:
      - "2095:2095"   # 面板
      - "2096:2096"   # 订阅
    restart: unless-stopped
```

hy2 的 UDP 端口需要另外映射(或使用 `network_mode: host`)。
