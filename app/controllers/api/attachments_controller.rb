class Api::AttachmentsController < ActionController::API
  def delete
    blob = ActiveStorage::Blob.find_signed(signed_id, purpose: :blob_id)
    blob.purge
  end

  private

  def signed_id
    params[:image_url].split('/')[4]
  end
end
