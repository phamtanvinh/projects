CENTOS_PACKAGE_LIST='../config/centos-package-list'

if [[ -f "$CENTOS_PACKAGE_LIST" ]]; then
  source "$CENTOS_PACKAGE_LIST"
else
  echo "$CENTOS_PACKAGE_LIST not found" && exit 1
fi

for GROUP in "${GROUP_LIST[@]}"; do
  yum groupinstall -y $GROUP 2>/dev/null || echo "$GROUP is installed"
done

for PACKAGE in ${PACKAGE_LIST[@]}; do
  yum install -y $PACKAGE 2>/dev/null || echo "$PACKAGE is installed" 
done
