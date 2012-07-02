# encoding: utf-8

require 'spec_helper'

describe AdminController, :redis => true do
  describe 'logged in as admin' do
    before { login(@user = create(:admin)) }

    describe 'GET configuration' do
      before { get :configuration }
      it { should respond_with(:success) }
      it { should render_template(:configuration) }
      it { should_not set_the_flash }
    end

    describe 'POST configuration' do
      before { post :configuration, :config => {:forum_name => 'My Forum'} }
      it { should respond_with(:success) }
      it { should render_template(:configuration) }
      it { should_not set_the_flash }
      it 'should update the forum configuration' do
        Sugar.config(:forum_name).should == 'My Forum'
      end
    end

  end

end