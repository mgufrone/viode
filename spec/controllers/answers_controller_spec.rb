require 'rails_helper'

RSpec.describe AnswersController, type: :controller do
  let(:user)     { create :confirmed_user }
  let(:question) { create :question, author: user }
  let(:answer)   { create :answer, question: question, author: user }

  describe "GET #new" do
    context "when not signed in" do
      it "redirects to sign in page" do
        get :new, question_id: question.id
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when signed in" do
      it "returns http success" do
        sign_in user

        get :new, question_id: question.id
        expect(response).to be_success
      end
    end
  end

  describe "POST #create" do
    context "when not signed in" do
      it "redirects to sign in page" do
        post :create, question_id: question.id
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when signed in" do
      it "creates answer and redirects to question page" do
        sign_in user

        expect {
          post :create, question_id: question.id, answer: attributes_for(:answer)
        }.to change(Answer, :count).by(1)
        expect(response).to redirect_to(question)
      end
    end
  end

  describe "POST #upvote" do
    context "when not signed in" do
      it "redirects to sign in page" do
        post :upvote, id: answer.id
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when signed in" do
      before { sign_in user }

      it "upvotes answer and redirects to answer question" do
        expect {
          post :upvote, id: answer.id
        }.to change { answer.reputation_for(:votes) }.by(1)
        expect(response).to redirect_to(answer.question)
      end

      it "returns http success for remote request" do
        xhr :post, :upvote, id: answer.id
        expect(response).to be_success
      end
    end
  end

  describe "POST #downvote" do
    context "when not signed in" do
      it "redirects to sign in page" do
        post :downvote, id: answer.id
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when signed in" do
      before { sign_in user }

      it "downvotes answer and redirects to answer question" do
        expect {
          post :downvote, id: answer.id
        }.to change { answer.reputation_for(:votes) }.by(-1)
        expect(response).to redirect_to(answer.question)
      end

      it "returns http success for remote request" do
        xhr :post, :downvote, id: answer.id
        expect(response).to be_success
      end
    end
  end
end
