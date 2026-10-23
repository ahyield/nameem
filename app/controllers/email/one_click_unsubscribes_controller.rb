module Email
  # The List-Unsubscribe-Post target (RFC 8058). Mail clients POST here with no session or form token;
  # the signed token in the URL is the only credential, so this is an API controller without cookies.
  class OneClickUnsubscribesController < ActionController::API
    def create
      user, category = User.from_unsubscribe_token(params[:token].to_s)
      return head :not_found unless user

      user.unsubscribe_from!(category)
      head :ok
    end
  end
end
