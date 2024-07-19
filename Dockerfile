FROM debian:stable-slim

RUN apt-get update && apt-get install socat file -y

WORKDIR /opt/app

COPY src/ /opt/app/ 

EXPOSE 80

CMD /opt/app/main.sh run
