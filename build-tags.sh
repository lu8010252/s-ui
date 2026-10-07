#!/bin/sh
# Build tags and the linker flags that go with them, for every pipeline.
#
#   . ./build-tags.sh
#   TAGS=$(tags_for docker)   # assign, so a bad profile aborts under set -e
#   go build -tags "$TAGS" -ldflags "$(ldflags_for docker)" ...
#
# Without tags sing-box swaps in the stubs from core/register_*_stub.go.
#
#   profile   linkname  cronet   used by
#   test      yes       -        go test; release.yml's non-naive targets
#   dev       yes       musl     build.sh
#   release   yes       musl     release.yml, naive targets only
#   windows   yes       purego   release.yml, build-windows
#   docker    -         purego   Dockerfile, Dockerfile.frontend-artifact
#
# with_musl links a prebuilt musl libcronet.a and needs the Chromium toolchain
# release.yml sets up; without it the linker fails with "cannot find
# -l:libcronet.a". The linkname tags require -checklinkname=0, which is why
# ldflags_for exists -- the pair used to be kept in step by hand in three files.

# Trimmed build: only hy2/socks5 needs QUIC. Dropped: grpc, utls, acme (certs are
# copied in by script), gvisor, tailscale, cloudflared, openconnect, openvpn,
# and naive (+ musl/purego, which only existed for libcronet).
BASE_TAGS="with_quic"
LINKNAME_TAGS="badlinkname,tfogo_checklinkname0"

tags_for() {
    case "$1" in
        test)        echo "${BASE_TAGS},${LINKNAME_TAGS}" ;;
        dev|release) echo "${BASE_TAGS},${LINKNAME_TAGS}" ;;
        windows)     echo "${BASE_TAGS},${LINKNAME_TAGS}" ;;
        docker)      echo "${BASE_TAGS}" ;;
        *)
            echo "build-tags.sh: unknown build profile '$1'" >&2
            return 1
            ;;
    esac
}

# Only the flags tied to the tags; callers add their own platform linking flags.
ldflags_for() {
    case "$1" in
        test|dev|release|windows) echo "-w -s -checklinkname=0" ;;
        docker)                   echo "-w -s" ;;
        *)
            echo "build-tags.sh: unknown build profile '$1'" >&2
            return 1
            ;;
    esac
}
