require 'rails_helper'

RSpec.describe CommentsController, type: :controller do

  before(:all) do
    Rails.application.load_seed if User.count == 0
  end

  let(:user) { User.first }
  let(:post) { user.posts.first }
  let(:comment_id) {user.comments.first.id}

  context 'when user is logged in' do

    before do
      sign_in(user)
    end

    describe 'POST #create' do
        it 'creates the new comment' do
          expect{post :create, params: { comment: { content: 'This is my first comment!', post_id: post.id } }}.to change{user.comments.count}.by(1)
          expect(user.comments.last.content).to eq 'This is my first comment!'
          expect(response).to redirect_to(root_url)
        end
    end

    describe 'GET #edit' do
        it 'shows the edit comment page' do
            get :edit, params: { id: comment_id }
            expect(response).to have_http_status(:success)
        end
    end

    describe 'POST #update' do
        it 'updates the comment' do
          patch :update, params: { id: comment_id, comment: { content: 'Editing my first comment!'} }
          expect(user.comments.first.content).to eq 'Editing my first comment!'
          expect(response).to redirect_to(user.comments.first.post)
        end
    end

    describe 'DELETE #destroy' do
      it 'deletes the comment' do
        expect { delete :destroy, params: { id: comment_id } }.to change{Comment.count}.by(-1)
        expect(response).to redirect_to(root_url)
      end
    end
  end

  context 'when user is not logged in' do

    describe 'POST #create' do
      it 'does not create comment and redirects to login' do
          expect{post :create, params: { comment: { content: 'I am trying to make a comment!', post_id: post.id } }}.to change{Comment.count}.by(0)
          expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'GET #edit' do
      it 'redirects to login page' do
          get :edit, params: { id: comment_id }
          expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'POST #update' do
      it 'does not edit the comment and redirects to login' do
        patch :update, params: { id: comment_id, comment: { content: 'Editing my first comment!'} }
        expect(user.comments.first.content).to_not eq 'Editing my first comment!'
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'DELETE #destroy' do
      it 'does NOT delete the comment and redirects to login' do
        expect { delete :destroy, params: { id: comment_id } }.to change{Comment.count}.by(0)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

  end

end
