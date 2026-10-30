require "rails_helper"
require "base64"
require "tempfile"

RSpec.describe ApplicationUploader do
  subject(:uploader) { described_class.new }

  it "limits uploads to 10 MB and raster image types" do
    expect(uploader.size_range).to eq(1.byte..10.megabytes)
    expect(uploader.extension_allowlist).to contain_exactly("jpg", "jpeg", "png", "webp", "gif")
    expect(uploader.content_type_allowlist).to match("image/png")
    expect(uploader.content_type_allowlist).not_to match("image/svg+xml")
  end

  it "rejects SVG uploads" do
    user = build(:user)

    Tempfile.create(["logo", ".svg"]) do |file|
      file.write('<svg xmlns="http://www.w3.org/2000/svg"></svg>')
      file.rewind
      user.image = ActionDispatch::Http::UploadedFile.new(
        tempfile: file,
        filename: "logo.svg",
        type: "image/svg+xml"
      )

      expect(user).not_to be_valid
      expect(user.errors[:image]).to be_present
    end
  end

  it "rejects raster uploads larger than 10 MB" do
    user = build(:user)
    png = Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADUlEQVR4nGP4z8AAAAMBAQDJ/pLvAAAAAElFTkSuQmCC")

    Tempfile.create(["large", ".png"]) do |file|
      file.binmode
      file.write(png)
      file.write("\0" * 10.megabytes)
      file.rewind
      user.image = ActionDispatch::Http::UploadedFile.new(
        tempfile: file,
        filename: "large.png",
        type: "image/png"
      )

      expect(user).not_to be_valid
      expect(user.errors[:image]).to be_present
    end
  end
end
