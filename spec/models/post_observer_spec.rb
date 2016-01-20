require "rails_helper"

describe PostObserver do
  let(:post) { double(exchange_id: 2, conversation: false) }
  let(:observer) { PostObserver.instance }
  let(:cache_path) do
    Rails.root.join(
      "public/cache/discussions/#{post.exchange_id}/posts/count.json"
    )
  end

  describe "#clean_cache_for" do
    context "when cache file exists" do
      before { allow(File).to receive(:exist?).and_return(true) }

      it "deletes the file" do
        expect(File).to receive(:unlink).
          with(cache_path).
          exactly(1).times
        observer.clean_cache_for(post)
      end
    end

    context "when cache does not exist" do
      before { allow(File).to receive(:exist?).and_return(false) }

      it "does not attempt to delete the file" do
        expect(File).to receive(:unlink).exactly(0).times
        observer.clean_cache_for(post)
      end
    end
  end

  describe "#after_create" do
    it "cleans cache for the post" do
      expect(observer).to receive(:clean_cache_for).with(post).exactly(1).times
      observer.after_create(post)
    end
  end

  describe "#after_destroy" do
    it "cleans cache for the post" do
      expect(observer).to receive(:clean_cache_for).with(post).exactly(1).times
      observer.after_destroy(post)
    end
  end
end
