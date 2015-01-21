module CommunityFeedsHelper

  def show_attachment(obj)
    if obj[0].type == "image"
      return link_to image_tag(obj[0].media.url, :height => "500", :width => "525"), obj[0].media.url, :target => "_blank"
    elsif obj[0].type == "audio"
      return raw ("<embed src='#{obj[0].url}' autostart='false' loop='false' height = '300' width ='450'>")
    else
      if obj[0].media.html.nil?
        link_to obj[0].url, obj[0].url, :target => "_blank"
      else
        if request.port == 443
          media = obj[0].media.html.sub("http", "https")
          raw "<div class='video-container'>#{media}</div>".html_safe
        else
        return raw "<div class='video-container'>#{obj[0].media.html}</div>".html_safe
        end
      end
    end
  end

  def show_attachment_search(obj)
    if obj[0].type == "image"
      return link_to image_tag(obj[0].media.url, :class => "img-responsive user-img"), obj[0].media.url, :target => "_blank"
    else
      if obj[0].media.html.nil?
      return link_to image_tag("community_feed_msg.png", :class => "img-responsive user-img"), obj[0].url, :target => "_blank"
      else
        return raw "<div style='margin-top:5px;'>#{obj[0].media.html}</div>"
      end
    end
  end  

  def show_attachment_on_summary(obj)
    if obj[0].type == "image"
      return link_to image_tag(obj[0].media.url, :class => "img img-responsive"), program_community_feeds_path(context_program), :target => "_blank"
    else
      if obj[0].media.html.nil?
      return link_to image_tag("company.jpg", :class => "img img-responsive"), program_community_feeds_path(context_program), :target => "_blank"
      else
        return raw "<div class='video-container' style='margin-bottom:15px;'><div style='margin-top:5px;'>#{obj[0].media.html}</div></div>"
      end
    end
  end

  def tags_for_filter
    (CommunityFeed.for_program(context_program).pluck(:tags)).flatten.reject(&:empty?).uniq
  end 

end
