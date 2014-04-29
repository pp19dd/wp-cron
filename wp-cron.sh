#!/bin/bash

# ----------------------------------------------------------------------------
# configurable section
# ----------------------------------------------------------------------------

mysql_username="enter_mysql_username_here";
mysql_password="enter_mysql_password_here";
mysql_database="enter_mysql_database_here";
wordpress_blogs="wp_blogs";
wordpress_url="http://blogs.example.com";

# ----------------------------------------------------------------------------
# only allow this cronjob to run once
# ----------------------------------------------------------------------------

script_name=`basename $0`;
if [ $(pidof -x ${script_name} | wc -w) -gt 2 ];
then
    echo "wp-cron script (${script_name}) already running - exiting";
    exit;
fi

# ----------------------------------------------------------------------------
# get a list of blogs in the MU installation
# ----------------------------------------------------------------------------

where="""
select
	path
from
	${wordpress_blogs}
where
	archived='0' and
	spam='0' and
	deleted='0';
""";

blogs=`mysql \
	-u${mysql_username} \
	-p${mysql_password} \
	--silent \
	--skip-column-names \
	${mysql_database} \
	--execute "${where}"`

status_ok="200";

# ----------------------------------------------------------------------------
# pull each blog's wp-cron via curl, then wait 5 seconds
# exit if the site is unavailable or returns any http code other than 200
# ----------------------------------------------------------------------------

for blog in $blogs; do
	url="{$wordpress_url}${blog}wp-cron.php?doing_wp_cron";
	status=`curl -s -I ${url} | grep HTTP/1.1 | awk {'print $2'}`

	if [ ! "$status" == "${status_ok}" ];
	then
			echo "ERROR - unable to reach blog ${blog}";
			echo "exiting wp-cron script (${script_name})";
			exit;

	fi

	echo "done with ${blog}";
	sleep 5;
done;
