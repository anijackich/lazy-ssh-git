#!/bin/bash

while true; do
  read -rp "Your account email address (your_email@example.com): " email
  if [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]] ; then break; fi
  echo "Incorrect email format"
done

while true; do
  read -rp "Hostname for your account (my-github): " hostname
  if [[ "$hostname" =~ ^[^\s]+$ ]]; then break; fi
  echo "Spaces are not allowed, choose another hostname"
done

while true; do
  read -rp "Domain of the git service (github.com): " domain
  if [[ "$domain" =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then break; fi
  echo "Incorrect domain format"
done

echo "Generating key pair..."
ssh-keygen -t rsa -b 4096 -C "$email" -f ~/.ssh/"$hostname"_key -N '' > /dev/null

echo "Copy SSH public key and add it to SSH keys settings of your account:"
cat ~/.ssh/"$hostname"_key.pub
echo "As soon as it's ready, press any key to continue... "
read -n 1 -s -r

echo "# Created by lazy-ssh-git script
Host $hostname
   HostName $domain
   IdentityFile ~/.ssh/${hostname}_key
   IdentitiesOnly yes

" >> ~/.ssh/config

if [ -z "$SSH_AGENT_PID" ] || ! ps -p "$SSH_AGENT_PID" > /dev/null; then eval "$(ssh-agent)"; fi

echo "Connecting to git@$hostname..."
ssh-keyscan "$hostname" 2>/dev/null >> ~/.ssh/known_hosts
ssh -T git@"$hostname"
