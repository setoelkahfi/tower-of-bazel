class MyController < ApplicationController
  before_action :must_login

  def must_login
    unless user_signed_in?
      flash[:success] = t('need_to_logged_in_my_profile')
      redirect_to login_path
    end

    redirect_to current_user.splitfire_profile_link unless current_user.nil?
  end

  def index
    @user = current_user

    meta = Meta
           .select(:title, :description)
           .where(home: 'profile', locale: [I18n.locale, I18n.default_locale])
           .last

    @meta_title = meta.title if meta
    @meta_description = meta.description if meta
  end

  def edit
    @user = current_user

    meta = Meta
           .select(:title, :description)
           .where(home: 'profile', locale: [I18n.locale, I18n.default_locale])
           .last

    @meta_title = meta.title if meta
    @meta_description = meta.description if meta
  end

  def add_lyric
    if request.post?
      @lyric = Lyric.new(lyric_params)
      if @lyric.save
        redirect_to my_path
      else
        flash[:warning] = t('lyric_cannot_be_empty')
        redirect_to add_lyric_path(@lyric.song_id)
      end

      return
    end

    @song = Song.find_by id: params[:song_id]
    @lyric = Lyric.new(
      song_id: @song.id,
      user_id: current_user.id
    )

    @user = current_user

    meta = Meta
           .select(:title, :description)
           .where(home: 'profile', locale: [I18n.locale, I18n.default_locale])
           .last

    @meta_title = meta.title if meta
    @meta_description = meta.description if meta
  end

  def edit_lyric
    @lyric = Lyric.find_by(id: params[:id])

    if request.patch?
      if @lyric.update_attributes(lyric_params)
        redirect_to my_path
      else
        flash[:warning] = t('lyric_cannot_be_empty')
        redirect_to add_lyric_path(@lyric.song_id)
      end

      return
    end

    @song = @lyric.song

    @user = current_user

    meta = Meta
           .select(:title, :description)
           .where(home: 'profile', locale: [I18n.locale, I18n.default_locale])
           .last

    @meta_title = meta.title if meta
    @meta_description = meta.description if meta
  end

  def lyrics
    @lyrics = Lyric
              .select(:id, :views_count, :song_id, :user_id)
              .where(user_id: current_user.id, is_published: false)
              .all

    @user = current_user

    meta = Meta
           .select(:title, :description)
           .where(home: 'profile', locale: I18n.locale)
           .first

    @meta_title = meta.title if meta
    @meta_description = meta.description if meta
  end

  def files
    if request.post?
      splitfire_process
      return
    end

    if request.delete?
      audio_file = AudioFile.find_by(id: params[:id])
      audio_file.destroy

      flash[:success] = 'File has been successfully deleted.'

      respond_to do |format|
        format.html { redirect_to my_files_path }
        format.xml { head :ok }
      end
    end

    @audio_files = AudioFile
                   .where(user_id: current_user.id)
                   .all
                   .order(created_at: :desc)

    @audio_file = AudioFile.new

    @user = current_user

    meta = Meta
           .select(:title, :description)
           .where(home: 'profile', locale: [I18n.locale, I18n.default_locale])
           .last

    @meta_title = meta.title if meta
    @meta_description = meta.description if meta
  end

  def file_detail
    @audio_file = AudioFile.find_by(
      id: params[:id],
      user_id: current_user.id
    )

    if @audio_file.nil?
      redirect_to my_files_path
      return
    end

    @user = current_user

    meta = Meta
           .select(:title, :description)
           .where(home: 'profile', locale: [I18n.locale, I18n.default_locale])
           .last

    @meta_title = meta.title if meta
    @meta_description = meta.description if meta
  end

  def admin_files
    @audio_files = AudioFile.all.order(created_at: :desc)

    meta = Meta
           .select(:title, :description)
           .where(home: 'profile', locale: [I18n.locale, I18n.default_locale])
           .last

    @meta_title = meta.title if meta
    @meta_description = meta.description if meta
  end

  def splitfire
    @user = current_user
    @audio_files = AudioFile
                   .where(user_id: @user.id)
                   .all
                   .order(created_at: :desc)

    @splitfire_settings = UserSetting.find_by(user_id: @user.id)
    if @splitfire_settings.nil?
      @splitfire_settings = UserSetting.new(
        user_id: @user.id,
        model: :'2stems',
        frequency: :'11kHz'
      )
      @splitfire_settings.save
    end

    meta = Meta
           .select(:title, :description)
           .where(home: 'profile', locale: [I18n.locale, I18n.default_locale])
           .last

    @meta_title = meta.title if meta
    @meta_description = meta.description if meta
  end

  def splitfire_settings
    return unless request.patch?

    splitfire_setting = UserSetting.find_by(user_id: current_user.id)
    splitfire_setting.update(
      model: params[:splitfire_setting][:model],
      frequency: params[:splitfire_setting][:frequency]
    )

    flash[:success] = 'Splitfile settings have been updated.'
    respond_to do |format|
      format.html { redirect_to my_splitfire_path }
      format.xml  { head :ok }
    end
  end

  def splitfire_detail
    @audio_file = AudioFile.find_by(
      id: params[:id],
      user_id: current_user.id
    )

    if @audio_file.nil?
      redirect_to my_splitfire_path
      return
    end

    @user = current_user

    meta = Meta
           .select(:title, :description)
           .where(home: 'profile', locale: [I18n.locale, I18n.default_locale])
           .last

    @meta_title = meta.title if meta
    @meta_description = meta.description if meta
  end

  def splitfire_delete
    splitfire_result = SplitfireResult.find_by(id: params[:id])
    audio_file_id = splitfire_result.audio_file_id

    splitfire_result.destroy

    # Check if no result for the given audio_file_id...
    splitfire_results = SplitfireResult.find_by(audio_file_id: audio_file_id)
    if splitfire_results.nil?
      # ... then set the AudioFile as :no_results.
      AudioFile
        .find_by(id: audio_file_id)
        .audio_file_split_status
        .no_results!
    end

    respond_to do |format|
      format.html { redirect_to my_splitfire_detail_path(audio_file_id) }
      format.xml  { head :ok }
    end
  end

  def splitfire_cancel
    audio_file = AudioFile.find_by(id: params[:id])
    audio_file.audio_file_split_status.cancelled!

    respond_to do |format|
      format.html { redirect_to my_splitfire_path }
      format.xml  { head :ok }
    end
  end

  def splitfire_start
    audio_file_id = params[:id]

    # Change the status here because we want to see the updated status right away.
    audio_file = AudioFile.find_by(id: audio_file_id)
    if audio_file.audio_file_split_status.nil?
      AudioFileSplitStatus.new(
        audio_file_id: audio_file_id,
        status: :processing,
        processing_progress: 5
      ).save
    elsif status = AudioFileSplitStatus.find_by(audio_file_id: audio_file_id)
      status.update(
        status: :processing,
        processing_progress: 5
      )
    end

    # Send to the ActiveJob
    SplitfireJob.perform_later(audio_file_id)

    flash[:success] = 'Sit down and relax. SplitFire is doing its job!'
    redirect_to my_splitfire_path
  end

  def bass64
    @audio_files = AudioFile
                   .where(user_id: current_user.id)
                   .all
                   .order(created_at: :desc)

    @audio_file = AudioFile.new

    @user = current_user
    meta = Meta
           .select(:title, :description)
           .where(home: 'profile', locale: [I18n.locale, I18n.default_locale])
           .last

    @meta_title = meta.title if meta
    @meta_description = meta.description if meta
  end

  def bass64_start
    return unless request.post?

    audio_file_id = params[:id]

    # Change the status here because we want to see the updated status right away.
    audio_file = AudioFile.find_by(id: audio_file_id)
    if audio_file.audio_file_bass64_status.nil?
      AudioFileBass64Status.new(audio_file_id: audio_file_id, status: :processing).save
    elsif audio_file.audio_file_bass64_status.processing!
    end

    # Send to the ActiveJob
    Bass64Job.perform_later(audio_file_id)

    flash[:success] = 'Sit down and relax. Bass64 is doing its job!'
    redirect_to my_bass64_path

    nil
  end

  def bass64_cancel
    return unless request.patch?

    audio_file_id   = params[:id]
    audio_file      = AudioFile.find_by(id: audio_file_id)
    audio_file.audio_file_bass64_status.cancelled!

    respond_to do |format|
      format.html { redirect_to my_bass64_path }
      format.xml  { head :ok }
    end
  end

  def bass64_detail
    @audio_file = AudioFile.find_by(
      id: params[:id],
      user_id: current_user.id
    )

    if @audio_file.nil?
      redirect_to my_bass64_path
      return
    end

    @user = current_user

    meta = Meta
           .select(:title, :description)
           .where(home: 'profile', locale: [I18n.locale, I18n.default_locale])
           .last

    @meta_title = meta.title if meta
    @meta_description = meta.description if meta
  end

  def bass64_delete
    audio_file = BassBackingTrack.find_by(id: params[:id])
    audio_file.destroy

    # Check if no result for the given audio_file_id...
    audio_file_results = BassBackingTrack.find_by(audio_file_id: audio_file.audio_file_id)
    if audio_file_results.nil?
      # ... then set the AudioFile as :no_results.
      split_audio_file = AudioFile.find_by(id: audio_file.audio_file_id)
      split_audio_file.audio_file_bass64_status.no_results!
    end

    respond_to do |format|
      format.html { redirect_to my_bass64_path }
      format.xml  { head :ok }
    end
  end

  def karokowe
    @audio_files = current_user.audio_files.order(created_at: :desc)
    @user = current_user

    meta = Meta
           .select(:title, :description)
           .where(home: 'profile', locale: [I18n.locale, I18n.default_locale])
           .last

    @meta_title = meta.title if meta
    @meta_description = meta.description if meta
  end

  def karokowe_start
    return unless request.post?

    audio_file_id = params[:id]

    # Change the status here because we want to see the updated status right away.
    audio_file = AudioFile.find_by(id: audio_file_id)
    if audio_file.audio_file_karokowe_status.nil?
      AudioFileKarokoweStatus.new(audio_file_id: audio_file_id, status: :processing).save
    elsif audio_file.audio_file_karokowe_status.processing!
    end

    # Send to the ActiveJob
    KarokoweJob.perform_later(audio_file_id)

    flash[:success] = 'Sit down and relax. We are generating the karaoke file for you!'
    redirect_to my_karokowe_path

    nil
  end

  def karokowe_cancel
    return unless request.patch?

    audio_file_id   = params[:id]
    audio_file      = AudioFile.find_by(id: audio_file_id)
    audio_file.audio_file_karokowe_status.cancelled!

    respond_to do |format|
      format.html { redirect_to my_karokowe_path }
      format.xml  { head :ok }
    end
  end

  def karokowe_detail
    @audio_file = AudioFile.find_by(
      id: params[:id],
      user_id: current_user.id
    )

    if @audio_file.nil?
      redirect_to my_karokowe_path
      return
    end

    @user = current_user

    meta = Meta
           .select(:title, :description)
           .where(home: 'profile', locale: [I18n.locale, I18n.default_locale])
           .last

    @meta_title = meta.title if meta
    @meta_description = meta.description if meta
  end

  def karokowe_delete
    audio_file = KaraokeFile.find_by(id: params[:id])
    audio_file.destroy

    # Check if no result for the given audio_file_id...
    audio_file_results = KaraokeFile.find_by(audio_file_id: audio_file.audio_file_id)
    if audio_file_results.nil?
      # ... then set the AudioFile as :no_results.
      split_audio_file = AudioFile.find_by(id: audio_file.audio_file_id)
      split_audio_file.audio_file_karokowe_status.no_results!
    end

    respond_to do |format|
      format.html { redirect_to my_karokowe_path }
      format.xml  { head :ok }
    end
  end

  def bonzo
    @audio_files = AudioFile
                   .where(user_id: current_user.id)
                   .all
                   .order(created_at: :desc)

    @audio_file = AudioFile.new

    @user = current_user
    meta = Meta
           .select(:title, :description)
           .where(home: 'profile', locale: [I18n.locale, I18n.default_locale])
           .last

    @meta_title = meta.title if meta
    @meta_description = meta.description if meta
  end

  def bonzo_start
    return unless request.post?

    audio_file_id = params[:id]

    # Change the status here because we want to see the updated status right away.
    audio_file = AudioFile.find_by(
      id: audio_file_id,
      user_id: current_user.id
    )
    if audio_file.audio_file_bonzo_status.nil?
      AudioFileBonzoStatus.new(
        audio_file_id: audio_file_id,
        status: :processing
      ).save
    elsif audio_file.audio_file_bonzo_status.processing!
    end

    # Send to the ActiveJob
    BonzoJob.perform_later(audio_file_id)

    flash[:success] = 'Sit down and relax. We are generating the drum backing track file for you!'
    redirect_to my_bonzo_path

    nil
  end

  def bonzo_detail
    @audio_file = AudioFile.find_by(
      id: params[:id],
      user_id: current_user.id
    )

    if @audio_file.nil?
      redirect_to my_bonzo_path
      return
    end

    @user = current_user

    meta = Meta
           .select(:title, :description)
           .where(home: 'profile', locale: [I18n.locale, I18n.default_locale])
           .last

    @meta_title = meta.title if meta
    @meta_description = meta.description if meta
  end

  def bonzo_delete
    audio_file = DrumBackingTrack.find_by(
      id: params[:id]
    )
    audio_file.destroy

    # Check if no result for the given audio_file_id...
    audio_file_results = DrumBackingTrack.find_by(audio_file_id: audio_file.audio_file_id)
    if audio_file_results.nil?
      # ... then set the AudioFile as :no_results.
      audio_file = AudioFile.find_by(id: audio_file.audio_file_id)
      audio_file.audio_file_bonzo_status.no_results!
    end

    respond_to do |format|
      format.html { redirect_to my_bonzo_path }
      format.xml  { head :ok }
    end
  end

  private

  def lyric_params
    params
      .require(:lyric)
      .permit(:song_id, :lyric, :locale, :user_id)
  end

  def audio_file_params
    params
      .require(:audio_file)
      .permit(:user_id, :source_file, :youtube_video_url, :is_public)
  end

  def splitfire_process
    if request.post?

      # A series of validation...

      # ... both are empty
      if params[:audio_file][:source_file].nil? && params[:audio_file][:youtube_video_url].empty?
        flash[:danger] = "Jeez, it's 2021. Please use YouTube video link or use your own file."
        redirect_to my_files_path
        return
      end

      # ... both are not empty
      if !params[:audio_file][:source_file].nil? && !params[:audio_file][:youtube_video_url].empty?
        flash[:danger] = "OMG, don't be greedy. Please use YouTube video link OR use your own file."
        redirect_to my_files_path
        return
      end

      # ... YouTube link
      if !params[:audio_file][:youtube_video_url].empty? && !valid_youtube_link?(params[:audio_file][:youtube_video_url])
        flash[:danger] = "Jeez, you're so stubborn. Please use a valid YouTube link."
        redirect_to my_files_path
        return
      end

      # ... audio file
      if params[:audio_file][:youtube_video_url].empty? && params[:audio_file][:source_file].nil?
        flash[:danger] = "Really, what are you trying to do? Where's the file?"
        redirect_to my_files_path
        return
      end

      # ... happy path

      # ... but still paranoid
      if !params[:audio_file][:youtube_video_url].empty? && valid_youtube_link?(params[:audio_file][:youtube_video_url])

        youtube_video_url_and_id = get_clean_youtube_url_and_video_id(params[:audio_file][:youtube_video_url])

        if youtube_video_url_and_id.nil?
          flash[:danger] = 'The URL looks strange.'
          redirect_to my_files_path
        end

        length_string   = `yt-dlp --get-duration #{youtube_video_url_and_id.first}`
        length_strings  = length_string.split(':')

        if length_strings.count > 1 && length_strings.first.to_i >= 5
          flash[:danger] = 'Less than 5 minutes, please. Live is too short. This video is too long.'
          redirect_to my_files_path
          return
        end

        # TODO: Check if we've already have this video id
        unless AudioFile.find_by(youtube_video_id: youtube_video_url_and_id.last).nil?
          flash[:warning] = "We've done this. Give us new link."
          redirect_to my_files_path
          return
        end

        audio_file = AudioFile.new(audio_file_params)
        audio_file.assign_attributes(youtube_video_id: youtube_video_url_and_id.last)

        if audio_file.save

          AudioFileSplitStatus.new(
            audio_file_id: audio_file.id,
            status: :downloading,
            processing_progress: 3
          ).save

          YoutubeToAudioJob.perform_later(audio_file.id)

          flash[:success] = 'SplitFire is processing this YouTube video for you.'

          return redirect_to my_splitfire_path
        else
          flash[:success] = 'I dont know what is happening. Sorry.'

          return redirect_to my_files_path
        end
      end

      # ... audio file
      unless params[:audio_file][:source_file].nil?

        audio_file = AudioFile.new(audio_file_params)

        if audio_file.save

          AudioFileSplitStatus.new(
            audio_file_id: audio_file.id,
            status: :processing,
            processing_progress: 5
          ).save

          SplitfireDemoJob.perform_later(audio_file.id)

          flash[:success] = 'File has been successfully uploaded. SplitFire is doing its job.'
          redirect_to my_splitfire_path
          return
        else
          flash[:success] = 'I dont know what is happening. Sorry.'
          redirect_to my_files_path
          return
        end
      end

    end

    @audio_file = AudioFile.new
    @user       = User.find_by_id(69) # Splitfire
  end

  def valid_youtube_link?(youtube_video_url)
    uri = URI.parse(youtube_video_url)

    # To make things simple, we only recognize youtube.com and youtu.be
    if !uri.host.nil? && (uri.host.include?('youtube.com') || uri.host.include?('youtu.be'))
      return youtube_video_url =~ %r{^https*://[www.]*youtu[.]{1}*be[.com]{4}*/[watch?v=]*([a-zA-Z0-9_-]*)}
    end

    false
  end

  # Return set
  def get_clean_youtube_url_and_video_id(youtube_video_url)
    uri = URI.parse(youtube_video_url)

    if uri.host.include?('youtube.com')

      split_query     = uri.query.split('&')

      query_video_id  = split_query.find { |item| item.include?('v=') }

      uri.query       = query_video_id
      video_id        = query_video_id.split('v=').last
      set             = [uri.to_s, video_id]
      return set

    end

    if uri.host.include?('youtu.be')
      video_id  = uri.to_s.split('/').last
      set       = [uri.to_s, video_id]
      return set
    end

    nil
  end
end
