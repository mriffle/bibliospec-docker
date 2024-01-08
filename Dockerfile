FROM ubuntu:18.04 AS builder
LABEL maintainer = "Michael Riffle <mriffle@uw.edu>"

ENV DEBIAN_FRONTEND='noninteractive'
ENV TZ='Etc/UTC'

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install build-essential git

RUN git clone https://github.com/ProteoWizard/pwiz.git

WORKDIR /pwiz

RUN ./quickbuild.sh -j$(($(nproc) - 1)) --hash optimization=space address-model=64 pwiz_tools/BiblioSpec >build.log

# add in the built files, create final image
FROM ubuntu:18.04
LABEL maintainer = "Michael Riffle <mriffle@uw.edu>"

COPY --from=builder /pwiz/build-linux-x86_64/gcc-release-x86_64/* /usr/local/bin/
ADD entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD []
