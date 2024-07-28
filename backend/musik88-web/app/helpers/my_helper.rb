module MyHelper
    def current_profile_menu?(path)
        request.path.start_with?(path) ? 'selected' : ''
    end
end
