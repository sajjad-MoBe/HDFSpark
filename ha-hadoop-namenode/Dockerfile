FROM bde2020/hadoop-namenode:2.0.0-hadoop3.2.1-java8

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh


ENTRYPOINT ["/entrypoint.sh"]