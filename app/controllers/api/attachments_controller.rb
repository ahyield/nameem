module Api
  class AttachmentsController < ApiBaseController
    def delete
      blob = ActiveStorage::Blob.find_signed(signed_id, purpose: :blob_id)
      blob.purge
    end

    private

    def signed_id
      params[:image_url]
    end
  end
end
