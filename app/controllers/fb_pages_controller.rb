# -*- coding: utf-8 -*-
class FbPagesController < ApplicationController
  
  def fb_auth
    fb_auth = FbGraph::Auth.new '387281317989326', 'bc8fc778501d7b432521262561ca9ca9', redirect_uri: 'http://bright-people.ru/fb_pages'
    client = fb_auth.client
    redirect_to client.authorization_uri(
      :scope => [:manage_pages, :publish_stream, :offline_access]
    )
  end

  def fb_pages
    fb_auth = FbGraph::Auth.new '387281317989326', 'bc8fc778501d7b432521262561ca9ca9', redirect_uri: 'http://bright-people.ru/fb_pages'
    client = fb_auth.client
    client.authorization_code = params[:code]
    access_token = client.access_token! :client_auth_body
    owner = FbGraph::User.me(access_token)
    pages = owner.accounts
    page = pages.detect do |page|
      page.name == 'Фестиваль "Яркие Люди"'
    end
    FbPage.all.map &:destroy
    @p = FbPage.new
    @p.identifier = page.identifier
    @p.token = page.access_token
    @p.save
  end
end