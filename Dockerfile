ARG BASE_IMAGE

FROM $BASE_IMAGE AS builder

RUN apt-get update && apt-get install -y jq curl busybox
RUN mkdir /emptydir

# Create symlinks to busybox to provide common Unix utilities (see https://busybox.net/FAQ.html#getting_started)
# Create symlink to /usr/bin which will be copied to /bin
RUN mkdir -p /symlinks/busybox && \
    mkdir -p /symlinks/root && \
    for i in $(busybox --list); do ln -s busybox /symlinks/busybox/$i; done && \
    ln -s /usr/bin /symlinks/root/bin

# Prepare all files to be copied to the target image, depending on the platform
ARG TARGETPLATFORM
ARG JAVA_VERSION
RUN case "${TARGETPLATFORM}" in \
        "linux/amd64") \
            ORIG_DIR="/usr/lib/x86_64-linux-gnu" && \
            TARGET_DIR="/copied_lib/lib/x86_64-linux-gnu" \
            ;; \
        "linux/arm64") \
            ORIG_DIR="/lib/aarch64-linux-gnu" && \
            TARGET_DIR="/copied_lib/lib/aarch64-linux-gnu" \
            ;; \
        *) exit 1 ;; \
    esac && \
    mkdir -p "$TARGET_DIR" && \
    cp "$ORIG_DIR"/libc.so* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/libtinfo.so* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/libm.so* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/libjq.so* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/libonig.so* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/libcurl.so* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/libz.so* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/libnghttp2.so* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/libidn2.so* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/librtmp.so* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/libssh.so* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/libpsl.so* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/libssl.so* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/libcrypto.so* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/libgssapi_krb5.so* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/libldap-2* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/liblber-2* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/libzstd.so* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/libbrotlidec.so* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/libunistring.so* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/libgnutls.so* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/libhogweed.so* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/libnettle.so* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/libgmp.so* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/libkrb5.so* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/libk5crypto.so* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/libcom_err.so* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/libkrb5support.so* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/libsasl2.so* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/libbrotlicommon.so* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/libp11-kit* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/libtasn1.so* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/libkeyutils.so* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/libresolv.so* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/libffi.so* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/libdl.so* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/librt.so* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/libpthread.so* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/libnss_file*.so* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/libnss_dns*.so* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/libstdc++.so* "$TARGET_DIR" && \
    cp "$ORIG_DIR"/libgcc_s.so* "$TARGET_DIR"

RUN case "${TARGETPLATFORM}" in \
        "linux/amd64") \
            mkdir -p /copied_lib/lib64/ && \
            cp /usr/lib64/ld-linux-x86-64.so* /copied_lib/lib64 \
            ;; \
        "linux/arm64") \
            mkdir -p /copied_lib/lib/ && \
            cp /lib/ld-linux-aarch64.so* /copied_lib/lib \
            ;; \
        *) exit 1 ;; \
    esac

RUN mkdir /copied_zulu/ && \
    case "${TARGETPLATFORM}" in \
        "linux/amd64") \
            cp -r "/usr/lib/jvm/zulu${JAVA_VERSION}-ca-amd64/." /copied_zulu \
            ;; \
        "linux/arm64") \
            cp -r "/usr/lib/jvm/zulu${JAVA_VERSION}-ca-arm64/." /copied_zulu \
            ;; \
        *) exit 1 ;; \
    esac

FROM scratch

COPY --from=builder /copied_lib/ /

COPY --from=builder /symlinks/busybox/ /usr/bin/
COPY --from=builder \
        /usr/bin/bash \
        /usr/bin/sh \
        /usr/bin/busybox \
        /usr/bin/nohup \
        /usr/bin/jq \
        /usr/bin/curl \
        /usr/bin/
COPY --from=builder /symlinks/root/ /

COPY --from=builder /copied_zulu /usr/lib/jvm/zulu

COPY --from=builder /etc/ssl/certs/ /etc/ssl/certs/

COPY --from=builder /emptydir /tmp

ENV PATH="${PATH}:/usr/lib/jvm/zulu/bin/"

ENTRYPOINT [ "/bin/bash" ]
