ARG EDGE_VERSION

FROM ibmwebmethods.azurecr.io/webmethods-edge-runtime:${EDGE_VERSION}

ARG WPM_CRED
ARG GITHUB_CREDS_USR
ARG GITHUB_CREDS_PSW

WORKDIR /opt/softwareag/wpm

#ADD --chown=sagadmin:sagadmin wpm ./wpm /opt/softwareag/wpm

#RUN chmod +x /opt/softwareag/wpm/bin/wpm.sh
ENV PATH=/opt/softwareag/wpm/bin:$PATH

RUN /opt/softwareag/wpm/bin/wpm.sh install -ws https://packages.webmethods.io -wr licensed -d /opt/softwareag/IntegrationServer -j ${WPM_CRED} WmJDBCAdapter
RUN /opt/softwareag/wpm/bin/wpm.sh install -u ${GITHUB_CREDS_USR} -p ${GITHUB_CREDS_PSW} -r https://github.com/elpinjo -d /opt/softwareag/IntegrationServer OrderEntry
RUN /opt/softwareag/wpm/bin/wpm.sh install -u ${GITHUB_CREDS_USR} -p ${GITHUB_CREDS_PSW} -r https://github.com/elpinjo -d /opt/softwareag/IntegrationServer OrderAnalytics

WORKDIR /
