GIT_ENV='../config/git_env'

if [[ -f "$GIT_ENV" ]]; then 
  source "$GIT_ENV"
else
  echo "$GIT_ENV not found"
  exit 1
fi

GIT_DIR="git-$GIT_VERSION"

for PACKAGE in "${GIT_PACKAGE_LIST[@]}"; do
  printf "Installing %s ..." "$PACKAGE" && yum install -y $PACKAGE &>/dev/null &&echo 'OK'
done

(
    rm -rf /usr/local/git
    [[ -d "/tmp/$GIT_DIR" ]] && rm -rf "/tmp/$GIT_DIR"
    sed -ci 's/.*\(\/usr\/local\/git\/bin\).*//' /etc/bashrc
    cd /tmp
    [[ -f ${GIT_SOURCE##*/} ]] && echo "Using exists ${GIT_SOURCE##*/}"|| wget $GIT_SOURCE
    tar xzf ${GIT_SOURCE##*/} && cd "$GIT_DIR"|| exit 1
    make prefix=/usr/local/git all
    make prefix=/usr/local/git install
    echo "export PATH=$PATH:/usr/local/git/bin" >> /etc/bashrc
    rm -rf "/tmp/$GIT_DIR"
    echo "Install done"
) || { echo "Install git-$GIT_VERSION fail" && exit 1; }
echo "Activate git-$GIT_VERSION: source /etc/bashrc"
