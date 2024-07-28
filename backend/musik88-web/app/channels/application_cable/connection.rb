module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      params = request.query_parameters()
      access_token = params['accessToken']

      self.current_user = find_verified_user access_token
    end

    private

    def find_verified_user(access_token)
      if verified_user = User.find_by(id: 1)
        verified_user
      else
        reject_unauthorized_connection
      end
    end
  end
end
