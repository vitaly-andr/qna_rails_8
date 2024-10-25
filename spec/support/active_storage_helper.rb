module ActiveStorageHelper
  def create_file_blob(filename: 'test.txt', content_type: 'text/plain', metadata: nil)
    ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new("Sample content"),
      filename: filename,
      content_type: content_type,
      metadata: metadata
    )
  end
end
