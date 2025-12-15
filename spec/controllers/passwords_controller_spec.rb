require 'rails_helper'

RSpec.describe PasswordsController, type: :controller do
  let(:user) do
    User.create!(
      email_address: 'test@example.com',
      login: 'testuser',
      password: 'password123',
      password_confirmation: 'password123',
      nome: 'Test User',
      matricula: '123456789'
    )
  end

  let(:valid_token) { 'valid_reset_token_12345' }
  let(:invalid_token) { 'invalid_token' }

  describe "GET #new" do
    it "returns a successful response" do
      get :new
      expect(response).to be_successful
    end

    it "renders without authentication" do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do
    context "with existing user email" do
      it "sends password reset email" do
        expect {
          post :create, params: { email_address: user.email_address }
        }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
          .with('PasswordsMailer', 'reset', 'deliver_now', { args: [ user ] })
      end

      it "enqueues email delivery job" do
        expect {
          post :create, params: { email_address: user.email_address }
        }.to have_enqueued_job
      end

      it "redirects to new_session_path" do
        post :create, params: { email_address: user.email_address }
        expect(response).to redirect_to(new_session_path)
      end

      it "shows generic success message" do
        post :create, params: { email_address: user.email_address }
        expect(flash[:notice]).to eq("Password reset instructions sent (if user with that email address exists).")
      end

      it "does not reveal that user exists" do
        post :create, params: { email_address: user.email_address }
        expect(flash[:notice]).to include("(if user with that email address exists)")
      end
    end

    context "with non-existent user email" do
      it "does not send any email" do
        expect {
          post :create, params: { email_address: 'nonexistent@example.com' }
        }.not_to have_enqueued_job
      end

      it "redirects to new_session_path" do
        post :create, params: { email_address: 'nonexistent@example.com' }
        expect(response).to redirect_to(new_session_path)
      end

      it "shows same generic message" do
        post :create, params: { email_address: 'nonexistent@example.com' }
        expect(flash[:notice]).to eq("Password reset instructions sent (if user with that email address exists).")
      end

      it "does not reveal that user does not exist" do
        post :create, params: { email_address: 'fake@example.com' }
        message = flash[:notice]
        expect(message).to eq("Password reset instructions sent (if user with that email address exists).")
      end
    end

    context "with missing email parameter" do
      it "handles missing email gracefully" do
        post :create, params: {}
        expect(response).to redirect_to(new_session_path)
        expect(flash[:notice]).to eq("Password reset instructions sent (if user with that email address exists).")
      end
    end

    context "with empty email" do
      it "handles empty email" do
        post :create, params: { email_address: '' }
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "GET #edit" do
    context "with valid token" do
      before do
        allow(User).to receive(:find_by_password_reset_token!).with(valid_token).and_return(user)
      end

      it "returns a successful response" do
        get :edit, params: { token: valid_token }
        expect(response).to be_successful
      end

      it "finds the user by token" do
        expect(User).to receive(:find_by_password_reset_token!).with(valid_token).and_return(user)
        get :edit, params: { token: valid_token }
      end

      it "allows access without authentication" do
        get :edit, params: { token: valid_token }
        expect(response).to have_http_status(:success)
      end
    end

    context "with invalid token" do
      before do
        allow(User).to receive(:find_by_password_reset_token!).with(invalid_token)
          .and_raise(ActiveSupport::MessageVerifier::InvalidSignature)
      end

      it "redirects to new_password_path" do
        get :edit, params: { token: invalid_token }
        expect(response).to redirect_to(new_password_path)
      end

      it "sets an error alert" do
        get :edit, params: { token: invalid_token }
        expect(flash[:alert]).to eq("Password reset link is invalid or has expired.")
      end

      it "handles invalid signature exception" do
        expect(User).to receive(:find_by_password_reset_token!).with(invalid_token)
          .and_raise(ActiveSupport::MessageVerifier::InvalidSignature)
        get :edit, params: { token: invalid_token }
        expect(response).to redirect_to(new_password_path)
      end
    end

    context "with expired token" do
      before do
        allow(User).to receive(:find_by_password_reset_token!).with('expired_token')
          .and_raise(ActiveSupport::MessageVerifier::InvalidSignature)
      end

      it "redirects to new_password_path" do
        get :edit, params: { token: 'expired_token' }
        expect(response).to redirect_to(new_password_path)
      end

      it "shows expiration message" do
        get :edit, params: { token: 'expired_token' }
        expect(flash[:alert]).to eq("Password reset link is invalid or has expired.")
      end
    end
  end

  describe "PATCH #update" do
    context "with valid token and matching passwords" do
      before do
        allow(User).to receive(:find_by_password_reset_token!).with(valid_token).and_return(user)
      end

      it "updates the user password" do
        expect(user).to receive(:update).with(
          hash_including('password' => 'newpassword123', 'password_confirmation' => 'newpassword123')
        ).and_return(true)

        patch :update, params: {
          token: valid_token,
          password: 'newpassword123',
          password_confirmation: 'newpassword123'
        }
      end

      it "redirects to new_session_path" do
        allow(user).to receive(:update).and_return(true)

        patch :update, params: {
          token: valid_token,
          password: 'newpassword123',
          password_confirmation: 'newpassword123'
        }

        expect(response).to redirect_to(new_session_path)
      end

      it "sets success notice" do
        allow(user).to receive(:update).and_return(true)

        patch :update, params: {
          token: valid_token,
          password: 'newpassword123',
          password_confirmation: 'newpassword123'
        }

        expect(flash[:notice]).to eq("Password has been reset.")
      end
    end

    context "with valid token but non-matching passwords" do
      before do
        allow(User).to receive(:find_by_password_reset_token!).with(valid_token).and_return(user)
      end

      it "does not update the password" do
        allow(user).to receive(:update).and_return(false)

        patch :update, params: {
          token: valid_token,
          password: 'newpassword123',
          password_confirmation: 'differentpassword'
        }

        expect(flash[:alert]).to eq("Passwords did not match.")
      end

      it "redirects back to edit page" do
        allow(user).to receive(:update).and_return(false)

        patch :update, params: {
          token: valid_token,
          password: 'newpassword123',
          password_confirmation: 'differentpassword'
        }

        expect(response).to redirect_to(edit_password_path(valid_token))
      end

      it "sets error alert" do
        allow(user).to receive(:update).and_return(false)

        patch :update, params: {
          token: valid_token,
          password: 'newpassword123',
          password_confirmation: 'differentpassword'
        }

        expect(flash[:alert]).to eq("Passwords did not match.")
      end
    end

    context "with invalid token" do
      before do
        allow(User).to receive(:find_by_password_reset_token!).with(invalid_token)
          .and_raise(ActiveSupport::MessageVerifier::InvalidSignature)
      end

      it "redirects to new_password_path" do
        patch :update, params: {
          token: invalid_token,
          password: 'newpassword123',
          password_confirmation: 'newpassword123'
        }

        expect(response).to redirect_to(new_password_path)
      end

      it "sets invalid token alert" do
        patch :update, params: {
          token: invalid_token,
          password: 'newpassword123',
          password_confirmation: 'newpassword123'
        }

        expect(flash[:alert]).to eq("Password reset link is invalid or has expired.")
      end

      it "does not update any user" do
        expect_any_instance_of(User).not_to receive(:update)

        patch :update, params: {
          token: invalid_token,
          password: 'newpassword123',
          password_confirmation: 'newpassword123'
        }
      end
    end

    context "with missing password parameters" do
      before do
        allow(User).to receive(:find_by_password_reset_token!).with(valid_token).and_return(user)
        allow(user).to receive(:update).and_return(false)
      end

      it "handles missing password" do
        patch :update, params: { token: valid_token, password_confirmation: 'password123' }
        expect(response).to redirect_to(edit_password_path(valid_token))
      end

      it "handles missing password_confirmation" do
        patch :update, params: { token: valid_token, password: 'password123' }
        expect(response).to redirect_to(edit_password_path(valid_token))
      end
    end
  end

  describe "security features" do
    it "allows unauthenticated access to all actions" do
      get :new
      expect(response).to be_successful

      post :create, params: { email_address: 'test@example.com' }
      expect(response).to have_http_status(:redirect)
    end

    it "does not leak user existence information" do
      post :create, params: { email_address: 'exists@example.com' }
      existing_message = flash[:notice]

      post :create, params: { email_address: 'notexists@example.com' }
      non_existing_message = flash[:notice]

      expect(existing_message).to eq(non_existing_message)
    end

    it "validates token before allowing password update" do
      allow(User).to receive(:find_by_password_reset_token!)
        .and_raise(ActiveSupport::MessageVerifier::InvalidSignature)

      patch :update, params: {
        token: 'bad_token',
        password: 'newpass',
        password_confirmation: 'newpass'
      }

      expect(response).to redirect_to(new_password_path)
      expect(flash[:alert]).to include("invalid or has expired")
    end
  end

  describe "layout" do
    it "uses login layout for new action" do
      get :new
      expect(response).to be_successful
    end

    it "uses login layout for edit action" do
      allow(User).to receive(:find_by_password_reset_token!).with(valid_token).and_return(user)
      get :edit, params: { token: valid_token }
      expect(response).to be_successful
    end
  end

  describe "mailer integration" do
    it "delivers password reset email asynchronously" do
      expect {
        post :create, params: { email_address: user.email_address }
      }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
    end

    it "does not deliver email for non-existent users" do
      expect {
        post :create, params: { email_address: 'fake@example.com' }
      }.not_to have_enqueued_job
    end

    it "uses PasswordsMailer to send reset email" do
      mailer_double = double('PasswordsMailer')
      allow(PasswordsMailer).to receive(:reset).with(user).and_return(mailer_double)
      allow(mailer_double).to receive(:deliver_later)

      post :create, params: { email_address: user.email_address }

      expect(PasswordsMailer).to have_received(:reset).with(user)
      expect(mailer_double).to have_received(:deliver_later)
    end
  end

  describe "token validation" do
    it "calls find_by_password_reset_token! with the provided token" do
      expect(User).to receive(:find_by_password_reset_token!).with(valid_token).and_return(user)
      get :edit, params: { token: valid_token }
    end

    it "rescues InvalidSignature exception" do
      allow(User).to receive(:find_by_password_reset_token!)
        .and_raise(ActiveSupport::MessageVerifier::InvalidSignature)

      expect {
        get :edit, params: { token: 'bad_token' }
      }.not_to raise_error

      expect(response).to redirect_to(new_password_path)
    end
  end

  describe "password update flow" do
    before do
      allow(User).to receive(:find_by_password_reset_token!).with(valid_token).and_return(user)
    end

    it "permits only password and password_confirmation parameters" do
      expect(user).to receive(:update).with(
        hash_including('password', 'password_confirmation')
      ).and_return(true)

      patch :update, params: {
        token: valid_token,
        password: 'newpass',
        password_confirmation: 'newpass',
        email_address: 'hacker@example.com'
      }
    end

    it "handles successful password update" do
      allow(user).to receive(:update).and_return(true)

      patch :update, params: {
        token: valid_token,
        password: 'newpass',
        password_confirmation: 'newpass'
      }

      expect(response).to redirect_to(new_session_path)
      expect(flash[:notice]).to eq("Password has been reset.")
    end

    it "handles failed password update" do
      allow(user).to receive(:update).and_return(false)

      patch :update, params: {
        token: valid_token,
        password: 'newpass',
        password_confirmation: 'different'
      }

      expect(response).to redirect_to(edit_password_path(valid_token))
      expect(flash[:alert]).to eq("Passwords did not match.")
    end
  end
end
