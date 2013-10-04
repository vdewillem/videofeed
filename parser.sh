#!/usr/bin/env python
from subprocess import call
import os
import subprocess
import datetime
from xml.sax.saxutils import escape
import urllib
import pocket
import config

def downloadFromPocket():
    consumer_key = config.pocket["consumer_key"]
    access_token = config.pocket["access_token"]
    pocket_instance = pocket.Pocket(consumer_key, access_token)
    list = pocket_instance.get(contentType="video")
    print list
    for itemId in list[0]["list"]:
        item = list[0]["list"][itemId]
        list[0]["list"]
        print "Item: " + itemId
        #print "-" + item["resolved_title"]
        #print "-" + item["resolved_url"]
        print "\n"
        download(item["resolved_url"]);
	print "Archiving item " + itemId
	pocket_instance.archive(itemId)
    if len(list[0]["list"]) >= 1:
	print "Committing archive list"
    	pocket_instance.commit()

def download(url):
    print "Downloading url: " + url
    call(["youtube-dl", "-f18", "-t", url])
    
def createITunesFeed():
    fileName = "pocket-videos.xml"
    file = open(fileName, 'w')
    
    file.write("""<rss xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" xmlns:media="http://search.yahoo.com/mrss/" xmlns:creativeCommons="http://blogs.law.harvard.edu/tech/creativeCommonsRssModule" version="2.0">
<channel>
<title><![CDATA[Pocket Videos - EU]]></title>
<link>http://librivox.org/the-art-of-war-by-sun-tzu/</link>
<description><![CDATA[Videos from your Pocket account. Currenlty supports youtube.]]></description>
<itunes:image href="http://librivox.org/librivox_logo.jpg" />
<language>en</language>
<itunes:summary><![CDATA[Videos from your Pocket account. Currenlty supports youtube.]]></itunes:summary>
<itunes:author>Willem Van den Eynde</itunes:author>
<itunes:block>No</itunes:block>
<itunes:explicit>No</itunes:explicit>
<media:rating scheme="urn:simple">nonadult</media:rating><creativeCommons:license>http://www.creativecommons.org/licenses/publicdomain</creativeCommons:license>
""")
    
    path = "/var/www"
    filenames = os.listdir(path)
    print "%(count)s files in path %(path)s" % {'count':len(filenames), 'path':path}
    for filename in filenames:
	if not ".mp4" in filename:
		continue
        print filename
        fullName = path + "/" + filename
        statinfo = os.stat(fullName)
        title = filename
        link = "http://ec2-54-229-82-153.eu-west-1.compute.amazonaws.com/" + urllib.quote(filename)
        #duration = getLength(fullName)
        duration = "5:00"
        size = statinfo.st_size
        pubDate = datetime.datetime.fromtimestamp(statinfo.st_ctime).strftime("%a, %d %b %Y %H:%M:%S %z")
        type = "audio/mpeg"
    
        itemXml = """<item>
    <title>{title}</title>
    <link>{link}</link>
    <enclosure url="{link}" length="{size}" type="{type}" />
    <itunes:explicit>No</itunes:explicit>
    <itunes:block>No</itunes:block>
    <itunes:duration>{duration}</itunes:duration>
    <pubDate>{pubDate}</pubDate>
    <media:content url="{link}" fileSize="{size}" type="{type}" />
</item>
""".format(title=escape(title),link=escape(link),duration=duration,pubDate=pubDate,size=size,type=type)
        file.write(itemXml)
    
    file.write(
        """</channel>
</rss>""")
    file.close()
    
def getLength(filename):
  result = subprocess.Popen(["ffprobe", filename],
    stdout = subprocess.PIPE, stderr = subprocess.STDOUT)
  return [x for x in result.stdout.readlines() if "Duration" in x]

def running(lockname = "lock"):
    if not os.path.exists(lockname):
        open('lock', 'w+')
        return False
    return True
    
def releaseLock(lockname = "lock"):
    os.remove(lockname)
    
def main():
    downloadFromPocket()
    createITunesFeed()
        
if not running():
    try:
     main()
     releaseLock()
    except e:
     print "error: %s"%e
else:
    print "already running"
