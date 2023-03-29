ARG BASE_VERSION

FROM azul/zulu-openjdk:$BASE_VERSION AS builder

RUN apt-get update && apt-get install -y jq curl busybox
RUN mkdir /emptydir

# Create symlinks to busybox to provide common Unix utilities (see https://busybox.net/FAQ.html#getting_started)
RUN mkdir /busybox_dir
RUN for i in $(busybox --list); do ln -s busybox /busybox_dir/$i; done

FROM scratch
ARG JAVA_VERSION

COPY --from=builder \
        /usr/lib/x86_64-linux-gnu/libc.so* \
        /usr/lib/x86_64-linux-gnu/libtinfo.so* \
        /usr/lib/x86_64-linux-gnu/libm.so* \
        /usr/lib/x86_64-linux-gnu/libjq.so* \
        /usr/lib/x86_64-linux-gnu/libonig.so* \
        /usr/lib/x86_64-linux-gnu/libcurl.so* \
        /usr/lib/x86_64-linux-gnu/libz.so* \
        /usr/lib/x86_64-linux-gnu/libnghttp2.so* \
        /usr/lib/x86_64-linux-gnu/libidn2.so* \
        /usr/lib/x86_64-linux-gnu/librtmp.so* \
        /usr/lib/x86_64-linux-gnu/libssh.so* \
        /usr/lib/x86_64-linux-gnu/libpsl.so* \
        /usr/lib/x86_64-linux-gnu/libssl.so* \
        /usr/lib/x86_64-linux-gnu/libcrypto.so* \
        /usr/lib/x86_64-linux-gnu/libgssapi_krb5.so* \
        /usr/lib/x86_64-linux-gnu/libldap-2* \
        /usr/lib/x86_64-linux-gnu/liblber-2* \
        /usr/lib/x86_64-linux-gnu/libzstd.so* \
        /usr/lib/x86_64-linux-gnu/libbrotlidec.so* \
        /usr/lib/x86_64-linux-gnu/libunistring.so* \
        /usr/lib/x86_64-linux-gnu/libgnutls.so* \
        /usr/lib/x86_64-linux-gnu/libhogweed.so* \
        /usr/lib/x86_64-linux-gnu/libnettle.so* \
        /usr/lib/x86_64-linux-gnu/libgmp.so* \
        /usr/lib/x86_64-linux-gnu/libkrb5.so* \
        /usr/lib/x86_64-linux-gnu/libk5crypto.so* \
        /usr/lib/x86_64-linux-gnu/libcom_err.so* \
        /usr/lib/x86_64-linux-gnu/libkrb5support.so* \
        /usr/lib/x86_64-linux-gnu/libsasl2.so* \
        /usr/lib/x86_64-linux-gnu/libbrotlicommon.so* \
        /usr/lib/x86_64-linux-gnu/libp11-kit* \
        /usr/lib/x86_64-linux-gnu/libtasn1.so* \
        /usr/lib/x86_64-linux-gnu/libkeyutils.so* \
        /usr/lib/x86_64-linux-gnu/libresolv.so* \
        /usr/lib/x86_64-linux-gnu/libffi.so* \
        /usr/lib/x86_64-linux-gnu/libdl.so* \
        /usr/lib/x86_64-linux-gnu/librt.so* \
        /usr/lib/x86_64-linux-gnu/libpthread.so* \
        /usr/lib/x86_64-linux-gnu/libnet.so* \
        /usr/lib/x86_64-linux-gnu/libnss_file*.so* \
        /usr/lib/x86_64-linux-gnu/libnss_dns*.so* \
        /usr/lib/x86_64-linux-gnu/libstdc++.so* \
        /usr/lib/x86_64-linux-gnu/libgcc_s.so* \
        /lib/x86_64-linux-gnu/

COPY --from=builder \
        /usr/lib64/ld-linux-x86-64.so* \
        /lib64/

COPY --from=builder /busybox_dir/ /bin/

COPY --from=builder \
        /usr/bin/bash \
        /usr/bin/sh \
        /usr/bin/busybox \
        /usr/bin/nohup \
        /usr/bin/jq \
        /usr/bin/curl \
        /bin/

COPY --from=builder /etc/ssl/certs/ /etc/ssl/certs/

COPY --from=builder /usr/lib/jvm/zulu${JAVA_VERSION}-ca-amd64 /usr/lib/jvm/zulu

COPY --from=builder /emptydir /tmp

ENV PATH="${PATH}:/usr/lib/jvm/zulu/bin/"

ENTRYPOINT [ "/bin/bash" ]
