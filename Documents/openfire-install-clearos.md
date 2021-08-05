# Installing Openfire from sources

## 1. Setup maven repo
```
sudo curl https://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo \
    -o /etc/yum.repos.d/epel-apache-maven.repo
sudo sed -i s/\$releasever/6/g /etc/yum.repos.d/epel-apache-maven.repo
```
As seen on https://docs.aws.amazon.com/neptune/latest/userguide/iam-auth-connect-prerq.html


## 2. Install packages
```
sudo yum install -y apache-maven java-1.8.0-openjdk-devel patch
```

## 3. Get the source
```
curl -L -O https://github.com/igniterealtime/Openfire/releases/download/v4.5.3/openfire_src_4_5_3.tar.gz
```

## 4. Uncompress it in a proper folder
```
mkdir openfire-src
tar -C openfire-src --strip-components=1 -zxf openfire_src_4_5_3.tar.gz
cd openfire-src
```

## 5. Apply LDAP patch on Openfire source
```
curl -L https://patch-diff.githubusercontent.com/raw/igniterealtime/Openfire/pull/1624.diff \
    | patch -p1
```

## 6. Build the app
```
mvn verify
```

## 7. Copy openfire binaries
```
sudo mv distribution/target/distribution-base /opt/openfire
```

## 8. Create Openfire user and home
```
sudo useradd -m -d /var/lib/openfire -u 990 -r openfire
```

## 9. Copy base files to Openfire home
```
sudo mkdir -p /var/lib/openfire/resources
sudo cp -an /opt/openfire/plugins            /var/lib/openfire
sudo cp -an /opt/openfire/conf               /var/lib/openfire
sudo cp -an /opt/openfire/resources/security /var/lib/openfire/resources
sudo chown -R openfire: /var/lib/openfire
```

## 10. Remove base files and set links
```
sudo rm -Rf /opt/openfire/plugins
sudo rm -Rf /opt/openfire/conf
sudo rm -Rf /opt/openfire/resources/security

sudo ln -sfT /var/lib/openfire/plugins             /opt/openfire/plugins
sudo ln -sfT /var/lib/openfire/conf                /opt/openfire/conf
sudo ln -sfT /var/lib/openfire/resources/security  /opt/openfire/resources/security
```

## 11. Create Openfire systemd unit
```
cat > /usr/lib/systemd/system/openfire.service <<'EOF'
[Unit]
Description=Openfire XMPP server
After=network.target rsyslog.service

[Service]
Type=simple
Environment="NAME="
EnvironmentFile=-/etc/sysconfig/openfire
ExecStart=/opt/openfire/bin/openfire.sh
SyslogIdentifier=openfire
User=openfire
Group=openfire

[Install]
WantedBy=multi-user.target
```
