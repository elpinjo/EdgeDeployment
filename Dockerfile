ARG EDGE_VERSION=11.0
FROM sagcr.azurecr.io/webmethods-edge-runtime:${EDGE_VERSION}

WORKDIR /opt/softwareag/wpm

ADD --chown=sagadmin:sagadmin wpm ./wpm /opt/softwareag/wpm
RUN  chmod +x /opt/softwareag/wpm/bin/wpm.sh
ENV PATH=/opt/softwareag/wpm/bin:$PATH

RUN /opt/softwareag/wpm/bin/wpm.sh install -ws https://packages.softwareag.com -wr softwareag -d /opt/softwareag/IntegrationServer -j eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJwa2ctbWdyLWV4dC11c2VyIiwiYXVkIjoicGFja2FnZS1tYW5hZ2VyIiwiaXNzIjoiU29mdHdhcmVBRyIsIm51bURheXMiOiIxODAiLCJpZCI6InNhZ3N0c0Bzb2Z0d2FyZWFnLmNvbSIsImxhYmVsIjoiVG9tYXNUb2tlbiIsImV4cCI6MTcwOTAzNTUwMn0.myKn7wcQmR4_tl7R1XzXlshv-HsKPnM4IOWGXZxnn6BO64xSxViG2O9e3TZsgHczzL2S3sYmH8ApRfW9OewfmOIuhQ1yNPIFlC8Bts5v5SlT91Ftf-ejdPqWVRfo5ykid7upTf2_2-KTKNytsZGQxKV3wiQM8yY9KSnnBVqN8KPqnaLiyN2j5CeyIatXg9Qg3YfvbJNQ3qPUdHw-XwjlB1FkFJE0SQ9mLj2mDJu7Kl4Na4qofDcuMbsJv0a3OEM4DCDrlpCSk0JQrsVWnZrq51bKaGxIpB1WmPNXCtO2TGW-d7OGDeoOOKAyuv7kRdx_oBkcgtCT1rhGNNNw6QE49Q WmJDBCAdapter

WORKDIR /
