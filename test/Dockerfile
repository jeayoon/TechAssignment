FROM '253854447487.dkr.ecr.ap-northeast-1.amazonaws.com/fix-ecr:latest'
RUN service nginx start
COPY src /usr/share/nginx/html
VOLUME /usr/share/nginx/html