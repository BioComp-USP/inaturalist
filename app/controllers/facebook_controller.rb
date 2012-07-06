class FacebookController < ApplicationController
  before_filter :return_here, :only => [:options]
  before_filter :login_required

  # This is the endpoint which allows a user to manager their facebook account
  # settings.  They use this endpoint after they have already gone through the
  # signup process.
  def options
    @album_cover_photos = if current_user.facebook_identity
      facebook_albums(current_user)[0..3] || []
    else
      []
    end
  rescue Koala::Facebook::APIError => e
    if e.message =~ /OAuthException/
      redirect_to ProviderAuthorization::AUTH_URLS['facebook']
    else
      logger.error "[Error #{Time.now}] Facebook connection failed, error ##{e.type} (#{e}):  #{e.message}"
      HoptoadNotifier.notify(e, :request => request, :session => session) # testing
      flash[:error] = "Ack! Something went horribly wrong, like a giant " + 
                       "squid ate your Facebook info.  You can contact us at " +
                       "help@inaturalist.org if you still can't get this " + 
                       "working.  Error: #{e.message}"
    end
  end

  # Return an HTML fragment containing a list of the user's fb albums
  def albums
    context = params[:context] || 'user'
    friend_id = params[:friend_id]
    friend_id = nil if friend_id=='null'
    # if context is friends, but no friend id specified, we want to show the friend selector
    if (context=='friends' && friend_id.nil?) 
      @friends = facebook_friends(current_user)
      render :partial => 'facebook/friends' and return
    end
    @albums = begin
      facebook_albums(current_user, friend_id)
    rescue Koala::Facebook::APIError => e
      raise e unless e.message =~ /OAuthException/
      @reauthorization_needed = true
      []
    end
    render :partial => 'facebook/albums'
  end

#  this is mapped in config/routes.rb
#  def photo_fields
#    redirect_to :action => "albums"
#  end

  # Return an HTML fragment containing photos in the album with the given fb native album id (i.e., params[:id])
  def album
    limit = (params[:limit] || 10).to_i
    offset = ((params[:page] || 1).to_i - 1) * limit
    @photos = current_user.facebook_api.get_connections(params[:id], 'photos', 
        :limit => limit, :offset => offset).map do |fp|
      FacebookPhoto.new_from_api_response(fp)
    end
    # sync doesn't work with facebook! they strip exif metadata from photos. :(
    #@synclink_base = params[:synclink_base] unless params[:synclink_base].blank?
    respond_to do |format|
      format.html do
        render :partial => 'photos/photo_list_form', 
               :locals => {
                 :photos => @photos, 
                 :index => params[:index],
                 :synclink_base => nil, #@synclink_base,
                 :local_photos => false,
                 :organized_by_album => true
               }
      end
    end
  end
  
  protected

  # returns an array of album data hashes like [{ 'name'=>'Safari Pics', 'cover_photo_src'=>(thumbnail_url) }, ...]
  # not terribly efficient, cause it makes an api call to get album data and separate calls for each album to get the url
  def facebook_albums(user, friend_id=nil)
    return [] unless user.facebook_api
    album_data = user.facebook_api.get_connections(friend_id || 'me','albums', :limit => 0)
    album_data.reject{|a| a['count'].nil? || a['count'] < 1}.map do |a|
      {
        'aid' => a['id'],
        'name' => a['name'],
        'photo_count' => a['count'],
        'cover_photo_src' => 
          "https://graph.facebook.com/#{a['cover_photo']}/picture?type=album&access_token=#{user.facebook_token}"
      }
    end
  rescue OpenSSL::SSL::SSLError, Timeout::Error => e
    Rails.logger.error "[ERROR #{Time.now}] #{e}"
    return []
  end

  def facebook_friends(user)
    return [] unless user.facebook_api
    friends_data = user.facebook_api.get_connections('me','friends').sort_by{|f| f['name']}
    return friends_data
  rescue OpenSSL::SSL::SSLError, Timeout::Error => e
    Rails.logger.error "[ERROR #{Time.now}] #{e}"
    return []
  end
  
end
