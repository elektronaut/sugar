require "spec_helper"

describe PostObserver do

  let(:post)       { stub_model(Post) }
  let(:observer)   { PostObserver.instance }
  let(:cache_path) { Rails.root.join("public/cache/discussions/#{post.discussion_id}/posts/count.json") }

  describe "#clean_cache_for" do

    context "when cache file exists" do

      before { File.stub(:exists?).and_return(true) }

      it "deletes the file" do
        File.should_receive(:unlink)
          .with(cache_path)
          .exactly(1).times
        observer.clean_cache_for(post)
      end

    end

    context "when cache does not exist" do

      before { File.stub(:exists?).and_return(false) }

      it "does not attempt to delete the file" do
        File.should_receive(:unlink).exactly(0).times
        observer.clean_cache_for(post)
      end

    end

  end

  describe "#after_create" do
    it "cleans cache for the post" do
      observer.should_receive(:clean_cache_for).with(post).exactly(1).times
      observer.after_create(post)
    end
  end

  describe "#after_destroy" do
    it "cleans cache for the post" do
      observer.should_receive(:clean_cache_for).with(post).exactly(1).times
      observer.after_destroy(post)
    end
  end

end