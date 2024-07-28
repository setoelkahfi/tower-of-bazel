class CommentsController < ApplicationController
  before_action :find_commentable
  before_action :auth_user

  def new
    @comment = Comment.new
  end

  def create
    @comment = @commentable.comments.new comment_params

    if @comment.save
      flash[:success] = 'Your comment was successfully posted!'
    else
      flash[:danger] = "Your comment wasn't posted! Comment cannot be empty."
    end
    redirect_to("#{URI(request.referer).path}#discussion")
  end

  private

  def comment_params
    params.require(:comment).permit(:body, :user_id)
  end

  def find_commentable
    @commentable = Comment.find_by_id(params[:comment_id]) if params[:comment_id]
    @commentable = Lyric.find_by_id(params[:lyric_id]) if params[:lyric_id]
    @commentable = Chord.find_by_id(params[:chord_id]) if params[:chord_id]
    @commentable = Artist.find_by_id(params[:artist_id]) if params[:artist_id]
    @commentable = Album.find_by_id(params[:album_id]) if params[:album_id]
    @commentable = Song.find_by_id(params[:song_id]) if params[:song_id]
    @commentable = Page.find_by_id(params[:page_id]) if params[:page_id]
    @commentable = AudioFile.find_by_id(params[:audio_file_id]) if params[:audio_file_id]
    if params[:javanese_gending_notation_id]
      @commentable = JavaneseGendingNotation.find_by_id(params[:javanese_gending_notation_id])
    end
    @commentable = JavaneseGending.find_by_id(params[:javanese_gending_id]) if params[:javanese_gending_id]
    @commentable = User.find_by_id(params[:user_id]) if params[:user_id]
  end

  def auth_user
    redirect_to login_path(redirect_to: "#{URI(request.referer).path}#discussion") unless user_signed_in?
  end
end
