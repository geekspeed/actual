module OrganisationsHelper
  def tags_for_filter_eco
    (CommunityFeed.feed_for_ecosystem(current_organisation).for_pitch(nil).pluck(:tags)).flatten.reject(&:empty?).uniq
  end

  def display_eco_blog?
    !eco_blog_posts.blank? && @organisation.try(:eco_summary).try(:eco_summary_customization).present? && @organisation.eco_summary.eco_summary_customization.blog == true
  end

  def eco_blog_posts
    CommunityFeed.blog_feed_for_organisation(@organisation.id, ["all"])
  end

end
