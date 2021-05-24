# frozen_string_literal: true

class OauthController < ApplicationController
  rescue_from Yt::Errors::Unauthorized, with: :redirect_to_new_auth

  def new
    url = Yt::Account.new(
      scopes: ['youtube.force-ssl', 'userinfo.email'],
      redirect_uri: oauth_url
    ).authentication_url

    # @note This adds state=channel-12 to the query params and will
    # be appended to the URL when the user returns to our app
    uri = URI(url)
    params = Hash[URI.decode_www_form(uri.query || '')].merge(state: 'channel-12')
    uri.query = URI.encode_www_form(params)

    @oauth_endpoint = uri.to_s
  end

  def show
    # @note: The code is only valid for single-use and therefore
    # the access and refresh tokens should be stored against the
    # resource
    @account = Yt::Account.new(
      authorization_code: params[:code],
      redirect_uri: oauth_url
    )
  end

  private

  def redirect_to_new_auth
    redirect_to new_oauth_path
  end
end
