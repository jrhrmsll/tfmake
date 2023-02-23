FROM ubuntu:20.04

RUN apt-get update
RUN apt-get install wget uuid -y 

RUN wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_arm64 -O /usr/bin/yq 
RUN chmod +x /usr/bin/yq

WORKDIR /app

CMD ["bash", "build.sh"]
