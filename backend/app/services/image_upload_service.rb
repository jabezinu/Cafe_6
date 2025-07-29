class ImageUploadService
  def self.upload(file)
    return nil if file.blank?
    
    begin
      # Upload to Cloudinary
      result = Cloudinary::Uploader.upload(file.tempfile, resource_type: 'image')
      result['secure_url']
    rescue => e
      Rails.logger.error "Cloudinary upload failed: #{e.message}"
      nil
    end
  end
end