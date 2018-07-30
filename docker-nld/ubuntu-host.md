### ip

```
10.1.1.x/24
220.189.127.106
```

### packages

```
sudo apt-get install vim-gtk3 ssh curl fonts-wqy-microhei docker.io
```

### systemctl

```
sudo systemctl enable sshd docker
```

### sshd

```
sudo vim /etc/ssh/sshd_config
sudo systemctl restart sshd
```

### docker

```
sudo gpasswd -a user docker
docker load -i xxx.tar.xz
```
