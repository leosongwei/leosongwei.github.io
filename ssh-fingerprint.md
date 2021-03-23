SSH: get server fingerprint
===========================

TAG: Linux; SSH;

If the key is ed25519:
`ssh-keygen -l -E sha256 -f /etc/ssh/ssh_host_ed25519_key.pub`
