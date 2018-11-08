source centos-package-list

for GROUP in "${GROUP_LIST[@]}"; do
  yum groupinstall -y $GROUP 2>/dev/null || echo "$GROUP is installed"
done

for PACKAGE in ${PACKAGE_LIST[@]}; do
  yum install -y $PACKAGE 2>/dev/null || echo "$PACKAGE is installed" 
done
