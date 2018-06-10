# frozen_string_literal: true

require "rails_helper"

describe IconsHelper do
  describe "#icon_tags" do
    let(:icon_tags) do
      '<link rel="icon" href="/assets/icons/favicon-46a53a4e4568d1c798f14' \
        '24a466a3887d30f5d10b1d2cd8d701f04fb9e42e3d6.ico" ' \
        'type="image/x-icon" />' \
        '<link rel="icon" href="/assets/icons/favicon-dd9904d823f4a78ebb5' \
        '46afc452a03e881da1287e89cd584a19ed980a9c50224.png" ' \
        'type="image/png" />'
    end

    let(:apple_icon_tags) do
      '<link rel="apple-touch-icon-precomposed" sizes="57x57" ' \
        'href="/assets/icons/apple-touch-icon-57x57-3dd302298e9c1865bc333a1' \
        '34785f3f2f742055741b53e2159e70ecd13d7cbd1.png" />' \
        '<link rel="apple-touch-icon-precomposed" sizes="72x72" ' \
        'href="/assets/icons/apple-touch-icon-72x72-2198d4248106b2087323d50' \
        'ee8868772aaf8153054309a0c2b56812f2eaa1ded.png" />' \
        '<link rel="apple-touch-icon-precomposed" sizes="114x114" ' \
        'href="/assets/icons/apple-touch-icon-114x114-fb936f553889a534711b6' \
        '227f57f6c7add224b47282866e69c43dd2035143926.png" />' \
        '<link rel="apple-touch-icon-precomposed" sizes="144x144" ' \
        'href="/assets/icons/apple-touch-icon-144x144-c851e00c37c810273bcce' \
        '5dd2c20491b43ce06fb5640c5586334fd186873cb3a.png" />' \
        '<link rel="apple-touch-icon-precomposed" sizes="60x60" ' \
        'href="/assets/icons/apple-touch-icon-60x60-4757864c672b56bc7441505' \
        '1c69ec949801465b1c309fed2287d47879317b52b.png" />' \
        '<link rel="apple-touch-icon-precomposed" sizes="120x120" ' \
        'href="/assets/icons/apple-touch-icon-120x120-384a7bcc4146fd98ee810' \
        'b58c73e66518f9f35ce75602a673788bb7f27c9d75e.png" />' \
        '<link rel="apple-touch-icon-precomposed" sizes="76x76" ' \
        'href="/assets/icons/apple-touch-icon-76x76-b5042f13cdaacfdb7236c35' \
        '8efcdc1cc985b191f8d29753646bca8966b2ed818.png" />' \
        '<link rel="apple-touch-icon-precomposed" sizes="152x152" ' \
        'href="/assets/icons/apple-touch-icon-152x152-2222a88f20664f4591fa7' \
        '01eda2fe6ac907662fc6194c0f88299907b57b882c9.png" />'
    end

    let(:windows_icon_tags) do
      '<meta name="msapplication-square70x70logo" ' \
        'content="/assets/icons/smalltile-65cf3ff8a9745446bc84fafea99a79bc7' \
        '859e661d3e94d5d1709eed55a672eee.png" />' \
        '<meta name="msapplication-square150x150logo" ' \
        'content="/assets/icons/mediumtile-3dce53b59a43b78fd6123b9190000ca6' \
        'fe7e5d70effc943348539c89345e0563.png" />' \
        '<meta name="msapplication-wide310x150logo" ' \
        'content="/assets/icons/widetile-8dc8d5c22f8147b2217a0691786a380655' \
        '3c4bb1dea1ae2a88ba548a33a04881.png" />' \
        '<meta name="msapplication-square310x310logo" ' \
        'content="/assets/icons/largetile-114c2d6dc39bbbf2bab0e31192a4dde6b' \
        'b353f0d9c95973a2ce1368ceb64da60.png" />'
    end

    it "should render the icons" do
      expect(helper.icon_tags).to eq(
        icon_tags + apple_icon_tags + windows_icon_tags
      )
    end
  end
end
