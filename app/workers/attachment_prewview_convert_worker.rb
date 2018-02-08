class AttachmentPrewviewConvertWorker
  include Sidekiq::Worker

  def perform(attachment_id)
    attachment = Attachment.find attachment_id

    file_for_convert = File.open("/tmp/#{SecureRandom.hex}", "wb+")
    file_for_convert << attachment.read_file.body

    result = system("soffice --headless --convert-to pdf --outdir /tmp #{file_for_convert.path}")
    if $?.exitstatus == 0
      attachment.save_preview_file("/tmp/#{File.basename(file_for_convert.path)}.pdf")
      attachment.process_finish!
    else
      attachment.process_fail!
    end

  end
end
