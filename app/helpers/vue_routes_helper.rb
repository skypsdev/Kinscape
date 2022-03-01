module VueRoutesHelper
  def invitation_url(id)
    "#{url}/invitations/#{id}"
  end

  def family_url(id)
    "#{url}/communities/#{id}"
  end

  def families_path(params = {})
    path_with_params '/communities', params
  end

  def stories_path(params = {})
    path_with_params '/stories', params
  end

  def story_path(story, params = {})
    path_with_params "#{stories_path}/#{story.to_param}", params
  end

  def edit_story_path(story, params = {})
    path_with_params "#{story_path(story)}/edit", params
  end

  def stories_url(params = {})
    path_with_params "#{url}#{stories_path}", params
  end

  def story_url(story, params = {})
    path_with_params "#{url}#{story_path(story)}", params
  end

  def edit_story_url(story, params = {})
    path_with_params "#{url}#{edit_story_path(story)}", params
  end

  def mylife_profile_path(params = {})
    path_with_params '/mylife/profile', params
  end

  def kinship_mylife_profile_path(kinship, params = {})
    path_with_params "/kinships/#{kinship.to_param}#{mylife_profile_path}", params
  end

  def mylife_profile_url(params = {})
    path_with_params "#{url}#{mylife_profile_path}", params
  end

  def kinship_mylife_profile_url(kinship, params = {})
    path_with_params "#{url}#{kinship_mylife_profile_path(kinship)}", params
  end

  private

  def url
    "#{protocol}://#{ActionMailer::Base.default_url_options[:host]}"
  end

  def protocol
    Rails.env.development? ? 'http' : 'https'
  end

  def path_with_params(path, params)
    return path if params.blank?

    query_params = CGI.unescape(params.to_query)
    "#{path}?#{query_params}"
  end
end
