#= require jquery
#= require jquery-ui
#= require jquery_ujs
#= require jquery.cookie
#= require slides.min.jquery
#= require jquery.raty.min
#= require jquery.pikachoose
#= require jquery.jcarousel.min
#= require jquery.countdown
#= require jquery.prettyPhoto
#= require jquery.tinycarousel.min
#= require js
#= require swfobject
#= require select_script
#= require home-video/youTubeEmbed-jquery-1.0
#= require_directory .

$ ->
  window.setup_dialogs()
  window.setup_notify()
  window.setup_home_video()
  window.setup_email_dialog()
  window.setup_activities_list()
  window.setup_activities_approval()
  window.add_comment()
  window.setup_favourite_button()
  window.setup_slider()
  window.setup_raty()
  window.setup_prev_next_expert_arrows()
  window.setup_ajax_articles_loading()
  window.setup_load_activity_comments()
  window.setup_expert_tabs()
  window.setup_new_participant_form_button()
  window.setup_ajax_contest_memberships_loading()
  window.setup_new_membership_creation()
  window.setup_profile_ajax()
  window.setup_logout_link()
  window.setup_organization_map()
  window.setup_search_tabs()
  window.setup_login()
  window.setup_lightbox()
  window.setup_participants_list()
  window.setup_member_lightbox()
