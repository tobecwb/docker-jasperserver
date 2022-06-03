FROM tomcat:9.0-jdk8
ENV JASPERSERVER_VERSION 8.0.2

# Execute all in one layer so that it keeps the image as small as possible
RUN wget "https://sourceforge.net/projects/jasperserver/files/JasperServer/JasperReports%20Server%20Community%20edition%20${JASPERSERVER_VERSION}/TIB_js-jrs-cp_${JASPERSERVER_VERSION}_bin.zip/download" \
         -O /tmp/jasperserver.zip  && \
    unzip /tmp/jasperserver.zip -d /usr/src/ && \
    rm /tmp/jasperserver.zip && \
    mv /usr/src/jasperreports-server-cp-${JASPERSERVER_VERSION}-bin /usr/src/jasperreports-server && \
    rm -r /usr/src/jasperreports-server/samples

# To speed up local testing
# Download manually the jasperreport server release to working dir
# Uncomment ADD & RUN commands below and comment out above RUN command
# ADD TIB_js-jrs-cp_${JASPERSERVER_VERSION}_bin.zip /tmp/jasperserver.zip
# RUN unzip /tmp/jasperserver.zip -d /usr/src/ && \
#     rm /tmp/jasperserver.zip && \
#     mv /usr/src/jasperreports-server-cp-$JASPERSERVER_VERSION-bin /usr/src/jasperreports-server && \
#     rm -r /usr/src/jasperreports-server/samples

# wait-for-it.sh:
# ===============
# Used to wait for the database to start before connecting to it
# This script is from https://github.com/vishnubob/wait-for-it
# as recommended by https://docs.docker.com/compose/startup-order/

# entrypoint.sh and .do_deploy_jasperserver
# =========================================
# Used to bootstrap JasperServer the first time it runs and start Tomcat each
COPY ["wait-for-it.sh", "entrypoint.sh", ".do_deploy_jasperserver", "/"]

#Execute all in one layer so that it keeps the image as small as possible
RUN chmod a+x /entrypoint.sh && \
    chmod a+x /wait-for-it.sh

# This volume allows JasperServer export zip files to be automatically imported when bootstrapping
VOLUME ["/jasperserver-import"]

# Copy web.xml with cross-domain enable
COPY web.xml /usr/local/tomcat/conf/

# Use the minimum recommended settings to start-up
# as per http://community.jaspersoft.com/documentation/jasperreports-server-install-guide/v561/setting-jvm-options-application-servers
ENV JAVA_OPTS="-Xms1024m -Xmx2048m -Xss2m -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -Doracle.jdbc.defaultNChar=true"

# Wait for DB to start-up, start up JasperServer and bootstrap if required
ENTRYPOINT ["/entrypoint.sh"]
