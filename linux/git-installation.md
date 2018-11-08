
GIT_VERSION='2.9.5'
GIT_SOURCE="https://mirrors.edge.kernel.org/pub/software/scm/git/git-$GIT_VERSION.tar.gz"


yum install -y curl-devel expat-devel gettext-devel openssl-devel zlib-devel perl-ExtUtils-MakeMaker
(
    rm -rf /usr/local/git
    rm -rf /tmp/git*
    sed -ci 's/.*\(\/usr\/local\/git\/bin\).*//' /etc/bashrc
    cd /tmp
    wget $GIT_SOURCE
    tar xzf ${GIT_SOURCE##*/}
    cd git-2.9.5
    make prefix=/usr/local/git all
    make prefix=/usr/local/git install
    echo "export PATH=$PATH:/usr/local/git/bin" >> /etc/bashrc
)
source /etc/bashrc
