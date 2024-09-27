FROM ubuntu
WORKDIR /root

# Install dependencies
RUN apt update && apt-get install -y openssh-server openjdk-8-jdk ssh wget curl vim && rm -rf /var/lib/apt/lists/*
RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz && tar -xzf hadoop-3.3.6.tar.gz && mv hadoop-3.3.6 /usr/local/hadoop && rm hadoop-3.3.6.tar.gz
RUN wget https://mirror.lyrahosting.com/apache/spark/spark-3.5.0/spark-3.5.0-bin-hadoop3.tgz && tar -xzf spark-3.5.0-bin-hadoop3.tgz && mv spark-3.5.0-bin-hadoop3 /usr/local/spark && rm spark-3.5.0-bin-hadoop3.tgz
RUN wget https://archive.apache.org/dist/kafka/3.6.1/kafka_2.13-3.6.1.tgz && tar -xzf kafka_2.13-3.6.1.tgz && mv kafka_2.13-3.6.1 /usr/local/kafka && rm kafka_2.13-3.6.1.tgz
RUN wget https://archive.apache.org/dist/hbase/2.5.8/hbase-2.5.8-hadoop3-bin.tar.gz && tar -xzf hbase-2.5.8-hadoop3-bin.tar.gz && mv hbase-2.5.8-hadoop3 /usr/local/hbase && rm hbase-2.5.8-hadoop3-bin.tar.gz

# Set environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV HADOOP_HOME=/usr/local/hadoop
ENV YARN_HOME=/usr/local/hadoop
ENV SPARK_HOME=/usr/local/spark
ENV KAFKA_HOME=/usr/local/kafka
ENV HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop
ENV YARN_CONF_DIR=/usr/local/hadoop/etc/hadoop
ENV LD_LIBRARY_PATH=/usr/local/hadoop/lib/native:
ENV HBASE_HOME=/usr/local/hbase
ENV CLASSPATH=:/usr/local/hbase/lib/*
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/hadoop/bin:/usr/local/hadoop/sbin:/usr/local/spark/bin:/usr/local/kafka/bin:/usr/local/hbase/bin

# Configure SSH
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && chmod 0600 ~/.ssh/authorized_keys

# Create HDFS directories
RUN mkdir -p ~/hdfs/namenode && mkdir -p ~/hdfs/datanode && mkdir $HADOOP_HOME/logs

# Copy configuration files
COPY config/* /tmp/

# Configure Hadoop
RUN mv /tmp/ssh_config ~/.ssh/config && mv /tmp/hadoop-env.sh /usr/local/hadoop/etc/hadoop/hadoop-env.sh && mv /tmp/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml && mv /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml && mv /tmp/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml && mv /tmp/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml && mv /tmp/workers $HADOOP_HOME/etc/hadoop/workers && mv /tmp/start-kafka-zookeeper.sh ~/start-kafka-zookeeper.sh && mv /tmp/start-hadoop.sh ~/start-hadoop.sh && mv /tmp/run-wordcount.sh ~/run-wordcount.sh && mv /tmp/spark-defaults.conf $SPARK_HOME/conf/spark-defaults.conf && mv /tmp/hbase-env.sh $HBASE_HOME/conf/hbase-env.sh && mv /tmp/hbase-site.xml $HBASE_HOME/conf/hbase-site.xml 

# Move test files
# RUN mv /tmp/purchases.txt /root/purchases.txt && mv /tmp/purchases2.txt /root/purchases2.txt

RUN chmod +x ~/start-hadoop.sh && chmod +x ~/start-kafka-zookeeper.sh && chmod +x ~/run-wordcount.sh && chmod +x $HADOOP_HOME/sbin/start-dfs.sh && chmod +x $HADOOP_HOME/sbin/start-yarn.sh

RUN /usr/local/hadoop/bin/hdfs namenode -format

# Configure SSH
RUN chmod 700 ~/.ssh && chmod 600 ~/.ssh/config
RUN mkdir /var/run/sshd
EXPOSE 22

# Start SSH server
CMD ["/usr/sbin/sshd", "-D"]












































































