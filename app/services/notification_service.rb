class NotificationService
  def self.call(resource)
    Rails.logger.info "Notification sent for #{resource.class.name} with id #{resource.id}"
  end
end