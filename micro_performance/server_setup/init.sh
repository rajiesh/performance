#!/bin/bash

yum install -y which net-tools pcp

echo "Setting up an empty Go config file, with site URLs set."
tee /godata/config/cruise-config.xml >/dev/null <<EOF
<?xml version="1.0" encoding="utf-8"?>
<cruise xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="cruise-config.xsd" schemaVersion="132">
  <server agentAutoRegisterKey="perf-auto-register-key" commandRepositoryLocation="default" serverId="perf-server">
    <siteUrls>
      <siteUrl>http://localhost:8153</siteUrl>
      <secureSiteUrl>https://localhost:8154</secureSiteUrl>
    </siteUrls>
    <security>
      <authConfigs>
        <authConfig id="password_file" pluginId="cd.go.authentication.passwordfile">
          <property>
            <key>PasswordFilePath</key>
            <value>/godata/password.properties</value>
          </property>
        </authConfig>
      </authConfigs>
    </security>
    <backup emailOnSuccess="true" emailOnFailure="true" />
    <artifacts>
      <artifactsDir>artifacts</artifactsDir>
    </artifacts>
  </server>
</cruise>

EOF

# Wait for Postgres to be ready and serving.
count=0
while [ "$count" -lt "30" -a "$(nc -zv db 5432 2>/dev/null; echo $?)" -ne "0" ]; do
  echo "Waiting for DB to be up."
  sleep 2
  count=$((count + 1))
done

chown -R 1000:1000 /godata/*


bash -x /docker-entrypoint.sh
