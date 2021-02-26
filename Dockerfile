ARG BASE=store/intersystems/iris-community:2020.1.0.215.0
FROM ${BASE}

USER root   

WORKDIR /opt/irisapp

RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/irisapp

USER ${ISC_PACKAGE_MGRUSER}

COPY  src src
COPY  iris.script /tmp/iris.script

RUN iris start IRIS \
     && iris session IRIS < /tmp/iris.script 

#\
#     && iris stop IRIS quietly