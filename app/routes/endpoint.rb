class Main
  get "#{MYSPACE_URL_BASE}/fake_post/?" do
    pub_url = Main.myspace_pub_callback 'test'
    resp = RestClient.post pub_url, myspace_sample_body
    flash[:success] = "[#{resp.to_s}] was returned"
    redirect MYSPACE_URL_BASE
  end

  def myspace_sample_body
    timestamp = Time.now.utc
    post_id, xml_timestamp, int_timestamp = [timestamp.to_i.to_s, timestamp.xmlschema, timestamp.to_i.to_s]
    '<feed fake="true" xml:lang="en-US" xml:base="http://api.myspace.com/v1/users/8675309/activities.atom" xmlns:activity="http://activitystrea.ms/spec/1.0/" xmlns:sx="http://feedsync.org/2007/feedsync" xmlns:re="http://purl.org/atompub/rank/1.0" xmlns:poco="http://portablecontacts.net/spec/1.0" xmlns:geo="http://www.georss.org/georss" xmlns="http://www.w3.org/2005/Atom"><title type="text">Recent activities from Sample User at MySpace</title><subtitle type="text">This feed contains all of the activities for a single MySpace user</subtitle><id>tag:myspace.com,2009:user/8675309/activities</id><rights type="text">Copyright (c) 2003-2009, MySpace.com</rights><updated>'+xml_timestamp+'</updated><author><name>Sample User</name><uri>http://profile.myspace.com/index.cfm?fuseaction=user.viewprofile&amp;friendid=8675309</uri></author><generator>StatusMoodFloodApi.1.1</generator><link rel="self" href="http://api.myspace.com/v1/users/8675309/activities.atom" /><entry><id>tag:myspace.com,2009:/activity/8675309/StatusMoodUpdate/'+post_id+'/'+post_id+'</id><title type="text">Sample User Crush your enemies, see them driven before you, and to hear the lamentation of the women!</title><published>'+xml_timestamp+'</published><updated>'+xml_timestamp+'</updated><author><name>Sample User</name><uri>http://profile.myspace.com/index.cfm?fuseaction=user.viewprofile&amp;friendid=8675309</uri></author><link rel="icon" type="image/gif" href="http://x.myspacecdn.com/modules/common/static/img/statusmoood.gif" /><link rel="alternate" type="text/html" href="http://friends.myspace.com/index.cfm?fuseaction=profile.friendmoods&amp;friendId=8675309" /><category term="StatusMoodUpdate" label="StatusMoodUpdate" scheme="http://activities.myspace.com/schema/1.0/" /><content type="xhtml"><div xmlns="http://www.w3.org/1999/xhtml"><div class="activityBody"><h5 class="activityHeader"><a href="http://profile.myspace.com/index.cfm?fuseaction=user.viewprofile&amp;friendid=8675309">Sample User</a> Crush your enemies, see them driven before you, and to hear the lamentation of the women!</h5><span class="activityFooter"><span class="moodLabel">Mood:</span> Stressed <img border="0" src="http://x.myspacecdn.com/images/blog/moods/iBrads/cold.gif" alt="Stressed" class="moodPicture" /></span></div></div></content><sx:sync id="tag:myspace.com,2009:/activity/8675309/StatusMoodUpdate/'+post_id+'/'+post_id+'"><sx:history sequence="1" when="'+xml_timestamp+'" /></sx:sync><re:rank scheme="http://www.myspace.com/friends#count" label="msFriendCount">250</re:rank><activity:actor><activity:object-type>http://activitystrea.ms/schema/1.0/person</activity:object-type><id>tag:myspace.com,2009:/Person/8675309</id><title>Sample User</title><link rel="alternate" type="text/html" href="http://profile.myspace.com/index.cfm?fuseaction=user.viewprofile&amp;friendid=8675309" /><link rel="avatar" type="image/jpeg" href="http://c3.ac-images.myspacecdn.com/images02/91/s_badeed.jpg" /><geo:point>33.0 -111.0</geo:point><poco:name><poco:givenName>Sample</poco:givenName><poco:familyName>User</poco:familyName></poco:name><poco:displayName>Sample User</poco:displayName><poco:preferredUsername>&amp;hearts; CareBear &amp;hearts;</poco:preferredUsername><poco:address><poco:locality>Chandler </poco:locality><poco:postalCode>85225</poco:postalCode><poco:country>US</poco:country></poco:address><published>2005-11-03T00:49:00Z</published></activity:actor><activity:object><activity:object-type>http://activitystrea.ms/schema/1.0/note</activity:object-type><id>tag:myspace.com,2009:/Note/'+post_id+'/'+post_id+'</id><title>Sample User Crush your enemies, see them driven before you, and to hear the lamentation of the women!</title><link rel="alternate" type="text/html" href="http://friends.myspace.com/index.cfm?fuseaction=profile.friendmoods&amp;friendId=8675309&amp;dateTime='+int_timestamp+' /><content type="xhtml">&lt;a href="http://profile.myspace.com/index.cfm?fuseaction=user.viewprofile&amp;amp;friendid=8675309"&gt;Sample User&lt;/a&gt; Crush your enemies, see them driven before you, and to hear the lamentation of the women!</content></activity:object><activity:verb>http://activitystrea.ms/schema/1.0/post</activity:verb><mood icon="http://x.myspacecdn.com/images/blog/moods/iBrads/cold.gif" xmlns="http://activitystrea.ms/context/">Stressed</mood><source><id>http://www.myspace.com/myspacemobile</id><title>Mobile</title><link rel="alternate" type="text/html" href="http://www.myspace.com/myspacemobile" /></source></entry></feed>}'
  end

  def self.myspace_pub_callback slug
    "http://" + settings(:domain) + MYSPACE_PUB_BASE + '/' + slug.to_s
  end
end
