module ApplicationHelper
  def render_flash_notice(message)
    turbo_stream.replace('flash-messages', partial: 'shared/flash', locals: { flash: { notice: message } })
  end

  def render_flash_alert(message)
    turbo_stream.replace('flash-messages', partial: 'shared/flash', locals: { flash: { alert: message } })
  end
end
