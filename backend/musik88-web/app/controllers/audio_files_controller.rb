class AudioFilesController < ApplicationController
  def index
    @page_title = 'Audio Files'
    @audio_files = AudioFile.all.order(created_at: :desc)

    @users = User.left_joins(:audio_files)
                 .group(:id)
                 .order('COUNT(audio_files.id) DESC')
                 .limit(10)

    @meta_title       = @page_title
    @meta_url         = request.url
  end

  def guitar_backing_track
    id = params[:slug].split('-')[-1]

    @audio_file = AudioFile.find_by(id: id)

    redirect_to root_path and return unless @audio_file.present?

    if request.post? && !user_signed_in?
      flash[:warning] = 'I told you'
      redirect_to login_path(redirect_to: guitar_backing_track_path) and return
    end

    if request.post? && user_signed_in?
      GuitarBackingTrackJob.perform_later(@audio_file.id)
      flash[:warning] = 'Be patient.'
      redirect_to guitar_backing_track_path and return
    end

    @page_title = @audio_file.guitar_backing_track_title
    @users = User.left_joins(:audio_files)
                 .group(:id)
                 .order('COUNT(audio_files.id) DESC')
                 .limit(10)

    @guitar_backing_track = GuitarBackingTrackFile.find_by(audio_file_id: @audio_file.id)
    @meta_title       = @page_title
    @meta_url         = request.url
  end

  def bass_backing_track
    id = params[:slug].split('-')[-1]

    @audio_file = AudioFile.find_by(id: id)

    redirect_to root_path and return unless @audio_file.present?

    if request.post? && !user_signed_in?
      flash[:warning] = 'I told you'
      redirect_to login_path(redirect_to: bass_backing_track_path) and return
    end

    if request.post? && user_signed_in?
      BassBackingTrackJob.perform_later(@audio_file.id)
      flash[:warning] = 'Be patient.'
      redirect_to bass_backing_track_path and return
    end

    @page_title = @audio_file.bass_backing_track_title
    @users = User.left_joins(:audio_files)
                 .group(:id)
                 .order('COUNT(audio_files.id) DESC')
                 .limit(10)

    @bass_backing_track = @audio_file.bass_backing_track_file
    @meta_title         = @page_title
    @meta_url           = request.url
  end

  def drum_backing_track
    id = params[:slug].split('-')[-1]

    @audio_file = AudioFile.find_by(id: id)

    redirect_to root_path and return unless @audio_file.present?

    if request.post? && !user_signed_in?
      flash[:warning] = 'I told you'
      redirect_to login_path(redirect_to: drum_backing_track_path) and return
    end

    if request.post? && user_signed_in?
      DrumBackingTrackJob.perform_later(@audio_file.id)
      flash[:warning] = 'Be patient.'
      redirect_to drum_backing_track_path and return
    end

    @page_title = @audio_file.drum_backing_track_title
    @users = User.left_joins(:audio_files)
                 .group(:id)
                 .order('COUNT(audio_files.id) DESC')
                 .limit(10)

    @drum_backing_track = @audio_file.drum_backing_track
    @meta_title         = @page_title
    @meta_url           = request.url
  end
end
