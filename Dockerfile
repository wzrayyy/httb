FROM debian:stable-slim
RUN apt-get update && apt-get install socat file -y
ENV HTTB_LIB_PATH="/usr/lib/httb"
WORKDIR ${HTTB_LIB_PATH}
COPY src/ .
WORKDIR /
CMD ["/bin/bash"]
