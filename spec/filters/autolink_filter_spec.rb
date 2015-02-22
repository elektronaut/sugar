require "spec_helper"

describe AutolinkFilter do

  it "embeds jpgs and pngs properly" do
    expect(AutolinkFilter.new("http://random.com/folder/folder/file.png").to_html).to eq("<img src=\"http://random.com/folder/folder/file.png\">")
  end

  it "embeds imgur gifs as mp4 video properly" do
    expect(AutolinkFilter.new("http://i.imgur.com/abcdefg.gif").to_html).to eq("<video loop controls autoplay><source src=\"http://i.imgur.com/abcdefg.mp4\" type=\"video/mp4\"></video>")
  end

  it "embeds imgur gifvs as mp4 video properly" do
    expect(AutolinkFilter.new("http://i.imgur.com/abcdefg.gifv").to_html).to eq("<video loop controls autoplay><source src=\"http://i.imgur.com/abcdefg.mp4\" type=\"video/mp4\"></video>")
  end

end
