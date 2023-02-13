FROM centos/python-36-centos7
USER root
ENV DockerHOME=/home/django
RUN mkdir -p $DockerHOME
ENV PYTHONWRITEBYCODE 1
ENV PYTHONUNBUFFERED 1
ENV PATH=/home/django/.local/bin:$PATH
COPY ./oracle-instantclient18.3-basiclite-18.3.0.0.0-3.x86_64.rpm /home/django
COPY ./oracle-instantclient18.3-basiclite-18.3.0.0.0-3.x86_64.rpm /home/django
COPY ./oracle.conf /home/django
RUN yum install -y dnf
RUN dnf install -y libaio libaio-devel
RUN rpm -i /home/django/oracle-instantclient18.3-basiclite-18.3.0.0.0-3.x86_64.rpm && \
            cp /home/django/oracle.conf /etc/ld.so.conf.d/ && \
            ldconfig && \
            ldconfig -p | grep client64
COPY ./realm/settings /home/django/realm/realm/settings
RUN mkdir -p /tmp/appd && chmod 775 /tmp/appd
WORKDIR /home/django/realm
COPY ./requirements /home/django/requirements
WORKDIR /home/django
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r ./requirements/development.txt
RUN wget -O splunkforwarder-9.0.0-6818ac46f2ec-Linux-x86_64.tgz "https://download.splunk.com/products/universalforwarder/releases/9.0.0/linux/splunkforwarder-9.0.0-6818ac46f2ec-Linux-x86_64.tgz"
RUN tar -xvzf splunkforwarder-9.0.0-6818ac46f2ec-Linux-x86_64.tgz -C /opt
RUN chmod -R a+rwX /opt/splunkforwarder
COPY . .
RUN chmod -R 777 /home/django
EXPOSE 5000
EXPOSE 5555
ENTRYPOINT ["/bin/bash", "-e", "docker-entrypoint.sh"]
