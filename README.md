wp-cron.sh
=======

Yet another **WordPress Multisite** wp-cron crontab bash script - with error checking and some queueing ability.

That is, if you can call `sleep(5)` a queueing. `;)`

#### What the script does

First, it makes sure another copy of itself isn't running. If it is, it exits. Otherwise, it grabs a list of blogs from MySQL and loops through them, pulling up `/wp-cron.php?doing_wp_cron`.  The script then sleeps for 5 seconds and moves onto the next entry. If any of the entries fails (does not return HTTP status code 200), it exits.

#### Why?

WordPress cron can be a pain in the neck. For larger blog installations (multisite), conventional wisdom (or lackthere of) is/was to decouple WordPress' native cron checking from WordPress, and run it when it's convenient for you.  Or rather, don't let WordPress decide when to make internal HTTP calls for its cron function.  Your access_log file might contain a number of entries like this:

    127.0.0.1 - - [27/Apr/2014:04:58:58 +0200] "POST /wp-cron.php?doing_wp_cron=1398567538.0118000507354736328125 HTTP/1.0"
    127.0.0.1 - - [27/Apr/2014:14:14:57 +0200] "POST /wp-cron.php?doing_wp_cron=1398600897.0319790840148925781250 HTTP/1.0"
    127.0.0.1 - - [27/Apr/2014:15:01:39 +0200] "POST /wp-cron.php?doing_wp_cron=1398603699.5494239330291748046875 HTTP/1.0"

#### Ok, how?

To prevent WordPress from doing this, edit your wp-config.php file and add this line somewhere up top:

    define('DISABLE_WP_CRON', true);
    
Setup this wp-cron.sh script somewhere, chmod +x it and add a crontab entry for it:

    # crontab -e
    @hourly /somewhere/wp-cron.sh

The script makes one assumption that your blog structure looks like this:

    http://blog.example.com/
    http://blog.example.com/first/
    http://blog.example.com/second/
    ...

If your blog structure looks differently from this, simply modify the script to match your URLs.

