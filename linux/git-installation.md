yum install -y curl-devel expat-devel gettext-devel openssl-devel zlib-devel perl-ExtUtils-MakeMaker
(
    rm -rf /usr/local/git
    sed -ci 's/.*\(\/usr\/local\/git\/bin\).*//' /etc/bashrc
    cd /tmp
    wget https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.9.5.tar.gz
    tar xzf git-2.9.5.tar.gz
    cd git-2.9.5
    make prefix=/usr/local/git all
    make prefix=/usr/local/git install
    echo "export PATH=$PATH:/usr/local/git/bin" >> /etc/bashrc
)
source /etc/bashrc