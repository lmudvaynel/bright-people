window.setup_dialogs = ->
  $('.dialog_block .close').bind 'click', ->
    $(this).closest('.dialog_block').addClass('hidden')
    false
    
window.setup_notify = ->
  $(document).ready ->
    slideUp = window.setTimeout ( ->
      $('.notify').animate { marginTop : 0 } 'normal', -> $(this).detach()
    )
    , 5000