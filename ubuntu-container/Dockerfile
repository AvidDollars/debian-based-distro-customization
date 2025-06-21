ARG IMAGE_NAME=ubuntu
FROM ${IMAGE_NAME}

RUN apt update -y && apt upgrade -y && apt install openssh-server -y

ARG FILE="/etc/ssh/sshd_config"
RUN echo "PasswordAuthentication yes" >> "${FILE}"  
RUN echo "PermitRootLogin yes" >> ${FILE}
RUN echo "root:root" | chpasswd

EXPOSE 22
