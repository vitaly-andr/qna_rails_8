module FileAttachable
  extend ActiveSupport::Concern

  included do
    has_many_attached :files
  end
end