# encoding: utf-8

require "rails_helper"

describe UsersHelper do
  describe "#users_tab" do
    let(:name) { "Stuff" }
    let(:path) { "/users/stuff" }
    let(:options) { {} }
    subject { helper.users_tab(name, path, options) }

    context "without options" do
      it do
        is_expected.to eq(
          "<li class=\"tab\"><a href=\"/users/stuff\">Stuff</a></li>"
        )
      end
    end

    context "with class" do
      let(:options) { { class: "foo" } }
      it do
        is_expected.to eq(
          "<li class=\"tab foo\"><a href=\"/users/stuff\">Stuff</a></li>"
        )
      end
    end

    context "with action" do
      let(:options) { { action: "stuff" } }

      context "and action doesn't match params" do
        it do
          is_expected.to eq(
            "<li class=\"tab\"><a href=\"/users/stuff\">Stuff</a></li>"
          )
        end
      end

      context "and action matches params" do
        before do
          allow(helper).to receive(:params).and_return(action: "stuff")
        end
        it do
          is_expected.to eq(
            "<li class=\"tab active\"><a href=\"/users/stuff\">Stuff</a></li>"
          )
        end
      end
    end
  end
end
