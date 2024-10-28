class AttachmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_attachment, only: [:destroy]

  def destroy
    # Use Pundit for authorization
    authorize @attachment.record

    @attachment.purge
    respond_to do |format|
      format.html { redirect_back fallback_location: root_path, notice: 'File was successfully deleted.' }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove("file_#{@attachment.id}"),
          helpers.render_flash_notice('File was successfully deleted.')
        ]
      end
    end
  end

  private

  def find_attachment
    @attachment = ActiveStorage::Attachment.find(params[:id])
  end
end
