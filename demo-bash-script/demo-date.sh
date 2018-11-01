# https://www.cyberciti.biz/faq/linux-unix-formatting-dates-for-display/
date -d"2018-11-01"
date -d"20181101"


date -d"20181101" +"%Y-%m-%d"
date -d"20181101" +"%D"

date +"%Y-%m-%d %H:%M:%S"
date +"%a-%b-%c-%d-%e-%g-%h-%j-%k-%l-%m-%n-%p-%r-%s-%u-%w-%x-%z"
date +"%s"
date +"%T"
date +"%r"

echo "file-name.$(date +"%Y-%m-%d.%H%M%S").bk"
