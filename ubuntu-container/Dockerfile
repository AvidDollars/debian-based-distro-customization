FROM ubuntu
RUN apt update -y && apt upgrade -y && apt install openssh-server -y
RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
RUN echo "root:root" | chpasswd
EXPOSE 22
