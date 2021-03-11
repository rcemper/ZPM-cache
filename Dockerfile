# ARG BASE=store/intersystems/iris-community:2020.1.0.215.0
ARG BASE=containers.intersystems.com/intersystems/iris-ml:2020.3.0.304.0
FROM ${BASE}

USER root   

WORKDIR /opt/irisapp

RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/irisapp

USER ${ISC_PACKAGE_MGRUSER}

COPY  zpm src
COPY  iris.script /tmp/iris.script

RUN iris start IRIS \
     && iris session IRIS < /tmp/iris.script 

#\
#     && iris stop IRIS quietly
