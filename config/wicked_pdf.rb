#config/initializers/wicked_pdf.rb
WickedPdf.config = {
  :exe_path => Rails.root.join('/usr/bin/wkhtmltopdf').to_s
}