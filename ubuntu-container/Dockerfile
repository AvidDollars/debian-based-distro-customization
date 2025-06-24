ARG IMAGE_NAME=ubuntu
ARG VERSION=latest
FROM ${IMAGE_NAME}:${VERSION}

ARG PACKAGE_MANAGER=apt
RUN ${PACKAGE_MANAGER} update -y && \
    ${PACKAGE_MANAGER} upgrade -y && \
    ${PACKAGE_MANAGER} install openssh-server -y

ARG FILE="/etc/ssh/sshd_config"
RUN echo "PasswordAuthentication yes" >> "${FILE}"  
RUN echo "PermitRootLogin yes" >> ${FILE}
RUN echo "root:root" | chpasswd

EXPOSE 22
