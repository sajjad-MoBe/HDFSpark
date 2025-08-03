# Use an official OpenJDK runtime as a parent image
FROM eclipse-temurin:8-jre-focal

# Set up environment variables for Hadoop
ENV HADOOP_VERSION=3.3.1
ENV HADOOP_URL=https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz
ENV HADOOP_HOME=/opt/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

# Install dependencies, download and unpack Hadoop
RUN apt-get update && \
    apt-get install -y wget curl
RUN wget -q ${HADOOP_URL} -O /tmp/hadoop.tar.gz && \
    tar -xzf /tmp/hadoop.tar.gz -C /opt/

RUN ln -s /opt/hadoop-${HADOOP_VERSION} ${HADOOP_HOME} && \
    rm /tmp/hadoop.tar.gz && \
    apt-get purge -y wget && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Default command
CMD ["bash"]
