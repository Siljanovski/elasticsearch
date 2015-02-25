#!/bin/bash
cd /tmp;

# Change the IP to the Logstash server 
IP=148.251.181.22

# getting the certificate
scp $IP:/etc/pki/tls/certs/logstash-forwarder.crt /tmp
mkdir -p /etc/pki/tls/certs
cp /tmp/logstash-forwarder.crt /etc/pki/tls/certs/

# Getting the deb file for 64bits
wget https://github.com/Siljanovski/elasticsearch/raw/master/logstash-forwarder_0.3.1_amd64.deb
dpkg -i logstash-forwarder_0.3.1_amd64.deb


# Creating logstash-forwarder Daemon
cd /etc/init.d/; 
wget https://raw.githubusercontent.com/Siljanovski/elasticsearch/master/logstash-forwarder -O logstash-forwarder;
chmod +x logstash-forwarder;
update-rc.d logstash-forwarder defaults;

# creating configuration file
touch /etc/logstash-forwarder;

echo '{
  "network": {
    "servers": [ "$IP:5000" ],
    "timeout": 15,
    "ssl ca": "/etc/pki/tls/certs/logstash-forwarder.crt"
  },
  "files": [
    {
      "paths": [
        "/srv/log/syslog",
        "/srv/log/auth.log"
       ],
      "fields": { "type": "syslog" }
    },
    {
      "paths": [
        "/srv/log/nginx/*.access.log"
      ],
        "fields": { "type": "nginx-access" }
    },
    {
      "paths": [
        "/srv/log/nginx/*.error.log"
      ],
        "fields": { "type": "nginx-error" }
    },
    {
      "paths": [
        "/srv/log/nodejs/*.log"
      ],
        "fields": { "type": "nodejs" }
    }
   ]
}
' > /etc/logstash-forwarder


service logstash-forwarder start