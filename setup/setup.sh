#!/bin/bash

mkdir /home/minecraft

docker pull itzg/minecraft-server
docker run -d --name=minecraft \
  -p 25565:25565 -p 25575:25575 \
  -v /home/minecraft:/data \
  -e EULA=TRUE -e ENABLE_RCON=true -e RCON_PASSWORD=pass -e MEMORY=500M \
  itzg/minecraft-server
docker stop minecraft

cp ./minecraft.service /lib/systemd/system
chmod 744 /lib/systemd/system/minecraft.service
systemctl daemon-reload
systemctl enable minecraft
