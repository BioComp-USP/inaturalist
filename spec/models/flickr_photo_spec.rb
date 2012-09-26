require File.dirname(__FILE__) + '/../spec_helper.rb'

describe FlickrPhoto, "creation" do
  
  before(:each) do
    setup_flickr_stuff
  end
  
  it "should not save if there is no assoc'd iNat user and the pic isn't CC" do
    @non_cc_flickr_photo.user = nil
    @non_cc_flickr_photo.valid?
    @non_cc_flickr_photo.errors[:license].should be_blank
  end
  
  it "should make a valid FlickrPhoto from a flickraw response" do
    FlickrPhoto.new_from_flickraw(@cc_flickr_photo_response, :user => @user).should be_valid
  end
  
  it "should not be valid if the associated user didn't take the photo" do
    FlickrPhoto.new_from_api_response(@cc_flickr_photo_response, :user => User.make!).should_not be_valid
  end
end

describe FlickrPhoto, "to_observation" do
  before(:all) do
    load_test_taxa
    
  end
  
  before(:each) do
    setup_flickr_stuff
  end
  
  it "should create a valid observation" do
    @cc_flickr_photo.to_observation.should be_valid
  end
end

def setup_flickr_stuff
  FlickRaw.api_key = FLICKR_API_KEY
  FlickRaw.shared_secret = FLICKR_SHARED_SECRET
  @flickr = flickr
  @user = User.make!
  @fi = FlickrIdentity.make!(:user => @user, :flickr_user_id => "18024068@N00")

  json = JSON.load(FLICKR_PHOTO_JSON)
  type, json = json.to_a.first
  @cc_flickr_photo_response = FlickRaw::Response.build(json, type)
  @cc_flickr_photo = FlickrPhoto.new_from_api_response(@cc_flickr_photo_response, :user => @user)
  
  json = JSON.load(NON_CC_FLICKR_PHOTO_JSON)
  type, json = json.to_a.first
  @non_cc_flickr_photo_response = FlickRaw::Response.build(json, type)
  @non_cc_flickr_photo = FlickrPhoto.new_from_api_response(@non_cc_flickr_photo_response, :user => @user)
end

FLICKR_PHOTO_JSON = <<-JSON
{ "photo": { "id": "2444432253", "secret": "82c3e12acf", "server": "2241", "farm": 3, "dateuploaded": "1209281517", "isfavorite": 0, "license": 2, "safety_level": 0, "rotation": 0, "originalsecret": "b31ef42992", "originalformat": "jpg", 
    "owner": { "nsid": "18024068@N00", "username": "Ken-ichi", "realname": "Ken-ichi Ueda", "location": "Oakland, CA, United States", "iconserver": 22, "iconfarm": 1 }, 
    "title": { "_content": "Finally" }, 
    "description": { "_content": "Black Widows are't exactly uncommon, so why has it taken me this long to find one (or several).  I also found a bunch of males in addition to this female, and caught one.  Didn't get any good pics of it, but I may try later on if I can figure out how to get it to stay still in an open container without escaping or biting me." }, 
    "visibility": { "ispublic": 1, "isfriend": 0, "isfamily": 0 }, 
    "dates": { "posted": "1209281517", "taken": "2008-04-26 20:10:30", "takengranularity": 0, "lastupdate": "1327389307" }, 
    "permissions": { "permcomment": 3, "permaddmeta": 2 }, "views": "136", 
    "editability": { "cancomment": 1, "canaddmeta": 1 }, 
    "publiceditability": { "cancomment": 1, "canaddmeta": 0 }, 
    "usage": { "candownload": 1, "canblog": 1, "canprint": 1, "canshare": 1 }, 
    "comments": { "_content": 3 }, 
    "notes": { 
      "note": [
        
      ] }, 
    "people": { "haspeople": 0 }, 
    "tags": { 
      "tag": [
        { "id": "1007768-2444432253-128063", "author": "18024068@N00", "raw": "Arachnida", "_content": "arachnida", "machine_tag": 0 },
        { "id": "1007768-2444432253-34246", "author": "18024068@N00", "raw": "arachnids", "_content": "arachnids", "machine_tag": 0 },
        { "id": "1007768-2444432253-2129", "author": "18024068@N00", "raw": "Berkeley", "_content": "berkeley", "machine_tag": 0 },
        { "id": "1007768-2444432253-50", "author": "18024068@N00", "raw": "California", "_content": "california", "machine_tag": 0 },
        { "id": "1007768-2444432253-4074", "author": "18024068@N00", "raw": "United States", "_content": "unitedstates", "machine_tag": 0 },
        { "id": "1007768-2444432253-597692", "author": "18024068@N00", "raw": "Latrodectus", "_content": "latrodectus", "machine_tag": 0 },
        { "id": "1007768-2444432253-749775", "author": "18024068@N00", "raw": "Theridiidae", "_content": "theridiidae", "machine_tag": 0 }
      ] }, 
    "location": { "latitude": 37.87266, "longitude": -122.246247, "accuracy": 16, "context": 0, 
      "neighbourhood": { "_content": "UC Berkeley", "place_id": "9qwABRNUV7LmHJPxvg", "woeid": "55858022" }, 
      "locality": { "_content": "Berkeley", "place_id": "4TuKIUlTUbxBjlKV", "woeid": "2362930" }, 
      "county": { "_content": "Alameda", "place_id": "1IvHpmpQUL8ZId.pmA", "woeid": "12587670" }, 
      "region": { "_content": "California", "place_id": "NsbUWfBTUb4mbyVu", "woeid": "2347563" }, 
      "country": { "_content": "United States", "place_id": "nz.gsghTUb4c2WAecA", "woeid": "23424977" }, "place_id": "9qwABRNUV7LmHJPxvg", "woeid": "55858022" }, 
    "geoperms": { "ispublic": 1, "iscontact": 0, "isfriend": 0, "isfamily": 0 }, 
    "urls": { 
      "url": [
        { "type": "photopage", "_content": "http:\/\/www.flickr.com\/photos\/ken-ichi\/2444432253\/" }
      ] }, "media": "photo" }, "stat": "ok" }
JSON

NON_CC_FLICKR_PHOTO_JSON = <<-JSON
{ "photo": { "id": "2394365945", "secret": "61a6cfa033", "server": "3185", "farm": 4, "dateuploaded": "1207543164", "isfavorite": 0, "license": 2, "safety_level": 0, "rotation": 0, "originalsecret": "5b78e8fa13", "originalformat": "jpg", 
    "owner": { "nsid": "18024068@N00", "username": "Ken-ichi", "realname": "Ken-ichi Ueda", "location": "Oakland, CA, United States", "iconserver": 22, "iconfarm": 1 }, 
    "title": { "_content": "O Fortuna" }, 
    "description": { "_content": "Sometimes I think I have something and it turns out bad, and other times I think there's nothing and it turns out good.  This is somewhere between.  If that center flower had just been in focus..." }, 
    "visibility": { "ispublic": 1, "isfriend": 0, "isfamily": 0 }, 
    "dates": { "posted": "1207543164", "taken": "2008-04-05 17:55:32", "takengranularity": 0, "lastupdate": "1327389306" }, 
    "permissions": { "permcomment": 3, "permaddmeta": 2 }, "views": 47, 
    "editability": { "cancomment": 1, "canaddmeta": 1 }, 
    "publiceditability": { "cancomment": 1, "canaddmeta": 0 }, 
    "usage": { "candownload": 1, "canblog": 1, "canprint": 1, "canshare": 1 }, 
    "comments": { "_content": 1 }, 
    "notes": { 
      "note": [
        
      ] }, 
    "people": { "haspeople": 0 }, 
    "tags": { 
      "tag": [
        { "id": "1007768-2394365945-140066", "author": "18024068@N00", "raw": "Arroyo Seco", "_content": "arroyoseco", "machine_tag": 0 },
        { "id": "1007768-2394365945-755198", "author": "18024068@N00", "raw": "Los Padres National Forest", "_content": "lospadresnationalforest", "machine_tag": 0 }
      ] }, 
    "urls": { 
      "url": [
        { "type": "photopage", "_content": "http:\/\/www.flickr.com\/photos\/ken-ichi\/2394365945\/" }
      ] }, "media": "photo" }, "stat": "ok" }
JSON
