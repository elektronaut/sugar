# frozen_string_literal: true

require "rails_helper"

describe UsersHelper do
  describe "#users_tab" do
    subject { helper.users_tab(name, path, options) }

    let(:name) { "Stuff" }
    let(:path) { "/users/stuff" }
    let(:options) { { action: "stuff" } }

    context "without options" do
      it do
        is_expected.to(
          eq('<li class="tab"><a href="/users/stuff">Stuff</a></li>')
        )
      end
    end

    context "with class" do
      let(:options) { { class: "foo" } }

      it do
        is_expected.to(
          eq('<li class="tab foo"><a href="/users/stuff">Stuff</a></li>')
        )
      end
    end

    context "when action doesn't match params" do
      it do
        is_expected.to(
          eq('<li class="tab"><a href="/users/stuff">Stuff</a></li>')
        )
      end
    end

    context "when action matches params" do
      before do
        allow(helper).to receive(:params).and_return(action: "stuff")
      end
      it do
        is_expected.to(
          eq('<li class="tab active"><a href="/users/stuff">Stuff</a></li>')
        )
      end
    end
  end
end
