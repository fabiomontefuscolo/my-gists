# Jitsi over Openfire

This document presents the configuration steps to install Jitsi meetings over the Openfire XMPP server. But it doesn't cover the Openfire installation.

## Materials

* ClearOS 7
* Apache 2.4
* Java 1.8

Despite being ClearOS 7, it is very close to CentOS and also helpful for distros other than Debian/Ubuntu

## Setting up Jitsi

1. Setup facts
```bash
export MEET_HTDOCS=/var/www/virtual/meet.example.com/html
export MEET_CONFIG=/var/www/virtual/meet.example.com/conf
```

2. Get the source
```bash
curl -O https://download.jitsi.org/jitsi-meet/src/jitsi-meet-1.0.4089.tar.bz2
```

3. Decompress on ${MEET_HTDOCS}
```bash
tar -C ${MEET_HTDOCS} --strip-components 1 -jxvf jitsi-meet-1.0.4089.tar.bz2
```

4. Create proper config folder
```bash
mkdir ${MEET_CONFIG}
```

5. Move config files to that folder
```bash
mv ${MEET_HTDOCS}/config.js ${MEET_CONFIG}/config.js
mv ${MEET_HTDOCS}/interface_config.js ${MEET_CONFIG}/interface_config.js
```

6. Link back config files
```bash
ln -sr ${MEET_CONFIG}/config.js ${MEET_HTDOCS}/config.js
ln -sr ${MEET_CONFIG}/interface_config.js ${MEET_HTDOCS}/interface_config.js
```

7. Create htaccess
```
cat > ${MEET_CONFIG}/htaccess <<EOF
RewriteEngine On
RewriteBase /
RewriteRule ^index.html$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.html [L]

Options +Includes
AddType text/html .html
AddHandler server-parsed .html
EOF

ln -sr ${MEET_CONFIG}/htaccess ${MEET_HTDOCS}/.htaccess
```

8. Edit ${MEET_CONFIG}/config.js and provide values for
  * config.hosts.domain
  * config.hosts.muc
  * config.hosts.bosh (OR config.hosts.websocket)

```javascript
var config = {
    hosts: {
        domain: 'example.com',
        muc: 'conference.example.com'
    },
    websocket: 'wss://server.example.com:7443/ws/'
    // ...
}
```

9. Save links state to restore after eventual upgrade
```bash
cd ${MEET_HTDOCS}
find -type l | xargs tar -cvf ../link-rep.tar
```

10. Restore symlinks after eventual upgrade
```bash
cd ${MEET_HTDOCS}
tar -xUf ../link-rep.tar
```


## Setting up Jicofo

Why Jicofo? From the docs you read *Conference focus is mandatory component of Jitsi Meet conferencing system next to the videobridge*.

There is no ClearOS packages for Jicofo. It is needed to build the package, so it is also needed to have JDK 1.8 and maven >3.

In this setup, Jicofo runs in the same machine where Openfire runs, so I set **XMPP_SERVER=127.0.0.1** and **org.jitsi.jicofo.ALWAYS_TRUST_MODE_ENABLED=true**.

1. Set facts
```bash
export XMPP_SERVER=127.0.0.1
export XMPP_DOMAIN=example.com
export XMPP_COMPONENT_SECRET=xuoUKyuwBeLn76yv
export XMPP_MUC_DOMAIN=conference.example.com
export JICOFO_AUTH_USER=focus
export JICOFO_AUTH_PASSWORD=vR6N69hE9fyTzNU9
export JVB_BREWERY_MUC=jvbbrewery
```

2. Get the sources
```bash
mkdir /opt/jicofo
curl -Lo jicofo-master.tar.gz https://github.com/jitsi/jicofo/archive/master.tar.gz
tar -C /opt/jicofo --strip-components 1 -zxvf jicofo-master.tar.gz
```

3. Build using maven
```bash
mkdir /opt/jicofo
mvn verify
```

4. Set the XMPP_COMPONENT_SECRET on Openfire
  1. Go to Openfire admin panel
  2. Navigate to *Server > Server Setting > External Components*
  3. Focus on field *Default Shared Secret*, in the box *Allowed to Connect*
  4. Paste there the value of **XMPP_COMPONENT_SECRET**;

5. Still on Openfire panel, in the same section above, copy value of *port*, in the *Plain-text (with STARTTLS) connections* and create a new fact, like below
```bash
export XMPP_COMPONENT_PORT=5275
```

6. Create a config file
```bash
cat > /etc/sysconfig/jicofo <<EOF
XMPP_SERVER=${XMPP_SERVER}
XMPP_DOMAIN=${XMPP_DOMAIN}
XMPP_COMPONENT_PORT=${XMPP_COMPONENT_PORT:-5275}
XMPP_COMPONENT_SECRET=${XMPP_COMPONENT_SECRET}
JICOFO_AUTH_USER=${JICOFO_AUTH_USER}
JICOFO_AUTH_PASSWORD=${JICOFO_AUTH_PASSWORD}
EOF
chown root:openfire /etc/sysconfig/jicofo
chmod 640 /etc/sysconfig/jicofo

```

4. Properties
```bash
mkdir -p /etc/jitsi-meet/jicofo
cat > /etc/jitsi-meet/jicofo/sip-communicator.properties <<EOF
org.jitsi.jicofo.auth.URL=XMPP:${XMPP_DOMAIN}
org.jitsi.jicofo.ALWAYS_TRUST_MODE_ENABLED=true
org.jitsi.jicofo.BRIDGE_MUC=${JVB_BREWERY_MUC}@${XMPP_MUC_DOMAIN}
org.jitsi.jicofo.health.ENABLE_HEALTH_CHECKS=true
EOF

chown -R openfire:root /etc/jitsi-meet/jicofo
chmod 700 /etc/jitsi-meet /etc/jitsi-meet/jicofo
```

7. Create systemd using to manage this servidce (note the single quote around EOF)
```bash
cat > /usr/lib/systemd/system/jicofo.service <<'EOF'
[Unit]
Description=Openfire XMPP server
After=syslog.target network.target openfire.service

[Service]
Type=simple
EnvironmentFile=-/etc/sysconfig/jicofo
ExecStart=/usr/bin/java                                                  \
    -Dnet.java.sip.communicator.SC_HOME_DIR_LOCATION=/etc/jitsi-meet/    \
    -Dnet.java.sip.communicator.SC_HOME_DIR_NAME=jicofo                  \
    -cp /opt/jicofo/target/jicofo-1.1-SNAPSHOT-jar-with-dependencies.jar \
        org.jitsi.jicofo.Main                                            \
            --host=${XMPP_SERVER}                                        \
            --domain=${XMPP_DOMAIN}                                      \
            --secret=${XMPP_COMPONENT_SECRET}                            \
            --user_domain=${XMPP_DOMAIN}                                 \
            --user_name=${JICOFO_AUTH_USER}                              \
            --user_password=${JICOFO_AUTH_PASSWORD}                      \
            --port=${XMPP_COMPONENT_PORT}
SyslogIdentifier=jicofo
User=openfire
Group=openfire

[Install]
WantedBy=multi-user.target
EOF

```

8. Enable and start Jicofo
```bash
systemctl enable jicofo
systemctl start jicofo
```


## Setting up jitsi-videobridge

1. Set facts
```bash
export XMPP_SERVER=127.0.0.1
export XMPP_DOMAIN=example.com
export JVB_AUTH_USER=jvb
export JVB_AUTH_PASSWORD=dDR6TqY6oGi5ezhT
export JVB_BREWERY_MUC=jvbbrewery
export XMPP_MUC_DOMAIN=conference.example.com

```

1. Getting the binary
```bash
curl -LO https://download.jitsi.org/jitsi-videobridge/linux/jitsi-videobridge-linux-x86-1132.zip
```

2. Unzip it to /opt
```bash
unzip -d /opt jitsi-videobridge-linux-x86-1132.zip
```

3. Rename the folder
```bash
mv /opt/jitsi-videobridge-linux-x86-1132 /opt/jitsi-videobridge
```

4. Properties
```bash
cat > /etc/jitsi-meet/jvb/sip-communicator.properties <<EOF
org.jitsi.videobridge.SINGLE_PORT_HARVESTER_PORT=10000
org.jitsi.videobridge.DISABLE_TCP_HARVESTER=true
org.jitsi.videobridge.TCP_HARVESTER_PORT=4443
org.ice4j.ice.harvest.STUN_MAPPING_HARVESTER_ADDRESSES=meet-jit-si-turnrelay.jitsi.net:443

org.jitsi.videobridge.xmpp.user.shard.HOSTNAME=${XMPP_SERVER}
org.jitsi.videobridge.xmpp.user.shard.DOMAIN=${XMPP_DOMAIN}
org.jitsi.videobridge.xmpp.user.shard.USERNAME=${JVB_AUTH_USER}
org.jitsi.videobridge.xmpp.user.shard.PASSWORD=${JVB_AUTH_PASSWORD}
org.jitsi.videobridge.xmpp.user.shard.MUC_JIDS=${JVB_BREWERY_MUC}@${XMPP_MUC_DOMAIN}
org.jitsi.videobridge.xmpp.user.shard.MUC_NICKNAME=${HOSTNAME}
org.jitsi.videobridge.xmpp.user.shard.DISABLE_CERTIFICATE_VERIFICATION=true

org.jitsi.videobridge.ENABLE_STATISTICS=true
org.jitsi.videobridge.STATISTICS_TRANSPORT=muc
org.jitsi.videobridge.STATISTICS_INTERVAL=5000
EOF

chown -R openfire:root /etc/jitsi-meet
chmod 700 /etc/jitsi-meet /etc/jitsi-meet/jvb
```


5. Systemd service
```bash
cat > /usr/lib/systemd/system/jvb.service <<'EOF'
[Unit]
Description=Openfire XMPP server
After=syslog.target network.target openfire.service

[Service]
Type=simple
ExecStart=/usr/bin/java -Xmx3072m                                                 \
    -Dnet.java.sip.communicator.SC_HOME_DIR_LOCATION=/etc/jitsi-meet/             \
    -Dnet.java.sip.communicator.SC_HOME_DIR_NAME=jvb                              \
    -cp /opt/jitsi-videobridge/jitsi-videobridge.jar:/opt/jitsi-videobridge/lib/* \
    org.jitsi.videobridge.Main --apis=none

SyslogIdentifier=jvb
User=openfire
Group=openfire

[Install]
WantedBy=multi-user.target
EOF

```

8. Enable and start Jicofo
```bash
systemctl enable jvb
systemctl start jvb
```
