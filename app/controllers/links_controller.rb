class LinksController < ApplicationController
  before_action :authenticate_user!

  def destroy
    link = Link.find(params[:id])
    authorize link
      begin
        link.destroy
        respond_to do |format|
          format.turbo_stream { render 'links/link_destroy', locals: { link: link } }
          format.html { redirect_back fallback_location: root_path, notice: 'Link was successfully removed.' }
        end
      rescue ActiveRecord::RecordNotDestroyed => e
        respond_to do |format|
          format.turbo_stream { render 'shared/flash_alert', locals: { message: 'Failed to delete the link.' }, status: :unprocessable_entity }
          format.html { redirect_back fallback_location: root_path, alert: 'Failed to delete the link.', status: :unprocessable_entity }
        end
      end
    # else
    #   respond_to do |format|
    #     format.html { redirect_back fallback_location: root_path, alert: 'You are not authorized to delete this link.', status: :forbidden }
    #     format.turbo_stream { render 'shared/flash_alert', locals: { message: 'You are not authorized to delete this link.' }, status: :forbidden }
    #   end
    # end
  end
end
