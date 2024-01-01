sudo rm /etc/resolv.conf
sudo bash -c 'echo "nameserver 8.8.8.8" > /etc/resolv.conf'
sudo bash -c 'echo "nameserver 8.8.4.4" >> /etc/resolv.conf'
sudo bash -c 'echo "[network]" > /etc/wsl.conf'
sudo bash -c 'echo "generateResolvConf = false" >> /etc/wsl.conf'
sudo chattr +i /etc/resolv.conf

sudo apt -y update && sudo apt -y upgrade

sudo apt-add-repository --yes ppa:ansible/ansible

sudo apt -y install ansible


sudo apt -y install python3-pip
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install python3-dev libkrb5-dev krb5-user
pip3 install pywinrm[kerberos]


sudo rm /etc/krb5.conf

sudo touch /etc/krb5.conf

sudo cat <<EOF >> /etc/krb5.conf

includedir /etc/krb5.conf.d/

[logging]
    default = FILE:/var/log/krb5libs.log
    kdc = FILE:/var/log/krb5kdc.log
    admin_server = FILE:/var/log/kadmind.log

[libdefaults]
    dns_lookup_realm = false
    ticket_lifetime = 24h
    renew_lifetime = 7d
    forwardable = true
    rdns = false
    pkinit_anchors = /etc/pki/tls/certs/ca-bundle.crt
    spake_preauth_groups = edwards25519
    default_realm = CONTOSO.COM
    default_ccache_name = KEYRING:persistent:%{uid}

[realms]
CONTOSO.COM = {

      kdc = ad01.contoso.com
      kdc = ad02.contoso.com

}

DMZ.CONTOSO.COM = {

      kdc = dmzad01.dmz.contoso.com
      kdc = dmzad02.dmz.contoso.com

}
EOF

sudo apt-get install git

git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/libexec/git-core/git-credential-manager-core.exe"

git config --global credential.https://dev.azure.com.useHttpPath true

sudo apt-get update

sudo apt-get install -y wget apt-transport-https software-properties-common

wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"

sudo dpkg -i packages-microsoft-prod.deb

sudo apt-get update

sudo apt-get install -y powershell

pip3 install PyVmomi